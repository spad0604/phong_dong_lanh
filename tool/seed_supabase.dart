import 'dart:math';

import 'package:args/args.dart';
import 'package:supabase/supabase.dart';

void main(List<String> args) async {
  final parser = ArgParser()
    ..addOption('url', help: 'Supabase project URL (e.g. https://xxxx.supabase.co)')
    ..addOption('key', help: 'Supabase anon key (or service role key for seeding)')
    ..addOption(
      'warehouses',
      defaultsTo: 'kho_1,kho_2,kho_3,kho_4',
      help: 'Comma-separated warehouse IDs.',
    )
    ..addOption('points', defaultsTo: '60', help: 'Telemetry points per warehouse.');

  final options = parser.parse(args);
  final url = (options['url'] as String?)?.trim() ?? '';
  final key = (options['key'] as String?)?.trim() ?? '';
  if (url.isEmpty || key.isEmpty) {
    throw Exception('Missing --url or --key');
  }

  final warehouseIds = (options['warehouses'] as String)
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
  final points = int.tryParse(options['points'] as String) ?? 60;

  final client = SupabaseClient(url, key);

  final now = DateTime.now().millisecondsSinceEpoch;
  final rng = Random();

  for (final id in warehouseIds) {
    final baseTemp = 4 + rng.nextDouble() * 6;
    final baseHum = 55 + rng.nextDouble() * 25;
    final startTs = now - (points - 1) * 60 * 1000;

    final rows = <Map<String, Object?>>[];
    for (var i = 0; i < points; i++) {
      final ts = startTs + i * 60 * 1000;
      final t = baseTemp + sin(i / 6) * 0.6 + (rng.nextDouble() - 0.5) * 0.2;
      final h = baseHum + cos(i / 7) * 1.5 + (rng.nextDouble() - 0.5) * 0.6;

      rows.add({
        'warehouse_id': id,
        'ts_ms': ts,
        'temperature_c': double.parse(t.toStringAsFixed(2)),
        'humidity_pct': double.parse(h.toStringAsFixed(2)),
      });
    }

    await client.from('telemetry_readings').upsert(
          rows,
          onConflict: 'warehouse_id,ts_ms',
        );

    await client.from('inventory_events').insert({
      'warehouse_id': id,
      'ts_ms': now,
      'scan_type': 'QR',
      'scan_code': 'DEMO-${rng.nextInt(9999).toString().padLeft(4, '0')}',
    });

    // ignore: avoid_print
    print('Seeded Supabase for $id ($points points)');
  }
}
