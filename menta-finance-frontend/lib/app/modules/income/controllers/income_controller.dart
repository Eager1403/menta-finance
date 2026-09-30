import 'package:get/get.dart';

import '../../../core/network/api_exception.dart';
import '../../projects/models/project_model.dart';
import '../../projects/project_service.dart';
import '../income_service.dart';
import '../models/income_model.dart';

class IncomeController extends GetxController {
  final IncomeService _service;
  final ProjectService _projectService;
  IncomeController(this._service, this._projectService);

  final isLoadingProjects = true.obs;
  final projects = <ProjectModel>[].obs;
  final selectedProjectId = RxnInt();

  final isLoadingIncome = false.obs;
  final isSaving = false.obs;
  final errorMessage = RxnString();
  final incomes = <IncomeModel>[].obs;

  double get total => incomes.fold(0, (sum, i) => sum + i.amount);

  @override
  void onInit() {
    super.onInit();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    isLoadingProjects.value = true;
    try {
      projects.assignAll(await _projectService.getAll());
    } catch (_) {
      errorMessage.value = 'Imeshindikana kupakia Projects.';
    } finally {
      isLoadingProjects.value = false;
    }
  }

  Future<void> selectProject(int? projectId) async {
    selectedProjectId.value = projectId;
    if (projectId == null) {
      incomes.clear();
      return;
    }
    isLoadingIncome.value = true;
    errorMessage.value = null;
    try {
      incomes.assignAll(await _service.getByProject(projectId));
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Imeshindikana kupakia Income.';
    } finally {
      isLoadingIncome.value = false;
    }
  }

  Future<bool> addIncome({
    required String? description,
    required double amount,
    DateTime? incomeDate,
    String? paymentMethod,
  }) async {
    if (selectedProjectId.value == null) return false;
    isSaving.value = true;
    try {
      await _service.create(
        projectId: selectedProjectId.value!,
        description: description,
        amount: amount,
        incomeDate: incomeDate,
        paymentMethod: paymentMethod,
      );
      await selectProject(selectedProjectId.value);
      return true;
    } on ApiException catch (e) {
      Get.snackbar('Hitilafu', e.message, snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteIncome(int id) async {
    try {
      await _service.delete(id);
      Get.snackbar('Imefanikiwa', 'Income imefutwa.', snackPosition: SnackPosition.BOTTOM);
      selectProject(selectedProjectId.value);
    } on ApiException catch (e) {
      Get.snackbar('Hitilafu', e.message, snackPosition: SnackPosition.BOTTOM);
    }
  }
}
