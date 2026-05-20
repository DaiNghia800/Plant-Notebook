import 'package:flutter/material.dart';

class MyGardenItem {
  const MyGardenItem({
    required this.id,
    required this.libraryPlantId,
    required this.healthStatus,
    required this.wateringFrequencyLabel,
    required this.lastWateredLabel,
    required this.careLogs,
    required this.growthTimeline,
  });

  final String id;
  final String libraryPlantId;
  final String healthStatus;
  final String wateringFrequencyLabel;
  final String lastWateredLabel;
  final List<PlantCareLogEntry> careLogs;
  final List<PlantGrowthSnapshot> growthTimeline;

  MyGardenItem copyWith({
    String? healthStatus,
    String? wateringFrequencyLabel,
    String? lastWateredLabel,
    List<PlantCareLogEntry>? careLogs,
    List<PlantGrowthSnapshot>? growthTimeline,
  }) {
    return MyGardenItem(
      id: id,
      libraryPlantId: libraryPlantId,
      healthStatus: healthStatus ?? this.healthStatus,
      wateringFrequencyLabel: wateringFrequencyLabel ?? this.wateringFrequencyLabel,
      lastWateredLabel: lastWateredLabel ?? this.lastWateredLabel,
      careLogs: careLogs ?? this.careLogs,
      growthTimeline: growthTimeline ?? this.growthTimeline,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'libraryPlantId': libraryPlantId,
      'healthStatus': healthStatus,
      'wateringFrequencyLabel': wateringFrequencyLabel,
      'lastWateredLabel': lastWateredLabel,
      'careLogs': careLogs.map((e) => e.toMap()).toList(),
      'growthTimeline': growthTimeline.map((e) => e.toMap()).toList(),
    };
  }

  factory MyGardenItem.fromMap(Map<String, dynamic> map) {
    return MyGardenItem(
      id: map['id'] as String,
      libraryPlantId: map['libraryPlantId'] as String,
      healthStatus: map['healthStatus'] as String,
      wateringFrequencyLabel: map['wateringFrequencyLabel'] as String,
      lastWateredLabel: map['lastWateredLabel'] as String,
      careLogs: List<PlantCareLogEntry>.from(
        (map['careLogs'] as List<dynamic>).map(
          (e) => PlantCareLogEntry.fromMap(e as Map<String, dynamic>),
        ),
      ),
      growthTimeline: List<PlantGrowthSnapshot>.from(
        (map['growthTimeline'] as List<dynamic>).map(
          (e) => PlantGrowthSnapshot.fromMap(e as Map<String, dynamic>),
        ),
      ),
    );
  }
}

class PlantCareLogEntry {
  const PlantCareLogEntry({
    required this.title,
    required this.timeLabel,
    required this.note,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String timeLabel;
  final String note;
  final IconData icon;
  final Color accentColor;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'timeLabel': timeLabel,
      'note': note,
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'iconFontPackage': icon.fontPackage,
      'accentColorValue': accentColor.value,
    };
  }

  factory PlantCareLogEntry.fromMap(Map<String, dynamic> map) {
    return PlantCareLogEntry(
      title: map['title'] as String,
      timeLabel: map['timeLabel'] as String,
      note: map['note'] as String,
      icon: IconData(
        map['iconCodePoint'] as int,
        fontFamily: map['iconFontFamily'] as String?,
        fontPackage: map['iconFontPackage'] as String?,
      ),
      accentColor: Color(map['accentColorValue'] as int),
    );
  }
}

class PlantGrowthSnapshot {
  const PlantGrowthSnapshot({
    required this.monthLabel,
    required this.imageUrl,
    required this.note,
  });

  final String monthLabel;
  final String imageUrl;
  final String note;

  Map<String, dynamic> toMap() {
    return {
      'monthLabel': monthLabel,
      'imageUrl': imageUrl,
      'note': note,
    };
  }

  factory PlantGrowthSnapshot.fromMap(Map<String, dynamic> map) {
    return PlantGrowthSnapshot(
      monthLabel: map['monthLabel'] as String,
      imageUrl: map['imageUrl'] as String,
      note: map['note'] as String,
    );
  }
}
