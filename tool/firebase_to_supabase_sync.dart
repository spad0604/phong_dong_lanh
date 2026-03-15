import 'dart:async';
import 'dart:convert';

import 'package:args/args.dart';
import 'package:http/http.dart' as http;
import 'package:supabase/supabase.dart';

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addOption(
      'firebase-url',
      defaultsTo: 'https://phong-dong-lanh-default-rtdb.firebaseio.com',
      help: 'Firebase RTDB base URL (no trailing slash).',
    )
    ..addOption(
      'supabase-url',
      help: 'Supabase project URL, for example https://xxxx.supabase.co',
    )
    ..addOption(
      'supabase-key',
      help: 'Supabase anon key or service role key for sync worker.',
    )
    ..addOption(
      'warehouses',
      defaultsTo: 'kho_1,kho_2,kho_3,kho_4',
      help: 'Comma-separated warehouse IDs to sync.',
    )
    ..addOption(
      'interval-seconds',
      defaultsTo: '5',
      help: 'Polling interval in seconds when not using --once.',
    )
    ..addFlag(
      'once',
      negatable: false,
      help: 'Run a single sync pass and exit.',
    );

  final options = parser.parse(args);
  final firebaseUrl = (options['firebase-url'] as String)
      .trim()
      .replaceAll(RegExp(r'/$'), '');
  final supabaseUrl = ((options['supabase-url'] as String?) ?? '').trim();
  final supabaseKey = ((options['supabase-key'] as String?) ?? '').trim();
  final warehouseIds = (options['warehouses'] as String)
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
  final intervalSeconds =
      int.tryParse(options['interval-seconds'] as String) ?? 5;
  final runOnce = options['once'] as bool;

  if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
    throw ArgumentError(
      'Missing --supabase-url or --supabase-key. '
      'Flutter Web should use URL + key, not a raw Postgres URI.',
    );
  }

  final service = _FirebaseToSupabaseSync(
    firebaseUrl: firebaseUrl,
    warehouseIds: warehouseIds,
    httpClient: http.Client(),
    supabaseClient: SupabaseClient(supabaseUrl, supabaseKey),
  );

  try {
    if (runOnce) {
      await service.syncOnce();
      return;
    }

    while (true) {
      await service.syncOnce();
      await Future<void>.delayed(Duration(seconds: intervalSeconds));
    }
  } finally {
    service.dispose();
  }
}

class _FirebaseToSupabaseSync {
  _FirebaseToSupabaseSync({
    required this.firebaseUrl,
    required this.warehouseIds,
    required this.httpClient,
    required this.supabaseClient,
  });

  final String firebaseUrl;
  final List<String> warehouseIds;
  final http.Client httpClient;
  final SupabaseClient supabaseClient;

  final Map<String, int> _lastTelemetryTsByWarehouse = <String, int>{};
  final Map<String, int> _lastInventoryTsByWarehouse = <String, int>{};

  Future<void> syncOnce() async {
    for (final warehouseId in warehouseIds) {
      final data = await _fetchWarehouse(warehouseId);
      if (data == null) continue;

      await _syncTelemetry(warehouseId, data);
      await _syncInventory(warehouseId, data);
    }
  }

  Future<Map<String, dynamic>?> _fetchWarehouse(String warehouseId) async {
    final uri = Uri.parse('$firebaseUrl/warehouses/$warehouseId.json');
    final response = await httpClient.get(uri);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to fetch $warehouseId from Firebase: '
          '${response.statusCode} ${response.body}');
    }

    final raw = jsonDecode(response.body);
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return raw.map((key, value) => MapEntry('$key', value));
    return null;
  }

  Future<void> _syncTelemetry(String warehouseId, Map<String, dynamic> data) async {
    final sensors = _asMap(data['sensors']);
    if (sensors == null) return;

    final ts = _toInt(sensors['updatedAtMs']);
    if (ts == null || ts <= 0) return;

    final lastTs = _lastTelemetryTsByWarehouse[warehouseId];
    if (lastTs == ts) return;

    final temperatureC = _toDouble(sensors['temperatureC']);
    final humidityPct = _toDouble(sensors['humidityPct']);
    if (temperatureC == null || humidityPct == null) return;

    await supabaseClient.from('telemetry_readings').upsert(
      {
        'warehouse_id': warehouseId,
        'ts_ms': ts,
        'temperature_c': temperatureC,
        'humidity_pct': humidityPct,
      },
      onConflict: 'warehouse_id,ts_ms',
    );

    _lastTelemetryTsByWarehouse[warehouseId] = ts;
  }

  Future<void> _syncInventory(String warehouseId, Map<String, dynamic> data) async {
    final inventory = _asMap(data['inventory']);
    if (inventory == null) return;

    final lastScan = _asMap(inventory['lastScan']);
    if (lastScan == null) return;

    final ts = _toInt(lastScan['ts']);
    final code = lastScan['code']?.toString();
    final type = lastScan['type']?.toString();
    if (ts == null || ts <= 0 || code == null || code.isEmpty || type == null || type.isEmpty) {
      return;
    }

    final lastTs = _lastInventoryTsByWarehouse[warehouseId];
    if (lastTs == ts) return;

    await supabaseClient.from('inventory_events').upsert(
      {
        'warehouse_id': warehouseId,
        'ts_ms': ts,
        'scan_type': type,
        'scan_code': code,
      },
      onConflict: 'warehouse_id,ts_ms,scan_code',
    );

    _lastInventoryTsByWarehouse[warehouseId] = ts;
  }

  Map<String, dynamic>? _asMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry('$key', val));
    }
    return null;
  }

  int? _toInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  double? _toDouble(Object? value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  void dispose() {
    httpClient.close();
  }
}
