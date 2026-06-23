import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plant_notebook/controller/library_plant_controller.dart';
import 'package:plant_notebook/data/models/library_plant_item.dart';
import 'package:plant_notebook/screens/my_garden/plant_detail_screen.dart';
import 'package:plant_notebook/common/styles/app_colors.dart';
import 'package:plant_notebook/controller/profile_controller.dart';

class LibraryPlantScreen extends StatefulWidget {
  const LibraryPlantScreen({super.key});

  @override
  State<LibraryPlantScreen> createState() => _LibraryPlantScreenState();
}

class _LibraryPlantScreenState extends State<LibraryPlantScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _query = '';
  String _selectedCategory = '';
  String _selectedLight = '';
  String _selectedWater = '';
  String _selectedDifficulty = '';

  int _visibleCount = 10;
  List<Map<String, dynamic>> _randomFacts = [];
  List<LibraryPlantItem>? _previousPlants;

  List<String> _categoryOptions(List<LibraryPlantItem> plants) => <String>[
    '',
    ...{for (final plant in plants) plant.category},
  ];

  List<String> _lightOptions(List<LibraryPlantItem> plants) => <String>[
    '',
    ...{for (final plant in plants) plant.lightLevel},
  ];

  List<String> _waterOptions(List<LibraryPlantItem> plants) => <String>[
    '',
    ...{for (final plant in plants) plant.waterNeed},
  ];

  List<String> _difficultyOptions(List<LibraryPlantItem> plants) => <String>[
    '',
    ...{for (final plant in plants) plant.difficulty},
  ];

  List<LibraryPlantItem> _filteredPlants(List<LibraryPlantItem> plants) {
    return plants.where((plant) {
      final query = _removeDiacritics(_query.toLowerCase());
      final name = _removeDiacritics(plant.name.toLowerCase());
      final category = _removeDiacritics(plant.category.toLowerCase());
      final bool matchesQuery =
          name.contains(query) || category.contains(query);
      final bool matchesCategory =
          _selectedCategory.isEmpty || plant.category == _selectedCategory;
      final bool matchesLight =
          _selectedLight.isEmpty || plant.lightLevel == _selectedLight;
      final bool matchesWater =
          _selectedWater.isEmpty || plant.waterNeed == _selectedWater;
      final bool matchesDifficulty =
          _selectedDifficulty.isEmpty ||
          plant.difficulty == _selectedDifficulty;

      return matchesQuery &&
          matchesCategory &&
          matchesLight &&
          matchesWater &&
          matchesDifficulty;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LibraryPlantController>().loadPlants();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<ProfileController>();
    return Consumer<LibraryPlantController>(
      builder: (context, controller, _) {
        // ── Loading ──────────────────────────────────────────────────────────
        if (controller.isLoading) {
          return _LoadingView();
        }

        // ── Error ────────────────────────────────────────────────────────────
        if (controller.hasError) {
          return _ErrorView(
            message: controller.errorMessage ?? lang.tr('error_occurred'),
            onRetry: controller.refresh,
          );
        }

        final List<LibraryPlantItem> allPlants = controller.plants;

        // Trộn ngẫu nhiên 3 fun facts từ danh sách cây thật
        if (_previousPlants == null || _previousPlants != allPlants) {
          _previousPlants = allPlants;
          final List<Map<String, dynamic>> allFacts = [];
          for (final plant in allPlants) {
            for (final fact in plant.funFacts) {
              allFacts.add({'plant': plant, 'fact': fact});
            }
          }
          if (allFacts.isEmpty) {
            _randomFacts = [];
          } else {
            final list = List<Map<String, dynamic>>.from(allFacts)..shuffle();
            _randomFacts = list.take(3).toList();
          }
        }

        final List<LibraryPlantItem> plants = _filteredPlants(allPlants);

        final LibraryPlantItem? featured =
            plants.cast<LibraryPlantItem?>().firstWhere(
              (p) => p?.isTrending ?? false,
              orElse: () => null,
            ) ??
            (plants.isNotEmpty ? plants.first : null);

        final displayedPlants = plants.take(_visibleCount).toList();

        return RefreshIndicator(
          onRefresh: controller.refresh,
          color: primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(
                top: 100,
                left: 20,
                right: 20,
                bottom: 120,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBox(),
                  const SizedBox(height: 16),
                  _buildCategoryRow(_categoryOptions(allPlants)),
                  const SizedBox(height: 14),
                  _buildFilterRow(
                    lang: lang,
                    lightOptions: _lightOptions(allPlants),
                    waterOptions: _waterOptions(allPlants),
                    difficultyOptions: _difficultyOptions(allPlants),
                  ),
                  const SizedBox(height: 16),
                  _buildDidYouKnowSection(),
                  const SizedBox(height: 16),
                  if (featured != null) _buildFeaturedCard(featured),
                  if (featured != null) const SizedBox(height: 16),
                  if (plants.isEmpty)
                    _buildEmptyState()
                  else ...[
                    ...displayedPlants.map(
                      (plant) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _PlantListCard(
                          plant: plant,
                          onTap: () => _openDetail(plant),
                        ),
                      ),
                    ),
                  ],
                  if (plants.length > _visibleCount) ...[
                    const SizedBox(height: 10),
                    Center(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _visibleCount += 10;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,
                          side: const BorderSide(
                            color: primaryColor,
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                        ),
                        child: Text(
                          lang.tr('load_more'),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBox() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3323) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isDark ? Border.all(color: const Color(0xFF2D4C34)) : null,
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() {
          _query = value.trim();
          _visibleCount = 10;
        }),
        decoration: InputDecoration(
          hintText: context.read<ProfileController>().tr('search_library'),
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _query = '';
                      _visibleCount = 10;
                    });
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildCategoryRow(List<String> categoryOptions) {
    final lang = context.read<ProfileController>();
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categoryOptions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final String category = categoryOptions[index];
          final bool selected = _selectedCategory == category;
          return ChoiceChip(
            label: Text(category.isEmpty ? lang.tr('all_filter') : category),
            selected: selected,
            onSelected: (_) => setState(() {
              _selectedCategory = category;
              _visibleCount = 10;
            }),
            selectedColor: primaryColor,
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1E3323)
                : const Color(0xFFE8F5E9),
            labelStyle: TextStyle(
              color: selected
                  ? Colors.white
                  : (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : const Color(0xFF0E3B1A)),
              fontWeight: FontWeight.w700,
            ),
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterRow({
    required ProfileController lang,
    required List<String> lightOptions,
    required List<String> waterOptions,
    required List<String> difficultyOptions,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _FilterMenuChip(
          label:
              '${lang.tr('light_filter')}: ${_selectedLight.isEmpty ? lang.tr('all_filter') : _selectedLight}',
          icon: Icons.wb_sunny_outlined,
          options: lightOptions
              .map((e) => e.isEmpty ? lang.tr('all_filter') : e)
              .toList(),
          onSelected: (value) => setState(() {
            _selectedLight = value == lang.tr('all_filter') ? '' : value;
            _visibleCount = 10;
          }),
        ),
        _FilterMenuChip(
          label:
              '${lang.tr('water_filter')}: ${_selectedWater.isEmpty ? lang.tr('all_filter') : _selectedWater}',
          icon: Icons.water_drop_outlined,
          options: waterOptions
              .map((e) => e.isEmpty ? lang.tr('all_filter') : e)
              .toList(),
          onSelected: (value) => setState(() {
            _selectedWater = value == lang.tr('all_filter') ? '' : value;
            _visibleCount = 10;
          }),
        ),
        _FilterMenuChip(
          label:
              '${lang.tr('difficulty_filter')}: ${_selectedDifficulty.isEmpty ? lang.tr('all_filter') : _selectedDifficulty}',
          icon: Icons.stacked_line_chart,
          options: difficultyOptions
              .map((e) => e.isEmpty ? lang.tr('all_filter') : e)
              .toList(),
          onSelected: (value) => setState(() {
            _selectedDifficulty = value == lang.tr('all_filter') ? '' : value;
            _visibleCount = 10;
          }),
        ),
      ],
    );
  }

  Widget _buildFeaturedCard(LibraryPlantItem plant) {
    return InkWell(
      onTap: () => _openDetail(plant),
      borderRadius: BorderRadius.circular(26),
      child: Container(
        height: 210,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          color: Colors.black,
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Image.network(
                plant.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFF7FA58D),
                    child: const Center(
                      child: Icon(Icons.eco, size: 72, color: Colors.white),
                    ),
                  );
                },
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(26)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x0A000000), Color(0xBB000000)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: const Color(0xFF9CF17A),
                    ),
                    child: const Text(
                      'TRENDING SPECIMEN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: Color(0xFF113418),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    plant.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 30,
                      height: 1.1,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    plant.shortDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3323) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2D4C34) : Colors.black12,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 34,
            color: isDark ? Colors.white54 : const Color(0xFF6C7A70),
          ),
          const SizedBox(height: 8),
          Text(
            context.read<ProfileController>().tr('no_plant_found'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF4A5A4E),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDidYouKnowSection() {
    if (_randomFacts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.read<ProfileController>().tr('did_you_know'),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : const Color(0xFF102A17),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 165,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _randomFacts.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final Map<String, dynamic> item = _randomFacts[index];
              final LibraryPlantItem plant = item['plant'] as LibraryPlantItem;
              final String fact = item['fact'] as String;
              return _DidYouKnowCard(
                plant: plant,
                fact: fact,
                onTap: () => _openDetail(plant),
              );
            },
          ),
        ),
      ],
    );
  }

  void _openDetail(LibraryPlantItem plant) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PlantDetailScreen(libraryPlant: plant),
      ),
    );
  }
}

