import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/warehouse_snapshot.dart';
import '../../../data/warehouse_repository.dart';
import '../models/warehouse_module.dart';

class WarehouseModuleCard extends StatelessWidget {
  const WarehouseModuleCard({
    super.key,
    required this.module,
    required this.repository,
    required this.onTap,
  });

  final WarehouseModule module;
  final WarehouseRepository repository;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<WarehouseSnapshot>(
      stream: repository.watchWarehouse(module.id),
      builder: (context, snapshot) {
        final data = snapshot.data ?? WarehouseSnapshot.defaults(module.id);

        final updatedAt = data.telemetry.updatedAtMs > 0
            ? DateTime.fromMillisecondsSinceEpoch(data.telemetry.updatedAtMs)
            : null;

        final dateText = updatedAt == null
            ? '—'
            : DateFormat('HH:mm:ss dd/MM').format(updatedAt);

        final tempOver = data.telemetry.temperatureC > data.thresholds.tempMaxC;
        final humOver = data.telemetry.humidityPct > data.thresholds.humidityMaxPct;
        final highlighted = tempOver || humOver || data.state.doorOpen;
        final accent = highlighted ? const Color(0xFF2F80ED) : const Color(0xFFD7E2F0);

        return InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: Colors.white,
              border: Border.all(
                color: highlighted ? const Color(0xFFBED2EC) : const Color(0xFFD7E2F0),
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.10),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              module.title,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                color: const Color(0xFF17324D),
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              module.subtitle,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF61778F),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      _HealthBadge(
                        label: highlighted ? 'Cần chú ý' : 'Ổn định',
                        highlighted: highlighted,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _MetricChip(
                        label: 'Nhiệt độ',
                        value: '${data.telemetry.temperatureC.toStringAsFixed(1)} °C',
                        highlighted: highlighted,
                        warning: tempOver,
                      ),
                      _MetricChip(
                        label: 'Độ ẩm',
                        value: '${data.telemetry.humidityPct.toStringAsFixed(1)} %',
                        highlighted: highlighted,
                        warning: humOver,
                      ),
                      _MetricChip(
                        label: 'Số kiện',
                        value: '${data.inventory.count}',
                        highlighted: highlighted,
                        warning: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _StatePill(
                        icon: Icons.door_sliding_outlined,
                        label: data.state.doorOpen ? 'Cửa mở' : 'Cửa đóng',
                        highlighted: highlighted,
                      ),
                      _StatePill(
                        icon: Icons.air_outlined,
                        label: data.state.fanOn ? 'Quạt bật' : 'Quạt tắt',
                        highlighted: highlighted,
                      ),
                      _StatePill(
                        icon: Icons.ac_unit_outlined,
                        label: data.state.acOn ? 'Điều hòa bật' : 'Điều hòa tắt',
                        highlighted: highlighted,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Cập nhật $dateText',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: const Color(0xFF61778F),
                              ),
                        ),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: onTap,
                        style: FilledButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFFF2F6FC),
                          foregroundColor: const Color(0xFF245C9B),
                        ),
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: const Text('Toàn màn hình'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
    required this.highlighted,
    required this.warning,
  });

  final String label;
  final String value;
  final bool highlighted;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final background = warning
        ? const Color(0xFFFFE5E7)
        : highlighted
        ? const Color(0xFFF2F6FC)
            : const Color(0xFFFFFFFF);
    final foreground = warning
        ? const Color(0xFFB42318)
      : const Color(0xFF17324D);

    return Container(
      width: 170,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: warning ? const Color(0xFFF3C7CB) : const Color(0xFFE1EAF4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: foreground.withValues(alpha: 0.88),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _StatePill extends StatelessWidget {
  const _StatePill({
    required this.icon,
    required this.label,
    required this.highlighted,
  });

  final IconData icon;
  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFFF2F6FC) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE1EAF4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: const Color(0xFF2F80ED),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF3E566E),
                ),
          ),
        ],
      ),
    );
  }
}

class _HealthBadge extends StatelessWidget {
  const _HealthBadge({required this.label, required this.highlighted});

  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFFEAF2FF) : const Color(0xFFF2F6FC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFDCE6F3)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: highlighted ? const Color(0xFF245C9B) : const Color(0xFF5A728A),
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
