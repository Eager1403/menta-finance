import '../../core/network/api_client.dart';
import 'models/team_member_model.dart';

/// Sawa moja kwa moja na com.mentafinance.controller.TeamMemberController
class TeamService {
  final ApiClient _api;
  TeamService(this._api);

  String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<List<TeamMemberModel>> getAllActive() async {
    final data = await _api.get('/api/team') as List;
    return data.map((e) => TeamMemberModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<TeamMemberModel> add({
    required String fullName,
    String? position,
    String? phone,
    String? email,
    DateTime? joinedDate,
  }) async {
    final data = await _api.post('/api/team', body: {
      'fullName': fullName,
      if (position != null) 'position': position,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (joinedDate != null) 'joinedDate': _isoDate(joinedDate),
    });
    return TeamMemberModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> remove(int id) => _api.delete('/api/team/$id');
}
