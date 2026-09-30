import 'package:get/get.dart';

import '../../../core/network/api_client.dart';
import '../../clients/client_service.dart';
import '../../expenses/expenses_service.dart';
import '../../income/income_service.dart';
import '../../invoices/invoice_service.dart';
import '../../projects/project_service.dart';
import '../controllers/reports_controller.dart';
import '../report_data_service.dart';
import '../reports_service.dart';

class ReportsBinding extends Bindings {
  @override
  void dependencies() {
    final api = Get.find<ApiClient>();
    final reportsService = ReportsService(api);
    final dataService = ReportDataService(
      ProjectService(api),
      IncomeService(api),
      ExpensesService(api),
      InvoiceService(api),
      ClientService(api),
      reportsService,
    );
    Get.lazyPut(() => ReportsController(reportsService, dataService));
  }
}
