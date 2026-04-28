import 'package:flutter/material.dart';
import 'package:plant_notebook/screens/home/widget/garden_health/health_card.dart';
import 'package:plant_notebook/screens/home/widget/garden_health/environment_toggle_tab.dart';

class HomeGardenHealth extends StatefulWidget {
  const HomeGardenHealth({super.key});

  @override
  State<HomeGardenHealth> createState() => _HomeGardenHealthState();
}

class _HomeGardenHealthState extends State<HomeGardenHealth> {
  bool isIndoor = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: const Text(
                'Sức khỏe khu vườn',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B1B1B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Nút Toggle chuyển đổi môi trường
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  EnvironmentToggleTab(
                    title: 'Ngoài trời',
                    isSelected: !isIndoor,
                    onTap: () {
                      setState(() {
                        isIndoor = false;
                      });
                    },
                  ),
                  EnvironmentToggleTab(
                    title: 'Trong nhà',
                    isSelected: isIndoor,
                    onTap: () {
                      setState(() {
                        isIndoor = true;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(), // Hiệu ứng cuộn mượt
          child: Row(
            children: [
              SizedBox(
                width: 140,
                child: HealthCard(
                  icon: Icons.thermostat_outlined,
                  iconColor: const Color(0xFFE65100),
                  backgroundColor: const Color(0xFFFFF3E0),
                  label: 'NHIỆT ĐỘ',
                  value: isIndoor ? '26°C' : '32°C',
                  valueStyle: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B1B1B),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 140,
                child: HealthCard(
                  icon: Icons.water_drop_outlined,
                  iconColor: const Color(0xFF0277BD),
                  backgroundColor: const Color(0xFFE1F5FE),
                  label: 'ĐỘ ẨM',
                  value: isIndoor ? '50%' : '65%',
                  valueStyle: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B1B1B),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 3. Thẻ Ánh sáng
              SizedBox(
                width: 140,
                child: HealthCard(
                  icon: isIndoor
                      ? Icons.wb_incandescent_outlined
                      : Icons.wb_sunny_outlined,
                  iconColor: const Color(0xFFF57F17),
                  backgroundColor: const Color(0xFFFFFDE7),
                  label: 'ÁNH SÁNG',
                  value: isIndoor ? 'Vừa' : 'Gắt',
                  valueStyle: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B1B1B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
