import 'package:get/get.dart';

import '../../../core/network/api_exception.dart';
import '../models/service_offering_model.dart';
import '../service_offering_service.dart';

class ServicesController extends GetxController {
  final ServiceOfferingService _service;
  ServicesController(this._service);

  final isLoading = true.obs;
  final isSaving = false.obs;
  final errorMessage = RxnString();
  final services = <ServiceOfferingModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadServices();
  }

  Future<void> loadServices() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      services.assignAll(await _service.getAllActive());
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Imeshindikana kupakia Services.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addService({required String name, String? description}) async {
    isSaving.value = true;
    try {
      await _service.create(name: name, description: description);
      await loadServices();
      return true;
    } on ApiException catch (e) {
      Get.snackbar('Hitilafu', e.message, snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deactivateService(int id) async {
    try {
      await _service.deactivate(id);
      Get.snackbar('Imefanikiwa', 'Service imezimwa.', snackPosition: SnackPosition.BOTTOM);
      loadServices();
    } on ApiException catch (e) {
      Get.snackbar('Hitilafu', e.message, snackPosition: SnackPosition.BOTTOM);
    }
  }
}
