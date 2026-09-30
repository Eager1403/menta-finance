import '../../core/network/api_client.dart';
import 'models/expense_model.dart';

/// Sawa moja kwa moja na com.mentafinance.controller.ExpenseController.
/// MUHIMU: hakuna "orodha ya Expenses zote" - backend inatoa TU
/// GET /api/expenses/project/{projectId}.
class ExpensesService {
  final ApiClient _api;
  ExpensesService(this._api);

  String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<List<ExpenseModel>> getByProject(int projectId) async {
    final data = await _api.get('/api/expenses/project/$projectId') as List;
    return data.map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ExpenseModel> create({
    required int projectId,
    String? description,
    required double amount,
    DateTime? expenseDate,
    String? category,
  }) async {
    final data = await _api.post('/api/expenses', body: {
      'projectId': projectId,
      if (description != null) 'description': description,
      'amount': amount,
      if (expenseDate != null) 'expenseDate': _isoDate(expenseDate),
      if (category != null) 'category': category,
    });
    return ExpenseModel.fromJson(data as Map<String, dynamic>);
  }

  Future<ExpenseModel> update(
    int id, {
    required int projectId,
    String? description,
    required double amount,
    DateTime? expenseDate,
    String? category,
  }) async {
    final data = await _api.put('/api/expenses/$id', body: {
      'projectId': projectId,
      if (description != null) 'description': description,
      'amount': amount,
      if (expenseDate != null) 'expenseDate': _isoDate(expenseDate),
      if (category != null) 'category': category,
    });
    return ExpenseModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> delete(int id) => _api.delete('/api/expenses/$id');
}
