enum CareActionType { watering, fertilizing }

class PlantCareHistory {
  const PlantCareHistory({
    this.id,
    required this.gardenPlantId,
    required this.actionType,
    required this.actionDate,
    this.notes,
  });

  final String? id;
  final String gardenPlantId;
  final CareActionType actionType;
  final DateTime actionDate;
  final String? notes;

  PlantCareHistory copyWith({
    String? id,
    String? gardenPlantId,
    CareActionType? actionType,
    DateTime? actionDate,
    String? notes,
  }) {
    return PlantCareHistory(
      id: id ?? this.id,
      gardenPlantId: gardenPlantId ?? this.gardenPlantId,
      actionType: actionType ?? this.actionType,
      actionDate: actionDate ?? this.actionDate,
      notes: notes ?? this.notes,
    );
  }

  factory PlantCareHistory.fromJson(Map<String, dynamic> json) {
    final actionDateValue = json['actionDate'] ?? json['performedAt'];
    return PlantCareHistory(
      id: json['id']?.toString(),
      gardenPlantId: json['gardenPlantId']?.toString() ?? '',
      actionType: _parseActionType(json['actionType']?.toString()),
      actionDate:
          DateTime.tryParse(actionDateValue?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'gardenPlantId': gardenPlantId,
      'type': actionType.name,
      'actionDate': actionDate.toIso8601String(),
      'notes': notes,
    };
  }

  static CareActionType _parseActionType(String? type) {
    switch (type) {
      case 'Bón phân':
      case 'fertilizing':
        return CareActionType.fertilizing;
      case 'Tưới nước':
      case 'watering':
      default:
        return CareActionType.watering;
    }
  }

  String get actionTypeLabel {
    switch (actionType) {
      case CareActionType.watering:
        return 'Tưới nước';
      case CareActionType.fertilizing:
        return 'Bón phân';
    }
  }
}
