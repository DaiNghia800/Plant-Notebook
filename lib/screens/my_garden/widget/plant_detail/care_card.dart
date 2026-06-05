import 'package:flutter/material.dart';

class CareCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? iconData;
  final Color? iconColor;
  final Color? bgColor;

  const CareCard({
    super.key,
    required this.label,
    required this.value,
    this.iconData,
    this.iconColor,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final IconData finalIconData = iconData ?? Icons.info_outline;
    final Color finalBgColor = bgColor ?? const Color(0xFFF3F8F4);
    final Color finalIconColor = iconColor ?? const Color(0xFF2E7D32);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: finalBgColor,
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
          Icon(finalIconData, color: finalIconColor, size: 28),
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
