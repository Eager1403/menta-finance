import 'package:get/get.dart';

import '../../../core/network/api_exception.dart';
import '../client_service.dart';
import '../models/client_model.dart';

class ClientListController extends GetxController {
  final ClientService _service;
  ClientListController(this._service);

  final isLoading = true.obs;
  final isSaving = false.obs;
  final errorMessage = RxnString();
  final clients = <ClientModel>[].obs;
  final searchText = ''.obs;

  List<ClientModel> get filtered {
    final q = searchText.value.trim().toLowerCase();
    if (q.isEmpty) return clients;
    return clients
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            (c.phone ?? '').toLowerCase().contains(q) ||
            (c.email ?? '').toLowerCase().contains(q))
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadClients();
  }

  Future<void> loadClients() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      clients.assignAll(await _service.getAll());
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Imeshindikana kupakia Clients.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createClient({required String name, String? phone, String? email, String? address}) async {
    isSaving.value = true;
    try {
      await _service.create(name: name, phone: phone, email: email, address: address);
      await loadClients();
      return true;
    } on ApiException catch (e) {
      Get.snackbar('Hitilafu', e.message, snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> updateClient(int id,
      {required String name, String? phone, String? email, String? address}) async {
    isSaving.value = true;
    try {
      await _service.update(id, name: name, phone: phone, email: email, address: address);
      await loadClients();
      return true;
    } on ApiException catch (e) {
      Get.snackbar('Hitilafu', e.message, snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteClient(int id) async {
    try {
      await _service.delete(id);
      Get.snackbar('Imefanikiwa', 'Client amefutwa.', snackPosition: SnackPosition.BOTTOM);
      loadClients();
    } on ApiException catch (e) {
      Get.snackbar('Hitilafu', e.message, snackPosition: SnackPosition.BOTTOM);
    }
  }
}
