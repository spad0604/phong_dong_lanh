import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/warehouse_repository.dart';
import '../models/warehouse_module.dart';

class DashboardController extends GetxController {
  DashboardController({required this.repository});

  final WarehouseRepository repository;

  final warehouseModules = const <WarehouseModule>[
    WarehouseModule(
      id: 'kho_1',
      title: 'Kho 1',
      subtitle: 'Thủy sản đông lạnh',
    ),
    WarehouseModule(
      id: 'kho_2',
      title: 'Kho 2',
      subtitle: 'Rau củ bảo quản mát',
    ),
    WarehouseModule(
      id: 'kho_3',
      title: 'Kho 3',
      subtitle: 'Sữa và chế phẩm',
    ),
    WarehouseModule(
      id: 'kho_4',
      title: 'Kho 4',
      subtitle: 'Thuốc và vật tư nhạy nhiệt',
    ),
  ];

  void openWarehouse(WarehouseModule module) {
    Get.toNamed(
      '${AppRoutes.warehouseDetail}/${module.id}',
      arguments: module,
    );
  }
}
