import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/money_fmt.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/data_table_card.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/page_header.dart';
import '../controllers/income_controller.dart';
import '../models/income_model.dart';

class IncomeView extends GetView<IncomeController> {
  const IncomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy');

    return AppShell(
      title: 'Income',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
            title: 'Income',
            subtitle: 'Chagua project ili kuona/kuongeza Income yake (backend inahitaji project maalum).',
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.isLoadingProjects.value) {
              return const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: LinearProgressIndicator());
            }
            return SizedBox(
              width: 380,
              child: DropdownButtonFormField<int>(
                initialValue: controller.selectedProjectId.value,
                decoration: const InputDecoration(labelText: 'Project', prefixIcon: Icon(Icons.work_outline)),
                items: controller.projects
                    .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                    .toList(),
                onChanged: controller.selectProject,
              ),
            );
          }),
          const SizedBox(height: 20),
          Expanded(
            child: Obx(() {
              if (controller.selectedProjectId.value == null) {
                return const EmptyStateWidget(
                  icon: Icons.attach_money,
                  title: 'Chagua Project kwanza',
                  subtitle: 'Chagua project hapo juu ili kuona Income yake.',
                );
              }
              if (controller.isLoadingIncome.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.errorMessage.value != null) {
                return Center(child: Text(controller.errorMessage.value!, style: const TextStyle(color: AppColors.danger)));
              }
              return SingleChildScrollView(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                            child: Text('Jumla ya Income: ${formatTZS(controller.total)}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _showAddDialog(context),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Ongeza Income'),
                          ),
                        ]),
                        const SizedBox(height: 14),
                        DataTableCard(
                          emptyIcon: Icons.attach_money,
                          emptyTitle: 'Hakuna Income bado kwenye project hii',
                          columns: const [
                            DataColumn(label: Text('Tarehe')),
                            DataColumn(label: Text('Maelezo')),
                            DataColumn(label: Text('Chanzo')),
                            DataColumn(label: Text('Njia ya Malipo')),
                            DataColumn(label: Text('Kiasi')),
                            DataColumn(label: Text('Vitendo')),
                          ],
                          rows: controller.incomes
                              .map((i) => DataRow(cells: [
                                    DataCell(Text(i.incomeDate != null ? dateFmt.format(i.incomeDate!) : '-')),
                                    DataCell(Text(i.description ?? '-')),
                                    DataCell(Text(incomeSourceLabel(i.sourceType))),
                                    DataCell(Text(i.paymentMethod ?? '-')),
                                    DataCell(Text(formatTZS(i.amount),
                                        style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w700))),
                                    DataCell(i.isEditable
                                        ? IconButton(
                                            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                                            tooltip: 'Futa',
                                            onPressed: () => controller.deleteIncome(i.id),
                                          )
                                        : const Tooltip(
                                            message: 'Income hii ilitengenezwa kiotomatiki na malipo ya Invoice',
                                            child: Icon(Icons.lock_outline, size: 16, color: Colors.grey),
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
    final descCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final methodCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        title: const Text('Ongeza Income'),
        content: Form(
          key: formKey,
          child: SizedBox(
            width: 420,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextFormField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Maelezo (hiari)')),
              const SizedBox(height: 12),
              TextFormField(
                controller: amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Kiasi (TZS)'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Weka kiasi';
                  if (double.tryParse(v.trim()) == null) return 'Namba si sahihi';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(controller: methodCtrl, decoration: const InputDecoration(labelText: 'Njia ya Malipo (hiari)')),
            ]),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Ghairi')),
          Obx(() => ElevatedButton(
                onPressed: controller.isSaving.value
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        final ok = await controller.addIncome(
                          description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                          amount: double.parse(amountCtrl.text.trim()),
                          incomeDate: DateTime.now(),
                          paymentMethod: methodCtrl.text.trim().isEmpty ? null : methodCtrl.text.trim(),
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
