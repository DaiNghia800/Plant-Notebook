import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plant_notebook/controller/my_garden_controller.dart';
import 'package:plant_notebook/screens/home/widget/watering_section/watering_plant_card.dart';

class HomeWateringSection extends StatelessWidget {
  const HomeWateringSection({super.key});

  @override
  Widget build(BuildContext context) {
    final gardenController = context.watch<MyGardenController>();
    final allPlants = gardenController.plantProfiles;

    // Filter plants that need watering (nextWateredAt <= now)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final needsWateringPlants = allPlants.where((p) {
      if (p.nextWateredAt == null) return false;
      final nextWaterDate = DateTime(
        p.nextWateredAt!.year,
        p.nextWateredAt!.month,
        p.nextWateredAt!.day,
      );
      return nextWaterDate.isBefore(today) || nextWaterDate.isAtSameMomentAs(today);
    }).toList();

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
            if (needsWateringPlants.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${needsWateringPlants.length} cây',
                  style: const TextStyle(
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        if (needsWateringPlants.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8E9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFDCEDC8)),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.sentiment_very_satisfied,
                  color: Color(0xFF689F38),
                  size: 40,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tuyệt vời!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF33691E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tất cả cây của bạn đã đủ nước 💧',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF558B2F).withOpacity(0.8),
                  ),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: needsWateringPlants.length,
              physics: const BouncingScrollPhysics(),
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final plant = needsWateringPlants[index];
                // Calculate water amount roughly based on some logic or default
                final waterAmount = '${plant.reminderSetting.wateringCycleDays * 50}ml';
                return WateringPlantCard(
                  name: plant.name.isNotEmpty ? plant.name : plant.latinName,
                  water: waterAmount,
                  imagePath: plant.imageUrl.isNotEmpty ? plant.imageUrl : 'assets/images/placeholder.png',
                );
              },
            ),
          ),
      ],
    );
  }
}
