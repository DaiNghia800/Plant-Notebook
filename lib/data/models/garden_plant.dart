import 'package:plant_notebook/data/models/reminder.dart';
import 'package:plant_notebook/data/models/category.dart';

enum GardenPlantStatus { thirsty, healthy, sick }

class GardenPlantProfile {
  const GardenPlantProfile({
    this.id,
    required this.plantId,
    required this.name,
    required this.latinName,
    required this.imageUrl,
    required this.status,
    required this.category,
    required this.startDate,
    required this.reminderSetting,
    this.lastWateredAt,
    this.nextWateredAt,
  });

  final String? id;
  final String plantId;
  final String name;
  final String latinName;
  final String imageUrl;
  final GardenPlantStatus status;
  final GardenCategory category;
  final DateTime startDate;
  final GardenReminder reminderSetting;
  final DateTime? lastWateredAt;
  final DateTime? nextWateredAt;

  GardenPlantProfile copyWith({
    String? id,
    String? name,
    String? latinName,
    String? nickname,
    String? imageUrl,
    String? photoPath,
    GardenPlantStatus? status,
    GardenCategory? category,
    DateTime? startDate,
    GardenReminder? reminderSetting,
    DateTime? lastWateredAt,
    DateTime? nextWateredAt,
  }) {
    return GardenPlantProfile(
      id: id ?? this.id,
      plantId: plantId,
      name: name ?? this.name,
      latinName: latinName ?? this.latinName,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      category: category ?? this.category,
      startDate: startDate ?? this.startDate,
      reminderSetting: reminderSetting ?? this.reminderSetting,
      lastWateredAt: lastWateredAt ?? this.lastWateredAt,
      nextWateredAt: nextWateredAt ?? this.nextWateredAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'plantId': plantId,
      'name': name,
      'latinName': latinName,
      'imageUrl': imageUrl,
      'status': status.name,
      'category': category.name,
      'startedAt': startDate.toIso8601String(),
      'reminderSetting': reminderSetting.toJson(),
      'lastWateredAt': lastWateredAt?.toIso8601String(),
      'nextWateredAt': nextWateredAt?.toIso8601String(),
    };
  }

  factory GardenPlantProfile.fromJson(Map<String, dynamic> json) {
    final plantInfo = json['Plant'] as Map<String, dynamic>?;
    final reminders = json['Reminders'] as List<dynamic>?;
    final categories = json['Category'] as Map<String, dynamic>?;

    DateTime? lastWateredAt;
    DateTime? nextWateredAt;
    for (var reminder in reminders ?? []) {
      if (reminder is Map<String, dynamic> && reminder['type'] == 'Tưới nước') {
        lastWateredAt = DateTime.tryParse(
          reminder['lastActionAt']?.toString() ?? '',
        );
        if (lastWateredAt != null) {
          final int cycle = (reminder['frequencyDays'] as num?)?.toInt() ?? 3;
          nextWateredAt = lastWateredAt.add(Duration(days: cycle));
        }
        break;
      }
    }

    return GardenPlantProfile(
      id: json['id']?.toString(),
      plantId: json['plantId']?.toString() ?? '',
      name: plantInfo?['name']?.toString() ?? '',
      latinName: json['latinName']?.toString() ?? '',
      imageUrl: (plantInfo?['imageUrl'])?.toString() ?? '',
      status: _parseStatus(json['status']?.toString()),
      category: GardenCategory.fromJson(categories ?? <String, dynamic>{}),
      startDate:
          DateTime.tryParse(json['startedAt']?.toString() ?? '') ??
          DateTime.now(),
      reminderSetting: GardenReminder.fromJson(reminders ?? []),
      lastWateredAt: lastWateredAt,
      nextWateredAt: nextWateredAt,
    );
  }

  static GardenPlantStatus _parseStatus(String? status) {
    switch (status) {
      case 'Đang khát':
      case 'thirsty':
        return GardenPlantStatus.thirsty;
      case 'Đang bệnh':
      case 'sick':
        return GardenPlantStatus.sick;
      case 'healthy':
      case 'Khỏe mạnh':
      default:
        return GardenPlantStatus.healthy;
    }
  }
}
