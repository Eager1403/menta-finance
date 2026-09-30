import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/data_table_card.dart';
import '../../../core/widgets/page_header.dart';
import '../controllers/client_list_controller.dart';
import '../models/client_model.dart';

class ClientListView extends GetView<ClientListController> {
  const ClientListView({super.key});

  bool get _canEdit => Get.find<StorageService>().hasManagementAccess;

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Clients',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: PageHeader(
                  title: 'Clients',
                  subtitle: 'Orodha ya wateja wa Menta Studio.',
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showClientDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Ongeza Client'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 340,
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search, size: 20),
                hintText: 'Tafuta kwa jina, simu au email',
                isDense: true,
              ),
              onChanged: (v) => controller.searchText.value = v,
            ),
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
                    ElevatedButton(onPressed: controller.loadClients, child: const Text('Jaribu tena')),
                  ]),
                );
              }
              final list = controller.filtered;
              return SingleChildScrollView(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Orodha ya Clients', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 14),
                        DataTableCard(
                          emptyIcon: Icons.people_outline,
                          emptyTitle: 'Hakuna Client bado',
                          emptySubtitle: 'Ongeza client wa kwanza kwa kutumia kitufe hapo juu.',
                          columns: const [
                            DataColumn(label: Text('Jina')),
                            DataColumn(label: Text('Simu')),
                            DataColumn(label: Text('Email')),
                            DataColumn(label: Text('Address')),
                            DataColumn(label: Text('Vitendo')),
                          ],
                          rows: list
                              .map((c) => DataRow(cells: [
                                    DataCell(Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                                    DataCell(Text(c.phone ?? '-')),
                                    DataCell(Text(c.email ?? '-')),
                                    DataCell(Text(c.address ?? '-')),
                                    DataCell(Row(children: [
                                      IconButton(
                                        icon: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.info),
                                        tooltip: 'Tazama',
                                        onPressed: () => Get.toNamed(AppRoutes.clientDetail, arguments: c.id),
                                      ),
                                      if (_canEdit) ...[
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primaryGreen),
                                          tooltip: 'Hariri',
                                          onPressed: () => _showClientDialog(context, existing: c),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                                          tooltip: 'Futa',
                                          onPressed: () => _confirmDelete(context, c),
                                        ),
                                      ],
                                    ])),
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

  void _confirmDelete(BuildContext context, ClientModel client) {
    Get.dialog(
      AlertDialog(
        title: const Text('Futa Client'),
        content: Text('Una uhakika unataka kumfuta "${client.name}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Ghairi')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              Get.back();
              controller.deleteClient(client.id);
            },
            child: const Text('Futa'),
          ),
        ],
      ),
    );
  }

  void _showClientDialog(BuildContext context, {ClientModel? existing}) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    final emailCtrl = TextEditingController(text: existing?.email ?? '');
    final addressCtrl = TextEditingController(text: existing?.address ?? '');
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        title: Text(existing == null ? 'Ongeza Client' : 'Hariri Client'),
        content: SizedBox(
          width: 440,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    autofocus: true,
                    decoration: const InputDecoration(labelText: 'Jina la Client'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Jina linahitajika' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Simu')),
                  const SizedBox(height: 12),
                  TextFormField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
                  const SizedBox(height: 12),
                  TextFormField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Address')),
                ],
              ),
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
                        bool ok;
                        if (existing == null) {
                          ok = await controller.createClient(
                            name: nameCtrl.text.trim(),
                            phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
                            email: emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
                            address: addressCtrl.text.trim().isEmpty ? null : addressCtrl.text.trim(),
                          );
                        } else {
                          ok = await controller.updateClient(
                            existing.id,
                            name: nameCtrl.text.trim(),
                            phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
                            email: emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
                            address: addressCtrl.text.trim().isEmpty ? null : addressCtrl.text.trim(),
                          );
                        }
                        if (ok) Get.back();
                      },
                child: controller.isSaving.value
                    ? const SizedBox(
                        height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Hifadhi'),
              )),
        ],
      ),
    );
  }
}
