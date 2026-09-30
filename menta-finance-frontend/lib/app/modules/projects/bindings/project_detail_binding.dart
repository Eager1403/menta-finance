import 'package:get/get.dart';

import '../../../core/network/api_client.dart';
import '../../expenses/expenses_service.dart';
import '../../income/income_service.dart';
import '../../invoices/invoice_service.dart';
import '../controllers/project_detail_controller.dart';
import '../project_service.dart';

class ProjectDetailBinding extends Bindings {
  @override
  void dependencies() {
    final projectId = Get.arguments as int;
    Get.lazyPut(() => ProjectService(Get.find<ApiClient>()));
    Get.lazyPut(() => IncomeService(Get.find<ApiClient>()));
    Get.lazyPut(() => ExpensesService(Get.find<ApiClient>()));
    Get.lazyPut(() => InvoiceService(Get.find<ApiClient>()));
    Get.lazyPut(() => ProjectDetailController(
          Get.find<ProjectService>(),
          Get.find<IncomeService>(),
          Get.find<ExpensesService>(),
          Get.find<InvoiceService>(),
          projectId: projectId,
        ));
  }
}
