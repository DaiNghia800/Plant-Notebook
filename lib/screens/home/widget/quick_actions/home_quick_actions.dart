import 'package:flutter/material.dart';
import 'package:plant_notebook/screens/home/widget/quick_actions/quick_action_card.dart';
import 'package:plant_notebook/routes/route_constant.dart';

class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hành động nhanh',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B1B1B),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: QuickActionCard(
                icon: Icons.document_scanner_outlined,
                iconColor: const Color(0xFF2E7D32),
                iconBgColor: const Color(0xFFE8F5E9),
                title: 'Scan AI',
                subtitle: 'Thông tin cây trồng/ Chẩn đoán sâu bệnh',
                onTap: () {
                  Navigator.of(context).pushNamed(scannerViewRoute);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionCard(
                icon: Icons.add_circle,
                iconColor: const Color(0xFF2E7D32),
                iconBgColor: const Color(0xFFE8F5E9),
                title: 'Thêm cây',
                subtitle: 'Vào vườn của bạn',
                onTap: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: QuickActionCard(
                icon: Icons.map_outlined,
                iconColor: const Color(0xFF1976D2),
                iconBgColor: const Color(0xFFE3F2FD),
                title: 'Cửa hàng & Vườn ươm',
                subtitle: 'Tìm tiệm cây, thuốc BVTV gần bạn',
                onTap: () {
                  Navigator.of(context).pushNamed(storeMapRoute);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
