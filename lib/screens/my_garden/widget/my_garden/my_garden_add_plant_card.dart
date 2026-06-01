import 'package:flutter/material.dart';

class MyGardenAddPlantCard extends StatelessWidget {
  const MyGardenAddPlantCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE7EFE9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFB8C9BC), width: 2),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Color(0xFFD0E2D5),
              child: Icon(Icons.add, color: Color(0xFF1B7A3D)),
            ),
            SizedBox(height: 12),
            Text(
              'Them cay moi',
              style: TextStyle(
                color: Color(0xFF1B7A3D),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
