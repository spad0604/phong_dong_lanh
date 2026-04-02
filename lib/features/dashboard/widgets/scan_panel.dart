import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScanPanel extends StatefulWidget {
  const ScanPanel({
    super.key,
    required this.lastScanCode,
    required this.lastScanType,
    required this.lastScanTimestampMs,
  });

  final String? lastScanCode;
  final String? lastScanType;
  final int? lastScanTimestampMs;

  @override
  State<ScanPanel> createState() => _ScanPanelState();
}

class _ScanPanelState extends State<ScanPanel> {
  @override
  Widget build(BuildContext context) {
    final lastTs = widget.lastScanTimestampMs;
    final lastTime = lastTs == null
        ? null
        : DateFormat(
            'HH:mm:ss dd/MM',
          ).format(DateTime.fromMillisecondsSinceEpoch(lastTs));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RFID gần nhất',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Lần quét RFID gần nhất: '
          '${widget.lastScanCode ?? '—'} '
          '${lastTime ?? ''}',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 6),
        Text(
          'RFID do vi điều khiển cập nhật lên hệ thống.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
