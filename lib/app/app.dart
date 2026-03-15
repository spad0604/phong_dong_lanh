import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_binding.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';
import '../data/warehouse_repository.dart';

class PhongDongLanhApp extends StatelessWidget {
  const PhongDongLanhApp({super.key, required this.repository});

  final WarehouseRepository repository;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      defaultTransition: Transition.noTransition,
      transitionDuration: Duration.zero,
      initialBinding: AppBinding(repository),
      initialRoute: AppRoutes.dashboard,
      getPages: AppPages.pages,
    );
  }
}
