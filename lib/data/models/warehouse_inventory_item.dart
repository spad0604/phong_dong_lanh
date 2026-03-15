class WarehouseInventoryItem {
  const WarehouseInventoryItem({
    required this.rfid,
    required this.inboundAtMs,
    this.expiresAtMs,
    this.outboundAtMs,
    this.label,
  });

  final String rfid;
  final int inboundAtMs;
  final int? expiresAtMs;
  final int? outboundAtMs;
  final String? label;

  bool get isInStock => outboundAtMs == null;

  static int? _toNullableInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  factory WarehouseInventoryItem.fromJson(
    Map<Object?, Object?> json, {
    required String fallbackRfid,
  }) {
    return WarehouseInventoryItem(
      rfid: json['rfid']?.toString() ?? fallbackRfid,
      inboundAtMs: _toNullableInt(json['inboundAtMs']) ?? 0,
      expiresAtMs: _toNullableInt(json['expiresAtMs']),
      outboundAtMs: _toNullableInt(json['outboundAtMs']),
      label: json['label']?.toString(),
    );
  }
}
