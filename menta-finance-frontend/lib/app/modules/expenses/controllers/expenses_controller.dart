import 'package:get/get.dart';

import '../../../core/network/api_exception.dart';
import '../../projects/models/project_model.dart';
import '../../projects/project_service.dart';
import '../expenses_service.dart';
import '../models/expense_model.dart';

class ExpensesController extends GetxController {
  final ExpensesService _service;
  final ProjectService _projectService;
  ExpensesController(this._service, this._projectService);

  final isLoadingProjects = true.obs;
  final projects = <ProjectModel>[].obs;
  final selectedProjectId = RxnInt();

  final isLoadingExpenses = false.obs;
  final isSaving = false.obs;
  final errorMessage = RxnString();
  final expenses = <ExpenseModel>[].obs;

  double get total => expenses.fold(0, (sum, e) => sum + e.amount);

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
      expenses.clear();
      return;
    }
    isLoadingExpenses.value = true;
    errorMessage.value = null;
    try {
      expenses.assignAll(await _service.getByProject(projectId));
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Imeshindikana kupakia Expenses.';
    } finally {
      isLoadingExpenses.value = false;
    }
  }

  Future<bool> addExpense({
    required String? description,
    required double amount,
    DateTime? expenseDate,
    String? category,
  }) async {
    if (selectedProjectId.value == null) return false;
    isSaving.value = true;
    try {
      await _service.create(
        projectId: selectedProjectId.value!,
        description: description,
        amount: amount,
        expenseDate: expenseDate,
        category: category,
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

  Future<void> deleteExpense(int id) async {
    try {
      await _service.delete(id);
      Get.snackbar('Imefanikiwa', 'Expense imefutwa.', snackPosition: SnackPosition.BOTTOM);
      selectProject(selectedProjectId.value);
    } on ApiException catch (e) {
      Get.snackbar('Hitilafu', e.message, snackPosition: SnackPosition.BOTTOM);
    }
  }
}
