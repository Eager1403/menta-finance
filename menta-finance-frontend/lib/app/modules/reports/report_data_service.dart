import '../clients/client_service.dart';
import '../expenses/expenses_service.dart';
import '../expenses/models/expense_model.dart';
import '../income/income_service.dart';
import '../income/models/income_model.dart';
import '../invoices/invoice_service.dart';
import '../invoices/models/invoice_model.dart';
import '../projects/models/project_model.dart';
import '../projects/project_service.dart';
import 'models/report_models.dart';
import 'models/service_performance_month_model.dart';
import 'reports_service.dart';

class _ProjectFinance {
  final ProjectModel project;
  final List<IncomeModel> incomes;
  final List<ExpenseModel> expenses;
  _ProjectFinance(this.project, this.incomes, this.expenses);
}

int _cmpDate(DateTime? a, DateTime? b) {
  if (a == null && b == null) return 0;
  if (a == null) return 1;
  if (b == null) return -1;
  return a.compareTo(b);
}

/// Inakusanya data kutoka kwenye endpoints zilizopo za backend (Projects,
/// Income, Expenses, Invoices, Clients, Reports) na kuipanga kwa ajili ya
/// ripoti za PDF. Backend haina "orodha ya Income/Expenses zote" - ni kwa
/// project moja moja (GET /api/income/project/{id}) - kwa hiyo hapa
/// tunapita kwenye kila project.
class ReportDataService {
  final ProjectService _projects;
  final IncomeService _income;
  final ExpensesService _expenses;
  final InvoiceService _invoices;
  final ClientService _clients;
  final ReportsService _reports;

  ReportDataService(
    this._projects,
    this._income,
    this._expenses,
    this._invoices,
    this._clients,
    this._reports,
  );

  Future<List<_ProjectFinance>> _loadProjectFinance() async {
    final projects = await _projects.getAll();
    return Future.wait(projects.map((p) async {
      final incFuture = _income.getByProject(p.id);
      final expFuture = _expenses.getByProject(p.id);
      final inc = await incFuture;
      final exp = await expFuture;
      return _ProjectFinance(p, inc, exp);
    }));
  }

  // -------------------------------------------------------------------
  //  1) RIPOTI YA FEDHA (kwa kipindi)
  // -------------------------------------------------------------------
  Future<FinancialReportData> buildFinancial(ReportPeriod period) async {
    final data = await _loadProjectFinance();

    double totalIncome = 0;
    double totalExpense = 0;
    final services = <String, ServiceFinanceRow>{};
    final projectRows = <ProjectFinanceRow>[];
    final categories = <String, double>{};
    final incomeRows = <TransactionRow>[];
    final expenseRows = <TransactionRow>[];

    for (final pf in data) {
      final p = pf.project;
      final serviceName = p.serviceName ?? 'Bila Service';
      double pIncome = 0;
      double pExpense = 0;

      for (final i in pf.incomes) {
        if (!period.contains(i.incomeDate)) continue;
        pIncome += i.amount;
        incomeRows.add(TransactionRow(
          date: i.incomeDate,
          projectName: p.name,
          description: i.description ?? '-',
          extra: i.paymentMethod ?? '-',
          amount: i.amount,
        ));
      }

      for (final e in pf.expenses) {
        if (!period.contains(e.expenseDate)) continue;
        pExpense += e.amount;
        final rawCat = e.category;
        final cat = (rawCat == null || rawCat.trim().isEmpty) ? 'Nyingine' : rawCat.trim();
        categories[cat] = (categories[cat] ?? 0) + e.amount;
        expenseRows.add(TransactionRow(
          date: e.expenseDate,
          projectName: p.name,
          description: e.description ?? '-',
          extra: cat,
          amount: e.amount,
        ));
      }

      if (pIncome == 0 && pExpense == 0) continue;

      totalIncome += pIncome;
      totalExpense += pExpense;

      projectRows.add(ProjectFinanceRow(
        projectName: p.name,
        clientName: p.clientName ?? 'Ndani ya kampuni',
        serviceName: serviceName,
        income: pIncome,
        expense: pExpense,
      ));

      final s = services.putIfAbsent(serviceName, () => ServiceFinanceRow(serviceName));
      s.income += pIncome;
      s.expense += pExpense;
      s.projectCount += 1;
    }

    incomeRows.sort((a, b) => _cmpDate(a.date, b.date));
    expenseRows.sort((a, b) => _cmpDate(a.date, b.date));

    final byService = services.values.toList()..sort((a, b) => b.income.compareTo(a.income));
    projectRows.sort((a, b) => b.income.compareTo(a.income));
    final categoryRows = categories.entries.map((e) => CategoryRow(e.key, e.value)).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    return FinancialReportData(
      period: period,
      generatedAt: DateTime.now(),
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      byService: byService,
      byProject: projectRows,
      expenseByCategory: categoryRows,
      incomes: incomeRows,
      expenses: expenseRows,
    );
  }

