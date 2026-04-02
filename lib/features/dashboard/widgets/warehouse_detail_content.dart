import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/warehouse_inventory_item.dart';
import '../../../data/models/warehouse_snapshot.dart';
import '../../../data/warehouse_repository.dart';
import 'scan_panel.dart';
import 'telemetry_charts.dart';
import 'threshold_editor.dart';

class WarehouseDetailContent extends StatelessWidget {
  const WarehouseDetailContent({
    super.key,
    required this.warehouseId,
    required this.title,
    required this.repository,
  });

  final String warehouseId;
  final String title;
  final WarehouseRepository repository;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<WarehouseSnapshot>(
      stream: repository.watchWarehouse(warehouseId),
      builder: (context, snapshot) {
        final data = snapshot.data ?? WarehouseSnapshot.defaults(warehouseId);

        final updatedAt = data.telemetry.updatedAtMs > 0
            ? DateTime.fromMillisecondsSinceEpoch(data.telemetry.updatedAtMs)
            : null;
        final dateText = updatedAt == null
            ? 'Chưa có dữ liệu'
            : DateFormat('HH:mm:ss dd/MM').format(updatedAt);

        final tempOver = data.telemetry.temperatureC > data.thresholds.tempMaxC;
        final humOver =
            data.telemetry.humidityPct > data.thresholds.humidityMaxPct;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeroPanel(
                title: title,
                updatedAtText: dateText,
                snapshot: data,
                temperatureWarning: tempOver,
                humidityWarning: humOver,
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 1050;
                  if (wide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: _ControlPanel(
                            warehouseId: warehouseId,
                            repository: repository,
                            snapshot: data,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          flex: 4,
                          child: _ActivityPanel(
                            warehouseId: warehouseId,
                            repository: repository,
                            snapshot: data,
                          ),
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      _ControlPanel(
                        warehouseId: warehouseId,
                        repository: repository,
                        snapshot: data,
                      ),
                      const SizedBox(height: 18),
                      _ActivityPanel(
                        warehouseId: warehouseId,
                        repository: repository,
                        snapshot: data,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.title,
    required this.updatedAtText,
    required this.snapshot,
    required this.temperatureWarning,
    required this.humidityWarning,
  });

  final String title;
  final String updatedAtText;
  final WarehouseSnapshot snapshot;
  final bool temperatureWarning;
  final bool humidityWarning;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD7E2F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D173B67),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Cập nhật gần nhất: $updatedAtText',
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
              _StatusBadge(
                label: snapshot.state.autoMode ? 'Tự động' : 'Thủ công',
                active: snapshot.state.autoMode,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              _HeroMetric(
                label: 'Nhiệt độ',
                value:
                    '${snapshot.telemetry.temperatureC.toStringAsFixed(1)} °C',
                warning: temperatureWarning,
              ),
              _HeroMetric(
                label: 'Độ ẩm',
                value: '${snapshot.telemetry.humidityPct.toStringAsFixed(1)} %',
                warning: humidityWarning,
              ),
              _HeroMetric(
                label: 'Số kiện',
                value: '${snapshot.inventory.count}',
              ),
              _HeroMetric(
                label: 'Cửa kho',
                value: snapshot.state.doorOpen ? 'Đang mở' : 'Đã đóng',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ControlPanel extends StatelessWidget {
  const _ControlPanel({
    required this.warehouseId,
    required this.repository,
    required this.snapshot,
  });

  final String warehouseId;
  final WarehouseRepository repository;
  final WarehouseSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Điều khiển và ngưỡng',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _QuickStateChip(
                label: 'Cửa',
                value: snapshot.state.doorOpen ? 'MỞ' : 'ĐÓNG',
              ),
              _QuickStateChip(
                label: 'Còi',
                value: snapshot.state.fanOn ? 'BẬT' : 'TẮT',
              ),
              _QuickStateChip(
                label: 'Điều hòa',
                value: snapshot.state.acOn ? 'BẬT' : 'TẮT',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: snapshot.state.doorOpen
                      ? null
                      : () => repository.setDoorOpen(warehouseId, true),
                  child: const Text('Mở cửa kho'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.tonal(
                  onPressed: snapshot.state.doorOpen
                      ? () => repository.setDoorOpen(warehouseId, false)
                      : null,
                  child: const Text('Đóng cửa kho'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Tự động điều khiển theo ngưỡng'),
            subtitle: const Text(
              'Tự bật còi (độ ẩm) và điều hòa (nhiệt độ) khi vượt ngưỡng',
            ),
            value: snapshot.state.autoMode,
            onChanged: (value) => repository.setAutoMode(warehouseId, value),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 760;
              if (stacked) {
                return Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Còi thủ công'),
                      value: snapshot.state.fanOn,
                      onChanged: snapshot.state.autoMode
                          ? null
                          : (value) => repository.setFanOn(warehouseId, value),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Điều hòa thủ công'),
                      value: snapshot.state.acOn,
                      onChanged: snapshot.state.autoMode
                          ? null
                          : (value) => repository.setAcOn(warehouseId, value),
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Còi thủ công'),
                      value: snapshot.state.fanOn,
                      onChanged: snapshot.state.autoMode
                          ? null
                          : (value) => repository.setFanOn(warehouseId, value),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Điều hòa thủ công'),
                      value: snapshot.state.acOn,
                      onChanged: snapshot.state.autoMode
                          ? null
                          : (value) => repository.setAcOn(warehouseId, value),
                    ),
                  ),
                ],
              );
            },
          ),
          const Divider(height: 26),
          ThresholdEditor(
            warehouseId: warehouseId,
            repository: repository,
            thresholds: snapshot.thresholds,
          ),
        ],
      ),
    );
  }
}

