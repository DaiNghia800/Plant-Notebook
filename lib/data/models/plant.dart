// lib/model/plant_model.dart

enum PlantStatus { healthy, warning, critical }

enum PlantCategory { all, indoor, balcony, outdoor }

class Plant {
  final String id;
  final String name;
  final String latinName;
  final String imageUrl;
  final PlantStatus status;
  final String statusLabel;
  final PlantCategory category;

  const Plant({
    required this.id,
    required this.name,
    required this.latinName,
    required this.imageUrl,
    required this.status,
    required this.statusLabel,
    required this.category,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      latinName: json['latin_name'] ?? '',
      imageUrl: json['image_url'] ?? '',
      status: _parseStatus(json['status']),
      statusLabel: json['status_label'] ?? '',
      category: _parseCategory(json['category']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'latin_name': latinName,
    'image_url': imageUrl,
    'status': status.name,
    'status_label': statusLabel,
    'category': category.name,
  };

  static PlantStatus _parseStatus(String? s) {
    switch (s) {
      case 'warning':
        return PlantStatus.warning;
      case 'critical':
        return PlantStatus.critical;
      default:
        return PlantStatus.healthy;
    }
  }

  static PlantCategory _parseCategory(String? s) {
    switch (s) {
      case 'indoor':
        return PlantCategory.indoor;
      case 'balcony':
        return PlantCategory.balcony;
      case 'outdoor':
        return PlantCategory.outdoor;
      default:
        return PlantCategory.indoor;
    }
  }
}
