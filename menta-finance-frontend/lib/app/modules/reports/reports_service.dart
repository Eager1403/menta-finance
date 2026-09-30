import '../../core/network/api_client.dart';
import 'models/service_performance_month_model.dart';

/// Sawa moja kwa moja na com.mentafinance.controller.ReportController
/// (SUPERADMIN pekee - hasRole('SUPERADMIN'))
class ReportsService {
  final ApiClient _api;
  ReportsService(this._api);

  Future<List<ServicePerformanceMonthModel>> getServicePerformance({int monthsBack = 6}) async {
    final data = await _api.get('/api/reports/service-performance', query: {'monthsBack': monthsBack}) as List;
    return data.map((e) => ServicePerformanceMonthModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// month: "2026-08"
  Future<void> regenerateSnapshot(String month) =>
      _api.post('/api/reports/service-performance/regenerate', query: {'month': month});
}
