import 'package:get/get.dart';

import '../../../core/storage/storage_service.dart';
import '../controllers/settings_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SettingsController(Get.find<StorageService>()));
  }
}