  // -------------------------------------------------------------------
  //  2) UTENDAJI WA PROJECTS (muda wote)
  // -------------------------------------------------------------------
  Future<ProjectPerformanceData> buildProjectPerformance() async {
    final data = await _loadProjectFinance();

    final rows = data.map((pf) {
      final p = pf.project;
      final paid = pf.incomes.fold(0.0, (s, i) => s + i.amount);
      final exp = pf.expenses.fold(0.0, (s, e) => s + e.amount);
      return ProjectPerformanceRow(
        projectName: p.name,
        clientName: p.clientName ?? 'Ndani ya kampuni',
        serviceName: p.serviceName ?? '-',
        typeLabel: projectTypeLabel(p.projectType),
        statusLabel: projectStatusLabel(p.status),
        value: p.projectValue,
        paid: paid,
        expenses: exp,
        isInternal: p.projectType == ProjectTypeX.internal,
      );
    }).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ProjectPerformanceData(generatedAt: DateTime.now(), rows: rows);
  }

  // -------------------------------------------------------------------
  //  3) CLIENTS NA MADENI
  // -------------------------------------------------------------------
  Future<ClientsReportData> buildClients() async {
    final clients = await _clients.getAll();
    final details = await Future.wait(clients.map((c) => _clients.getDetail(c.id)));
    final invoices = await _invoices.getAll();

    final rows = <ClientReportRow>[];
    for (var i = 0; i < clients.length; i++) {
      final c = clients[i];
      final d = details[i];
      rows.add(ClientReportRow(
        name: c.name,
        phone: c.phone ?? '-',
        projectCount: d.projects.length,
        projectsValue: d.projects.fold(0.0, (s, p) => s + p.price),
        paid: d.projects.fold(0.0, (s, p) => s + p.paid),
        outstanding: d.totalOutstanding,
      ));
    }
    rows.sort((a, b) => b.outstanding.compareTo(a.outstanding));

    final unpaid = invoices
        .where((inv) => inv.balanceDue > 0 && inv.status != InvoiceStatusX.cancelled)
        .toList()
      ..sort((a, b) => _cmpDate(a.dueDate, b.dueDate));

    final unpaidRows = unpaid
        .map((inv) => UnpaidInvoiceRow(
              number: inv.invoiceNumber,
              clientName: inv.clientName ?? '-',
              projectName: inv.projectName ?? '-',
              dueDate: inv.dueDate,
              total: inv.total,
              paid: inv.amountPaid,
              balance: inv.balanceDue,
              statusLabel: invoiceStatusLabel(inv.status),
            ))
        .toList();

    return ClientsReportData(generatedAt: DateTime.now(), rows: rows, unpaidInvoices: unpaidRows);
  }

  // -------------------------------------------------------------------
  //  4) HISTORIA YA UTENDAJI WA SERVICES (kutoka kwenye snapshots)
  // -------------------------------------------------------------------
  Future<List<ServicePerformanceMonthModel>> buildServiceHistory(int monthsBack) {
    return _reports.getServicePerformance(monthsBack: monthsBack);
  }
}
