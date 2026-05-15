import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/dashboard_controller.dart';
import '../../data/models/warehouse_snapshot.dart';
import 'widgets/warehouse_module_card.dart';

class DashboardPage extends GetView<DashboardController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hệ thống kho lạnh')),
      body: Stack(
        children: [
          const _DashboardBackdrop(),
          SafeArea(
            top: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final useTwoColumns = width >= 900;
                final cardWidth = useTwoColumns ? (width - 18) / 2 : width;

                return Obx(() {
                  final modules = controller.filteredModules;
                  final selectedIds = controller.selectedWarehouseIds;

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
                    children: [
                      Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Chọn phòng',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: selectedIds.isEmpty
                                        ? null
                                        : controller.clearSelectedWarehouses,
                                    child: const Text('Tất cả'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 12,
                                runSpacing: 8,
                                children: [
                                  for (final module in controller.warehouseModules)
                                    InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () {
                                        final next = !selectedIds.contains(module.id);
                                        controller.setWarehouseSelected(module.id, next);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 4,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Checkbox(
                                              value: selectedIds.contains(module.id),
                                              onChanged: (value) {
                                                controller.setWarehouseSelected(
                                                  module.id,
                                                  value ?? false,
                                                );
                                              },
                                            ),
                                            StreamBuilder<WarehouseSnapshot>(
                                              stream: controller.repository.watchWarehouse(module.id),
                                              builder: (context, snapshot) {
                                                final data = snapshot.data;
                                                final name =
                                                    data?.meta.name ?? module.defaultTitle;
                                                return Text(name);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 18,
                        runSpacing: 18,
                        children: [
                          for (final module in modules)
                            SizedBox(
                              width: cardWidth,
                              child: WarehouseModuleCard(
                                module: module,
                                repository: controller.repository,
                                onTap: () => controller.openWarehouse(module),
                              ),
                            ),
                        ],
                      ),
                    ],
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardBackdrop extends StatelessWidget {
  const _DashboardBackdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Color(0xFFF8FAFD)),
    );
  }
}
