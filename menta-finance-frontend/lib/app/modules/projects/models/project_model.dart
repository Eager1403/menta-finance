/// Sawa na entity.enums.ProjectType
enum ProjectTypeX { client, internal }

ProjectTypeX projectTypeFromString(String? s) => s == 'INTERNAL' ? ProjectTypeX.internal : ProjectTypeX.client;
String projectTypeToString(ProjectTypeX t) => t == ProjectTypeX.internal ? 'INTERNAL' : 'CLIENT';
String projectTypeLabel(ProjectTypeX t) => t == ProjectTypeX.internal ? 'Ndani ya Kampuni' : 'Client';

/// Sawa na entity.enums.ProjectStatus
enum ProjectStatusX { ongoing, completed, cancelled }

ProjectStatusX projectStatusFromString(String? s) {
  switch (s) {
    case 'COMPLETED':
      return ProjectStatusX.completed;
    case 'CANCELLED':
      return ProjectStatusX.cancelled;
    default:
      return ProjectStatusX.ongoing;
  }
}

String projectStatusToString(ProjectStatusX s) {
  switch (s) {
    case ProjectStatusX.completed:
      return 'COMPLETED';
    case ProjectStatusX.cancelled:
      return 'CANCELLED';
    case ProjectStatusX.ongoing:
      return 'ONGOING';
  }
}

String projectStatusLabel(ProjectStatusX s) {
  switch (s) {
    case ProjectStatusX.completed:
      return 'Imekamilika';
    case ProjectStatusX.cancelled:
      return 'Imeghairiwa';
    case ProjectStatusX.ongoing:
      return 'Inaendelea';
  }
}

/// Sawa na ProjectResponse ya backend
class ProjectModel {
  final int id;
  final String name;
  final int? clientId;
  final String? clientName;
  final int? serviceId;
  final String? serviceName;
  final ProjectTypeX projectType;
  final double projectValue;
  final ProjectStatusX status;
  final DateTime? startDate;
  final DateTime? endDate;

  ProjectModel({
    required this.id,
    required this.name,
    this.clientId,
    this.clientName,
    this.serviceId,
    this.serviceName,
    required this.projectType,
    required this.projectValue,
    required this.status,
    this.startDate,
    this.endDate,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> j) => ProjectModel(
        id: j['id'] as int,
        name: j['name'] as String? ?? '',
        clientId: j['clientId'] as int?,
        clientName: j['clientName'] as String?,
        serviceId: j['serviceId'] as int?,
        serviceName: j['serviceName'] as String?,
        projectType: projectTypeFromString(j['projectType'] as String?),
        projectValue: double.tryParse(j['projectValue'].toString()) ?? 0,
        status: projectStatusFromString(j['status'] as String?),
        startDate: j['startDate'] != null ? DateTime.tryParse(j['startDate'] as String) : null,
        endDate: j['endDate'] != null ? DateTime.tryParse(j['endDate'] as String) : null,
      );
}
