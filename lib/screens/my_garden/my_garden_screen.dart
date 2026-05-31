import 'package:flutter/material.dart';
import 'package:plant_notebook/common/styles/app_colors.dart';
import 'package:plant_notebook/controller/my_garden_controller.dart';
import 'package:plant_notebook/data/models/category.dart';
import 'package:plant_notebook/data/models/garden_plant.dart';
import 'package:plant_notebook/screens/my_garden/widget/my_garden/my_garden_add_plant_card.dart';
import 'package:plant_notebook/screens/my_garden/widget/my_garden/my_garden_filter_chips.dart';
import 'package:plant_notebook/screens/my_garden/widget/my_garden/my_garden_header.dart';
import 'package:plant_notebook/screens/my_garden/widget/my_garden/my_garden_plant_card.dart';
import 'package:plant_notebook/screens/my_garden/widget/my_garden/my_garden_plant_form_sheet.dart';
import 'package:plant_notebook/screens/my_garden/plant_detail_screen.dart';
import 'package:provider/provider.dart';

class MyGardenScreen extends StatefulWidget {
  const MyGardenScreen({super.key});

  @override
  State<MyGardenScreen> createState() => _MyGardenScreenState();
}

class _MyGardenScreenState extends State<MyGardenScreen> {
  Category _selectedCategory = Category.all;

  @override
  Widget build(BuildContext context) {
    return Consumer<MyGardenController>(
      builder: (context, controller, _) {
        final List<GardenPlantProfile> allPlants = controller.plantProfiles;
        final List<GardenCategory> category = controller.plantCategory;
        final List<GardenPlantProfile> visiblePlants = allPlants
            .where((plant) {
              if (_selectedCategory == Category.all) {
                return true;
              }
              return plant.category.name == _selectedCategory;
            })
            .toList(growable: false);

        return Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  top: 100,
                  left: 20,
                  right: 20,
                  bottom: 60,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyGardenHeader(totalPlants: allPlants.length),
                    if (controller.errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        controller.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                    const SizedBox(height: 16),
                    MyGardenFilterChips(
                      selectedCategory: _selectedCategory,
                      onCategoryChanged: (category) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    GridView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: visiblePlants.length + 1,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 0.72,
                          ),
                      itemBuilder: (context, index) {
                        if (index == visiblePlants.length) {
                          return MyGardenAddPlantCard(
                            onTap: () => _openPlantForm(
                              context,
                              controller,
                              category: category,
                            ),
                          );
                        }
                        final GardenPlantProfile profile = visiblePlants[index];
                        return MyGardenPlantCard(
                          profile: profile,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  PlantDetailScreen(profile: profile),
                            ),
                          ),
                          onEdit: () => _openPlantForm(
                            context,
                            controller,
                            category: category,
                            initialValue: profile,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
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
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
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
