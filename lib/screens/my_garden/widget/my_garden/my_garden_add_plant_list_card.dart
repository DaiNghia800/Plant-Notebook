import 'package:flutter/material.dart';

class MyGardenAddPlantListCard extends StatelessWidget {
  const MyGardenAddPlantListCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 76,
        decoration: BoxDecoration(
          color: const Color(0xFFE7EFE9).withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFB8C9BC),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Color(0xFFD0E2D5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: Color(0xFF1B7A3D),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Thêm cây mới',
                    style: TextStyle(
                      color: Color(0xFF1B7A3D),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Trồng thêm một cây mới vào khu vườn',
                    style: TextStyle(
                      color: Color(0xFF5E8B6D),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF1B7A3D),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
