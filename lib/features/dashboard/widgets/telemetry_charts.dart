import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
        final timestampsMs = <int>[];
        for (var i = 0; i < points.length; i++) {
          tempSpots.add(FlSpot(i.toDouble(), points[i].temperatureC));
          humSpots.add(FlSpot(i.toDouble(), points[i].humidityPct));
          timestampsMs.add(points[i].timestampMs);
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
                            timestampsMs: timestampsMs,
                            threshold: thresholds.tempMaxC,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: _LineChartCard(
                            title: 'Độ ẩm (%)',
                            spots: humSpots,
                            timestampsMs: timestampsMs,
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
                          timestampsMs: timestampsMs,
                          threshold: thresholds.tempMaxC,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _LineChartCard(
                          title: 'Độ ẩm (%)',
                          spots: humSpots,
                          timestampsMs: timestampsMs,
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
    required this.timestampsMs,
    required this.threshold,
  });

  final String title;
  final List<FlSpot> spots;
  final List<int> timestampsMs;
  final double threshold;

  static final DateFormat _axisTimeFmt = DateFormat('HH:mm');
  static final DateFormat _tooltipTimeFmt = DateFormat('dd/MM HH:mm:ss');

  String _formatTsForAxis(int tsMs) {
    if (tsMs <= 0) return '';
    return _axisTimeFmt.format(DateTime.fromMillisecondsSinceEpoch(tsMs));
  }

  String _formatTsForTooltip(int tsMs) {
    if (tsMs <= 0) return '';
    return _tooltipTimeFmt.format(DateTime.fromMillisecondsSinceEpoch(tsMs));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxX = spots.isEmpty ? 0.0 : spots.length - 1.0;
    final labelEvery = spots.length <= 1 ? 1 : (spots.length / 4).ceil();
    final bottomTextStyle = Theme.of(context).textTheme.labelSmall;

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
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        interval: labelEvery.toDouble(),
                        getTitlesWidget: (value, meta) {
                          final idx = value.round();
                          if (idx < 0 || idx >= timestampsMs.length) {
                            return const SizedBox.shrink();
                          }

                          final label = _formatTsForAxis(timestampsMs[idx]);
                          if (label.isEmpty) return const SizedBox.shrink();

                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(label, style: bottomTextStyle),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final idx = spot.x.round();
                          final tsMs = (idx >= 0 && idx < timestampsMs.length) ? timestampsMs[idx] : 0;
                          final time = _formatTsForTooltip(tsMs);
                          final value = spot.y.toStringAsFixed(1);

                          final text = time.isEmpty ? value : '$time\n$value';
                          return LineTooltipItem(
                            text,
                            TextStyle(color: scheme.onSurface),
                          );
                        }).toList();
                      },
                    ),
                  ),
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
