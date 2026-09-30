/// Muundo huu unafanana HASA na LoginResponse ya backend (angalia
/// com.mentafinance.dto.response.LoginResponse):
///   { "token": "...", "fullName": "...", "email": "...", "role": "SUPERADMIN"|"MANAGER"|"STAFF" }
class UserModel {
  final String fullName;
  final String email;
  final String role;

  UserModel({required this.fullName, required this.email, required this.role});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'STAFF',
    );
  }

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'email': email,
        'role': role,
      };
}
