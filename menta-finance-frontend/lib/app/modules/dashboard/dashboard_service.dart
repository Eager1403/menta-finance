import '../../core/network/api_client.dart';
import 'models/dashboard_model.dart';

/// Sawa moja kwa moja na com.mentafinance.controller.DashboardController -
/// endpoint MOJA TU (GET /api/dashboard), siyo /summary na /charts.
class DashboardService {
  final ApiClient _api;
  DashboardService(this._api);

  Future<DashboardModel> getDashboard() async {
    final data = await _api.get('/api/dashboard');
    return DashboardModel.fromJson(data as Map<String, dynamic>);
  }
}
