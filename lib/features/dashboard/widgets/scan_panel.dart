import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/warehouse_repository.dart';

class ScanPanel extends StatefulWidget {
  const ScanPanel({
    super.key,
    required this.warehouseId,
    required this.repository,
    required this.lastScanCode,
    required this.lastScanType,
    required this.lastScanTimestampMs,
  });

  final String warehouseId;
  final WarehouseRepository repository;
  final String? lastScanCode;
  final String? lastScanType;
  final int? lastScanTimestampMs;

  @override
  State<ScanPanel> createState() => _ScanPanelState();
}

class _ScanPanelState extends State<ScanPanel> {
  final _codeController = TextEditingController();
  DateTime? _expiresAt;
  bool _saving = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() => _saving = true);
    try {
      await widget.repository.registerScan(
        widget.warehouseId,
        code: code,
        expiryDate: _expiresAt,
      );
      _codeController.clear();
      _expiresAt = null;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã ghi nhận RFID nhập kho')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi nhập kho: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lastTs = widget.lastScanTimestampMs;
    final lastTime = lastTs == null
        ? null
        : DateFormat(
            'HH:mm:ss dd/MM',
          ).format(DateTime.fromMillisecondsSinceEpoch(lastTs));
    final expiryText = _expiresAt == null
        ? 'Chọn hạn dùng'
        : DateFormat('dd/MM/yyyy').format(_expiresAt!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quét RFID nhập kho',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 760;

            final expiryField = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hạn dùng (tuỳ chọn)',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _saving
                      ? null
                      : () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _expiresAt ?? now,
                            firstDate: DateTime(now.year - 1),
                            lastDate: DateTime(now.year + 5),
                          );
                          if (picked != null && mounted) {
                            setState(() => _expiresAt = picked);
                          }
                        },
                  icon: const Icon(Icons.event_outlined),
                  label: Text(expiryText),
                ),
              ],
            );

            final codeField = TextField(
              controller: _codeController,
              enabled: !_saving,
              decoration: const InputDecoration(labelText: 'Mã RFID'),
              onSubmitted: (_) => _submit(),
            );

            final actionButton = FilledButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Ghi nhận'),
            );

            if (stacked) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  codeField,
                  const SizedBox(height: 12),
                  expiryField,
                  const SizedBox(height: 12),
                  actionButton,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(flex: 2, child: codeField),
                const SizedBox(width: 12),
                SizedBox(width: 190, child: expiryField),
                const SizedBox(width: 12),
                actionButton,
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          'Lần quét RFID gần nhất: '
          '${widget.lastScanCode ?? '—'} '
          '${lastTime ?? ''}',
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ],
    );
  }
}
