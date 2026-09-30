import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/storage/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/money_fmt.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/data_table_card.dart';
import '../../../core/widgets/page_header.dart';
import '../../clients/client_service.dart';
import '../../clients/models/client_model.dart';
import '../../projects/project_service.dart';
import '../controllers/invoice_list_controller.dart';
import '../models/invoice_model.dart';
import '../widgets/invoice_form_dialog.dart';
import '../widgets/invoice_status_badge.dart';

class InvoiceListView extends GetView<InvoiceListController> {
  const InvoiceListView({super.key});

  bool get _canManage => Get.find<StorageService>().hasManagementAccess;

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy');

    return AppShell(
      title: 'Invoices',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(child: PageHeader(title: 'Invoices', subtitle: 'Orodha ya invoice zote za Menta Studio.')),
              ElevatedButton.icon(
                onPressed: () => _startCreateInvoice(context),
                icon: const Icon(Icons.receipt_long_outlined, size: 18),
                label: const Text('Tengeneza Invoice'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 340,
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search, size: 20),
                hintText: 'Tafuta kwa namba au jina la client',
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
                    ElevatedButton(onPressed: controller.loadInvoices, child: const Text('Jaribu tena')),
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
                        const Text('Orodha ya Invoices', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 14),
                        DataTableCard(
                          emptyIcon: Icons.receipt_long_outlined,
                          emptyTitle: 'Hakuna Invoice bado',
                          columns: const [
                            DataColumn(label: Text('Namba')),
                            DataColumn(label: Text('Client')),
                            DataColumn(label: Text('Tarehe')),
                            DataColumn(label: Text('Total')),
                            DataColumn(label: Text('Balance Due')),
                            DataColumn(label: Text('Hali')),
                            DataColumn(label: Text('Vitendo')),
                          ],
                          rows: list
                              .map((inv) => DataRow(cells: [
                                    DataCell(Text(inv.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.w600))),
                                    DataCell(Text(inv.clientName ?? '-')),
                                    DataCell(Text(inv.issueDate != null ? dateFmt.format(inv.issueDate!) : '-')),
                                    DataCell(Text(formatTZS(inv.total))),
                                    DataCell(Text(formatTZS(inv.balanceDue),
                                        style: TextStyle(
                                            color: inv.balanceDue > 0 ? AppColors.danger : AppColors.success,
                                            fontWeight: FontWeight.w700))),
                                    DataCell(InvoiceStatusBadge(inv.status)),
                                    DataCell(Row(children: [
                                      IconButton(
                                        icon: const Icon(Icons.download_outlined, size: 18, color: AppColors.primaryGreen),
                                        tooltip: 'Pakua PDF',
                                        onPressed: () => controller.downloadPdf(inv),
                                      ),
                                      if (_canManage && inv.balanceDue > 0)
                                        IconButton(
                                          icon: const Icon(Icons.payments_outlined, size: 18, color: AppColors.info),
                                          tooltip: 'Rekodi Malipo',
                                          onPressed: () => _showPaymentDialog(context, inv),
                                        ),
                                      if (_canManage)
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                                          tooltip: 'Futa',
                                          onPressed: () => _confirmDelete(context, inv),
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

  void _confirmDelete(BuildContext context, InvoiceModel inv) {
    Get.dialog(
      AlertDialog(
        title: const Text('Futa Invoice'),
        content: Text('Una uhakika unataka kufuta invoice "${inv.invoiceNumber}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Ghairi')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              Get.back();
              controller.deleteInvoice(inv.id);
            },
            child: const Text('Futa'),
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, InvoiceModel inv) {
    final amountCtrl = TextEditingController(text: inv.balanceDue.toStringAsFixed(0));
    final methodCtrl = TextEditingController();
    final refCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        title: Text('Rekodi Malipo - ${inv.invoiceNumber}'),
        content: Form(
          key: formKey,
          child: SizedBox(
            width: 420,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('Balance Due: ${formatTZS(inv.balanceDue)}', style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              TextFormField(
                controller: amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Kiasi Kilicholipwa (TZS)'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Weka kiasi';
                  if (double.tryParse(v.trim()) == null) return 'Namba si sahihi';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(controller: methodCtrl, decoration: const InputDecoration(labelText: 'Njia ya Malipo (hiari)')),
              const SizedBox(height: 12),
              TextFormField(controller: refCtrl, decoration: const InputDecoration(labelText: 'Reference No. (hiari)')),
            ]),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Ghairi')),
          ElevatedButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Get.back();
              controller.recordPayment(
                inv.id,
                amount: double.parse(amountCtrl.text.trim()),
                paymentDate: DateTime.now(),
                paymentMethod: methodCtrl.text.trim().isEmpty ? null : methodCtrl.text.trim(),
                referenceNo: refCtrl.text.trim().isEmpty ? null : refCtrl.text.trim(),
              );
            },
            child: const Text('Hifadhi Malipo'),
          ),
        ],
      ),
    );
  }

  void _startCreateInvoice(BuildContext context) async {
    List<ClientModel> clients;
    try {
      clients = await ClientService(Get.find()).getAll();
    } catch (_) {
      Get.snackbar('Hitilafu', 'Imeshindikana kupakia Clients.', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (clients.isEmpty) {
      Get.snackbar('Taarifa', 'Ongeza Client kwanza kabla ya kutengeneza Invoice.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final selectedClientId = RxnInt();
    final proceed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Chagua Client'),
        content: SizedBox(
          width: 380,
          child: Obx(() => DropdownButtonFormField<int>(
                initialValue: selectedClientId.value,
                decoration: const InputDecoration(labelText: 'Client'),
                items: clients.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: (v) => selectedClientId.value = v,
              )),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Ghairi')),
          ElevatedButton(
            onPressed: selectedClientId.value == null ? null : () => Get.back(result: true),
            child: const Text('Endelea'),
          ),
        ],
      ),
    );

    if (proceed != true || selectedClientId.value == null) return;

    List<ProjectOption> projectOptions = [];
    try {
      final projects = await ProjectService(Get.find()).getAll();
      projectOptions = projects
          .where((p) => p.clientId == selectedClientId.value)
          .map((p) => ProjectOption(p.id, p.name))
          .toList();
    } catch (_) {}

    Get.dialog(InvoiceFormDialog(
      clientId: selectedClientId.value!,
      projectOptions: projectOptions,
      onCreated: controller.loadInvoices,
    ));
  }
}
