import 'package:get/get.dart';

import '../../../core/network/api_client.dart';
import '../../clients/client_service.dart';
import '../../projects/project_service.dart';
import '../controllers/invoice_list_controller.dart';
import '../invoice_service.dart';

class InvoiceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => InvoiceService(Get.find<ApiClient>()));
    Get.lazyPut(() => ClientService(Get.find<ApiClient>()));
    Get.lazyPut(() => ProjectService(Get.find<ApiClient>()));
    Get.lazyPut(() => InvoiceListController(Get.find<InvoiceService>()));
  }
}
