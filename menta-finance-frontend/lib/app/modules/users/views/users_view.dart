import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/data_table_card.dart';
import '../../../core/widgets/page_header.dart';
import '../../../core/widgets/status_badge.dart';
import '../controllers/users_controller.dart';
import '../models/managed_user_model.dart';

const _roles = ['SUPERADMIN', 'MANAGER', 'STAFF'];

class UsersView extends GetView<UsersController> {
  const UsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Watumiaji wa Mfumo',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: PageHeader(
                  title: 'Watumiaji wa Mfumo (Users)',
                  subtitle: 'Akaunti za kuingia kwenye Menta Finance - SUPERADMIN pekee anaweza kusimamia.',
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddDialog(context),
                icon: const Icon(Icons.person_add_alt, size: 18),
                label: const Text('Ongeza Mtumiaji'),
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
                    ElevatedButton(onPressed: controller.loadUsers, child: const Text('Jaribu tena')),
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
                        const Text('Orodha ya Watumiaji', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 14),
                        DataTableCard(
                          emptyIcon: Icons.people_alt_outlined,
                          emptyTitle: 'Hakuna mtumiaji mwingine bado',
                          columns: const [
                            DataColumn(label: Text('Jina')),
                            DataColumn(label: Text('Email')),
                            DataColumn(label: Text('Role')),
                            DataColumn(label: Text('Hali')),
                            DataColumn(label: Text('Vitendo')),
                          ],
                          rows: controller.users
                              .map((u) => DataRow(cells: [
                                    DataCell(Text(u.fullName, style: const TextStyle(fontWeight: FontWeight.w600))),
                                    DataCell(Text(u.email)),
                                    DataCell(Text(u.role)),
                                    DataCell(StatusBadge.active(u.active)),
                                    DataCell(TextButton(
                                      onPressed: () => controller.toggleActive(u),
                                      child: Text(u.active ? 'Zima (Deactivate)' : 'Amsha (Reactivate)'),
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
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final role = 'STAFF'.obs;
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        title: const Text('Ongeza Mtumiaji Mpya'),
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
                TextFormField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Email inahitajika' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: passwordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password (angalau herufi 8)'),
                  validator: (v) =>
                      (v == null || v.trim().length < 8) ? 'Password lazima iwe angalau herufi 8' : null,
                ),
                const SizedBox(height: 12),
                Obx(() => DropdownButtonFormField<String>(
                      initialValue: role.value,
                      decoration: const InputDecoration(labelText: 'Role'),
                      items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                      onChanged: (v) => role.value = v!,
                    )),
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
                        final ok = await controller.createUser(
                          fullName: nameCtrl.text.trim(),
                          email: emailCtrl.text.trim(),
                          password: passwordCtrl.text,
                          role: role.value,
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
