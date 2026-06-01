import 'package:flutter/material.dart';
import 'package:plant_notebook/utils/date_formatter.dart';

class PlantActionProgress extends StatelessWidget {
  final String label;
  final DateTime lastActionDate;
  final int cycleDays;
  final Color activeColor;

  const PlantActionProgress({
    super.key,
    required this.label,
    required this.lastActionDate,
    required this.cycleDays,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final lastWatered = lastActionDate;
    final nextWatered = lastWatered.add(Duration(days: cycleDays));

    final totalDuration = nextWatered.difference(lastWatered);
    final elapsedDuration = now.difference(lastWatered);

    final progress =
        elapsedDuration.inMilliseconds / totalDuration.inMilliseconds;
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Column(
      children: [
        Text(
          'Tưới nước',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: clampedProgress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            clampedProgress < 0.8 ? activeColor : Colors.orange,
          ),
          minHeight: 8,
        ),
        const SizedBox(height: 8),
        Text(
          DateFormatter.formatNextActionDate(nextWatered),
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
}
