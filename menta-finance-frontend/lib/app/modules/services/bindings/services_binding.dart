import 'package:get/get.dart';

import '../../../core/network/api_client.dart';
import '../controllers/services_controller.dart';
import '../service_offering_service.dart';

class ServicesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ServiceOfferingService(Get.find<ApiClient>()));
    Get.lazyPut(() => ServicesController(Get.find<ServiceOfferingService>()));
  }
}
