import 'package:flutter/material.dart';

class MyGardenHeader extends StatelessWidget {
  const MyGardenHeader({super.key, required this.totalPlants});

  final int totalPlants;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vườn của tôi',
          style: TextStyle(fontSize: 42, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          'Bạn đang chăm sóc $totalPlants loài cây khác nhau trong bộ sưu tập cá nhân.',
          style: const TextStyle(fontSize: 16, color: Color(0xFF5A7A5E)),
        ),
      ],
    );
  }
}
