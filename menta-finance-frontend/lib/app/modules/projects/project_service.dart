import '../../core/network/api_client.dart';
import 'models/project_model.dart';

/// Sawa moja kwa moja na com.mentafinance.controller.ProjectController
class ProjectService {
  final ApiClient _api;
  ProjectService(this._api);

  String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<List<ProjectModel>> getAll() async {
    final data = await _api.get('/api/projects') as List;
    return data.map((e) => ProjectModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ProjectModel> getById(int id) async {
    final data = await _api.get('/api/projects/$id');
    return ProjectModel.fromJson(data as Map<String, dynamic>);
  }

  Future<ProjectModel> create({
    required String name,
    int? clientId,
    int? serviceId,
    required ProjectTypeX projectType,
    required double projectValue,
    ProjectStatusX? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final data = await _api.post('/api/projects', body: {
      'name': name,
      if (clientId != null) 'clientId': clientId,
      if (serviceId != null) 'serviceId': serviceId,
      'projectType': projectTypeToString(projectType),
      'projectValue': projectValue,
      if (status != null) 'status': projectStatusToString(status),
      if (startDate != null) 'startDate': _isoDate(startDate),
      if (endDate != null) 'endDate': _isoDate(endDate),
    });
    return ProjectModel.fromJson(data as Map<String, dynamic>);
  }

  Future<ProjectModel> update(
    int id, {
    required String name,
    int? clientId,
    int? serviceId,
    required ProjectTypeX projectType,
    required double projectValue,
    ProjectStatusX? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final data = await _api.put('/api/projects/$id', body: {
      'name': name,
      if (clientId != null) 'clientId': clientId,
      if (serviceId != null) 'serviceId': serviceId,
      'projectType': projectTypeToString(projectType),
      'projectValue': projectValue,
      if (status != null) 'status': projectStatusToString(status),
      if (startDate != null) 'startDate': _isoDate(startDate),
      if (endDate != null) 'endDate': _isoDate(endDate),
    });
    return ProjectModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> delete(int id) => _api.delete('/api/projects/$id');
}
