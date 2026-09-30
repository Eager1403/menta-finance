import '../../core/network/api_client.dart';
import 'models/user_model.dart';

class AuthService {
  final ApiClient _api;
  AuthService(this._api);

  /// POST /api/auth/login - {email, password} -> LoginResponse
  /// (angalia com.mentafinance.controller.AuthController)
  Future<({String token, UserModel user})> login({
    required String email,
    required String password,
  }) async {
    final data = await _api.post(
      '/api/auth/login',
      body: {'email': email, 'password': password},
      auth: false,
    ) as Map<String, dynamic>;
    final token = data['token'] as String;
    final user = UserModel.fromJson(data);
    return (token: token, user: user);
  }
}
