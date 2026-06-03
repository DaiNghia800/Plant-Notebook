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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F9F7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EFEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF102A17),
                ),
              ),
              Text(
                DateFormatter.formatNextActionDate(nextWatered),
                style: const TextStyle(
                  fontSize: 14, 
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF587064),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: clampedProgress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                clampedProgress < 0.8 ? activeColor : const Color(0xFFF57C00),
              ),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }
}
