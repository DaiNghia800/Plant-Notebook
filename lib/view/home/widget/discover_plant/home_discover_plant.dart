import 'package:flutter/material.dart';
import 'dart:math';

class HomeDiscoverPlant extends StatefulWidget {
  const HomeDiscoverPlant({super.key});

  @override
  State<HomeDiscoverPlant> createState() => _HomeDiscoverPlantState();
}

class _HomeDiscoverPlantState extends State<HomeDiscoverPlant> {
  late Map<String, String> _selectedPlant;

  static const List<Map<String, String>> _plantsFact = [
    {
      'name': 'Cây Kim Tiền',
      'fact': 'Được cho là mang lại tài lộc. Rất dễ sống trong khu vực ánh sáng yếu.',
      'icon': '🌿',
      'bgColor': '0xFFE8F5E9',
      'iconColor': '0xFF2E7D32',
    },
    {
      'name': 'Cây Nha Đam',
      'fact': 'Thanh lọc không khí tuyệt vời và có thể dùng gel để làm dịu vết bỏng.',
      'icon': '🌵',
      'bgColor': '0xFFE0F7FA',
      'iconColor': '0xFF006064',
    },
    {
      'name': 'Cây Lưỡi Hổ',
      'fact': 'Nhả oxy mạnh vào ban đêm thay vì ban ngày, cực hợp để trong phòng ngủ.',
      'icon': '🪴',
      'bgColor': '0xFFFFF3E0',
      'iconColor': '0xFFE65100',
    },
    {
      'name': 'Cây Lan Ý',
      'fact': 'Hút các tia bức xạ từ màn hình máy tính và hút ẩm cực kỳ tốt.',
      'icon': '🌸',
      'bgColor': '0xFFFCE4EC',
      'iconColor': '0xFF880E4F',
    },
  ];

  @override
  void initState() {
    super.initState();
    _randomizePlant();
  }

  void _randomizePlant() {
    final random = Random();
    _selectedPlant = _plantsFact[random.nextInt(_plantsFact.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Có thể bạn chưa biết?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B1B1B),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFF757575), size: 20),
              onPressed: () {
                setState(() {
                  _randomizePlant();
                });
              },
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            )
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(int.parse(_selectedPlant['bgColor']!)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _selectedPlant['icon']!,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedPlant['name']!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(int.parse(_selectedPlant['iconColor']!)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _selectedPlant['fact']!,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Color(int.parse(_selectedPlant['iconColor']!)).withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
