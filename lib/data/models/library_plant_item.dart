import 'package:flutter/material.dart';

class LibraryPlantItem {
  const LibraryPlantItem({
    required this.id,
    required this.name,
    required this.category,
    required this.shortDescription,
    required this.description,
    required this.lightLevel,
    required this.waterNeed,
    required this.difficulty,
    required this.careGuide,
    required this.careLogs,
    required this.growthTimeline,
    required this.funFacts,
    required this.imageUrl,
    this.scientificName,
    this.temperature,
    this.humidity,
    this.toxicity,
    this.badge,
    this.isTrending = false,
    this.isRare = false,
    this.approvalStatus = 'approved',
    this.healthStatus = 'Khỏe mạnh',
    this.wateringFrequencyLabel = '2 lần/tuần',
    this.lastWateredLabel = '2 ngày trước',
  });

  final String id;
  final String name;
  final String category;
  final String shortDescription;
  final String description;
  final String lightLevel;
  final String waterNeed;
  final String difficulty;
  final List<String> careGuide;
  final List<PlantCareLogEntry> careLogs;
  final List<PlantGrowthSnapshot> growthTimeline;
  final List<String> funFacts;
  final String imageUrl;
  final String? scientificName;
  final String? temperature;
  final String? humidity;
  final String? toxicity;
  final String? badge;
  final bool isTrending;
  final bool isRare;
  final String approvalStatus;
  final String healthStatus;
  final String wateringFrequencyLabel;
  final String lastWateredLabel;

  /// Parse từ JSON trả về từ server (GET /library-plants hoặc /library-plants/:id).
  factory LibraryPlantItem.fromJson(Map<String, dynamic> json) {
    List<String> parseStringList(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) {
        return raw.map((e) {
          if (e is Map) {
            final step = e['step'];
            final title = e['title'] ?? '';
            final content = e['content'] ?? '';
            final stepPrefix = step != null ? 'Bước $step: ' : '';
            final titleText = title.toString().isNotEmpty ? '$title - ' : '';
            return '$stepPrefix$titleText$content';
          }
          return e.toString();
        }).toList();
      }
      return [];
    }

    List<PlantGrowthSnapshot> parseTimeline(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) {
        return raw
            .whereType<Map<String, dynamic>>()
            .map(PlantGrowthSnapshot.fromJson)
            .toList();
      }
      return [];
    }

    return LibraryPlantItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      shortDescription: json['shortDescription'] as String? ?? '',
      description: json['description'] as String? ?? '',
      lightLevel: json['lightLevel'] as String? ?? '',
      waterNeed: json['waterNeed'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? '',
      careGuide: parseStringList(json['careGuide']),
      growthTimeline: parseTimeline(json['growthTimeline']),
      funFacts: parseStringList(json['funFacts']),
      imageUrl: json['imageUrl'] as String? ?? '',
      scientificName: json['scientificName'] as String?,
      temperature: json['temperature'] as String?,
      humidity: json['humidity'] as String?,
      toxicity: json['toxicity'] as String?,
      badge: json['badge'] as String?,
      isTrending: json['isTrending'] == true,
      isRare: json['isRare'] == true,
      approvalStatus: json['approvalStatus'] as String? ?? 'approved',
      healthStatus: json['healthStatus'] as String? ?? 'Khỏe mạnh',
      wateringFrequencyLabel: json['wateringFrequencyLabel'] as String? ?? '2 lần/tuần',
      lastWateredLabel: json['lastWateredLabel'] as String? ?? '2 ngày trước',
      // careLogs không có trong API response — dùng mặc định rỗng
      careLogs: const [],
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

  factory PlantGrowthSnapshot.fromJson(Map<String, dynamic> json) {
    final stage = json['stage'] as String?;
    final duration = json['duration'] as String?;
    final monthLabel = json['monthLabel'] as String? ?? stage ?? '';
    
    final note = json['note'] as String? ?? '';
    final displayNote = (duration != null && duration.isNotEmpty)
        ? '($duration) $note'
        : note;

    return PlantGrowthSnapshot(
      monthLabel: monthLabel,
      imageUrl: json['imageUrl'] as String? ?? '',
      note: displayNote,
    );
  }
}
