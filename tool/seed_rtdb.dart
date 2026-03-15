import 'dart:convert';
import 'dart:math';

import 'package:args/args.dart';
import 'package:http/http.dart' as http;

void main(List<String> args) async {
  final parser = ArgParser()
    ..addOption(
      'base-url',
      defaultsTo: 'https://phong-dong-lanh-default-rtdb.firebaseio.com',
      help: 'Firebase RTDB base URL (no trailing slash).',
    )
    ..addOption(
      'warehouses',
      defaultsTo: 'kho_1,kho_2,kho_3,kho_4',
      help: 'Comma-separated warehouse IDs.',
    )
    ..addOption(
      'points',
      defaultsTo: '60',
      help: 'Number of telemetry points to seed per warehouse.',
    );

  final options = parser.parse(args);
  final baseUrl = (options['base-url'] as String).trim().replaceAll(
    RegExp(r'/$'),
    '',
  );
  final warehouseIds = (options['warehouses'] as String)
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
  final points = int.tryParse(options['points'] as String) ?? 60;

  final now = DateTime.now().millisecondsSinceEpoch;
  final rng = Random();
  const dayMs = 24 * 60 * 60 * 1000;

  Future<void> putJson(String path, Object body) async {
    final url = Uri.parse('$baseUrl/$path.json');
    final resp = await http.put(url, body: jsonEncode(body));
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('PUT $url failed: ${resp.statusCode} ${resp.body}');
    }
  }

  for (final id in warehouseIds) {
    final baseTemp = 4 + rng.nextDouble() * 6; // 4..10
    final baseHum = 55 + rng.nextDouble() * 25; // 55..80

    final telemetryHistory = <String, Object>{};
    final startTs = now - (points - 1) * 60 * 1000;

    for (var i = 0; i < points; i++) {
      final ts = startTs + i * 60 * 1000;
      final t = baseTemp + sin(i / 6) * 0.6 + (rng.nextDouble() - 0.5) * 0.2;
      final h = baseHum + cos(i / 7) * 1.5 + (rng.nextDouble() - 0.5) * 0.6;

      telemetryHistory['p_$ts'] = {
        'ts': ts,
        't': double.parse(t.toStringAsFixed(2)),
        'h': double.parse(h.toStringAsFixed(2)),
      };
    }

    final last = telemetryHistory['p_$now'] ?? telemetryHistory.values.last;
    final lastMap = last as Map;
    final inStockCount = 6 + rng.nextInt(8);
    final archivedCount = 1 + rng.nextInt(3);
    final inventoryItems = <String, Object>{};

    for (var i = 0; i < inStockCount + archivedCount; i++) {
      final inboundAt =
          now -
          ((i + 1) * 10 * 60 * 60 * 1000) -
          rng.nextInt(4) * 60 * 60 * 1000;
      final expiresAt = inboundAt + (18 + rng.nextInt(45)) * dayMs;
      final hasOutbound = i >= inStockCount;
      final outboundAt = hasOutbound
          ? inboundAt + (2 + rng.nextInt(5)) * dayMs
          : null;
      final rfid =
          'RFID-${id.toUpperCase()}-${(i + 1).toString().padLeft(3, '0')}';

      inventoryItems['item_${i + 1}'] = {
        'rfid': rfid,
        'label': 'Kiện hàng ${(i + 1).toString().padLeft(2, '0')}',
        'inboundAtMs': inboundAt,
        'expiresAtMs': expiresAt,
        if (outboundAt != null) 'outboundAtMs': outboundAt,
      };
    }

    final latestRfid =
        (inventoryItems['item_1'] as Map<String, Object>)['rfid'] as String;

    await putJson('warehouses/$id/thresholds', {
      'tempMaxC': 10,
      'humidityMaxPct': 75,
    });

    await putJson('warehouses/$id/state', {
      'doorOpen': false,
      'fanOn': false,
      'acOn': false,
      'autoMode': true,
    });

    await putJson('warehouses/$id/inventory', {
      'count': inStockCount,
      'items': inventoryItems,
      'lastScan': {'type': 'RFID', 'code': latestRfid, 'ts': now},
    });

    await putJson('warehouses/$id/sensors', {
      'temperatureC': lastMap['t'],
      'humidityPct': lastMap['h'],
      'updatedAtMs': now,
    });

    await putJson('warehouses/$id/telemetryHistory', telemetryHistory);

    // ignore: avoid_print
    print('Seeded RTDB for $id ($points points)');
  }
}
