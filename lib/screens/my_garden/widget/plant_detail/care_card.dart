import 'package:flutter/material.dart';

class CareCard extends StatelessWidget {
  final String label;
  final String value;

  const CareCard({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    IconData iconData = Icons.info_outline;
    Color bgColor = const Color(0xFFF3F8F4);
    Color iconColor = const Color(0xFF2E7D32);

    if (label == 'Chu kỳ') {
      iconData = Icons.autorenew_rounded;
      bgColor = const Color(0xFFE8F5E9);
      iconColor = const Color(0xFF388E3C);
    } else if (label == 'Lần cuối') {
      iconData = Icons.history_rounded;
      bgColor = const Color(0xFFE3F2FD);
      iconColor = const Color(0xFF1976D2);
    } else if (label == 'Vị trí') {
      iconData = Icons.location_on_rounded;
      bgColor = const Color(0xFFFFF3E0);
      iconColor = const Color(0xFFF57C00);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(iconData, color: iconColor, size: 28),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF587064),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF102A17),
            ),
          ),
        ],
      ),
    );
  }
}
