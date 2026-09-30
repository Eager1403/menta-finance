import 'package:get/get.dart';

import '../../../core/network/api_exception.dart';
import '../models/managed_user_model.dart';
import '../users_service.dart';

class UsersController extends GetxController {
  final UsersService _service;
  UsersController(this._service);

  final isLoading = true.obs;
  final isSaving = false.obs;
  final errorMessage = RxnString();
  final users = <ManagedUserModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  Future<void> loadUsers() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      users.assignAll(await _service.getAll());
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Imeshindikana kupakia Users.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createUser({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    isSaving.value = true;
    try {
      await _service.create(fullName: fullName, email: email, password: password, role: role);
      await loadUsers();
      return true;
    } on ApiException catch (e) {
      Get.snackbar('Hitilafu', e.message, snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> toggleActive(ManagedUserModel user) async {
    try {
      if (user.active) {
        await _service.deactivate(user.id);
      } else {
        await _service.reactivate(user.id);
      }
      loadUsers();
    } on ApiException catch (e) {
      Get.snackbar('Hitilafu', e.message, snackPosition: SnackPosition.BOTTOM);
    }
  }
}
