import 'package:get/get.dart';

import '../../features/dashboard/controllers/warehouse_detail_controller.dart';
import '../../features/dashboard/dashboard_page.dart';
import '../../features/dashboard/views/warehouse_detail_page.dart';
import 'app_routes.dart';

abstract final class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage<dynamic>(
      name: AppRoutes.dashboard,
      page: () => const DashboardPage(),
    ),
    GetPage<dynamic>(
      name: '${AppRoutes.warehouseDetail}/:id',
      page: () => const WarehouseDetailPage(),
      transition: Transition.noTransition,
      transitionDuration: Duration.zero,
      binding: BindingsBuilder(() {
        Get.lazyPut<WarehouseDetailController>(
          () => WarehouseDetailController(),
        );
      }),
    ),
  ];
}
