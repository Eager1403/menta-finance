import 'package:get/get.dart';

import '../../../core/network/api_client.dart';
import '../controllers/team_controller.dart';
import '../team_service.dart';

class TeamBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TeamService(Get.find<ApiClient>()));
    Get.lazyPut(() => TeamController(Get.find<TeamService>()));
  }
}
