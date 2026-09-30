import 'package:get/get.dart';

import '../../../core/network/api_exception.dart';
import '../dashboard_service.dart';
import '../models/dashboard_model.dart';

class DashboardController extends GetxController {
  final DashboardService _service;
  DashboardController(this._service);

  final isLoading = true.obs;
  final errorMessage = RxnString();
  final dashboard = Rxn<DashboardModel>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      dashboard.value = await _service.getDashboard();
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Imeshindikana kupakia Dashboard.';
    } finally {
      isLoading.value = false;
    }
  }
}
