import 'package:get/get.dart';

import '../../../core/network/api_client.dart';
import '../client_service.dart';
import '../controllers/client_list_controller.dart';

class ClientListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ClientService(Get.find<ApiClient>()));
    Get.lazyPut(() => ClientListController(Get.find<ClientService>()));
  }
}
