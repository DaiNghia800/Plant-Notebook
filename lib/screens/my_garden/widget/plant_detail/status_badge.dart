import 'package:flutter/material.dart';
import 'package:plant_notebook/data/models/garden_plant.dart';
import 'package:provider/provider.dart';
import 'package:plant_notebook/controller/profile_controller.dart';

class StatusBadge extends StatelessWidget {
  final GardenPlantStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    String text;
    Color color;

    switch (status) {
      case GardenPlantStatus.healthy:
        text = context.watch<ProfileController>().tr('status_healthy');
        color = Colors.green;
        break;
      case GardenPlantStatus.thirsty:
        text = context.watch<ProfileController>().tr('status_thirsty');
        color = Colors.orange;
        break;
      case GardenPlantStatus.sick:
        text = context.watch<ProfileController>().tr('status_sick');
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
