import 'package:get/get.dart';

import '../../../core/network/api_exception.dart';
import '../../expenses/expenses_service.dart';
import '../../expenses/models/expense_model.dart';
import '../../income/income_service.dart';
import '../../income/models/income_model.dart';
import '../../invoices/invoice_service.dart';
import '../../invoices/models/invoice_model.dart';
import '../models/project_model.dart';
import '../project_service.dart';

class ProjectDetailController extends GetxController {
  final ProjectService _projectService;
  final IncomeService _incomeService;
  final ExpensesService _expensesService;
  final InvoiceService _invoiceService;
  final int projectId;

  ProjectDetailController(
    this._projectService,
    this._incomeService,
    this._expensesService,
    this._invoiceService, {
    required this.projectId,
  });

  final isLoading = true.obs;
  final errorMessage = RxnString();
  final project = Rxn<ProjectModel>();

  final isLoadingFinance = true.obs;
  final incomes = <IncomeModel>[].obs;
  final expenses = <ExpenseModel>[].obs;
  final invoices = <InvoiceModel>[].obs;

  double get totalIncome => incomes.fold(0, (sum, i) => sum + i.amount);
  double get totalExpenses => expenses.fold(0, (sum, e) => sum + e.amount);
  double get netProfit => totalIncome - totalExpenses;

  @override
  void onInit() {
    super.onInit();
    loadProject();
    loadFinance();
  }

  Future<void> loadProject() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      project.value = await _projectService.getById(projectId);
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Imeshindikana kupakia taarifa za project.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadFinance() async {
    isLoadingFinance.value = true;
    try {
      incomes.assignAll(await _incomeService.getByProject(projectId));
    } catch (_) {
      // STAFF hana ruhusa ya kuona hii - haitakuwa na Income section
    }
    try {
      expenses.assignAll(await _expensesService.getByProject(projectId));
    } catch (_) {}
    try {
      final all = await _invoiceService.getAll();
      invoices.assignAll(all.where((inv) => inv.projectId == projectId));
    } catch (_) {}
    isLoadingFinance.value = false;
  }
}
