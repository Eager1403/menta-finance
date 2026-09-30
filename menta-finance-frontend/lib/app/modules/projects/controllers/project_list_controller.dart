import 'package:get/get.dart';

import '../../../core/network/api_exception.dart';
import '../../clients/client_service.dart';
import '../../clients/models/client_model.dart';
import '../../services/models/service_offering_model.dart';
import '../../services/service_offering_service.dart';
import '../models/project_model.dart';
import '../project_service.dart';

class ProjectListController extends GetxController {
  final ProjectService _service;
  final ClientService _clientService;
  final ServiceOfferingService _serviceOfferingService;

  ProjectListController(this._service, this._clientService, this._serviceOfferingService);

  final isLoading = true.obs;
  final isSaving = false.obs;
  final errorMessage = RxnString();
  final projects = <ProjectModel>[].obs;
  final searchText = ''.obs;

  final clientOptions = <ClientModel>[].obs;
  final serviceOptions = <ServiceOfferingModel>[].obs;

  List<ProjectModel> get filtered {
    final q = searchText.value.trim().toLowerCase();
    if (q.isEmpty) return projects;
    return projects
        .where((p) => p.name.toLowerCase().contains(q) || (p.clientName ?? '').toLowerCase().contains(q))
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadProjects();
    _loadOptions();
  }

  Future<void> loadProjects() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      projects.assignAll(await _service.getAll());
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Imeshindikana kupakia Projects.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadOptions() async {
    try {
      clientOptions.assignAll(await _clientService.getAll());
    } catch (_) {}
    try {
      serviceOptions.assignAll(await _serviceOfferingService.getAllActive());
    } catch (_) {}
  }

  Future<bool> createProject({
    required String name,
    int? clientId,
    int? serviceId,
    required ProjectTypeX projectType,
    required double projectValue,
    ProjectStatusX? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    isSaving.value = true;
    try {
      await _service.create(
        name: name,
        clientId: clientId,
        serviceId: serviceId,
        projectType: projectType,
        projectValue: projectValue,
        status: status,
        startDate: startDate,
        endDate: endDate,
      );
      await loadProjects();
      return true;
    } on ApiException catch (e) {
      Get.snackbar('Hitilafu', e.message, snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteProject(int id) async {
    try {
      await _service.delete(id);
      Get.snackbar('Imefanikiwa', 'Project imefutwa.', snackPosition: SnackPosition.BOTTOM);
      loadProjects();
    } on ApiException catch (e) {
      Get.snackbar('Hitilafu', e.message, snackPosition: SnackPosition.BOTTOM);
    }
  }
}
