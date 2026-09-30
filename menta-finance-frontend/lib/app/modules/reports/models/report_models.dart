/// Aina za ripoti za PDF zinazopatikana kwenye ukurasa wa Reports.
enum ReportKind { financial, projects, clients, serviceHistory }

/// Chaguo za kipindi kwa Ripoti ya Fedha.
enum PeriodChoice { thisMonth, lastMonth, last3Months, thisYear, allTime, custom }

String periodChoiceLabel(PeriodChoice c) {
  switch (c) {
    case PeriodChoice.thisMonth:
      return 'Mwezi huu';
    case PeriodChoice.lastMonth:
      return 'Mwezi uliopita';
    case PeriodChoice.last3Months:
      return 'Miezi 3 iliyopita';
    case PeriodChoice.thisYear:
      return 'Mwaka huu';
    case PeriodChoice.allTime:
      return 'Muda wote';
    case PeriodChoice.custom:
      return 'Chagua tarehe...';
  }
}

const _swMonths = [
  'Januari',
  'Februari',
  'Machi',
  'Aprili',
  'Mei',
  'Juni',
  'Julai',
  'Agosti',
  'Septemba',
  'Oktoba',
  'Novemba',
  'Desemba',
];

/// Mfano: "Septemba 2026"
String monthLabelSw(DateTime d) => '${_swMonths[d.month - 1]} ${d.year}';

/// Kipindi cha ripoti. Kama 'start' na 'end' zote ni null = muda wote.
class ReportPeriod {
  final String label;
  final DateTime? start;
  final DateTime? end;

  const ReportPeriod({required this.label, this.start, this.end});

  bool get isAllTime => start == null && end == null;

  /// Je, tarehe hii iko ndani ya kipindi (pamoja na siku ya kwanza na ya mwisho)?
  bool contains(DateTime? date) {
    final s = start;
    final e = end;
    if (s == null && e == null) return true;
    if (date == null) return false;
    final d = DateTime(date.year, date.month, date.day);
    if (s != null && d.isBefore(DateTime(s.year, s.month, s.day))) return false;
    if (e != null && d.isAfter(DateTime(e.year, e.month, e.day))) return false;
    return true;
  }
}

// ---------------------------------------------------------------------
//  RIPOTI YA FEDHA
// ---------------------------------------------------------------------

class ServiceFinanceRow {
  final String serviceName;
  double income = 0;
  double expense = 0;
  int projectCount = 0;

  ServiceFinanceRow(this.serviceName);

  double get net => income - expense;
}

class ProjectFinanceRow {
  final String projectName;
  final String clientName;
  final String serviceName;
  final double income;
  final double expense;

  const ProjectFinanceRow({
    required this.projectName,
    required this.clientName,
    required this.serviceName,
    required this.income,
    required this.expense,
  });

  double get net => income - expense;
}

class TransactionRow {
  final DateTime? date;
  final String projectName;
  final String description;

  /// Njia ya malipo (kwa Income) au Category (kwa Expense)
  final String extra;
  final double amount;

  const TransactionRow({
    required this.date,
    required this.projectName,
    required this.description,
    required this.extra,
    required this.amount,
  });
}

class CategoryRow {
  final String category;
  final double amount;
  const CategoryRow(this.category, this.amount);
}

class FinancialReportData {
  final ReportPeriod period;
  final DateTime generatedAt;
  final double totalIncome;
  final double totalExpense;
  final List<ServiceFinanceRow> byService;
  final List<ProjectFinanceRow> byProject;
  final List<CategoryRow> expenseByCategory;
  final List<TransactionRow> incomes;
  final List<TransactionRow> expenses;

  const FinancialReportData({
    required this.period,
    required this.generatedAt,
    required this.totalIncome,
    required this.totalExpense,
    required this.byService,
    required this.byProject,
    required this.expenseByCategory,
    required this.incomes,
    required this.expenses,
  });

  double get netProfit => totalIncome - totalExpense;
}

// ---------------------------------------------------------------------
//  RIPOTI YA UTENDAJI WA PROJECTS
// ---------------------------------------------------------------------

class ProjectPerformanceRow {
  final String projectName;
  final String clientName;
  final String serviceName;
  final String typeLabel;
  final String statusLabel;
  final double value;
  final double paid;
  final double expenses;
  final bool isInternal;

  const ProjectPerformanceRow({
    required this.projectName,
    required this.clientName,
    required this.serviceName,
    required this.typeLabel,
    required this.statusLabel,
    required this.value,
    required this.paid,
    required this.expenses,
    required this.isInternal,
  });

  /// Deni: thamani ya project - kilicholipwa (haihusu project za ndani)
  double get outstanding {
    if (isInternal) return 0;
    final v = value - paid;
    return v > 0 ? v : 0;
  }

  double get net => paid - expenses;
}

class ProjectPerformanceData {
  final DateTime generatedAt;
  final List<ProjectPerformanceRow> rows;

  const ProjectPerformanceData({required this.generatedAt, required this.rows});

  double get totalValue => rows.fold(0.0, (s, r) => s + r.value);
  double get totalPaid => rows.fold(0.0, (s, r) => s + r.paid);
  double get totalExpenses => rows.fold(0.0, (s, r) => s + r.expenses);
  double get totalOutstanding => rows.fold(0.0, (s, r) => s + r.outstanding);
  double get totalNet => totalPaid - totalExpenses;
}

// ---------------------------------------------------------------------
//  RIPOTI YA CLIENTS NA MADENI (OUTSTANDING)
// ---------------------------------------------------------------------

class ClientReportRow {
  final String name;
  final String phone;
  final int projectCount;
  final double projectsValue;
  final double paid;
  final double outstanding;

  const ClientReportRow({
    required this.name,
    required this.phone,
    required this.projectCount,
    required this.projectsValue,
    required this.paid,
    required this.outstanding,
  });
}

class UnpaidInvoiceRow {
  final String number;
  final String clientName;
  final String projectName;
  final DateTime? dueDate;
  final double total;
  final double paid;
  final double balance;
  final String statusLabel;

  const UnpaidInvoiceRow({
    required this.number,
    required this.clientName,
    required this.projectName,
    required this.dueDate,
    required this.total,
    required this.paid,
    required this.balance,
    required this.statusLabel,
  });
}

class ClientsReportData {
  final DateTime generatedAt;
  final List<ClientReportRow> rows;
  final List<UnpaidInvoiceRow> unpaidInvoices;

  const ClientsReportData({
    required this.generatedAt,
    required this.rows,
    required this.unpaidInvoices,
  });

  double get totalValue => rows.fold(0.0, (s, r) => s + r.projectsValue);
  double get totalPaid => rows.fold(0.0, (s, r) => s + r.paid);
  double get totalOutstanding => rows.fold(0.0, (s, r) => s + r.outstanding);
  double get totalInvoiceBalance => unpaidInvoices.fold(0.0, (s, r) => s + r.balance);
}
