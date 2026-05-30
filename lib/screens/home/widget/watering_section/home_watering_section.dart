import 'package:flutter/material.dart';
import 'package:plant_notebook/screens/home/widget/watering_section/watering_plant_card.dart';

class HomeWateringSection extends StatelessWidget {
  const HomeWateringSection({super.key});

  static const List<Map<String, String>> _plants = [
    {'name': 'Lưỡi Hổ', 'water': '250ml', 'image': 'assets/images/plant_1.jpg'},
    {'name': 'Sen Đá', 'water': '50ml', 'image': 'assets/images/plant_2.jpg'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Cần tưới hôm nay',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B1B1B),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '3 cây',
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _plants.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final plant = _plants[index];
              return WateringPlantCard(
                name: plant['name']!,
                water: plant['water']!,
                imagePath: plant['image']!,
              );
            },
          ),
        ),
      ],
    );
  }
}
