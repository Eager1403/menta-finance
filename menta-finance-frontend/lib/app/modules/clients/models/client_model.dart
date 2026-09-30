/// Sawa na ClientResponse ya backend (com.mentafinance.dto.response.ClientResponse)
class ClientModel {
  final int id;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final DateTime? createdAt;

  ClientModel({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.createdAt,
  });

  factory ClientModel.fromJson(Map<String, dynamic> j) => ClientModel(
        id: j['id'] as int,
        name: j['name'] as String? ?? '',
        phone: j['phone'] as String?,
        email: j['email'] as String?,
        address: j['address'] as String?,
        createdAt: j['createdAt'] != null ? DateTime.tryParse(j['createdAt'] as String) : null,
      );

  /// Kwa POST/PUT - sawa na ClientRequest ya backend
  Map<String, dynamic> toRequestJson() => {
        'name': name,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        if (address != null) 'address': address,
      };
}

/// Sawa na ProjectSummaryResponse - row moja ndani ya Client Detail
class ProjectSummaryModel {
  final int projectId;
  final String projectName;
  final double price;
  final double paid;
  final double outstanding;

  ProjectSummaryModel({
    required this.projectId,
    required this.projectName,
    required this.price,
    required this.paid,
    required this.outstanding,
  });

  factory ProjectSummaryModel.fromJson(Map<String, dynamic> j) => ProjectSummaryModel(
        projectId: j['projectId'] as int,
        projectName: j['projectName'] as String? ?? '',
        price: double.tryParse(j['price'].toString()) ?? 0,
        paid: double.tryParse(j['paid'].toString()) ?? 0,
        outstanding: double.tryParse(j['outstanding'].toString()) ?? 0,
      );
}

/// Sawa na ClientDetailResponse - GET /api/clients/{id}/detail
class ClientDetailModel {
  final int clientId;
  final String clientName;
  final List<ProjectSummaryModel> projects;
  final double totalOutstanding;

  ClientDetailModel({
    required this.clientId,
    required this.clientName,
    required this.projects,
    required this.totalOutstanding,
  });

  factory ClientDetailModel.fromJson(Map<String, dynamic> j) => ClientDetailModel(
        clientId: j['clientId'] as int,
        clientName: j['clientName'] as String? ?? '',
        projects: (j['projects'] as List? ?? [])
            .map((e) => ProjectSummaryModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalOutstanding: double.tryParse(j['totalOutstanding'].toString()) ?? 0,
      );
}
