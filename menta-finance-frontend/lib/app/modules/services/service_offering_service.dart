import '../../core/network/api_client.dart';
import 'models/service_offering_model.dart';

/// Sawa moja kwa moja na com.mentafinance.controller.ServiceOfferingController
/// NB: hakuna trailing slash - Spring Boot 3 haifanyi trailing-slash match
/// kwa default, "/api/services/" ingerudisha 404.
class ServiceOfferingService {
  final ApiClient _api;
  ServiceOfferingService(this._api);

  Future<List<ServiceOfferingModel>> getAllActive() async {
    final data = await _api.get('/api/services') as List;
    return data.map((e) => ServiceOfferingModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ServiceOfferingModel> create({required String name, String? description}) async {
    final data = await _api.post('/api/services', body: {
      'name': name,
      if (description != null) 'description': description,
    });
    return ServiceOfferingModel.fromJson(data as Map<String, dynamic>);
  }

  Future<ServiceOfferingModel> update(int id, {required String name, String? description}) async {
    final data = await _api.put('/api/services/$id', body: {
      'name': name,
      if (description != null) 'description': description,
    });
    return ServiceOfferingModel.fromJson(data as Map<String, dynamic>);
  }

  /// Backend "delete" ni deactivate (soft-delete) - angalia
  /// ServiceOfferingController.deactivate()
  Future<void> deactivate(int id) => _api.delete('/api/services/$id');
}