class _PlantListCard extends StatelessWidget {
  const _PlantListCard({required this.plant, required this.onTap});

  final LibraryPlantItem plant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1E3323)
              : Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: isDark ? const Color(0xFF2D4C34) : Colors.black12,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: Image.network(
                  plant.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFFE8EFE7),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.local_florist,
                        color: primaryColor,
                        size: 52,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    plant.name,
                    style: TextStyle(
                      fontSize: 33,
                      height: 1,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF101713),
                    ),
                  ),
                ),
                if (plant.isRare)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF4A1F2D)
                          : const Color(0xFFF9D9E4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Rare',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? const Color(0xFFF9D9E4)
                            : const Color(0xFF8A3E58),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              plant.shortDescription,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white70 : const Color(0xFF404F45),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 6,
              children: [
                _MetaText(
                  icon: Icons.wb_sunny_outlined,
                  text: plant.lightLevel,
                ),
                _MetaText(
                  icon: Icons.water_drop_outlined,
                  text: plant.waterNeed,
                ),
                _MetaText(icon: Icons.eco_outlined, text: plant.difficulty),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaText extends StatelessWidget {
  const _MetaText({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final contentColor = isDark
        ? const Color(0xFF81C784)
        : const Color(0xFF1E5A2F);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: contentColor),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : const Color(0xFF2B4A34),
          ),
        ),
      ],
    );
  }
}

