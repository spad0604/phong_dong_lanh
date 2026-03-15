import 'warehouse_inventory.dart';
import 'warehouse_state.dart';
import 'warehouse_telemetry.dart';
import 'warehouse_thresholds.dart';

class WarehouseSnapshot {
  const WarehouseSnapshot({
    required this.warehouseId,
    required this.telemetry,
    required this.thresholds,
    required this.state,
    required this.inventory,
  });

  final String warehouseId;
  final WarehouseTelemetry telemetry;
  final WarehouseThresholds thresholds;
  final WarehouseState state;
  final WarehouseInventory inventory;

  static WarehouseSnapshot defaults(String warehouseId) {
    return WarehouseSnapshot(
      warehouseId: warehouseId,
      telemetry: WarehouseTelemetry.defaults,
      thresholds: WarehouseThresholds.defaults,
      state: WarehouseState.defaults,
      inventory: WarehouseInventory.defaults,
    );
  }

  factory WarehouseSnapshot.fromJson(String warehouseId, Map<Object?, Object?> json) {
    final sensors = json['sensors'];
    final thresholds = json['thresholds'];
    final state = json['state'];
    final inventory = json['inventory'];

    return WarehouseSnapshot(
      warehouseId: warehouseId,
      telemetry: sensors is Map<Object?, Object?>
          ? WarehouseTelemetry.fromJson(sensors)
          : WarehouseTelemetry.defaults,
      thresholds: thresholds is Map<Object?, Object?>
          ? WarehouseThresholds.fromJson(thresholds)
          : WarehouseThresholds.defaults,
      state: state is Map<Object?, Object?>
          ? WarehouseState.fromJson(state)
          : WarehouseState.defaults,
      inventory: inventory is Map<Object?, Object?>
          ? WarehouseInventory.fromJson(inventory)
          : WarehouseInventory.defaults,
    );
  }
}
