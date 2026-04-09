import 'package:flutter/material.dart';
import 'package:plant_notebook/features/library-plant/models/library_plant_item.dart';
import 'package:plant_notebook/features/my_garden/controllers/my_garden_controller.dart';
import 'package:plant_notebook/utils/constant.dart';
import 'package:provider/provider.dart';

class LibraryPlantDetailView extends StatelessWidget {
  const LibraryPlantDetailView({super.key, required this.plant});

  final LibraryPlantItem plant;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: neutral,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: neutral,
            title: Text(
              plant.name,
              style: const TextStyle(
                color: Color(0xFF11331A),
                fontWeight: FontWeight.w700,
              ),
            ),
            iconTheme: const IconThemeData(color: Color(0xFF11331A)),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    plant.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFE6EFE8),
                        child: const Icon(
                          Icons.local_florist,
                          size: 80,
                          color: primaryColor,
                        ),
                      );
                    },
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xA6000000)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoChip(label: plant.category, icon: Icons.category),
                      _InfoChip(label: plant.lightLevel, icon: Icons.wb_sunny),
                      _InfoChip(label: plant.waterNeed, icon: Icons.water_drop),
                      _InfoChip(
                        label: 'Độ khó: ${plant.difficulty}',
                        icon: Icons.stacked_line_chart,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Mô tả đặc tính',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F2A17),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    plant.description,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Color(0xFF3E4E43),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Hướng dẫn chăm sóc chuẩn',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F2A17),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...plant.careGuide.map(
                    (tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 5),
                            child: Icon(
                              Icons.check_circle_rounded,
                              size: 18,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              tip,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.5,
                                color: Color(0xFF3E4E43),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Đồng bộ trạng thái nút với dữ liệu thật trong My Garden.
                  Consumer<MyGardenController>(
                    builder: (context, gardenController, _) {
                      final bool alreadyAdded = gardenController.containsPlant(
                        plant.id,
                      );

                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: alreadyAdded
                              ? null
                              : () async {
                                  // Thêm cây vào vườn và phản hồi kết quả cho người dùng.
                                  final bool added = await gardenController
                                      .addPlant(plant.id);
                                  if (!context.mounted) {
                                    return;
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        added
                                            ? 'Đã thêm ${plant.name} vào vườn của tôi'
                                            : '${plant.name} đã có trong vườn',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                          icon: Icon(
                            alreadyAdded
                                ? Icons.check_circle_rounded
                                : Icons.add_circle_outline,
                          ),
                          label: Text(
                            alreadyAdded
                                ? 'Đã có trong vườn của tôi'
                                : 'Thêm vào vườn của tôi',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            textStyle: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F0E4),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: primaryColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF144123),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