class _DidYouKnowCard extends StatelessWidget {
  const _DidYouKnowCard({
    required this.plant,
    required this.fact,
    required this.onTap,
  });

  final LibraryPlantItem plant;
  final String fact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E3323) : const Color(0xFFF3F8F4),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark ? const Color(0xFF2D4C34) : const Color(0xFFE1EAE2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2D4C34)
                        : const Color(0xFFE3F1E4),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plant.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF102A17),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.watch<ProfileController>().tr('plant_tip'),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.white54
                              : const Color(0xFF688071),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              fact,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: isDark ? Colors.white70 : const Color(0xFF3E4E43),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterMenuChip extends StatelessWidget {
  const _FilterMenuChip({
    required this.label,
    required this.icon,
    required this.options,
    required this.onSelected,
  });

  final String label;
  final IconData icon;
  final List<String> options;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E3323) : const Color(0xFFE5EFE8);
    final borderColor = isDark
        ? const Color(0xFF2D4C34)
        : const Color(0xFFD2E1D7);
    final contentColor = isDark
        ? const Color(0xFF81C784)
        : const Color(0xFF1D5630);

    return PopupMenuButton<String>(
      onSelected: onSelected,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      itemBuilder: (context) {
        return options
            .map(
              (value) =>
                  PopupMenuItem<String>(value: value, child: Text(value)),
            )
            .toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: contentColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: contentColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.expand_more, size: 14, color: contentColor),
          ],
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: primaryColor),
            const SizedBox(height: 16),
            Text(
              context.watch<ProfileController>().tr('loading_library'),
              style: TextStyle(
                color: isDark ? Colors.white70 : const Color(0xFF4A5A4E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 52,
              color: Color(0xFFB05C5C),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : const Color(0xFF4A3A3A),
                fontWeight: FontWeight.w600,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.watch<ProfileController>().tr('retry')),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
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
    RegExp(r'[ỲÝỴỶỸ]'),
  ];

  var result = str;
  for (var i = 0; i < vietnameseRegex.length; i++) {
    result = result.replaceAll(vietnameseRegex[i], vietnamese[i]);
  }
  return result;
}
