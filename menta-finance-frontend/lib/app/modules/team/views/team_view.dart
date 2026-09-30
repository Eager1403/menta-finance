import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/data_table_card.dart';
import '../../../core/widgets/page_header.dart';
import '../controllers/team_controller.dart';

class TeamView extends GetView<TeamController> {
  const TeamView({super.key});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy');

    return AppShell(
      title: 'Team',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: PageHeader(title: 'Team', subtitle: 'Wafanyakazi/wanachama wa timu ya Menta Studio.'),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Ongeza Team Member'),
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
                    ElevatedButton(onPressed: controller.loadMembers, child: const Text('Jaribu tena')),
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
                        const Text('Orodha ya Team', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 14),
                        DataTableCard(
                          emptyIcon: Icons.groups_outlined,
                          emptyTitle: 'Hakuna Team Member bado',
                          columns: const [
                            DataColumn(label: Text('Jina')),
                            DataColumn(label: Text('Nafasi')),
                            DataColumn(label: Text('Simu')),
                            DataColumn(label: Text('Email')),
                            DataColumn(label: Text('Tarehe ya Kujiunga')),
                            DataColumn(label: Text('Vitendo')),
                          ],
                          rows: controller.members
                              .map((m) => DataRow(cells: [
                                    DataCell(Text(m.fullName, style: const TextStyle(fontWeight: FontWeight.w600))),
                                    DataCell(Text(m.position ?? '-')),
                                    DataCell(Text(m.phone ?? '-')),
                                    DataCell(Text(m.email ?? '-')),
                                    DataCell(Text(m.joinedDate != null ? dateFmt.format(m.joinedDate!) : '-')),
                                    DataCell(IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                                      tooltip: 'Futa',
                                      onPressed: () => controller.removeMember(m.id),
                                    )),
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
    final positionCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        title: const Text('Ongeza Team Member'),
        content: Form(
          key: formKey,
          child: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextFormField(
                  controller: nameCtrl,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Jina Kamili'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Jina linahitajika' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(controller: positionCtrl, decoration: const InputDecoration(labelText: 'Nafasi (hiari)')),
                const SizedBox(height: 12),
                TextFormField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Simu (hiari)')),
                const SizedBox(height: 12),
                TextFormField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email (hiari)')),
              ]),
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
                        final ok = await controller.addMember(
                          fullName: nameCtrl.text.trim(),
                          position: positionCtrl.text.trim().isEmpty ? null : positionCtrl.text.trim(),
                          phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
                          email: emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
                          joinedDate: DateTime.now(),
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
