import 'package:flutter/material.dart';

import '../../../data/models/warehouse_thresholds.dart';
import '../../../data/warehouse_repository.dart';

class ThresholdEditor extends StatefulWidget {
  const ThresholdEditor({
    super.key,
    required this.warehouseId,
    required this.repository,
    required this.thresholds,
  });

  final String warehouseId;
  final WarehouseRepository repository;
  final WarehouseThresholds thresholds;

  @override
  State<ThresholdEditor> createState() => _ThresholdEditorState();
}

class _ThresholdEditorState extends State<ThresholdEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tempMaxController;
  late final TextEditingController _humMaxController;
  final _tempFocus = FocusNode();
  final _humFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _tempMaxController = TextEditingController(text: widget.thresholds.tempMaxC.toString());
    _humMaxController = TextEditingController(text: widget.thresholds.humidityMaxPct.toString());
  }

  @override
  void didUpdateWidget(covariant ThresholdEditor oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Refresh controllers when values change and user isn't editing.
    if (!_tempFocus.hasFocus && oldWidget.thresholds.tempMaxC != widget.thresholds.tempMaxC) {
      _tempMaxController.text = widget.thresholds.tempMaxC.toString();
    }
    if (!_humFocus.hasFocus &&
        oldWidget.thresholds.humidityMaxPct != widget.thresholds.humidityMaxPct) {
      _humMaxController.text = widget.thresholds.humidityMaxPct.toString();
    }
  }

  @override
  void dispose() {
    _tempMaxController.dispose();
    _humMaxController.dispose();
    _tempFocus.dispose();
    _humFocus.dispose();
    super.dispose();
  }

  double? _parsePositiveDouble(String raw) {
    final v = double.tryParse(raw.trim().replaceAll(',', '.'));
    if (v == null) return null;
    return v;
  }

  Future<void> _save(BuildContext context) async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final tempMax = _parsePositiveDouble(_tempMaxController.text)!;
    final humMax = _parsePositiveDouble(_humMaxController.text)!;

    try {
      await widget.repository.setThresholds(
        widget.warehouseId,
        tempMaxC: tempMax,
        humidityMaxPct: humMax,
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu ngưỡng')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi lưu ngưỡng: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ngưỡng cảnh báo', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 760;

              final tempField = TextFormField(
                controller: _tempMaxController,
                focusNode: _tempFocus,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Nhiệt độ tối đa (°C)',
                ),
                validator: (v) {
                  final parsed = _parsePositiveDouble(v ?? '');
                  if (parsed == null) return 'Nhập số hợp lệ';
                  return null;
                },
              );

              final humidityField = TextFormField(
                controller: _humMaxController,
                focusNode: _humFocus,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Độ ẩm tối đa (%)',
                ),
                validator: (v) {
                  final parsed = _parsePositiveDouble(v ?? '');
                  if (parsed == null) return 'Nhập số hợp lệ';
                  if (parsed < 0 || parsed > 100) return '0–100';
                  return null;
                },
              );

              if (stacked) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    tempField,
                    const SizedBox(height: 10),
                    humidityField,
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => _save(context),
                      child: const Text('Lưu ngưỡng'),
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: tempField),
                  const SizedBox(width: 10),
                  Expanded(child: humidityField),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: () => _save(context),
                    child: const Text('Lưu'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
