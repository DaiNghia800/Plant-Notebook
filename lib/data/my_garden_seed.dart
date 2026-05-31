import 'package:flutter/material.dart';
import 'package:plant_notebook/data/models/my_garden_item.dart';

const List<PlantCareLogEntry> defaultCareLogs = [
  PlantCareLogEntry(
    title: 'Đã tưới nước',
    timeLabel: '2 ngày trước • 08:30 AM',
    note: '',
    icon: Icons.water_drop_rounded,
    accentColor: Color(0xFF1B7A3D),
  ),
  PlantCareLogEntry(
    title: 'Bón phân hữu cơ',
    timeLabel: '1 tuần trước • 09:15 AM',
    note: '',
    icon: Icons.eco_rounded,
    accentColor: Color(0xFF6C8F49),
  ),
  PlantCareLogEntry(
    title: 'Đã tưới nước',
    timeLabel: '9 ngày trước • 07:45 AM',
    note: '',
    icon: Icons.water_drop_rounded,
    accentColor: Color(0xFF1B7A3D),
  ),
];

const List<PlantGrowthSnapshot> defaultGrowthTimeline = [
  PlantGrowthSnapshot(
    monthLabel: 'Tháng 2',
    imageUrl:
        'https://images.unsplash.com/photo-1592150621744-aca64f48394e?auto=format&fit=crop&w=1200&q=80',
    note: 'Cây bắt đầu ổn định sau khi thay chậu.',
  ),
];

MyGardenItem createDefaultGardenItem(String libraryPlantId) {
  if (libraryPlantId == 'pothos') {
    return MyGardenItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      libraryPlantId: libraryPlantId,
      nickname: 'Bà Bà',
      healthStatus: 'Khỏe mạnh',
      wateringFrequencyLabel: '2 times/week',
      lastWateredLabel: '2 days ago',
      careLogs: List.from(defaultCareLogs),
      growthTimeline: List.from(defaultGrowthTimeline),
    );
  }

  return MyGardenItem(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    libraryPlantId: libraryPlantId,
    healthStatus: 'Khỏe mạnh',
    wateringFrequencyLabel: '1 lần/tuần',
    lastWateredLabel: 'Hôm qua',
    careLogs: [],
    growthTimeline: [],
  );
}
