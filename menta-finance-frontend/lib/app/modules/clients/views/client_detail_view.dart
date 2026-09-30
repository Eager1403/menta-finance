import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/money_fmt.dart';
import '../../../core/utils/web_download.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/data_table_card.dart';
import '../../../core/widgets/page_header.dart';
import '../../invoices/invoice_service.dart';
import '../../invoices/widgets/invoice_form_dialog.dart';
import '../../invoices/widgets/invoice_status_badge.dart';
import '../controllers/client_detail_controller.dart';

class ClientDetailView extends GetView<ClientDetailController> {
  const ClientDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy');

    return AppShell(
      title: 'Taarifa za Client',
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value != null) {
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(controller.errorMessage.value!, style: const TextStyle(color: AppColors.danger)),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: controller.loadDetail, child: const Text('Jaribu tena')),
            ]),
          );
        }

        final detail = controller.detail.value!;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: PageHeader(
                      title: detail.clientName,
                      subtitle: 'Taarifa kamili za client huyu - projects na invoices zake.',
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Rudi Clients'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LayoutBuilder(builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 720;
                final cards = [
                  _SummaryCard(
                    icon: Icons.pending_actions_rounded,
                    color: AppColors.warning,
                    label: 'Outstanding (Deni)',
                    value: formatTZS(detail.totalOutstanding),
                  ),
                  _SummaryCard(
                    icon: Icons.work_outline,
                    color: AppColors.primaryTeal,
                    label: 'Idadi ya Projects',
                    value: '${detail.projects.length}',
                  ),
                ];
                return isNarrow
                    ? Column(children: [cards[0], const SizedBox(height: 12), cards[1]])
                    : Row(children: [
                        Expanded(child: cards[0]),
                        const SizedBox(width: 14),
                        Expanded(child: cards[1]),
                      ]);
              }),
              const SizedBox(height: 20),
              const Text('Projects za Client huyu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              DataTableCard(
                emptyIcon: Icons.work_outline,
                emptyTitle: 'Client huyu hana Project bado',
                columns: const [
                  DataColumn(label: Text('Project')),
                  DataColumn(label: Text('Thamani (Price)')),
                  DataColumn(label: Text('Kilicholipwa')),
                  DataColumn(label: Text('Outstanding')),
                ],
                rows: detail.projects
                    .map((p) => DataRow(cells: [
                          DataCell(Text(p.projectName, style: const TextStyle(fontWeight: FontWeight.w600))),
                          DataCell(Text(formatTZS(p.price))),
                          DataCell(Text(formatTZS(p.paid), style: const TextStyle(color: AppColors.success))),
                          DataCell(Text(formatTZS(p.outstanding),
                              style: TextStyle(
                                  color: p.outstanding > 0 ? AppColors.danger : AppColors.success,
                                  fontWeight: FontWeight.w700))),
                        ]))
                    .toList(),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(
                    child: Text('Invoices za Client huyu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Get.dialog(InvoiceFormDialog(
                      clientId: detail.clientId,
                      projectOptions: detail.projects
                          .map((p) => ProjectOption(p.projectId, p.projectName))
                          .toList(),
                      onCreated: controller.refreshAll,
                    )),
                    icon: const Icon(Icons.receipt_long_outlined, size: 18),
                    label: const Text('Tengeneza Invoice'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Obx(() {
                if (controller.isLoadingInvoices.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return DataTableCard(
                  emptyIcon: Icons.receipt_long_outlined,
                  emptyTitle: 'Hakuna Invoice bado',
                  columns: const [
                    DataColumn(label: Text('Namba')),
                    DataColumn(label: Text('Tarehe')),
                    DataColumn(label: Text('Jumla (Total)')),
                    DataColumn(label: Text('Balance Due')),
                    DataColumn(label: Text('Hali')),
                    DataColumn(label: Text('Vitendo')),
                  ],
                  rows: controller.invoices
                      .map((inv) => DataRow(cells: [
                            DataCell(Text(inv.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.w600))),
                            DataCell(Text(inv.issueDate != null ? dateFmt.format(inv.issueDate!) : '-')),
                            DataCell(Text(formatTZS(inv.total))),
                            DataCell(Text(formatTZS(inv.balanceDue),
                                style: TextStyle(
                                    color: inv.balanceDue > 0 ? AppColors.danger : AppColors.success,
                                    fontWeight: FontWeight.w700))),
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
                );
              }),
            ],
          ),
        );
      }),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  const _SummaryCard({required this.icon, required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(13)),
              alignment: Alignment.center,
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 3),
                  Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
