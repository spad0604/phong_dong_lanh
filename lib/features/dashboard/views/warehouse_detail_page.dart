import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/warehouse_detail_controller.dart';
import '../widgets/warehouse_detail_content.dart';

class WarehouseDetailPage extends GetView<WarehouseDetailController> {
  const WarehouseDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(controller.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                controller.subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          const _DetailBackdrop(),
          SafeArea(
            top: false,
            child: WarehouseDetailContent(
              warehouseId: controller.warehouseId,
              title: controller.title,
              repository: controller.repository,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailBackdrop extends StatelessWidget {
  const _DetailBackdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Color(0xFFF8FAFD)),
    );
  }
}
