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
    this.isTrending = false,
    this.isRare = false,
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
  final bool isTrending;
  final bool isRare;
  final String healthStatus;
  final String wateringFrequencyLabel;
  final String lastWateredLabel;
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
}
