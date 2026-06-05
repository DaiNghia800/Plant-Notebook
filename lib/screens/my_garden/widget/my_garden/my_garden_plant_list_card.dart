import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:plant_notebook/data/models/garden_plant.dart';
import 'package:provider/provider.dart';
import 'package:plant_notebook/controller/profile_controller.dart';

class MyGardenPlantListCard extends StatelessWidget {
  const MyGardenPlantListCard({
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
    final lang = context.watch<ProfileController>();
    final (String titleText, Color color, IconData icon) statusMeta =
        switch (profile.status) {
          GardenPlantStatus.healthy => (
            lang.tr('status_healthy').toUpperCase(),
            const Color(0xFF199E63),
            Icons.spa,
          ),
          GardenPlantStatus.thirsty => (
            lang.tr('status_thirsty').toUpperCase(),
            const Color(0xFFB8860B),
            Icons.sunny,
          ),
          GardenPlantStatus.sick => (
            lang.tr('status_sick').toUpperCase(),
            const Color(0xFFC62828),
            Icons.warning,
          ),
        };
    final (title, statusColor, statusIcon) = statusMeta;

    final String subtitle =
        lang.tr('watering_format').replaceAll('{days}', profile.reminderSetting.wateringCycleDays.toString());

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            // Plant Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 72,
                height: 72,
                child: profile.imageUrl.isNotEmpty
                    ? (profile.imageUrl.startsWith('http') || profile.imageUrl.startsWith('https'))
                        ? CachedNetworkImage(
                            imageUrl: profile.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: const Color(0xFFF1F6F2),
                              child: const Icon(
                                Icons.local_florist,
                                size: 32,
                                color: Color(0xFF88AA90),
                              ),
                            ),
                          )
                        : Image.file(
                            File(profile.imageUrl),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: const Color(0xFFF1F6F2),
                              child: const Icon(
                                Icons.local_florist,
                                size: 32,
                                color: Color(0xFF88AA90),
                              ),
                            ),
                          )
                    : Container(
                        color: const Color(0xFFF1F6F2),
                        child: const Icon(
                          Icons.local_florist,
                          size: 32,
                          color: Color(0xFF88AA90),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            // Info Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (profile.latinName.isNotEmpty) ...[
                    Text(
                      profile.latinName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                  ],
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, color: statusColor, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            title,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.water_drop, size: 14, color: statusColor),
                          const SizedBox(width: 2),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Edit Button
            GestureDetector(
              onTap: onEdit,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit,
                  size: 16,
                  color: Color(0xFF5A5A5A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
