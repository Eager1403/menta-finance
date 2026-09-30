import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/money_fmt.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/data_table_card.dart';
import '../../../core/widgets/page_header.dart';
import '../../../core/widgets/status_badge.dart';
import '../controllers/project_list_controller.dart';
import '../models/project_model.dart';

class ProjectListView extends GetView<ProjectListController> {
  const ProjectListView({super.key});

  bool get _canEdit => Get.find<StorageService>().hasManagementAccess;

  Color _statusColor(ProjectStatusX s) {
    switch (s) {
      case ProjectStatusX.completed:
        return AppColors.success;
      case ProjectStatusX.cancelled:
        return AppColors.danger;
      case ProjectStatusX.ongoing:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Projects',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: PageHeader(title: 'Projects', subtitle: 'Orodha ya projects zote za Menta Studio.'),
              ),
              ElevatedButton.icon(
                onPressed: () => _showCreateDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Ongeza Project'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 340,
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search, size: 20),
                hintText: 'Tafuta kwa jina la project au client',
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
                    ElevatedButton(onPressed: controller.loadProjects, child: const Text('Jaribu tena')),
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
                        const Text('Orodha ya Projects', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 14),
                        DataTableCard(
                          emptyIcon: Icons.work_outline,
                          emptyTitle: 'Hakuna Project bado',
                          emptySubtitle: 'Ongeza project ya kwanza kwa kutumia kitufe hapo juu.',
                          columns: const [
                            DataColumn(label: Text('Jina')),
                            DataColumn(label: Text('Client')),
                            DataColumn(label: Text('Service')),
                            DataColumn(label: Text('Aina')),
                            DataColumn(label: Text('Thamani')),
                            DataColumn(label: Text('Hali')),
                            DataColumn(label: Text('Vitendo')),
                          ],
                          rows: list
                              .map((p) => DataRow(cells: [
                                    DataCell(Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                                    DataCell(Text(p.clientName ?? '-')),
                                    DataCell(Text(p.serviceName ?? '-')),
                                    DataCell(Text(projectTypeLabel(p.projectType))),
                                    DataCell(Text(formatTZS(p.projectValue))),
                                    DataCell(StatusBadge(projectStatusLabel(p.status), color: _statusColor(p.status))),
                                    DataCell(Row(children: [
                                      IconButton(
                                        icon: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.info),
                                        tooltip: 'Tazama',
                                        onPressed: () => Get.toNamed(AppRoutes.projectDetail, arguments: p.id),
                                      ),
                                      if (_canEdit)
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                                          tooltip: 'Futa',
                                          onPressed: () => _confirmDelete(context, p),
                                        ),
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

  void _confirmDelete(BuildContext context, ProjectModel project) {
    Get.dialog(
      AlertDialog(
        title: const Text('Futa Project'),
        content: Text('Una uhakika unataka kufuta "${project.name}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Ghairi')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              Get.back();
              controller.deleteProject(project.id);
            },
            child: const Text('Futa'),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final valueCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final dateFmt = DateFormat('dd/MM/yyyy');

    final projectType = ProjectTypeX.client.obs;
    final clientId = RxnInt();
    final serviceId = RxnInt();
    final status = ProjectStatusX.ongoing.obs;
    final startDate = Rxn<DateTime>();
    final endDate = Rxn<DateTime>();

    Future<void> pickDate(bool isStart) async {
      final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2015),
        lastDate: DateTime(2100),
      );
      if (picked == null) return;
      if (isStart) {
        startDate.value = picked;
      } else {
        endDate.value = picked;
      }
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Ongeza Project'),
        content: SizedBox(
          width: 480,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    autofocus: true,
                    decoration: const InputDecoration(labelText: 'Jina la Project'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Jina linahitajika' : null,
                  ),
                  const SizedBox(height: 12),
                  Obx(() => DropdownButtonFormField<ProjectTypeX>(
                        initialValue: projectType.value,
                        decoration: const InputDecoration(labelText: 'Aina ya Project'),
                        items: const [
                          DropdownMenuItem(value: ProjectTypeX.client, child: Text('Client')),
                          DropdownMenuItem(value: ProjectTypeX.internal, child: Text('Ndani ya Kampuni (Internal)')),
                        ],
                        onChanged: (v) {
                          projectType.value = v!;
                          if (v == ProjectTypeX.internal) clientId.value = null;
                        },
                      )),
                  const SizedBox(height: 12),
                  Obx(() => projectType.value == ProjectTypeX.client
                      ? DropdownButtonFormField<int>(
                          initialValue: clientId.value,
                          decoration: const InputDecoration(labelText: 'Client'),
                          items: controller.clientOptions
                              .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                              .toList(),
                          onChanged: (v) => clientId.value = v,
                          validator: (v) => v == null ? 'Chagua client' : null,
                        )
                      : const SizedBox.shrink()),
                  const SizedBox(height: 12),
                  Obx(() => DropdownButtonFormField<int>(
                        initialValue: serviceId.value,
                        decoration: const InputDecoration(labelText: 'Service (hiari)'),
                        items: controller.serviceOptions
                            .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                            .toList(),
                        onChanged: (v) => serviceId.value = v,
                      )),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: valueCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Thamani ya Project (TZS)'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Weka thamani';
                      if (double.tryParse(v.trim()) == null) return 'Namba si sahihi';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Obx(() => DropdownButtonFormField<ProjectStatusX>(
                        initialValue: status.value,
                        decoration: const InputDecoration(labelText: 'Hali (Status)'),
                        items: ProjectStatusX.values
                            .map((s) => DropdownMenuItem(value: s, child: Text(projectStatusLabel(s))))
                            .toList(),
                        onChanged: (v) => status.value = v!,
                      )),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: Obx(() => InkWell(
                            onTap: () => pickDate(true),
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'Tarehe ya Kuanza'),
                              child: Text(startDate.value == null ? 'Chagua' : dateFmt.format(startDate.value!)),
                            ),
                          )),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(() => InkWell(
                            onTap: () => pickDate(false),
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'Tarehe ya Mwisho'),
                              child: Text(endDate.value == null ? 'Chagua' : dateFmt.format(endDate.value!)),
                            ),
                          )),
                    ),
                  ]),
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
                        final ok = await controller.createProject(
                          name: nameCtrl.text.trim(),
                          clientId: clientId.value,
                          serviceId: serviceId.value,
                          projectType: projectType.value,
                          projectValue: double.parse(valueCtrl.text.trim()),
                          status: status.value,
                          startDate: startDate.value,
                          endDate: endDate.value,
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
