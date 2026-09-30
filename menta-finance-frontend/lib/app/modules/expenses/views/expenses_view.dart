import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/money_fmt.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/data_table_card.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/page_header.dart';
import '../controllers/expenses_controller.dart';

class ExpensesView extends GetView<ExpensesController> {
  const ExpensesView({super.key});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy');

    return AppShell(
      title: 'Expenses',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
            title: 'Expenses',
            subtitle: 'Chagua project ili kuona/kuongeza Expenses zake (backend inahitaji project maalum).',
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
                  icon: Icons.money_off,
                  title: 'Chagua Project kwanza',
                  subtitle: 'Chagua project hapo juu ili kuona Expenses zake.',
                );
              }
              if (controller.isLoadingExpenses.value) {
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
                            child: Text('Jumla ya Expenses: ${formatTZS(controller.total)}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _showAddDialog(context),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Ongeza Expense'),
                          ),
                        ]),
                        const SizedBox(height: 14),
                        DataTableCard(
                          emptyIcon: Icons.money_off,
                          emptyTitle: 'Hakuna Expense bado kwenye project hii',
                          columns: const [
                            DataColumn(label: Text('Tarehe')),
                            DataColumn(label: Text('Maelezo')),
                            DataColumn(label: Text('Category')),
                            DataColumn(label: Text('Kiasi')),
                            DataColumn(label: Text('Vitendo')),
                          ],
                          rows: controller.expenses
                              .map((e) => DataRow(cells: [
                                    DataCell(Text(e.expenseDate != null ? dateFmt.format(e.expenseDate!) : '-')),
                                    DataCell(Text(e.description ?? '-')),
                                    DataCell(Text(e.category ?? '-')),
                                    DataCell(Text(formatTZS(e.amount),
                                        style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700))),
                                    DataCell(IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                                      tooltip: 'Futa',
                                      onPressed: () => controller.deleteExpense(e.id),
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
    final categoryCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        title: const Text('Ongeza Expense'),
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
              TextFormField(controller: categoryCtrl, decoration: const InputDecoration(labelText: 'Category (hiari)')),
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
                        final ok = await controller.addExpense(
                          description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                          amount: double.parse(amountCtrl.text.trim()),
                          expenseDate: DateTime.now(),
                          category: categoryCtrl.text.trim().isEmpty ? null : categoryCtrl.text.trim(),
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
