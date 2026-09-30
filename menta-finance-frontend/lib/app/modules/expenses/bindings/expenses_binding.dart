import 'package:get/get.dart';

import '../../../core/network/api_client.dart';
import '../../projects/project_service.dart';
import '../controllers/expenses_controller.dart';
import '../expenses_service.dart';

class ExpensesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ExpensesService(Get.find<ApiClient>()));
    Get.lazyPut(() => ProjectService(Get.find<ApiClient>()));
    Get.lazyPut(() => ExpensesController(Get.find<ExpensesService>(), Get.find<ProjectService>()));
  }
}
