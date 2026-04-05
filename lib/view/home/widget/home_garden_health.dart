import 'package:flutter/material.dart';

class HomeGardenHealth extends StatelessWidget {
  const HomeGardenHealth({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sức khỏe khu vườn',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B1B1B),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            // Light card
            Expanded(
              child: _HealthCard(
                icon: Icons.wb_sunny_outlined,
                iconColor: const Color(0xFF2E7D32),
                backgroundColor: const Color(0xFFE8F5E9),
                label: 'ÁNH SÁNG',
                value: 'Tốt',
                valueStyle: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B1B1B),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Humidity card
            Expanded(
              child: _HealthCard(
                icon: Icons.water_drop_outlined,
                iconColor: const Color(0xFFB71C1C),
                backgroundColor: const Color(0xFFFCE4EC),
                label: 'ĐỘ ẨM',
                value: '65%',
                valueStyle: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B1B1B),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HealthCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String label;
  final String value;
  final TextStyle valueStyle;

  const _HealthCard({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.label,
    required this.value,
    required this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 26),
          const SizedBox(height: 16),
          Text(value, style: valueStyle),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF757575),
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
