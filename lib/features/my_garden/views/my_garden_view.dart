import 'package:flutter/material.dart';
import 'package:plant_notebook/features/library-plant/views/library_plant_detail_view.dart';
import 'package:plant_notebook/features/my_garden/controllers/my_garden_controller.dart';
import 'package:plant_notebook/utils/constant.dart';
import 'package:provider/provider.dart';

class MyGardenView extends StatelessWidget {
  const MyGardenView({super.key});

  @override
  Widget build(BuildContext context) {
    // Lắng nghe thay đổi để danh sách cây cập nhật ngay sau khi thêm/xóa.
    return Consumer<MyGardenController>(
      builder: (context, controller, _) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final plants = controller.savedPlants;

        if (plants.isEmpty) {
          // Trạng thái rỗng khi chưa có cây nào được lưu.
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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cây của tôi (${plants.length})',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF173722),
              ),
            ),
            const SizedBox(height: 14),
            ...plants.map(
              (plant) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LibraryPlantDetailView(plant: plant),
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
                              plant.imageUrl,
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
                                plant.name,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF183224),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                plant.shortDescription,
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
                            await controller.removePlant(plant.id);
                            if (!context.mounted) {
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Đã xóa ${plant.name} khỏi vườn của tôi',
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
              ),
            ),
          ],
        );
      },
    );
  }
}
