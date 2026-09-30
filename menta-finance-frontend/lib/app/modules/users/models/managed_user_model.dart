/// Sawa na UserResponse ya backend - hii ni AKAUNTI YA KUINGIA MFUMO
/// (SUPERADMIN/MANAGER/STAFF), tofauti na TeamMemberModel (mfanyakazi
/// wa timu ya kazi ambaye hawezi kuwa na akaunti kabisa).
class ManagedUserModel {
  final int id;
  final String fullName;
  final String email;
  final String role;
  final bool active;
  final DateTime? createdAt;

  ManagedUserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.active,
    this.createdAt,
  });

  factory ManagedUserModel.fromJson(Map<String, dynamic> j) => ManagedUserModel(
        id: j['id'] as int,
        fullName: j['fullName'] as String? ?? '',
        email: j['email'] as String? ?? '',
        role: j['role'] as String? ?? 'STAFF',
        active: j['active'] as bool? ?? true,
        createdAt: j['createdAt'] != null ? DateTime.tryParse(j['createdAt'] as String) : null,
      );
}
