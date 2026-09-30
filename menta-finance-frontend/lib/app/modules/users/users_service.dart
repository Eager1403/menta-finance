import '../../core/network/api_client.dart';
import 'models/managed_user_model.dart';

/// Sawa moja kwa moja na com.mentafinance.controller.UserController
/// (SUPERADMIN pekee kwenye moduli hii YOTE). Backend haina update wala
/// delete wala change-password - kuna TU create/deactivate/reactivate/list.
class UsersService {
  final ApiClient _api;
  UsersService(this._api);

  Future<List<ManagedUserModel>> getAll() async {
    final data = await _api.get('/api/users') as List;
    return data.map((e) => ManagedUserModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ManagedUserModel> create({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    final data = await _api.post('/api/users', body: {
      'fullName': fullName,
      'email': email,
      'password': password,
      'role': role,
    });
    return ManagedUserModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deactivate(int id) => _api.put('/api/users/$id/deactivate');
  Future<void> reactivate(int id) => _api.put('/api/users/$id/reactivate');
}
