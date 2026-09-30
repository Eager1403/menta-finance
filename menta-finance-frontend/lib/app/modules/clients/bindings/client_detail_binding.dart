import 'package:get/get.dart';

import '../../../core/network/api_client.dart';
import '../../invoices/invoice_service.dart';
import '../client_service.dart';
import '../controllers/client_detail_controller.dart';

class ClientDetailBinding extends Bindings {
  @override
  void dependencies() {
    final clientId = Get.arguments as int;
    Get.lazyPut(() => ClientService(Get.find<ApiClient>()));
    Get.lazyPut(() => InvoiceService(Get.find<ApiClient>()));
    Get.lazyPut(() => ClientDetailController(
          Get.find<ClientService>(),
          Get.find<InvoiceService>(),
          clientId: clientId,
        ));
  }
}
