class WarehouseInventoryItem {
  const WarehouseInventoryItem({
    required this.itemKey,
    required this.rfid,
    required this.inboundAtMs,
    this.manufacturedAtMs,
    this.expiresAtMs,
    this.outboundAtMs,
    this.label,
  });

  final String itemKey;
  final String rfid;
  final int inboundAtMs;
  final int? manufacturedAtMs;
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

  // Accept either epoch milliseconds or epoch seconds.
  // Return null for clearly invalid/unsynced values to avoid showing 1970 in UI.
  static int? normalizeEpochMs(int? raw) {
    if (raw == null) return null;
    if (raw >= 1700000000000) return raw; // ms epoch (>= ~2023)
    if (raw >= 1700000000 && raw < 20000000000) return raw * 1000; // sec epoch
    return null;
  }

  static String _normUid(String raw) => raw.trim().toUpperCase();

  static int _utcMs(int y, int m, int d) =>
      DateTime.utc(y, m, d).millisecondsSinceEpoch;

  static final Map<String, ({String name, int mfgMs, int expMs})> _catalog = {
    '07A22625': (
      name: 'Thit Bo Dong Lanh',
      mfgMs: _utcMs(2026, 4, 2),
      expMs: _utcMs(2026, 4, 30),
    ),
    '4A11EA06': (
      name: 'Ca Hoi Dong Lanh',
      mfgMs: _utcMs(2026, 4, 2),
      expMs: _utcMs(2026, 4, 20),
    ),
    '6535E906': (
      name: 'Ga Dong Lanh',
      mfgMs: _utcMs(2026, 4, 1),
      expMs: _utcMs(2026, 4, 25),
    ),
    '9E8AE806': (
      name: 'Rau Cu Dong Lanh',
      mfgMs: _utcMs(2026, 4, 2),
      expMs: _utcMs(2026, 4, 15),
    ),
    '14AD2107': (
      name: 'Xuc Xich Dong Lanh',
      mfgMs: _utcMs(2026, 4, 2),
      expMs: _utcMs(2026, 5, 10),
    ),
    '8348A614': (
      name: 'Tom Dong Lanh',
      mfgMs: _utcMs(2026, 4, 1),
      expMs: _utcMs(2026, 4, 18),
    ),
    '3A297DE1': (
      name: 'Sua Chua',
      mfgMs: _utcMs(2026, 4, 2),
      expMs: _utcMs(2026, 4, 12),
    ),
    '3EBB2107': (
      name: 'Kem Hop',
      mfgMs: _utcMs(2026, 4, 2),
      expMs: _utcMs(2026, 5, 30),
    ),
    '1D5C2507': (
      name: 'Thit Lon Dong Lanh',
      mfgMs: _utcMs(2026, 4, 1),
      expMs: _utcMs(2026, 4, 22),
    ),
  };

  factory WarehouseInventoryItem.fromJson(
    Map<Object?, Object?> json, {
    required String itemKey,
    required String fallbackRfid,
  }) {
    final uid = _normUid(json['rfid']?.toString() ?? fallbackRfid);
    final meta = _catalog[uid];

    final inboundMs = normalizeEpochMs(_toNullableInt(json['inboundAtMs']));
    final manufacturedMs = normalizeEpochMs(
      _toNullableInt(json['manufacturedAtMs']) ?? meta?.mfgMs,
    );
    final expiresMs = normalizeEpochMs(
      _toNullableInt(json['expiresAtMs']) ?? meta?.expMs,
    );
    final outboundMs = normalizeEpochMs(_toNullableInt(json['outboundAtMs']));

    return WarehouseInventoryItem(
      itemKey: itemKey,
      rfid: uid,
      inboundAtMs: inboundMs ?? 0,
      manufacturedAtMs: manufacturedMs,
      expiresAtMs: expiresMs,
      outboundAtMs: outboundMs,
      label: json['label']?.toString() ?? meta?.name,
    );
  }
}
