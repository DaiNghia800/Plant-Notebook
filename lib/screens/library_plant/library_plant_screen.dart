import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plant_notebook/controller/library_plant_controller.dart';
import 'package:plant_notebook/data/models/library_plant_item.dart';
import 'package:plant_notebook/screens/my_garden/plant_detail_screen.dart';
import 'package:plant_notebook/common/styles/app_colors.dart';

class LibraryPlantScreen extends StatefulWidget {
  const LibraryPlantScreen({super.key});

  @override
  State<LibraryPlantScreen> createState() => _LibraryPlantScreenState();
}

class _LibraryPlantScreenState extends State<LibraryPlantScreen> {
  final TextEditingController _searchController = TextEditingController();

  static const String _all = 'Tất cả';

  String _query = '';
  String _selectedCategory = _all;
  String _selectedLight = _all;
  String _selectedWater = _all;
  String _selectedDifficulty = _all;

  int _visibleCount = 10;
  List<Map<String, dynamic>> _randomFacts = [];
  List<LibraryPlantItem>? _previousPlants;

  List<String> _categoryOptions(List<LibraryPlantItem> plants) => <String>[
        _all,
        ...{for (final plant in plants) plant.category},
      ];

  List<String> _lightOptions(List<LibraryPlantItem> plants) => <String>[
        _all,
        ...{for (final plant in plants) plant.lightLevel},
      ];

  List<String> _waterOptions(List<LibraryPlantItem> plants) => <String>[
        _all,
        ...{for (final plant in plants) plant.waterNeed},
      ];

  List<String> _difficultyOptions(List<LibraryPlantItem> plants) => <String>[
        _all,
        ...{for (final plant in plants) plant.difficulty},
      ];

  List<LibraryPlantItem> _filteredPlants(List<LibraryPlantItem> plants) {
    return plants.where((plant) {
      final bool matchesQuery =
          plant.name.toLowerCase().contains(_query.toLowerCase()) ||
          plant.category.toLowerCase().contains(_query.toLowerCase());
      final bool matchesCategory =
          _selectedCategory == _all || plant.category == _selectedCategory;
      final bool matchesLight =
          _selectedLight == _all || plant.lightLevel == _selectedLight;
      final bool matchesWater =
          _selectedWater == _all || plant.waterNeed == _selectedWater;
      final bool matchesDifficulty =
          _selectedDifficulty == _all ||
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
    return Consumer<LibraryPlantController>(
      builder: (context, controller, _) {
        // ── Loading ──────────────────────────────────────────────────────────
        if (controller.isLoading) {
          return const _LoadingView();
        }

        // ── Error ────────────────────────────────────────────────────────────
        if (controller.hasError) {
          return _ErrorView(
            message: controller.errorMessage ?? 'Đã xảy ra lỗi.',
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
              allFacts.add({
                'plant': plant,
                'fact': fact,
              });
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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBox(),
            const SizedBox(height: 16),
            _buildCategoryRow(_categoryOptions(allPlants)),
            const SizedBox(height: 14),
            _buildFilterRow(
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
                      side: const BorderSide(color: primaryColor, width: 1.5),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    child: const Text(
                      'Xem thêm cây trồng',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ],
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildSearchBox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() {
          _query = value.trim();
          _visibleCount = 10;
        }),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm cây trồng...',
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
            label: Text(category),
            selected: selected,
            onSelected: (_) => setState(() {
              _selectedCategory = category;
              _visibleCount = 10;
            }),
            selectedColor: primaryColor,
            backgroundColor: const Color(0xFF7BCF7A),
            labelStyle: TextStyle(
              color: selected ? Colors.white : const Color(0xFF0E3B1A),
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
    required List<String> lightOptions,
    required List<String> waterOptions,
    required List<String> difficultyOptions,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _FilterMenuChip(
          label: 'Ánh sáng: $_selectedLight',
          icon: Icons.wb_sunny_outlined,
          options: lightOptions,
          onSelected: (value) => setState(() {
            _selectedLight = value;
            _visibleCount = 10;
          }),
        ),
        _FilterMenuChip(
          label: 'Nước: $_selectedWater',
          icon: Icons.water_drop_outlined,
          options: waterOptions,
          onSelected: (value) => setState(() {
            _selectedWater = value;
            _visibleCount = 10;
          }),
        ),
        _FilterMenuChip(
          label: 'Độ khó: $_selectedDifficulty',
          icon: Icons.stacked_line_chart,
          options: difficultyOptions,
          onSelected: (value) => setState(() {
            _selectedDifficulty = value;
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
        height: 198,
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
                    style: const TextStyle(
                      fontSize: 38,
                      height: 1,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    plant.shortDescription,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 16,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off_rounded, size: 34, color: Color(0xFF6C7A70)),
          SizedBox(height: 8),
          Text(
            'Không tìm thấy cây phù hợp bộ lọc hiện tại.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF4A5A4E),
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
        const Text(
          'Bạn có biết?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF102A17),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _randomFacts.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final Map<String, dynamic> item = _randomFacts[index];
              final LibraryPlantItem plant = item['plant'] as LibraryPlantItem;
              final String fact = item['fact'] as String;
              return _DidYouKnowCard(plant: plant, fact: fact);
            },
          ),
        ),
      ],
    );
  }

  void _openDetail(LibraryPlantItem plant) {
    // TODO: Navigate to library plant detail screen
    // Navigator.of(context).push(
    //   MaterialPageRoute(builder: (context) => PlantDetailScreen(plant: plant)),
    // );
  }
}

class _PlantListCard extends StatelessWidget {
  const _PlantListCard({required this.plant, required this.onTap});

  final LibraryPlantItem plant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: Colors.black12),
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
                    style: const TextStyle(
                      fontSize: 33,
                      height: 1,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF101713),
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
                      color: const Color(0xFFF9D9E4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Rare',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF8A3E58),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              plant.shortDescription,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF404F45),
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF1E5A2F)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2B4A34),
          ),
        ),
      ],
    );
  }
}

class _DidYouKnowCard extends StatelessWidget {
  const _DidYouKnowCard({required this.plant, required this.fact});

  final LibraryPlantItem plant;
  final String fact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F8F4),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE1EAE2)),
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
                  color: const Color(0xFFE3F1E4),
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
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF102A17),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Mẹo chăm cây nhanh',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF688071),
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
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              height: 1.45,
              color: Color(0xFF3E4E43),
            ),
          ),
        ],
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
          color: const Color(0xFFE5EFE8),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFD2E1D7)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: const Color(0xFF1D5630)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF1D5630),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.expand_more, size: 14, color: Color(0xFF1D5630)),
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
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: primaryColor),
            SizedBox(height: 16),
            Text(
              'Đang tải thư viện cây...',
              style: TextStyle(
                color: Color(0xFF4A5A4E),
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
              style: const TextStyle(
                color: Color(0xFF4A3A3A),
                fontWeight: FontWeight.w600,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
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
