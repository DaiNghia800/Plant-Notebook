import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:plant_notebook/data/models/garden_plant.dart';

class MyGardenPlantCard extends StatelessWidget {
  const MyGardenPlantCard({
    super.key,
    required this.profile,
    required this.onTap,
    required this.onEdit,
  });

  final GardenPlantProfile profile;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final (String title, Color color, IconData icon) statusMeta =
        switch (profile.status) {
          GardenPlantStatus.healthy => (
            'KHOE MANH',
            const Color(0xFF199E63),
            Icons.spa,
          ),
          GardenPlantStatus.thirsty => (
            'DANG KHAT',
            const Color(0xFFB8860B),
            Icons.sunny,
          ),
          GardenPlantStatus.sick => (
            'DANG BENH',
            const Color(0xFFC62828),
            Icons.warning,
          ),
        };
    final (title, color, icon) = statusMeta;

    final String subtitle =
        '${profile.reminderSetting.wateringCycleDays} ngày/lần';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      child: _PlantImage(profile: profile),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, color: color, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            title,
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: onEdit, // Gọi hàm sửa khi nhấn vào đây
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface, // Nền trắng để nổi bật trên ảnh
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 14,
                          color: Color(0xFF5A5A5A),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                profile.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF5A5A5A),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Icon(Icons.water_drop, size: 16, color: color),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlantImage extends StatelessWidget {
  const _PlantImage({required this.profile});

  final GardenPlantProfile profile;

  @override
  Widget build(BuildContext context) {
    if (profile.imageUrl.isNotEmpty) {
      if (profile.imageUrl.startsWith('http') || profile.imageUrl.startsWith('https')) {
        return CachedNetworkImage(
          imageUrl: profile.imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: const Color(0xFFF1F6F2),
            child: const Center(
              child: Icon(Icons.local_florist, size: 42, color: Color(0xFF88AA90)),
            ),
          ),
        );
      } else {
        return Image.file(
          File(profile.imageUrl),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: const Color(0xFFF1F6F2),
            child: const Center(
              child: Icon(Icons.local_florist, size: 42, color: Color(0xFF88AA90)),
            ),
          ),
        );
      }
    }

    return Container(
      color: const Color(0xFFF1F6F2),
      child: const Center(
        child: Icon(Icons.local_florist, size: 42, color: Color(0xFF88AA90)),
      ),
    );
  }
}
