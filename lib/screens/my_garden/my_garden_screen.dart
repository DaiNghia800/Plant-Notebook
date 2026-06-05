import 'package:flutter/material.dart';
import 'package:plant_notebook/common/styles/app_colors.dart';
import 'package:plant_notebook/controller/my_garden_controller.dart';
import 'package:plant_notebook/data/models/category.dart';
import 'package:plant_notebook/data/models/garden_plant.dart';
import 'package:plant_notebook/screens/my_garden/widget/my_garden/my_garden_filter_chips.dart';
import 'package:plant_notebook/screens/my_garden/widget/my_garden/my_garden_header.dart';
import 'package:plant_notebook/screens/my_garden/widget/my_garden/my_garden_plant_card.dart';
import 'package:plant_notebook/screens/my_garden/widget/my_garden/my_garden_plant_list_card.dart';
import 'package:plant_notebook/screens/my_garden/widget/my_garden/my_garden_plant_form_sheet.dart';
import 'package:plant_notebook/screens/my_garden/plant_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:plant_notebook/controller/profile_controller.dart';

class MyGardenScreen extends StatefulWidget {
  const MyGardenScreen({super.key});

  @override
  State<MyGardenScreen> createState() => _MyGardenScreenState();
}

class _MyGardenScreenState extends State<MyGardenScreen> {
  Category _selectedCategory = Category.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MyGardenController>(context, listen: false).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<ProfileController>();
    return Consumer<MyGardenController>(
      builder: (context, controller, _) {
        final List<GardenPlantProfile> allPlants = controller.plantProfiles;
        final List<GardenCategory> category = controller.plantCategory;
        final List<GardenPlantProfile> visiblePlants = allPlants
            .where((plant) {
              if (_selectedCategory != Category.all &&
                  plant.category.name != _selectedCategory) {
                return false;
              }
              if (controller.searchQuery.isNotEmpty) {
                final query = _removeDiacritics(controller.searchQuery.toLowerCase());
                final name = _removeDiacritics(plant.name.toLowerCase());
                final latin = _removeDiacritics(plant.latinName.toLowerCase());
                final matchesName = name.contains(query);
                final matchesLatin = latin.contains(query);
                if (!matchesName && !matchesLatin) {
                  return false;
                }
              }
              return true;
            })
            .toList(growable: true);

        if (controller.sortBy == 'name') {
          visiblePlants.sort((a, b) => a.name.compareTo(b.name));
        } else if (controller.sortBy == 'waterNeed') {
          int getStatusPriority(GardenPlantStatus s) {
            switch (s) {
              case GardenPlantStatus.thirsty:
                return 0;
              case GardenPlantStatus.sick:
                return 1;
              case GardenPlantStatus.healthy:
                return 2;
            }
          }
          visiblePlants.sort((a, b) => getStatusPriority(a.status).compareTo(getStatusPriority(b.status)));
        } else {
          visiblePlants.sort((a, b) => b.startDate.compareTo(a.startDate));
        }

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
                    if (controller.searchQuery.isNotEmpty && visiblePlants.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                lang.tr('no_plant_match'),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (controller.isGridView)
                      GridView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: visiblePlants.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              childAspectRatio: 0.72,
                            ),
                        itemBuilder: (context, index) {
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
                      )
                    else
                      ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: visiblePlants.length,
                        itemBuilder: (context, index) {
                          final GardenPlantProfile profile = visiblePlants[index];
                          return MyGardenPlantListCard(
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (_) {
        return MyGardenPlantFormSheet(
          initialValue: initialValue,
          plantOptions: category,
        );
      },
    );
  }
}

String _removeDiacritics(String str) {
  const vietnamese = 'aAeEoOuUiIdDyY';
  final vietnameseRegex = [
    RegExp(r'[àáạảãâầấậẩẫăằắặẳẵ]'),
    RegExp(r'[ÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴ]'),
    RegExp(r'[èéẹẻẽêềếệểễ]'),
    RegExp(r'[ÈÉẸẺẼÊỀẾỆỂỄ]'),
    RegExp(r'[òóọỏõôồốộổỗơờớợởỡ]'),
    RegExp(r'[ÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠ]'),
    RegExp(r'[ùúụủũưừứựửữ]'),
    RegExp(r'[ÙÚỤỦŨƯỪỨỰỬỮ]'),
    RegExp(r'[ìíịỉĩ]'),
    RegExp(r'[ÌÍỊỈĨ]'),
    RegExp(r'[đ]'),
    RegExp(r'[Đ]'),
    RegExp(r'[ỳýỵỷỹ]'),
    RegExp(r'[ỲÝỴỶỸ]')
  ];

  var result = str;
  for (var i = 0; i < vietnameseRegex.length; i++) {
    result = result.replaceAll(vietnameseRegex[i], vietnamese[i]);
  }
  return result;
}
