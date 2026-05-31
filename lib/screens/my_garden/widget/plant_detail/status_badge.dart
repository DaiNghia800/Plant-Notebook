import 'package:flutter/material.dart';
import 'package:plant_notebook/data/models/garden_plant.dart';

class StatusBadge extends StatelessWidget {
  final GardenPlantStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    String text;
    Color color;

    switch (status) {
      case GardenPlantStatus.healthy:
        text = 'Khỏe mạnh';
        color = Colors.green;
        break;
      case GardenPlantStatus.thirsty:
        text = 'Đang khát';
        color = Colors.orange;
        break;
      case GardenPlantStatus.sick:
        text = 'Đang bệnh';
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
