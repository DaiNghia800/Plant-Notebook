import 'package:flutter/material.dart';
import 'package:plant_notebook/screens/plant_detail/plant_detail_screen.dart';
import 'package:plant_notebook/controller/my_garden_controller.dart';
import 'package:plant_notebook/common/styles/app_colors.dart';
import 'package:plant_notebook/data/models/category.dart';
import 'package:plant_notebook/data/models/garden_plant.dart';
import 'package:plant_notebook/data/models/my_garden_item.dart';
import 'package:plant_notebook/screens/my_garden/widget/my_garden/my_garden_plant_form_sheet.dart';
import 'package:provider/provider.dart';

class MyGardenScreen extends StatefulWidget {
  const MyGardenScreen({super.key});

  @override
  State<MyGardenScreen> createState() => _MyGardenScreenState();
}

class _MyGardenScreenState extends State<MyGardenScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MyGardenController>(
      builder: (context, controller, _) {
        final List<GardenCategory> category = controller.plantCategory;
        final gardenPlants = controller.savedPlants;

        return Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 100,
                  left: 20,
                  right: 20,
                  bottom: 60,
                ),
                child: gardenPlants.isEmpty
                    ? _buildEmptyState()
                    : _buildGardenList(context, gardenPlants, controller),
              ),
            ),
            Positioned(
              bottom: 150,
              right: 20,
              child: GestureDetector(
                onTap: () =>
                    _openPlantForm(context, controller, category: category),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2E7D32),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.spa_outlined, size: 48, color: primaryColor),
          SizedBox(height: 12),
          Text(
            'Vườn của bạn chưa có cây nào.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF21352A),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Vào Từ điển cây để thêm cây yêu thích vào vườn.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF4F6458)),
          ),
        ],
      ),
    );
  }

  Widget _buildGardenList(
    BuildContext context,
    List<MyGardenItem> gardenPlants,
    MyGardenController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cây của tôi (${gardenPlants.length})',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF173722),
          ),
        ),
        const SizedBox(height: 14),
        ...gardenPlants.map(
          (gardenPlant) {
            final libraryPlant =
                controller.getLibraryPlant(gardenPlant.libraryPlantId);

            // Bỏ qua nếu cây gốc không còn tồn tại trong thư viện (phòng hờ)
            if (libraryPlant == null) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PlantDetailScreen(plant: libraryPlant),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 72,
                          height: 72,
                          child: Image.network(
                            libraryPlant.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: const Color(0xFFE3EEE6),
                                child: const Icon(
                                  Icons.local_florist,
                                  color: primaryColor,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              libraryPlant.name,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF183224),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              libraryPlant.shortDescription,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF4B6255),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Xóa khỏi vườn',
                        onPressed: () async {
                          // Xóa cây khỏi vườn và hiển thị thông báo.
                          await controller.removePlant(gardenPlant.id);
                          if (!context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Đã xóa ${libraryPlant.name} khỏi vườn của tôi',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Color(0xFF9B3A3A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Future<void> _openPlantForm(
    BuildContext context,
    MyGardenController controller, {
    required List<GardenCategory> category,
    GardenPlantProfile? initialValue,
  }) async {
    await showModalBottomSheet<GardenPlantProfile>(
      context: context,
      isScrollControlled: true,
      backgroundColor: neutral,
      builder: (_) {
        return MyGardenPlantFormSheet(
          initialValue: initialValue,
          plantOptions: category,
        );
      },
    );
  }
}
