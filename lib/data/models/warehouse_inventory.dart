import 'warehouse_inventory_item.dart';

class WarehouseInventory {
  const WarehouseInventory({
    required this.count,
    required this.lastScanCode,
    required this.lastScanType,
    required this.lastScanTimestampMs,
    required this.items,
  });

  final int count;
  final String? lastScanCode;
  final String? lastScanType;
  final int? lastScanTimestampMs;
  final List<WarehouseInventoryItem> items;

  static const WarehouseInventory defaults = WarehouseInventory(
    count: 0,
    lastScanCode: null,
    lastScanType: null,
    lastScanTimestampMs: null,
    items: <WarehouseInventoryItem>[],
  );

  static int _toInt(Object? value, {required int fallback}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  factory WarehouseInventory.fromJson(Map<Object?, Object?> json) {
    final lastScan = json['lastScan'];
    final lastScanJson = lastScan is Map<Object?, Object?> ? lastScan : null;
    final items = <WarehouseInventoryItem>[];
    final rawItems = json['items'];

    if (rawItems is Map<Object?, Object?>) {
      for (final entry in rawItems.entries) {
        final value = entry.value;
        if (value is Map<Object?, Object?>) {
          items.add(
            WarehouseInventoryItem.fromJson(
              value,
              fallbackRfid: entry.key?.toString() ?? '',
            ),
          );
        }
      }
    }

    items.sort((a, b) {
      if (a.isInStock != b.isInStock) {
        return a.isInStock ? -1 : 1;
      }
      return b.inboundAtMs.compareTo(a.inboundAtMs);
    });

    final activeCount = items.where((item) => item.isInStock).length;

    return WarehouseInventory(
      count: items.isEmpty
          ? _toInt(json['count'], fallback: defaults.count)
          : activeCount,
      lastScanCode: lastScanJson?['code']?.toString(),
      lastScanType: lastScanJson?['type']?.toString(),
      lastScanTimestampMs: lastScanJson?['ts'] is num
          ? (lastScanJson?['ts'] as num).toInt()
          : int.tryParse(lastScanJson?['ts']?.toString() ?? ''),
      items: items,
    );
  }
}
