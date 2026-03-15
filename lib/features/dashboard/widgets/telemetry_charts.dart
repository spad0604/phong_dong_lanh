import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../data/models/telemetry_point.dart';
import '../../../data/models/warehouse_thresholds.dart';
import '../../../data/warehouse_repository.dart';

class TelemetryCharts extends StatelessWidget {
  const TelemetryCharts({
    super.key,
    required this.warehouseId,
    required this.repository,
    required this.thresholds,
  });

  final String warehouseId;
  final WarehouseRepository repository;
  final WarehouseThresholds thresholds;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TelemetryPoint>>(
      stream: repository.watchTelemetryHistory(warehouseId),
      builder: (context, snapshot) {
        final points = snapshot.data ?? const <TelemetryPoint>[];

        if (points.isEmpty) {
          return const Center(child: Text('Chưa có dữ liệu biểu đồ'));
        }

        final tempSpots = <FlSpot>[];
        final humSpots = <FlSpot>[];
        for (var i = 0; i < points.length; i++) {
          tempSpots.add(FlSpot(i.toDouble(), points[i].temperatureC));
          humSpots.add(FlSpot(i.toDouble(), points[i].humidityPct));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Biểu đồ (gần đây)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final stacked = constraints.maxWidth < 760;
                  if (stacked) {
                    return Column(
                      children: [
                        Expanded(
                          child: _LineChartCard(
                            title: 'Nhiệt độ (°C)',
                            spots: tempSpots,
                            threshold: thresholds.tempMaxC,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: _LineChartCard(
                            title: 'Độ ẩm (%)',
                            spots: humSpots,
                            threshold: thresholds.humidityMaxPct,
                          ),
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(
                        child: _LineChartCard(
                          title: 'Nhiệt độ (°C)',
                          spots: tempSpots,
                          threshold: thresholds.tempMaxC,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _LineChartCard(
                          title: 'Độ ẩm (%)',
                          spots: humSpots,
                          threshold: thresholds.humidityMaxPct,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LineChartCard extends StatelessWidget {
  const _LineChartCard({
    required this.title,
    required this.spots,
    required this.threshold,
  });

  final String title;
  final List<FlSpot> spots;
  final double threshold;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxX = spots.isEmpty ? 0.0 : spots.length - 1.0;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Expanded(
              child: LineChart(
                duration: Duration.zero,
                curve: Curves.linear,
                LineChartData(
                  minX: 0,
                  maxX: maxX,
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  lineTouchData: const LineTouchData(enabled: true),
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      HorizontalLine(
                        y: threshold,
                        color: scheme.error,
                        strokeWidth: 1,
                        dashArray: [6, 4],
                      ),
                    ],
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      dotData: const FlDotData(show: false),
                      barWidth: 2,
                      color: scheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