class _ActivityPanel extends StatelessWidget {
  const _ActivityPanel({
    required this.warehouseId,
    required this.repository,
    required this.snapshot,
  });

  final String warehouseId;
  final WarehouseRepository repository;
  final WarehouseSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionCard(
          title: 'Biểu đồ theo thời gian',
          child: SizedBox(
            height: 320,
            child: TelemetryCharts(
              warehouseId: warehouseId,
              repository: repository,
              thresholds: snapshot.thresholds,
            ),
          ),
        ),
        const SizedBox(height: 18),
        _SectionCard(
          title: 'RFID gần nhất',
          child: ScanPanel(
            lastScanCode: snapshot.inventory.lastScanCode,
            lastScanType: snapshot.inventory.lastScanType,
            lastScanTimestampMs: snapshot.inventory.lastScanTimestampMs,
          ),
        ),
        const SizedBox(height: 18),
        _SectionCard(
          title: 'Danh sách hàng theo RFID',
          child: _InventoryListPanel(items: snapshot.inventory.items),
        ),
      ],
    );
  }
}

class _InventoryListPanel extends StatelessWidget {
  const _InventoryListPanel({required this.items});

  final List<WarehouseInventoryItem> items;

  String _formatDateTime(int? timestampMs) {
    if (timestampMs == null || timestampMs <= 0) return 'Chưa có';
    return DateFormat(
      'HH:mm dd/MM/yyyy',
    ).format(DateTime.fromMillisecondsSinceEpoch(timestampMs));
  }

  String _formatDate(int? timestampMs) {
    if (timestampMs == null || timestampMs <= 0) return 'Chưa cập nhật';
    return DateFormat(
      'dd/MM/yyyy',
    ).format(DateTime.fromMillisecondsSinceEpoch(timestampMs));
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text(
        'Chưa có kiện hàng nào được gán RFID trong kho này.',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    final now = DateTime.now().millisecondsSinceEpoch;

    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFD),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFDCE6F3)),
              ),
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
                              item.rfid,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            if ((item.label ?? '').trim().isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                item.label!,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ],
                        ),
                      ),
                      _StatusBadge(
                        label: item.isInStock ? 'Trong kho' : 'Đã xuất',
                        active: item.isInStock,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _InfoPill(
                        label: 'Ngày sản xuất',
                        value: _formatDate(item.manufacturedAtMs),
                      ),
                      _InfoPill(
                        label: 'Hạn dùng',
                        value: _formatDate(item.expiresAtMs),
                      ),
                      _InfoPill(
                        label: 'Nhập kho',
                        value: _formatDateTime(item.inboundAtMs),
                      ),
                      _InfoPill(
                        label: 'Xuất kho',
                        value: item.outboundAtMs == null
                            ? 'Chưa xuất'
                            : _formatDateTime(item.outboundAtMs),
                      ),
                      if (item.expiresAtMs != null &&
                          item.expiresAtMs! < now &&
                          item.isInStock)
                        const _InfoPill(
                          label: 'Cảnh báo',
                          value: 'Đã quá hạn',
                          warning: true,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: Colors.white,
          border: Border.all(color: const Color(0xFFD7E2F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D173B67),
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.label,
    required this.value,
    this.warning = false,
  });

  final String label;
  final String value;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: warning ? const Color(0xFFFFE5E7) : const Color(0xFFF2F6FC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: warning ? const Color(0xFFF3C7CB) : const Color(0xFFDCE6F3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: warning
                  ? const Color(0xFFB42318)
                  : const Color(0xFF62788F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: warning
                  ? const Color(0xFFB42318)
                  : const Color(0xFF17324D),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStateChip extends StatelessWidget {
  const _QuickStateChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDCE6F3)),
      ),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.label,
    required this.value,
    this.warning = false,
  });

  final String label;
  final String value;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: warning ? const Color(0xFFFFE5E7) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: warning ? const Color(0xFFF3C7CB) : const Color(0xFFDCE6F3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: warning
                  ? const Color(0xFFB42318)
                  : const Color(0xFF62788F),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: warning
                  ? const Color(0xFFB42318)
                  : const Color(0xFF17324D),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFEAF2FF) : const Color(0xFFF2F6FC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFDCE6F3)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: active ? const Color(0xFF245C9B) : const Color(0xFF5A728A),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
