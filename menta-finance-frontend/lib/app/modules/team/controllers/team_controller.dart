import 'package:get/get.dart';

import '../../../core/network/api_exception.dart';
import '../models/team_member_model.dart';
import '../team_service.dart';

class TeamController extends GetxController {
  final TeamService _service;
  TeamController(this._service);

  final isLoading = true.obs;
  final isSaving = false.obs;
  final errorMessage = RxnString();
  final members = <TeamMemberModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadMembers();
  }

  Future<void> loadMembers() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      members.assignAll(await _service.getAllActive());
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Imeshindikana kupakia Team Members.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addMember({
    required String fullName,
    String? position,
    String? phone,
    String? email,
    DateTime? joinedDate,
  }) async {
    isSaving.value = true;
    try {
      await _service.add(fullName: fullName, position: position, phone: phone, email: email, joinedDate: joinedDate);
      await loadMembers();
      return true;
    } on ApiException catch (e) {
      Get.snackbar('Hitilafu', e.message, snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> removeMember(int id) async {
    try {
      await _service.remove(id);
      Get.snackbar('Imefanikiwa', 'Team member amefutwa.', snackPosition: SnackPosition.BOTTOM);
      loadMembers();
    } on ApiException catch (e) {
      Get.snackbar('Hitilafu', e.message, snackPosition: SnackPosition.BOTTOM);
    }
  }
}
