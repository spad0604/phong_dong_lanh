import 'package:get/get.dart';

import '../../../data/warehouse_repository.dart';
import '../models/warehouse_module.dart';

class WarehouseDetailController extends GetxController {
  WarehouseDetailController();

  WarehouseRepository get repository => Get.find<WarehouseRepository>();

  String get warehouseId => Get.parameters['id'] ?? '';

  WarehouseModule? get module {
    final args = Get.arguments;
    if (args is WarehouseModule) return args;
    return null;
  }

  String get title => module?.title ?? warehouseId;

  String get subtitle => module?.subtitle ?? 'Mô-đun giám sát kho lạnh';
}
