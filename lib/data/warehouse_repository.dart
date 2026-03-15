import 'dart:async';
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:supabase/supabase.dart';

import 'models/telemetry_point.dart';
import 'models/warehouse_snapshot.dart';
import 'supabase_warehouse_store.dart';

class WarehouseRepository {
  WarehouseRepository({
    FirebaseDatabase? database,
    SupabaseClient? supabaseClient,
  }) : _db = database ?? FirebaseDatabase.instance,
       _supabaseStore = supabaseClient == null
           ? null
           : SupabaseWarehouseStore(supabaseClient);

  final FirebaseDatabase _db;
  final SupabaseWarehouseStore? _supabaseStore;

  final Map<String, int> _lastPersistedTelemetryTsByWarehouse = {};

  DatabaseReference _warehouseRef(String warehouseId) {
    return _db.ref('warehouses/$warehouseId');
  }

  String _inventoryItemKey(String code) {
    return base64Url.encode(utf8.encode(code)).replaceAll('=', '');
  }

  Stream<WarehouseSnapshot> watchWarehouse(String warehouseId) {
    final ref = _warehouseRef(warehouseId);
    return ref.onValue.map((event) {
      final raw = event.snapshot.value;
      final json = raw is Map<Object?, Object?>
          ? raw
          : const <Object?, Object?>{};
      return WarehouseSnapshot.fromJson(warehouseId, json);
    });
  }

  Stream<List<TelemetryPoint>> watchTelemetryHistory(
    String warehouseId, {
    int limit = 60,
  }) {
    final query = _warehouseRef(
      warehouseId,
    ).child('telemetryHistory').orderByChild('ts').limitToLast(limit);

    return query.onValue.map((event) {
      final raw = event.snapshot.value;
      if (raw is! Map<Object?, Object?>) return const <TelemetryPoint>[];

      final points = <TelemetryPoint>[];
      for (final entry in raw.entries) {
        final value = entry.value;
        if (value is Map<Object?, Object?>) {
          points.add(TelemetryPoint.fromJson(value));
        }
      }

      points.sort((a, b) => a.timestampMs.compareTo(b.timestampMs));
      return points;
    });
  }

  Future<void> setDoorOpen(String warehouseId, bool open) {
    return _warehouseRef(warehouseId).child('state').update({'doorOpen': open});
  }

  Future<void> setAutoMode(String warehouseId, bool autoMode) {
    return _warehouseRef(
      warehouseId,
    ).child('state').update({'autoMode': autoMode});
  }

  Future<void> setFanOn(String warehouseId, bool on) {
    return _warehouseRef(warehouseId).child('state').update({'fanOn': on});
  }

  Future<void> setAcOn(String warehouseId, bool on) {
    return _warehouseRef(warehouseId).child('state').update({'acOn': on});
  }

  Future<void> setThresholds(
    String warehouseId, {
    required double tempMaxC,
    required double humidityMaxPct,
  }) {
    return _warehouseRef(warehouseId).child('thresholds').update({
      'tempMaxC': tempMaxC,
      'humidityMaxPct': humidityMaxPct,
    });
  }

  Future<void> registerScan(
    String warehouseId, {
    required String code,
    DateTime? expiryDate,
  }) async {
    final warehouseRef = _warehouseRef(warehouseId);
    final trimmedCode = code.trim();
    final now = DateTime.now().millisecondsSinceEpoch;
    final itemKey = _inventoryItemKey(trimmedCode);

    await warehouseRef.child('inventory').runTransaction((value) {
      final inventory = value is Map
          ? Map<Object?, Object?>.from(value as Map)
          : <Object?, Object?>{};
      final rawItems = inventory['items'];
      final items = rawItems is Map
          ? Map<Object?, Object?>.from(rawItems as Map)
          : <Object?, Object?>{};
      final rawExisting = items[itemKey];
      final existing = rawExisting is Map
          ? Map<Object?, Object?>.from(rawExisting as Map)
          : <Object?, Object?>{};

      items[itemKey] = {
        ...existing,
        'rfid': trimmedCode,
        'inboundAtMs': existing['inboundAtMs'] ?? now,
        'outboundAtMs': null,
        if (expiryDate != null)
          'expiresAtMs': expiryDate.millisecondsSinceEpoch
        else if (existing['expiresAtMs'] != null)
          'expiresAtMs': existing['expiresAtMs'],
      };

      final count = items.values.where((entry) {
        if (entry is! Map) return false;
        return entry['outboundAtMs'] == null;
      }).length;

      inventory['items'] = items;
      inventory['count'] = count;
      inventory['lastScan'] = {'type': 'RFID', 'code': trimmedCode, 'ts': now};

      return Transaction.success(inventory);
    });

    // Long-term storage (best-effort). If RLS is enabled you must have policies
    // that allow inserts for this client.
    final store = _supabaseStore;
    if (store != null) {
      try {
        await store.insertInventoryEvent(
          warehouseId: warehouseId,
          tsMs: now,
          type: 'RFID',
          code: trimmedCode,
        );
      } catch (_) {
        // ignore: avoid_catches_without_on_clauses
      }
    }
  }

  Future<void> maybePersistTelemetryToSupabase(
    WarehouseSnapshot snapshot,
  ) async {
    final store = _supabaseStore;
    if (store == null) return;

    final ts = snapshot.telemetry.updatedAtMs;
    if (ts <= 0) return;

    final last = _lastPersistedTelemetryTsByWarehouse[snapshot.warehouseId];
    if (last == ts) return;
    _lastPersistedTelemetryTsByWarehouse[snapshot.warehouseId] = ts;

    try {
      await store.upsertTelemetryReading(
        warehouseId: snapshot.warehouseId,
        tsMs: ts,
        temperatureC: snapshot.telemetry.temperatureC,
        humidityPct: snapshot.telemetry.humidityPct,
      );
    } catch (_) {
      // ignore: avoid_catches_without_on_clauses
    }
  }

  /// Client-side auto control (demo/MVP).
  ///
  /// In production, this logic is usually implemented on the device/edge or via
  /// cloud functions to avoid multiple clients racing to control actuators.
  Future<void> applyAutoControlIfNeeded(WarehouseSnapshot snapshot) async {
    if (!snapshot.state.autoMode) return;

    final desiredAc =
        snapshot.telemetry.temperatureC > snapshot.thresholds.tempMaxC;
    final desiredFan =
        snapshot.telemetry.humidityPct > snapshot.thresholds.humidityMaxPct;

    final updates = <String, Object?>{};
    if (desiredAc != snapshot.state.acOn) updates['acOn'] = desiredAc;
    if (desiredFan != snapshot.state.fanOn) updates['fanOn'] = desiredFan;

    if (updates.isEmpty) return;

    await _warehouseRef(snapshot.warehouseId).child('state').update(updates);
  }
}
