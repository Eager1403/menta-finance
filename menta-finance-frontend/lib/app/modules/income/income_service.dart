import '../../core/network/api_client.dart';
import 'models/income_model.dart';

/// Sawa moja kwa moja na com.mentafinance.controller.IncomeController.
/// MUHIMU: hakuna "orodha ya Income zote" - backend inatoa TU
/// GET /api/income/project/{projectId}.
class IncomeService {
  final ApiClient _api;
  IncomeService(this._api);

  String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<List<IncomeModel>> getByProject(int projectId) async {
    final data = await _api.get('/api/income/project/$projectId') as List;
    return data.map((e) => IncomeModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<IncomeModel> create({
    required int projectId,
    String? description,
    required double amount,
    DateTime? incomeDate,
    String? paymentMethod,
  }) async {
    final data = await _api.post('/api/income', body: {
      'projectId': projectId,
      if (description != null) 'description': description,
      'amount': amount,
      if (incomeDate != null) 'incomeDate': _isoDate(incomeDate),
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
    });
    return IncomeModel.fromJson(data as Map<String, dynamic>);
  }

  Future<IncomeModel> update(
    int id, {
    required int projectId,
    String? description,
    required double amount,
    DateTime? incomeDate,
    String? paymentMethod,
  }) async {
    final data = await _api.put('/api/income/$id', body: {
      'projectId': projectId,
      if (description != null) 'description': description,
      'amount': amount,
      if (incomeDate != null) 'incomeDate': _isoDate(incomeDate),
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
    });
    return IncomeModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> delete(int id) => _api.delete('/api/income/$id');
}
