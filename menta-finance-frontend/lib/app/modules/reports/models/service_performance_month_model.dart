/// Sawa na ServicePerformanceMonthResponse ya backend
class ServicePerformanceMonthModel {
  final int serviceId;
  final String serviceName;
  final DateTime? yearMonth;
  final double totalIncome;
  final double totalExpense;
  final double netProfit;
  final int projectCount;
  final int clientCount;
  final double avgProjectValue;
  final bool isLive;

  ServicePerformanceMonthModel({
    required this.serviceId,
    required this.serviceName,
    this.yearMonth,
    required this.totalIncome,
    required this.totalExpense,
    required this.netProfit,
    required this.projectCount,
    required this.clientCount,
    required this.avgProjectValue,
    required this.isLive,
  });

  factory ServicePerformanceMonthModel.fromJson(Map<String, dynamic> j) => ServicePerformanceMonthModel(
        serviceId: j['serviceId'] as int,
        serviceName: j['serviceName'] as String? ?? '',
        yearMonth: j['yearMonth'] != null ? DateTime.tryParse(j['yearMonth'] as String) : null,
        totalIncome: double.tryParse(j['totalIncome'].toString()) ?? 0,
        totalExpense: double.tryParse(j['totalExpense'].toString()) ?? 0,
        netProfit: double.tryParse(j['netProfit'].toString()) ?? 0,
        projectCount: j['projectCount'] as int? ?? 0,
        clientCount: j['clientCount'] as int? ?? 0,
        avgProjectValue: double.tryParse(j['avgProjectValue'].toString()) ?? 0,
        isLive: j['isLive'] as bool? ?? false,
      );
}
