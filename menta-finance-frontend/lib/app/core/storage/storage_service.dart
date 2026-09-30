import 'package:get_storage/get_storage.dart';

/// Wrapper juu ya GetStorage - sehemu pekee ya app inayogusa storage moja
/// kwa moja. Moduli nyingine zote zinapitia hapa (usitumie GetStorage()
/// moja kwa moja kwingine popote).
class StorageService {
  static const _boxName = 'menta_finance_box';
  static const _keyToken = 'auth_token';
  static const _keyUser = 'auth_user';
  static const _keyThemeMode = 'theme_mode'; // 'light' | 'dark'

  final GetStorage _box = GetStorage(_boxName);

  /// Lazima iitwe mara moja kabla ya runApp() - ona main.dart
  static Future<void> init() async {
    await GetStorage.init(_boxName);
  }

  String? get token => _box.read<String>(_keyToken);

  Future<void> saveToken(String token) => _box.write(_keyToken, token);

  /// Muundo: {'fullName': ..., 'email': ..., 'role': 'SUPERADMIN'|'MANAGER'|'STAFF'}
  /// (moja kwa moja kutoka LoginResponse ya backend - angalia auth_service.dart)
  Map<String, dynamic>? get user => _box.read<Map<String, dynamic>>(_keyUser);

  Future<void> saveUser(Map<String, dynamic> user) => _box.write(_keyUser, user);

  bool get isLoggedIn => token != null && token!.isNotEmpty;

  Future<void> clearSession() async {
    await _box.remove(_keyToken);
    await _box.remove(_keyUser);
  }

  String get themeMode => _box.read<String>(_keyThemeMode) ?? 'light';
  Future<void> saveThemeMode(String mode) => _box.write(_keyThemeMode, mode);

  String get fullName => user?['fullName'] as String? ?? '';
  String get email => user?['email'] as String? ?? '';

  /// Role halisi ya mtumiaji kwenye Menta Finance - SUPERADMIN, MANAGER
  /// au STAFF (angalia entity.enums.UserRole upande wa backend). Backend
  /// ndiyo inayolinda kwa uhalisia (kupitia @PreAuthorize) - hii hapa ni
  /// kwa ajili ya kuonyesha/kuficha UI (Sidebar, vitufe) tu.
  String get role => user?['role'] as String? ?? 'STAFF';

  bool get isSuperAdmin => role == 'SUPERADMIN';
  bool get isManager => role == 'MANAGER';
  bool get isStaff => role == 'STAFF';

  /// SUPERADMIN na MANAGER wana ufikiaji mpana (Income/Expenses/Team/
  /// Users) - STAFF ana ufikiaji mdogo zaidi (angalia @PreAuthorize kwenye
  /// Controllers za backend kwa ruhusa kamili za kila role).
  bool get hasManagementAccess => isSuperAdmin || isManager;
}
