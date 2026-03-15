import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/dashboard_controller.dart';
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

                return ListView(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
                  children: [
                    // _OverviewHero(
                    //   moduleCount: controller.warehouseModules.length,
                    // ),
                    // const SizedBox(height: 18),
                    Wrap(
                      spacing: 18,
                      runSpacing: 18,
                      children: [
                        for (final module in controller.warehouseModules)
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
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewHero extends StatelessWidget {
  const _OverviewHero({required this.moduleCount});

  final int moduleCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD7E2F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D173B67),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 92,
            decoration: BoxDecoration(
              color: const Color(0xFF2F80ED),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Wrap(
              spacing: 18,
              runSpacing: 18,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$moduleCount kho lạnh đang theo dõi',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Theo dõi nhiệt độ, độ ẩm, trạng thái cửa kho và thiết bị vận hành theo thời gian thực.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F6FC),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFDCE6F3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$moduleCount mô-đun kho',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mở từng kho để xem RFID, cảnh báo môi trường và điều khiển tại chỗ.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
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
