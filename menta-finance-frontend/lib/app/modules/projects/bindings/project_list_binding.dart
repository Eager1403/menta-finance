import 'package:get/get.dart';

import '../../../core/network/api_client.dart';
import '../../clients/client_service.dart';
import '../../services/service_offering_service.dart';
import '../controllers/project_list_controller.dart';
import '../project_service.dart';

class ProjectListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProjectService(Get.find<ApiClient>()));
    Get.lazyPut(() => ClientService(Get.find<ApiClient>()));
    Get.lazyPut(() => ServiceOfferingService(Get.find<ApiClient>()));
    Get.lazyPut(() => ProjectListController(
          Get.find<ProjectService>(),
          Get.find<ClientService>(),
          Get.find<ServiceOfferingService>(),
        ));
  }
}
