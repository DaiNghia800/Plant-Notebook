import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plant_notebook/controller/library_plant_controller.dart';
import 'package:plant_notebook/data/models/library_plant_item.dart';
import 'package:plant_notebook/controller/profile_controller.dart';
import 'package:plant_notebook/screens/my_garden/plant_detail_screen.dart';
import 'dart:math';

class HomeDiscoverPlant extends StatefulWidget {
  const HomeDiscoverPlant({super.key});

  @override
  State<HomeDiscoverPlant> createState() => _HomeDiscoverPlantState();
}

class _HomeDiscoverPlantState extends State<HomeDiscoverPlant> {
  LibraryPlantItem? _selectedPlant;

  void _randomizePlant(List<LibraryPlantItem> plants) {
    if (plants.isEmpty) return;
    final random = Random();
    setState(() {
      _selectedPlant = plants[random.nextInt(plants.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<ProfileController>();
    final libraryController = context.watch<LibraryPlantController>();
    final plants = libraryController.plants;

    if (_selectedPlant == null && plants.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _randomizePlant(plants);
      });
    }

    if (plants.isEmpty) {
      return const SizedBox.shrink(); // Hide if no data
    }

    final plant = _selectedPlant ?? plants.first;
    final String imageUrl = plant.imageUrl;
    final String description = plant.description.isNotEmpty
        ? plant.description
        : lang.tr('default_plant_desc');

    final plantName = plant.name.isNotEmpty
        ? plant.name
        : (plant.scientificName ?? 'Unknown');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              lang.tr('did_you_know_home'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.refresh,
                color: Color(0xFF757575),
                size: 20,
              ),
              onPressed: () {
                _randomizePlant(plants);
              },
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
        const SizedBox(height: 14),
        InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PlantDetailScreen(libraryPlant: plant),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Background Image with gradient
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: imageUrl.startsWith('http')
                      ? Image.network(
                          imageUrl,
                          width: double.infinity,
                          height: 140,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildFallbackBg(),
                        )
                      : _buildFallbackBg(),
                ),
                // Gradient Overlay
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.black.withOpacity(0.2),
                        Colors.transparent,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              plantName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              description,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.4,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Expanded(
                        flex: 1,
                        child: SizedBox(),
                      ), // Space for the right side
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackBg() {
    return Container(
      width: double.infinity,
      height: 140,
      color: const Color(0xFFE8F5E9),
      child: const Center(
        child: Icon(Icons.eco, color: Color(0xFF81C784), size: 60),
      ),
    );
  }
}
