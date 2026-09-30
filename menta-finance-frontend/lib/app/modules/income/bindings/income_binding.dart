import 'package:get/get.dart';

import '../../../core/network/api_client.dart';
import '../../projects/project_service.dart';
import '../controllers/income_controller.dart';
import '../income_service.dart';

class IncomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => IncomeService(Get.find<ApiClient>()));
    Get.lazyPut(() => ProjectService(Get.find<ApiClient>()));
    Get.lazyPut(() => IncomeController(Get.find<IncomeService>(), Get.find<ProjectService>()));
  }
}
