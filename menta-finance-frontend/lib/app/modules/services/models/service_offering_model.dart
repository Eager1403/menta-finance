/// Sawa na ServiceOfferingResponse ya backend
class ServiceOfferingModel {
  final int id;
  final String name;
  final String? description;
  final bool active;

  ServiceOfferingModel({
    required this.id,
    required this.name,
    this.description,
    this.active = true,
  });

  factory ServiceOfferingModel.fromJson(Map<String, dynamic> j) => ServiceOfferingModel(
        id: j['id'] as int,
        name: j['name'] as String? ?? '',
        description: j['description'] as String?,
        active: j['active'] as bool? ?? true,
      );
}
