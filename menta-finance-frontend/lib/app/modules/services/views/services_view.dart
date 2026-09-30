import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/storage/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/data_table_card.dart';
import '../../../core/widgets/page_header.dart';
import '../../../core/widgets/status_badge.dart';
import '../controllers/services_controller.dart';
import '../models/service_offering_model.dart';

class ServicesView extends GetView<ServicesController> {
  const ServicesView({super.key});

  bool get _canEdit => Get.find<StorageService>().hasManagementAccess;

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Services',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: PageHeader(
                  title: 'Services',
                  subtitle: 'Aina za huduma zinazotolewa na Menta Studio.',
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Ongeza Service'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.errorMessage.value != null) {
                return Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(controller.errorMessage.value!, style: const TextStyle(color: AppColors.danger)),
                    const SizedBox(height: 10),
                    ElevatedButton(onPressed: controller.loadServices, child: const Text('Jaribu tena')),
                  ]),
                );
              }
              return SingleChildScrollView(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Orodha ya Services', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 14),
                        DataTableCard(
                          emptyIcon: Icons.design_services_outlined,
                          emptyTitle: 'Hakuna Service bado',
                          emptySubtitle: 'Ongeza service ya kwanza kwa kutumia kitufe hapo juu.',
                          columns: const [
                            DataColumn(label: Text('Jina la Service')),
                            DataColumn(label: Text('Maelezo')),
                            DataColumn(label: Text('Hali')),
                            DataColumn(label: Text('Vitendo')),
                          ],
                          rows: controller.services
                              .map((s) => DataRow(cells: [
                                    DataCell(Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                                    DataCell(SizedBox(width: 420, child: Text(s.description ?? '-', overflow: TextOverflow.ellipsis))),
                                    DataCell(StatusBadge.active(s.active)),
                                    DataCell(_canEdit
                                        ? IconButton(
                                            icon: const Icon(Icons.block, size: 18, color: AppColors.danger),
                                            tooltip: 'Zima Service',
                                            onPressed: s.active ? () => controller.deactivateService(s.id) : null,
                                          )
                                        : const Text('-')),
                                  ]))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        title: const Text('Ongeza Service'),
        content: Form(
          key: formKey,
          child: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Jina la Service'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Weka jina la service' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Maelezo (hiari)'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Ghairi')),
          Obx(() => ElevatedButton(
                onPressed: controller.isSaving.value
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        final ok = await controller.addService(
                          name: nameCtrl.text.trim(),
                          description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                        );
                        if (ok) Get.back();
                      },
                child: controller.isSaving.value
                    ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Hifadhi'),
              )),
        ],
      ),
    );
  }
}
