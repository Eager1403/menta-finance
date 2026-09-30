import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/money_fmt.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/data_table_card.dart';
import '../../../core/widgets/page_header.dart';
import '../../../core/widgets/status_badge.dart';
import '../controllers/reports_controller.dart';
import '../models/report_models.dart';

class ReportsView extends GetView<ReportsController> {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Reports',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: 'Ripoti (Reports)',
              subtitle: 'Tengeneza ripoti halisi za PDF - ziangalie mtandaoni au zipakue.',
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _ReportCard(
                  controller: controller,
                  kind: ReportKind.financial,
                  icon: Icons.account_balance_wallet_outlined,
                  color: AppColors.success,
                  title: 'Ripoti ya Fedha',
                  description:
                      'Mapato, gharama na faida kwa kipindi ulichochagua - kwa service, kwa project, gharama kwa category, na orodha kamili ya miamala.',
                  controls: _financialControls(context),
                ),
                _ReportCard(
                  controller: controller,
                  kind: ReportKind.projects,
                  icon: Icons.work_outline,
                  color: AppColors.info,
                  title: 'Utendaji wa Projects',
                  description:
                      'Projects zote: thamani, kilicholipwa, deni, gharama na faida ya kila project (muda wote).',
                ),
                _ReportCard(
                  controller: controller,
                  kind: ReportKind.clients,
                  icon: Icons.people_outline,
                  color: AppColors.warning,
                  title: 'Clients na Madeni',
                  description:
                      'Hali ya kila client (thamani, kilicholipwa, deni) pamoja na orodha ya invoices zisizolipwa kikamilifu.',
                ),
                _ReportCard(
                  controller: controller,
                  kind: ReportKind.serviceHistory,
                  icon: Icons.insert_chart_outlined,
                  color: AppColors.primaryTeal,
                  title: 'Utendaji wa Services (Kila Mwezi)',
                  description:
                      'Historia ya mapato, gharama na faida ya kila service kwa kila mwezi, kutoka kwenye kumbukumbu za mfumo.',
                  controls: _historyControls(),
                ),
              ],
            ),
            const SizedBox(height: 28),
            _SnapshotSection(controller: controller),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ---- Chaguo za kipindi (Ripoti ya Fedha) ----
  Widget _financialControls(BuildContext context) {
    return Obx(() {
      final choice = controller.periodChoice.value;
      final range = controller.customRange.value;
      String? rangeText;
      if (choice == PeriodChoice.custom && range != null) {
        rangeText = controller.resolvePeriod().label;
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          InputDecorator(
            decoration: const InputDecoration(labelText: 'Kipindi', isDense: true),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<PeriodChoice>(
                value: choice,
                isExpanded: true,
                isDense: true,
                items: PeriodChoice.values
                    .map((c) => DropdownMenuItem(value: c, child: Text(periodChoiceLabel(c))))
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  if (v == PeriodChoice.custom) {
                    _pickRange(context);
                  } else {
                    controller.periodChoice.value = v;
                  }
                },
              ),
            ),
          ),
          if (rangeText != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(rangeText, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ),
        ],
      );
    });
  }

  Future<void> _pickRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2015),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange: controller.customRange.value,
    );
    if (picked != null) {
      controller.customRange.value = picked;
      controller.periodChoice.value = PeriodChoice.custom;
    }
  }

  // ---- Chaguo za miezi (Historia ya Services) ----
  Widget _historyControls() {
    return Obx(() => InputDecorator(
          decoration: const InputDecoration(labelText: 'Miezi ya kurudi nyuma', isDense: true),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: controller.monthsBack.value,
              isExpanded: true,
              isDense: true,
              items: const [3, 6, 12, 24]
                  .map((m) => DropdownMenuItem(value: m, child: Text('Miezi $m')))
                  .toList(),
              onChanged: (v) {
                if (v != null) controller.changeMonthsBack(v);
              },
            ),
          ),
        ));
  }
}

/// Kadi moja ya ripoti: kichwa, maelezo, (hiari) chaguo, na vitufe vya
/// "Angalia" (preview kwenye tab mpya) na "Pakua PDF".
class _ReportCard extends StatelessWidget {
  final ReportsController controller;
  final ReportKind kind;
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final Widget? controls;

