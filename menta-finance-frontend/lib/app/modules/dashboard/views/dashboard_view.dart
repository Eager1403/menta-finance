import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/storage/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/money_fmt.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/page_header.dart';
import '../controllers/dashboard_controller.dart';
import '../models/dashboard_model.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = Get.find<StorageService>();
    final dateFmt = DateFormat('dd/MM/yyyy');

    return AppShell(
      title: 'Dashboard',
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value != null) {
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(controller.errorMessage.value!, style: const TextStyle(color: AppColors.danger)),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: controller.load, child: const Text('Jaribu tena')),
            ]),
          );
        }

        final data = controller.dashboard.value!;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: 'Karibu, ${storage.fullName.isEmpty ? storage.role : storage.fullName}',
                subtitle: 'Muhtasari wa fedha wa Menta Studio - kutegemea role yako (${data.role}).',
              ),
              const SizedBox(height: 20),
              _buildStatCards(data),
              const SizedBox(height: 26),
              if (data.hasFullFinancials) ...[
                LayoutBuilder(builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 900;
                  final left = _RecentTransactionsCard(data.recentTransactions ?? [], dateFmt: dateFmt);
                  final right = _PerformanceByServiceCard(data.performanceByService ?? []);
                  if (isNarrow) {
                    return Column(children: [left, const SizedBox(height: 16), right]);
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: left),
                      const SizedBox(width: 16),
                      Expanded(flex: 2, child: right),
                    ],
                  );
                }),
              ] else
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: EmptyStateWidget(
                    icon: Icons.lock_outline,
                    title: 'Taarifa za kina ni za SUPERADMIN/MANAGER pekee',
                    subtitle: 'Kama STAFF, unaona TU jumla ya deni la clients (Outstanding) hapo juu.',
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatCards(DashboardModel data) {
    final cards = <Widget>[
      _StatCard(
        icon: Icons.pending_actions_rounded,
        color: AppColors.warning,
        label: 'Outstanding (Deni la Clients)',
        value: formatTZS(data.totalOutstanding),
      ),
    ];
    if (data.hasFullFinancials) {
      cards.addAll([
        _StatCard(icon: Icons.attach_money, color: AppColors.success, label: 'Income Mwezi huu', value: formatTZS(data.incomeThisMonth!)),
        _StatCard(icon: Icons.money_off, color: AppColors.danger, label: 'Expenses Mwezi huu', value: formatTZS(data.expensesThisMonth!)),
        _StatCard(
          icon: Icons.trending_up,
          color: (data.netProfit ?? 0) >= 0 ? AppColors.primaryGreen : AppColors.danger,
          label: 'Net Profit',
          value: formatTZS(data.netProfit!),
        ),
      ]);
    }
    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 900;
      if (isNarrow) {
        return Wrap(spacing: 12, runSpacing: 12, children: cards.map((c) => SizedBox(width: 240, child: c)).toList());
      }
      return Row(children: [
        for (int i = 0; i < cards.length; i++) ...[
          if (i != 0) const SizedBox(width: 12),
          Expanded(child: cards[i]),
        ],
      ]);
    });
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
                  Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentTransactionsCard extends StatelessWidget {
  final List<TransactionModel> transactions;
  final DateFormat dateFmt;
  const _RecentTransactionsCard(this.transactions, {required this.dateFmt});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Transactions za Hivi Karibuni', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            if (transactions.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('Hakuna transaction bado.', style: TextStyle(color: Colors.grey)),
              )
            else
              ...transactions.map((t) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(t.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                            size: 18, color: t.isIncome ? AppColors.success : AppColors.danger),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.description ?? (t.isIncome ? 'Income' : 'Expense'),
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              if (t.date != null)
                                Text(dateFmt.format(t.date!), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ),
                        Text(formatTZS(t.amount),
                            style: TextStyle(
                                color: t.isIncome ? AppColors.success : AppColors.danger, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

class _PerformanceByServiceCard extends StatelessWidget {
  final List<ServicePerformanceModel> items;
  const _PerformanceByServiceCard(this.items);

  @override
  Widget build(BuildContext context) {
    final maxValue = items.isEmpty ? 1.0 : items.map((e) => e.totalEarned).reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Performance kwa Service', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('Hakuna data bado.', style: TextStyle(color: Colors.grey)),
              )
            else
              ...items.map((s) {
                final ratio = maxValue == 0 ? 0.0 : (s.totalEarned / maxValue).clamp(0.0, 1.0);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(child: Text(s.serviceName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                        Text(formatTZS(s.totalEarned), style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                      ]),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 8,
                          backgroundColor: AppColors.neutralGrayBg,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
