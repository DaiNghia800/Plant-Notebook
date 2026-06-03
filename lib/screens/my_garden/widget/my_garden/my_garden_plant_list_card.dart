import 'package:flutter/material.dart';
import 'package:plant_notebook/data/models/garden_plant.dart';

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
    final (String titleText, Color color, IconData icon) statusMeta =
        switch (profile.status) {
          GardenPlantStatus.healthy => (
            'KHOẺ MẠNH',
            const Color(0xFF199E63),
            Icons.spa,
          ),
          GardenPlantStatus.thirsty => (
            'ĐANG KHÁT',
            const Color(0xFFB8860B),
            Icons.sunny,
          ),
          GardenPlantStatus.sick => (
            'ĐANG BỆNH',
            const Color(0xFFC62828),
            Icons.warning,
          ),
        };
    final (title, statusColor, statusIcon) = statusMeta;

    final String subtitle =
        'Tưới: ${profile.reminderSetting.wateringCycleDays} ngày/lần';

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
                    ? Image.network(profile.imageUrl, fit: BoxFit.cover)
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
