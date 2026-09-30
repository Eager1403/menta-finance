/// Sawa na TransactionResponse - row moja ya "Transactions za hivi karibuni"
class TransactionModel {
  final String type; // "INCOME" au "EXPENSE"
  final DateTime? date;
  final String? description;
  final double amount;

  TransactionModel({required this.type, this.date, this.description, required this.amount});

  factory TransactionModel.fromJson(Map<String, dynamic> j) => TransactionModel(
        type: j['type'] as String? ?? 'INCOME',
        date: j['date'] != null ? DateTime.tryParse(j['date'] as String) : null,
        description: j['description'] as String?,
        amount: double.tryParse(j['amount'].toString()) ?? 0,
      );

  bool get isIncome => type == 'INCOME';
}

/// Sawa na ServicePerformanceResponse - performance kwa kila Service
class ServicePerformanceModel {
  final int serviceId;
  final String serviceName;
  final double totalEarned;

  ServicePerformanceModel({required this.serviceId, required this.serviceName, required this.totalEarned});

  factory ServicePerformanceModel.fromJson(Map<String, dynamic> j) => ServicePerformanceModel(
        serviceId: j['serviceId'] as int,
        serviceName: j['serviceName'] as String? ?? '',
        totalEarned: double.tryParse(j['totalEarned'].toString()) ?? 0,
      );
}

/// Sawa MOJA KWA MOJA na DashboardResponse ya backend - endpoint MOJA
/// (GET /api/dashboard) inayorudisha fields tofauti kutegemea role:
///   - STAFF: totalOutstanding TU (fields nyingine zote null)
///   - SUPERADMIN/MANAGER: fields ZOTE zimejazwa
class DashboardModel {
  final String role;
  final double? incomeThisMonth;
  final double? expensesThisMonth;
  final double? netProfit;
  final double totalOutstanding;
  final List<TransactionModel>? recentTransactions;
  final List<ServicePerformanceModel>? performanceByService;

  DashboardModel({
    required this.role,
    this.incomeThisMonth,
    this.expensesThisMonth,
    this.netProfit,
    required this.totalOutstanding,
    this.recentTransactions,
    this.performanceByService,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> j) => DashboardModel(
        role: j['role'] as String? ?? 'STAFF',
        incomeThisMonth: j['incomeThisMonth'] != null ? double.tryParse(j['incomeThisMonth'].toString()) : null,
        expensesThisMonth: j['expensesThisMonth'] != null ? double.tryParse(j['expensesThisMonth'].toString()) : null,
        netProfit: j['netProfit'] != null ? double.tryParse(j['netProfit'].toString()) : null,
        totalOutstanding: double.tryParse(j['totalOutstanding'].toString()) ?? 0,
        recentTransactions: j['recentTransactions'] != null
            ? (j['recentTransactions'] as List).map((e) => TransactionModel.fromJson(e as Map<String, dynamic>)).toList()
            : null,
        performanceByService: j['performanceByService'] != null
            ? (j['performanceByService'] as List)
                .map((e) => ServicePerformanceModel.fromJson(e as Map<String, dynamic>))
                .toList()
            : null,
      );

  /// STAFF hupata TU totalOutstanding - fields nyingine zote null.
  bool get hasFullFinancials => incomeThisMonth != null;
}
