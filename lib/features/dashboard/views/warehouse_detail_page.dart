import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/warehouse_snapshot.dart';
import '../controllers/warehouse_detail_controller.dart';
import '../widgets/warehouse_detail_content.dart';

class WarehouseDetailPage extends GetView<WarehouseDetailController> {
  const WarehouseDetailPage({super.key});

  static const _defaultSubtitle = 'Mô-đun giám sát kho lạnh';

  Future<void> _showEditMetaDialog(
    BuildContext context, {
    required String initialName,
    required String initialSubtitle,
  }) async {
    final nameController = TextEditingController(text: initialName);
    final subtitleController = TextEditingController(text: initialSubtitle);

    final result = await showDialog<_WarehouseMetaInput>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chỉnh sửa thông tin phòng'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Tên phòng',
                  hintText: 'Ví dụ: Kho Hải Sản',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: subtitleController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Mô tả (dòng dưới)',
                  hintText: 'Ví dụ: Thủy sản đông lạnh',
                ),
                onSubmitted: (_) {
                  Navigator.of(context).pop(
                    _WarehouseMetaInput(
                      name: nameController.text,
                      subtitle: subtitleController.text,
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(
                  _WarehouseMetaInput(
                    name: nameController.text,
                    subtitle: subtitleController.text,
                  ),
                );
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );

    if (result == null) return;
    final trimmedName = result.name.trim();
    if (trimmedName.isEmpty) return;

    await controller.repository.setWarehouseMeta(
      controller.warehouseId,
      name: result.name,
      subtitle: result.subtitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<WarehouseSnapshot>(
      stream: controller.repository.watchWarehouse(controller.warehouseId),
      builder: (context, snapshot) {
        final data = snapshot.data ?? WarehouseSnapshot.defaults(controller.warehouseId);

        final displayTitle = data.meta.name ?? controller.title;
        final displaySubtitle = data.meta.subtitle ??
          (controller.subtitle.isEmpty ? _defaultSubtitle : controller.subtitle);

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: Get.back,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            title: Text(displayTitle),
            actions: [
              IconButton(
                tooltip: 'Chỉnh sửa',
                onPressed: () => _showEditMetaDialog(
                  context,
                  initialName: displayTitle,
                  initialSubtitle: displaySubtitle,
                ),
                icon: const Icon(Icons.edit_rounded),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(30),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    displaySubtitle,
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
                  title: displayTitle,
                  repository: controller.repository,
                ),
              ),
            ],
          ),
        );
      },
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

class _WarehouseMetaInput {
  const _WarehouseMetaInput({required this.name, required this.subtitle});

  final String name;
  final String subtitle;
}
