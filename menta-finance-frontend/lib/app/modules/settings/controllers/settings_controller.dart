import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/storage/storage_service.dart';

/// Backend haina endpoint ya "update profile" wala "change password" ya
/// mtumiaji mwenyewe (angalia UserController - create/deactivate/reactivate/
/// list TU, SUPERADMIN pekee). Kwa hiyo Settings hapa inashughulikia TU
/// mambo yanayowezekana kwa uhalisia: Appearance na taarifa za akaunti
/// (soma-tu), pamoja na Logout.
class SettingsController extends GetxController {
  final StorageService storage;
  SettingsController(this.storage);

  Future<void> logout() async {
    await storage.clearSession();
    Get.offAllNamed(AppRoutes.login);
  }
}
