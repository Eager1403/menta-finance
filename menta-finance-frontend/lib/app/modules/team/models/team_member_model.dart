/// Sawa na TeamMemberResponse ya backend
class TeamMemberModel {
  final int id;
  final String fullName;
  final String? position;
  final String? phone;
  final String? email;
  final DateTime? joinedDate;
  final bool active;

  TeamMemberModel({
    required this.id,
    required this.fullName,
    this.position,
    this.phone,
    this.email,
    this.joinedDate,
    this.active = true,
  });

  factory TeamMemberModel.fromJson(Map<String, dynamic> j) => TeamMemberModel(
        id: j['id'] as int,
        fullName: j['fullName'] as String? ?? '',
        position: j['position'] as String?,
        phone: j['phone'] as String?,
        email: j['email'] as String?,
        joinedDate: j['joinedDate'] != null ? DateTime.tryParse(j['joinedDate'] as String) : null,
        active: j['active'] as bool? ?? true,
      );
}
