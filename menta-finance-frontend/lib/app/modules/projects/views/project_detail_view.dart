import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/storage/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/money_fmt.dart';
import '../../../core/utils/web_download.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/data_table_card.dart';
import '../../../core/widgets/page_header.dart';
import '../../../core/widgets/status_badge.dart';
import '../../expenses/expenses_service.dart';
import '../../income/income_service.dart';
import '../../income/models/income_model.dart';
import '../../invoices/invoice_service.dart';
import '../../invoices/widgets/invoice_form_dialog.dart';
import '../../invoices/widgets/invoice_status_badge.dart';
import '../controllers/project_detail_controller.dart';
import '../models/project_model.dart';

class ProjectDetailView extends GetView<ProjectDetailController> {
  const ProjectDetailView({super.key});

  bool get _canManageFinance => Get.find<StorageService>().hasManagementAccess;

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
    final dateFmt = DateFormat('dd/MM/yyyy');

    return AppShell(
      title: 'Taarifa za Project',
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value != null) {
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(controller.errorMessage.value!, style: const TextStyle(color: AppColors.danger)),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: controller.loadProject, child: const Text('Jaribu tena')),
            ]),
          );
        }

        final project = controller.project.value!;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: PageHeader(
                      title: project.name,
                      subtitle: '${project.clientName ?? "Project ya ndani ya kampuni"} · ${project.serviceName ?? "Hakuna service maalum"}',
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Rudi Projects'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              StatusBadge(projectStatusLabel(project.status), color: _statusColor(project.status)),
              const SizedBox(height: 20),
              Obx(() {
                final cards = [
                  _StatCard(icon: Icons.attach_money, color: AppColors.success, label: 'Income', value: formatTZS(controller.totalIncome)),
                  _StatCard(icon: Icons.money_off, color: AppColors.danger, label: 'Expenses', value: formatTZS(controller.totalExpenses)),
                  _StatCard(
                    icon: Icons.trending_up,
                    color: controller.netProfit >= 0 ? AppColors.primaryGreen : AppColors.danger,
                    label: 'Net Profit',
                    value: formatTZS(controller.netProfit),
                  ),
                  _StatCard(icon: Icons.price_check, color: AppColors.primaryTeal, label: 'Thamani ya Project', value: formatTZS(project.projectValue)),
                ];
                return LayoutBuilder(builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 900;
                  if (isNarrow) {
                    return Wrap(spacing: 12, runSpacing: 12, children: cards.map((c) => SizedBox(width: 260, child: c)).toList());
                  }
                  return Row(children: [
                    for (int i = 0; i < cards.length; i++) ...[
                      if (i != 0) const SizedBox(width: 12),
                      Expanded(child: cards[i]),
                    ],
                  ]);
                });
              }),
              const SizedBox(height: 24),
              Obx(() {
                if (controller.isLoadingFinance.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_canManageFinance) ...[
                      Row(children: [
                        const Expanded(child: Text('Income', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
                        TextButton.icon(
                          onPressed: () => _showIncomeDialog(context, project.id),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Ongeza Income'),
                        ),
                      ]),
                      const SizedBox(height: 10),
                      DataTableCard(
                        emptyIcon: Icons.attach_money,
                        emptyTitle: 'Hakuna Income bado',
                        columns: const [
                          DataColumn(label: Text('Tarehe')),
                          DataColumn(label: Text('Maelezo')),
                          DataColumn(label: Text('Chanzo')),
                          DataColumn(label: Text('Njia ya Malipo')),
                          DataColumn(label: Text('Kiasi')),
                        ],
                        rows: controller.incomes
                            .map((i) => DataRow(cells: [
                                  DataCell(Text(i.incomeDate != null ? dateFmt.format(i.incomeDate!) : '-')),
                                  DataCell(Text(i.description ?? '-')),
                                  DataCell(Text(incomeSourceLabel(i.sourceType))),
                                  DataCell(Text(i.paymentMethod ?? '-')),
                                  DataCell(Text(formatTZS(i.amount), style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w700))),
                                ]))
                            .toList(),
                      ),
                      const SizedBox(height: 24),
                      Row(children: [
                        const Expanded(child: Text('Expenses', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
                        TextButton.icon(
                          onPressed: () => _showExpenseDialog(context, project.id),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Ongeza Expense'),
                        ),
                      ]),
                      const SizedBox(height: 10),
                      DataTableCard(
                        emptyIcon: Icons.money_off,
                        emptyTitle: 'Hakuna Expense bado',
                        columns: const [
                          DataColumn(label: Text('Tarehe')),
                          DataColumn(label: Text('Maelezo')),
                          DataColumn(label: Text('Category')),
                          DataColumn(label: Text('Kiasi')),
                        ],
                        rows: controller.expenses
                            .map((e) => DataRow(cells: [
                                  DataCell(Text(e.expenseDate != null ? dateFmt.format(e.expenseDate!) : '-')),
                                  DataCell(Text(e.description ?? '-')),
                                  DataCell(Text(e.category ?? '-')),
                                  DataCell(Text(formatTZS(e.amount), style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700))),
                                ]))
                            .toList(),
                      ),
                      const SizedBox(height: 24),
                    ],
                    Row(children: [
                      const Expanded(child: Text('Invoices za Project hii', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
                      if (project.clientId != null)
                        ElevatedButton.icon(
                          onPressed: () => Get.dialog(InvoiceFormDialog(
                            clientId: project.clientId!,
                            projectOptions: [ProjectOption(project.id, project.name)],
                            onCreated: controller.loadFinance,
                          )),
                          icon: const Icon(Icons.receipt_long_outlined, size: 18),
                          label: const Text('Tengeneza Invoice'),
                        ),
                    ]),
                    const SizedBox(height: 10),
                    DataTableCard(
                      emptyIcon: Icons.receipt_long_outlined,
                      emptyTitle: 'Hakuna Invoice bado',
                      columns: const [
                        DataColumn(label: Text('Namba')),
                        DataColumn(label: Text('Total')),
                        DataColumn(label: Text('Balance Due')),
                        DataColumn(label: Text('Hali')),
                        DataColumn(label: Text('Vitendo')),
                      ],
                      rows: controller.invoices
                          .map((inv) => DataRow(cells: [
                                DataCell(Text(inv.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.w600))),
                                DataCell(Text(formatTZS(inv.total))),
                                DataCell(Text(formatTZS(inv.balanceDue))),
                                DataCell(InvoiceStatusBadge(inv.status)),
                                DataCell(IconButton(
                                  icon: const Icon(Icons.download_outlined, size: 18, color: AppColors.primaryGreen),
                                  tooltip: 'Pakua PDF',
                                  onPressed: () async {
                                    try {
                                      final bytes = await InvoiceService(Get.find()).getPdfBytes(inv.id);
                                      downloadBytesAsFile(bytes, 'invoice-${inv.invoiceNumber}.pdf');
                                    } catch (_) {
                                      Get.snackbar('Hitilafu', 'Imeshindikana kupakua PDF.', snackPosition: SnackPosition.BOTTOM);
                                    }
                                  },
                                )),
                              ]))
                          .toList(),
                    ),
                  ],
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  void _showIncomeDialog(BuildContext context, int projectId) {
    final descCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final methodCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final saving = false.obs;

    Get.dialog(
      AlertDialog(
        title: const Text('Ongeza Income'),
        content: Form(
          key: formKey,
          child: SizedBox(
            width: 420,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextFormField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Maelezo (hiari)'),
              ),
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
                onPressed: saving.value
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        saving.value = true;
                        try {
                          await IncomeService(Get.find()).create(
                            projectId: projectId,
                            description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                            amount: double.parse(amountCtrl.text.trim()),
                            incomeDate: DateTime.now(),
                            paymentMethod: methodCtrl.text.trim().isEmpty ? null : methodCtrl.text.trim(),
                          );
                          Get.back();
                          controller.loadFinance();
                          Get.snackbar('Imefanikiwa', 'Income imeongezwa.', snackPosition: SnackPosition.BOTTOM);
                        } catch (e) {
                          Get.snackbar('Hitilafu', 'Imeshindikana kuongeza income.', snackPosition: SnackPosition.BOTTOM);
                        } finally {
                          saving.value = false;
                        }
                      },
                child: saving.value
                    ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Hifadhi'),
              )),
        ],
      ),
    );
  }

  void _showExpenseDialog(BuildContext context, int projectId) {
    final descCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final categoryCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final saving = false.obs;

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
                onPressed: saving.value
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        saving.value = true;
                        try {
                          await ExpensesService(Get.find()).create(
                            projectId: projectId,
                            description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                            amount: double.parse(amountCtrl.text.trim()),
                            expenseDate: DateTime.now(),
                            category: categoryCtrl.text.trim().isEmpty ? null : categoryCtrl.text.trim(),
                          );
                          Get.back();
                          controller.loadFinance();
                          Get.snackbar('Imefanikiwa', 'Expense imeongezwa.', snackPosition: SnackPosition.BOTTOM);
                        } catch (e) {
                          Get.snackbar('Hitilafu', 'Imeshindikana kuongeza expense.', snackPosition: SnackPosition.BOTTOM);
                        } finally {
                          saving.value = false;
                        }
                      },
                child: saving.value
                    ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Hifadhi'),
              )),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  const _StatCard({required this.icon, required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}
