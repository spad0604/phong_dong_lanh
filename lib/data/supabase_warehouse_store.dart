import 'package:supabase/supabase.dart';

class SupabaseWarehouseStore {
  SupabaseWarehouseStore(this._client);

  final SupabaseClient _client;

  Future<void> upsertTelemetryReading({
    required String warehouseId,
    required int tsMs,
    required double temperatureC,
    required double humidityPct,
  }) async {
    await _client.from('telemetry_readings').upsert(
      {
        'warehouse_id': warehouseId,
        'ts_ms': tsMs,
        'temperature_c': temperatureC,
        'humidity_pct': humidityPct,
      },
      onConflict: 'warehouse_id,ts_ms',
    );
  }

  Future<void> insertInventoryEvent({
    required String warehouseId,
    required int tsMs,
    required String type,
    required String code,
  }) async {
    await _client.from('inventory_events').upsert(
      {
        'warehouse_id': warehouseId,
        'ts_ms': tsMs,
        'scan_type': type,
        'scan_code': code,
      },
      onConflict: 'warehouse_id,ts_ms,scan_code',
    );
  }
}
