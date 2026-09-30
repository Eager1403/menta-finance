import '../../core/network/api_client.dart';
import 'models/client_model.dart';

/// Sawa moja kwa moja na com.mentafinance.controller.ClientController
class ClientService {
  final ApiClient _api;
  ClientService(this._api);

  Future<List<ClientModel>> getAll() async {
    final data = await _api.get('/api/clients') as List;
    return data.map((e) => ClientModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ClientModel> getById(int id) async {
    final data = await _api.get('/api/clients/$id');
    return ClientModel.fromJson(data as Map<String, dynamic>);
  }

  Future<ClientDetailModel> getDetail(int id) async {
    final data = await _api.get('/api/clients/$id/detail');
    return ClientDetailModel.fromJson(data as Map<String, dynamic>);
  }

  Future<ClientModel> create({required String name, String? phone, String? email, String? address}) async {
    final data = await _api.post('/api/clients', body: {
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
    });
    return ClientModel.fromJson(data as Map<String, dynamic>);
  }

  Future<ClientModel> update(int id,
      {required String name, String? phone, String? email, String? address}) async {
    final data = await _api.put('/api/clients/$id', body: {
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
    });
    return ClientModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> delete(int id) => _api.delete('/api/clients/$id');
}
