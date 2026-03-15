import 'package:get/get.dart';

import '../data/warehouse_repository.dart';
import '../features/dashboard/controllers/dashboard_controller.dart';

class AppBinding extends Bindings {
  AppBinding(this.repository);

  final WarehouseRepository repository;

  @override
  void dependencies() {
    Get.put<WarehouseRepository>(repository, permanent: true);
    Get.put<DashboardController>(
      DashboardController(repository: Get.find<WarehouseRepository>()),
      permanent: true,
    );
  }
}