  const _ReportCard({
    required this.controller,
    required this.kind,
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    this.controls,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(description, style: const TextStyle(fontSize: 12.5, color: Colors.grey, height: 1.4)),
              if (controls != null) ...[
                const SizedBox(height: 14),
                controls!,
              ],
              const SizedBox(height: 16),
              Obx(() {
                final busy = controller.generating.value != null;
                final mine = controller.generating.value == kind;
                return Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: busy ? null : () => controller.generate(kind, download: false),
                        icon: mine
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.visibility_outlined, size: 18),
                        label: const Text('Angalia'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: busy ? null : () => controller.generate(kind, download: true),
                        icon: const Icon(Icons.download_outlined, size: 18),
                        label: const Text('Pakua PDF'),
                      ),
                    ),
                  ],
                );
              }),
              Obx(() => controller.generating.value == kind
                  ? const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text('Inatengeneza ripoti...', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    )
                  : const SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kumbukumbu za mfumo: picha (snapshot) ya utendaji wa kila service kwa
/// kila mwezi, zinazohifadhiwa na mfumo wenyewe. Zimewekwa hapa kwa ajili
/// ya kuzitazama/kuzitengeneza upya (regenerate) - ripoti kamili za PDF ni
/// zile zilizo juu.
class _SnapshotSection extends StatelessWidget {
  final ReportsController controller;
  const _SnapshotSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        title: const Text(
          'Kumbukumbu za Mfumo (Snapshots za Kila Mwezi)',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        subtitle: const Text(
          'Mfumo huhifadhi picha ya utendaji wa kila service kila mwezi kwa ajili ya kumbukumbu.',
          style: TextStyle(fontSize: 12.5),
        ),
        children: [
          Row(
            children: [
              const Text('Onyesha:'),
              const SizedBox(width: 10),
              Obx(() => DropdownButton<int>(
                    value: controller.monthsBack.value,
                    items: const [3, 6, 12, 24]
                        .map((m) => DropdownMenuItem(value: m, child: Text('Miezi $m nyuma')))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) controller.changeMonthsBack(v);
                    },
                  )),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () => _showRegenerateDialog(),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Regenerate Mwezi'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (controller.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (controller.errorMessage.value != null) {
              return Padding(
                padding: const EdgeInsets.all(12),
                child: Text(controller.errorMessage.value!, style: const TextStyle(color: AppColors.danger)),
              );
            }
            return DataTableCard(
              emptyIcon: Icons.insert_chart_outlined,
              emptyTitle: 'Hakuna kumbukumbu bado',
              columns: const [
                DataColumn(label: Text('Service')),
                DataColumn(label: Text('Mwezi')),
                DataColumn(label: Text('Income')),
                DataColumn(label: Text('Expense')),
                DataColumn(label: Text('Net Profit')),
                DataColumn(label: Text('Projects')),
                DataColumn(label: Text('Clients')),
                DataColumn(label: Text('Hali')),
              ],
              rows: controller.rows
                  .map((r) => DataRow(cells: [
                        DataCell(Text(r.serviceName, style: const TextStyle(fontWeight: FontWeight.w600))),
                        DataCell(Text(r.yearMonth != null ? monthLabelSw(r.yearMonth!) : '-')),
                        DataCell(Text(formatTZS(r.totalIncome), style: const TextStyle(color: AppColors.success))),
                        DataCell(Text(formatTZS(r.totalExpense), style: const TextStyle(color: AppColors.danger))),
                        DataCell(Text(formatTZS(r.netProfit),
                            style: TextStyle(
                                color: r.netProfit >= 0 ? AppColors.primaryGreen : AppColors.danger,
                                fontWeight: FontWeight.w700))),
                        DataCell(Text('${r.projectCount}')),
                        DataCell(Text('${r.clientCount}')),
                        DataCell(StatusBadge(r.isLive ? 'Mwezi wa Sasa' : 'Snapshot',
                            color: r.isLive ? AppColors.info : AppColors.neutralGray)),
                      ]))
                  .toList(),
            );
          }),
        ],
      ),
    );
  }

  void _showRegenerateDialog() {
    final monthCtrl = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('Regenerate Snapshot ya Mwezi'),
        content: SizedBox(
          width: 360,
          child: TextField(
            controller: monthCtrl,
            decoration: const InputDecoration(labelText: 'Mwezi (mfano 2026-08)'),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Ghairi')),
          ElevatedButton(
            onPressed: () {
              final m = monthCtrl.text.trim();
              if (m.isEmpty) return;
              Get.back();
              controller.regenerate(m);
            },
            child: const Text('Regenerate'),
          ),
        ],
      ),
    );
  }
}
