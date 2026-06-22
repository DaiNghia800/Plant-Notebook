import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:plant_notebook/controller/my_garden_controller.dart';
import 'package:plant_notebook/controller/library_plant_controller.dart';
import 'package:plant_notebook/data/models/category.dart';
import 'package:plant_notebook/data/models/garden_plant.dart';
import 'package:plant_notebook/data/models/care_history.dart';
import 'package:plant_notebook/data/models/library_plant_item.dart';
import 'package:plant_notebook/data/models/reminder.dart';
import 'package:plant_notebook/screens/my_garden/widget/my_garden/my_garden_plant_form_sheet.dart';
import 'package:plant_notebook/screens/my_garden/widget/plant_detail/care_card.dart';
import 'package:plant_notebook/screens/my_garden/widget/plant_detail/plant_action_progress.dart';
import 'package:plant_notebook/screens/my_garden/widget/plant_detail/status_badge.dart';
import 'package:provider/provider.dart';
import 'package:plant_notebook/controller/profile_controller.dart';

class PlantDetailScreen extends StatefulWidget {
  const PlantDetailScreen({super.key, this.profile, this.libraryPlant})
    : assert(
        profile != null || libraryPlant != null,
        'Either profile or libraryPlant must be provided',
      );

  final GardenPlantProfile? profile;
  final LibraryPlantItem? libraryPlant;

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  late LibraryPlantItem _libraryPlant;
  GardenPlantProfile? _currentProfile;
  late List<PlantCareHistory> _careHistory;
  bool _isLoading = false;
  int _daysSinceLastWater = 0;
  int _daysSinceLastFertilize = 0;
  DateTime? _lastWatered;
  DateTime? _lastFertilized;
  int _wateringCycleDays = 0;
  int _fertilizingCycleDays = 0;

  @override
  void initState() {
    super.initState();
    _careHistory = [];
    final controller = context.read<MyGardenController>();
    final libController = context.read<LibraryPlantController>();
    if (widget.profile != null) {
      _currentProfile = widget.profile;
      LibraryPlantItem? matchedPlant;
      // 1. Ưu tiên so sánh tên khoa học (latinName)
      if (_currentProfile!.latinName.trim().isNotEmpty) {
        try {
          matchedPlant = libController.plants.firstWhere(
            (p) =>
                p.scientificName != null &&
                p.scientificName!.toLowerCase().trim() ==
                    _currentProfile!.latinName.toLowerCase().trim(),
          );
        } catch (_) {}
      }

      // 2. Không có tên khoa học hoặc không khớp -> so sánh tên tiếng Việt
      if (matchedPlant == null) {
        try {
          matchedPlant = libController.plants.firstWhere(
            (p) =>
                p.name.toLowerCase().trim() ==
                _currentProfile!.name.toLowerCase().trim(),
          );
        } catch (_) {}
      }

      // 3. Fallback cuối cùng -> so sánh ID
      if (matchedPlant == null) {
        matchedPlant = libController.findById(_currentProfile!.plantId);
      }

      _libraryPlant =
          matchedPlant ??
          controller.getLibraryPlant(_currentProfile!.plantId) ??
          LibraryPlantItem(
            id: _currentProfile!.plantId,
            name: _currentProfile!.name,
            category: GardenCategory.categoryToText(
              _currentProfile!.category.name,
            ),
            shortDescription: '',
            description: '',
            lightLevel: 'Vừa',
            waterNeed: 'Vừa',
            difficulty: 'Vừa',
            careGuide: const [],
            funFacts: const [],
            imageUrl: _currentProfile!.imageUrl,
          );
      _initCareTimings();
      _loadCareHistory();
    } else {
      _libraryPlant = widget.libraryPlant!;
      _currentProfile = controller.getPlantProfileByLibraryId(_libraryPlant.id);
      if (_currentProfile != null) {
        _initCareTimings();
        _loadCareHistory();
      }
    }
  }

  void _initCareTimings() {
    if (_currentProfile == null) return;
    _lastWatered =
        _currentProfile!.reminderSetting.lastWateredAt ??
        _currentProfile!.startDate;
    _lastFertilized =
        _currentProfile!.reminderSetting.lastFertilizedAt ??
        _currentProfile!.startDate;
    _wateringCycleDays = _currentProfile!.reminderSetting.wateringCycleDays;
    _fertilizingCycleDays =
        _currentProfile!.reminderSetting.fertilizingCycleDays;
    _daysSinceLastWater = DateTime.now().difference(_lastWatered!).inDays;
    _daysSinceLastFertilize = DateTime.now()
        .difference(_lastFertilized!)
        .inDays;
  }

  Future<void> _loadCareHistory() async {
    if (_currentProfile == null) return;
    try {
      final controller = context.read<MyGardenController>();
      await controller.initialize();
      await controller.fetchCareHistory(
        _currentProfile!.id ?? _currentProfile!.plantId,
      );
      if (mounted) {
        setState(() {
          try {
            _currentProfile = controller.plantProfiles.firstWhere(
              (p) =>
                  p.id == _currentProfile!.id ||
                  p.plantId == _currentProfile!.plantId,
            );
          } catch (_) {}
          _careHistory = controller.getCareHistory(
            _currentProfile!.id ?? _currentProfile!.plantId,
          );
          _initCareTimings();
        });
      }
    } catch (e) {
      debugPrint('Error loading care history: $e');
    }
  }

  bool isReadyToWater(DateTime lastWateredAt, int frequencyDays) {
    if (_currentProfile?.status == GardenPlantStatus.thirsty) {
      return true;
    }
    double cooldownHours = (frequencyDays * 24) * 0.3;
    DateTime earliestAllowedTime = lastWateredAt.add(
      Duration(minutes: (cooldownHours * 60).toInt()),
    );
    return DateTime.now().isAfter(earliestAllowedTime);
  }

  bool isReadyToFertilize(DateTime lastFertilizedAt, int frequencyDays) {
    double cooldownHours = (frequencyDays * 24) * 0.3;
    DateTime earliestAllowedTime = lastFertilizedAt.add(
      Duration(minutes: (cooldownHours * 60).toInt()),
    );
    return DateTime.now().isAfter(earliestAllowedTime);
  }

  GardenPlantProfile _createPreFilledProfile(MyGardenController controller) {
    GardenCategory? matchedCategory;
    final String libCatText = _libraryPlant.category.trim();
    for (final cat in controller.plantCategory) {
      if (GardenCategory.categoryToText(cat.name).toLowerCase() ==
          libCatText.toLowerCase()) {
        matchedCategory = cat;
        break;
      }
    }
    matchedCategory ??=
        controller.plantCategory.firstOrNull ??
        const GardenCategory(id: '1', name: Category.indoor);

    return GardenPlantProfile(
      id: null,
      plantId: _libraryPlant.id,
      name: _libraryPlant.name,
      latinName: _libraryPlant.scientificName ?? _libraryPlant.name,
      category: matchedCategory,
      imageUrl: _libraryPlant.imageUrl,
      startDate: DateTime.now(),
      status: GardenPlantStatus.healthy,
      reminderSetting: GardenReminder(
        wateringCycleDays: _libraryPlant.wateringIntervalDays ?? 7,
        fertilizingCycleDays: 30,
        pushNotificationEnabled: true,
      ),
    );
  }

  Future<void> _openPlantForm(
    BuildContext context,
    MyGardenController controller,
  ) async {
    final preFilled = _createPreFilledProfile(controller);

    final result = await showModalBottomSheet<GardenPlantProfile>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return MyGardenPlantFormSheet(
          initialValue: preFilled,
          plantOptions: controller.plantCategory,
        );
      },
    );

    if (result != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${result.name} ${context.read<ProfileController>().tr('added_to_garden')}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget build(BuildContext context) {
    final lang = context.watch<ProfileController>();
    return Consumer<MyGardenController>(
      builder: (context, controller, _) {
        if (_currentProfile != null) {
          try {
            _currentProfile = controller.plantProfiles.firstWhere(
              (p) =>
                  p.id == _currentProfile!.id || p.plantId == _libraryPlant.id,
            );
            _initCareTimings();
          } catch (_) {}
        } else {
          _currentProfile = controller.getPlantProfileByLibraryId(
            _libraryPlant.id,
          );
          if (_currentProfile != null) {
            _initCareTimings();
            _loadCareHistory();
          }
        }

        final profile = _currentProfile;
        final bool isAdded = profile != null;

        return Scaffold(
          body: RefreshIndicator(
            onRefresh: isAdded ? _loadCareHistory : () async {},
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 280,
                  pinned: true,
                  backgroundColor: const Color(0xFF2E7D32),
                  elevation: 0,
                  iconTheme: const IconThemeData(
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Hero(
                          tag: isAdded
                              ? (profile.id ?? profile.plantId)
                              : _libraryPlant.id,
                          child:
                              (isAdded &&
                                  profile.imageUrl.isNotEmpty &&
                                  !profile.imageUrl.startsWith('http') &&
                                  !profile.imageUrl.startsWith('https'))
                              ? Image.file(
                                  File(profile.imageUrl),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        color: const Color(0xFFE6EFE8),
                                        child: const Icon(
                                          Icons.local_florist,
                                          size: 80,
                                          color: Color(0xFF2E7D32),
                                        ),
                                      ),
                                )
                              : CachedNetworkImage(
                                  imageUrl: isAdded
                                      ? profile.imageUrl
                                      : _libraryPlant.imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: const Color(0xFFE6EFE8),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Color(0xFF2E7D32),
                                            ),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        color: const Color(0xFFE6EFE8),
                                        child: const Icon(
                                          Icons.local_florist,
                                          size: 80,
                                          color: Color(0xFF2E7D32),
                                        ),
                                      ),
                                ),
                        ),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.4),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.3],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    if (isAdded)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                          ),
                          onPressed: () => _showDeleteDialog(context),
                        ),
                      ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isAdded ? profile.name : _libraryPlant.name,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      height: 1.1,
                                      color: Color(0xFF102A17),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  if (_libraryPlant.scientificName != null &&
                                      _libraryPlant
                                          .scientificName!
                                          .isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      _libraryPlant.scientificName!,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontStyle: FontStyle.italic,
                                        color: Color(0xFF587064),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (isAdded) StatusBadge(status: profile.status),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: CareCard(
                                    label: isAdded ? lang.tr('cycle') : lang.tr('water_plant'),
                                    value: isAdded
                                        ? '${profile.reminderSetting.wateringCycleDays} ${lang.tr('days_label')}'
                                        : (_libraryPlant
                                                  .wateringFrequencyLabel ??
                                              '${_libraryPlant.wateringIntervalDays ?? 7} ${lang.tr('days_label')}'),
                                    iconData: Icons.autorenew_rounded,
                                    bgColor: const Color(0xFFE8F5E9),
                                    iconColor: const Color(0xFF388E3C),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: CareCard(
                                    label: isAdded ? lang.tr('last_time') : lang.tr('light_filter'),
                                    value: isAdded
                                        ? (profile.lastWateredAt != null
                                              ? '${DateTime.now().difference(_lastWatered!).inDays} ${lang.tr('days_label')} ${lang.tr('ago')}'
                                              : lang.tr('not_watered'))
                                        : _libraryPlant.lightLevel,
                                    iconData: Icons.history_rounded,
                                    bgColor: const Color(0xFFE3F2FD),
                                    iconColor: const Color(0xFF1976D2),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: CareCard(
                                    label: isAdded ? lang.tr('location') : lang.tr('difficulty_filter'),
                                    value: isAdded
                                        ? _getCategoryDisplayName(
                                            profile.category.name,
                                          )
                                        : _libraryPlant.difficulty,
                                    iconData: Icons.location_on_rounded,
                                    bgColor: const Color(0xFFFFF3E0),
                                    iconColor: const Color(0xFFF57C00),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            if (isAdded) ...[
                              Text(
                                lang.tr('care_progress'),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (profile.reminderSetting.wateringCycleDays > 0)
                                PlantActionProgress(
                                  label: lang.tr('water_plant'),
                                  lastActionDate: _lastWatered!,
                                  cycleDays: _wateringCycleDays,
                                  activeColor: Colors.blue,
                                ),
                              if (profile.reminderSetting.fertilizingCycleDays >
                                  0) ...[
                                const SizedBox(height: 16),
                                PlantActionProgress(
                                  label: lang.tr('fertilize_plant'),
                                  lastActionDate: _lastFertilized!,
                                  cycleDays: _fertilizingCycleDays,
                                  activeColor: Colors.green,
                                ),
                              ],
                              const SizedBox(height: 32),

                              Container(
                                width: double.infinity,
                                height: 58,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow:
                                      isReadyToWater(
                                            _lastWatered!,
                                            _wateringCycleDays,
                                          ) &&
                                          !_isLoading
                                      ? [
                                          BoxShadow(
                                            color: const Color(
                                              0xFF2196F3,
                                            ).withOpacity(0.3),
                                            blurRadius: 16,
                                            offset: const Offset(0, 6),
                                          ),
                                        ]
                                      : [],
                                  gradient:
                                      isReadyToWater(
                                            _lastWatered!,
                                            _wateringCycleDays,
                                          ) &&
                                          !_isLoading
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFF42A5F5),
                                            Color(0xFF1E88E5),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color:
                                      isReadyToWater(
                                            _lastWatered!,
                                            _wateringCycleDays,
                                          ) &&
                                          !_isLoading
                                      ? null
                                      : const Color(0xFFE3E9E5),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap:
                                        _isLoading ||
                                            !isReadyToWater(
                                              _lastWatered!,
                                              _wateringCycleDays,
                                            )
                                        ? null
                                        : () => _waterPlant(context),
                                    child: Center(
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  isReadyToWater(
                                                        _lastWatered!,
                                                        _wateringCycleDays,
                                                      )
                                                      ? Icons.water_drop
                                                      : Icons.check_circle,
                                                  color:
                                                      isReadyToWater(
                                                        _lastWatered!,
                                                        _wateringCycleDays,
                                                      )
                                                      ? Colors.white
                                                      : const Color(0xFF7A9384),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  isReadyToWater(
                                                        _lastWatered!,
                                                        _wateringCycleDays,
                                                      )
                                                      ? lang.tr('water_plant').toUpperCase()
                                                      : lang.tr('already_watered').replaceAll('{time}', '${DateTime.now().difference(_lastWatered!).inHours > 24 ? "${DateTime.now().difference(_lastWatered!).inDays} ${lang.tr('days_label')}" : "${DateTime.now().difference(_lastWatered!).inHours}${lang.tr('hours_short')}"}'),
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w800,
                                                    letterSpacing: 0.5,
                                                    color:
                                                        isReadyToWater(
                                                          _lastWatered!,
                                                          _wateringCycleDays,
                                                        )
                                                        ? Colors.white
                                                        : const Color(
                                                            0xFF7A9384,
                                                          ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              Container(
                                width: double.infinity,
                                height: 58,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow:
                                      isReadyToFertilize(
                                            _lastFertilized!,
                                            _fertilizingCycleDays,
                                          ) &&
                                          !_isLoading
                                      ? [
                                          BoxShadow(
                                            color: const Color(
                                              0xFF4CAF50,
                                            ).withOpacity(0.3),
                                            blurRadius: 16,
                                            offset: const Offset(0, 6),
                                          ),
                                        ]
                                      : [],
                                  gradient:
                                      isReadyToFertilize(
                                            _lastFertilized!,
                                            _fertilizingCycleDays,
                                          ) &&
                                          !_isLoading
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFF66BB6A),
                                            Color(0xFF43A047),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color:
                                      isReadyToFertilize(
                                            _lastFertilized!,
                                            _fertilizingCycleDays,
                                          ) &&
                                          !_isLoading
                                      ? null
                                      : const Color(0xFFE3E9E5),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap:
                                        _isLoading ||
                                            !isReadyToFertilize(
                                              _lastFertilized!,
                                              _fertilizingCycleDays,
                                            )
                                        ? null
                                        : () => _showFertilizerDialog(context),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            isReadyToFertilize(
                                                  _lastFertilized!,
                                                  _fertilizingCycleDays,
                                                )
                                                ? Icons.eco
                                                : Icons.check_circle,
                                            color:
                                                isReadyToFertilize(
                                                  _lastFertilized!,
                                                  _fertilizingCycleDays,
                                                )
                                                ? Colors.white
                                                : const Color(0xFF7A9384),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            isReadyToFertilize(
                                                  _lastFertilized!,
                                                  _fertilizingCycleDays,
                                                )
                                                ? lang.tr('fertilize_plant').toUpperCase()
                                                : '${lang.tr('fertilized')} (${DateTime.now().difference(_lastFertilized!).inHours > 24 ? "${DateTime.now().difference(_lastFertilized!).inDays} ${lang.tr('days')}" : "${DateTime.now().difference(_lastFertilized!).inHours}h"} ${lang.tr('ago')})',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.5,
                                              color:
                                                  isReadyToFertilize(
                                                    _lastFertilized!,
                                                    _fertilizingCycleDays,
                                                  )
                                                  ? Colors.white
                                                  : const Color(0xFF7A9384),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),

                              Text(
                                lang.tr('care_history'),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildCareHistoryTimeline(),
                              const SizedBox(height: 32),
                            ] else ...[
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton.icon(
                                  onPressed: () =>
                                      _openPlantForm(context, controller),
                                  icon: const Icon(Icons.add_circle_outline),
                                  label: Text(lang.tr('add_to_my_garden')),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2E7D32),
                                    foregroundColor: Colors.white,
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],

                            const SizedBox(height: 24),
                            _SectionHeader(
                              title: lang.tr('detail_info'),
                              subtitle: lang.tr('plant_bio_desc'),
                            ),
                            const SizedBox(height: 12),
                            _DetailedInfoCard(plant: _libraryPlant),
                            const SizedBox(height: 24),
                            _SectionHeader(
                              title: lang.tr('about_plant'),
                              subtitle: lang.tr('about_plant_desc'),
                            ),
                            const SizedBox(height: 12),
                            _PanelCard(
                              child: Text(
                                _libraryPlant.description.isNotEmpty
                                    ? _libraryPlant.description
                                    : lang.tr('no_plant_desc'),
                                style: const TextStyle(
                                  fontSize: 15,
                                  height: 1.5,
                                  color: Color(0xFF2E4033),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            if (_libraryPlant.careGuide.isNotEmpty) ...[
                              _SectionHeader(
                                title: lang.tr('care_guide'),
                                subtitle: lang.tr('plant_care_summary'),
                              ),
                              const SizedBox(height: 12),
                              _PanelCard(
                                child: Column(
                                  children: _libraryPlant.careGuide
                                      .map(
                                        (tip) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 12,
                                          ),
                                          child: _FactRow(text: tip),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],

                            if (_libraryPlant.funFacts.isNotEmpty) ...[
                              _SectionHeader(
                                title: lang.tr('did_you_know'),
                                subtitle: lang.tr('interesting_facts_desc'),
                              ),
                              const SizedBox(height: 12),
                              _PanelCard(
                                child: Column(
                                  children: _libraryPlant.funFacts
                                      .map(
                                        (fact) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 12,
                                          ),
                                          child: _FactRow(text: fact),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.read<ProfileController>().tr('confirm_delete')),
        content: Text(context.read<ProfileController>().tr('confirm_delete')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.watch<ProfileController>().tr('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(context.watch<ProfileController>().tr('delete')),
          ),
        ],
      ),
    );

    if (result == true) {
      await _deletePlant(context);
    }
  }

  Future<void> _waterPlant(BuildContext context) async {
    if (_currentProfile == null) return;
    setState(() => _isLoading = true);
    try {
      DateTime nextWateringTime = _lastWatered!.add(
        Duration(days: _wateringCycleDays),
      );

      if (DateTime.now().isBefore(nextWateringTime)) {
        if (!mounted) return;
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(context.read<ProfileController>().tr('water_early')),
            content: Text(
              context.read<ProfileController>().tr('water_early_confirm').replaceAll('{name}', _currentProfile!.name),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(context.read<ProfileController>().tr('no')),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(context.read<ProfileController>().tr('yes')),
              ),
            ],
          ),
        );
        if (confirm != true) {
          if (mounted) setState(() => _isLoading = false);
          return;
        }
      }

      final controller = context.read<MyGardenController>();
      final refreshedProfile = await controller.waterPlant(_currentProfile!);
      if (mounted) {
        setState(() {
          if (refreshedProfile != null) {
            _currentProfile = refreshedProfile;
            _lastWatered = _currentProfile!.reminderSetting.lastWateredAt!;
            _wateringCycleDays =
                _currentProfile!.reminderSetting.wateringCycleDays;
            _daysSinceLastWater = DateTime.now()
                .difference(_lastWatered!)
                .inDays;
          }
        });
        await _loadCareHistory();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.read<ProfileController>().tr('water_success')),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error watering plant: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.read<ProfileController>().tr('water_error').replaceAll('{error}', e.toString())),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deletePlant(BuildContext context) async {
    if (_currentProfile == null) return;
    final controller = context.read<MyGardenController>();
    await controller.removePlant(
      _currentProfile!.id ?? _currentProfile!.plantId,
    );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Widget _buildCareHistoryTimeline() {
    if (_careHistory.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F8F5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2ECE5), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFE3EFE6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.spa_outlined,
                size: 32,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              context.watch<ProfileController>().tr('no_care_history'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF102A17),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              context.watch<ProfileController>().tr('no_care_history_desc'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: Color(0xFF5A7C65),
              ),
            ),
          ],
        ),
      );
    }

    final sortedHistory = _careHistory.toList()
      ..sort((a, b) => b.actionDate.compareTo(a.actionDate));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedHistory.length,
      itemBuilder: (context, index) {
        final history = sortedHistory[index];
        final isLast = index == sortedHistory.length - 1;
        return _buildCareHistoryItem(history, isLast);
      },
    );
  }

  Widget _buildCareHistoryItem(PlantCareHistory history, bool isLast) {
    final icon = history.actionType == CareActionType.watering
        ? Icons.water_drop
        : Icons.eco;
    final color = history.actionType == CareActionType.watering
        ? Colors.blue
        : Colors.green;

    final now = DateTime.now();
    final difference = now.difference(history.actionDate);
    String timeAgo;
    if (difference.inDays > 0) {
      timeAgo = context.read<ProfileController>().tr('days_ago').replaceAll('{days}', difference.inDays.toString());
    } else if (difference.inHours > 0) {
      timeAgo = '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      timeAgo = context.read<ProfileController>().tr('minutes_ago').replaceAll('{mins}', difference.inMinutes.toString());
    } else {
      timeAgo = 'Vừa xong';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: color.withOpacity(0.3), width: 1.5),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 60,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE8EFEA)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        history.actionTypeLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Color(0xFF102A17),
                        ),
                      ),
                      Text(
                        timeAgo,
                        style: const TextStyle(
                          color: Color(0xFF7A9384),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (history.notes != null && history.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      history.notes!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF587064),
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showFertilizerDialog(BuildContext context) async {
    DateTime nextFertilizeringTime = _lastFertilized!.add(
      Duration(days: _fertilizingCycleDays),
    );

    if (DateTime.now().isBefore(nextFertilizeringTime)) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.read<ProfileController>().tr('fertilize_early')),
          content: Text(
            context.read<ProfileController>().tr('fertilize_early_confirm').replaceAll('{name}', _currentProfile!.name),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.read<ProfileController>().tr('no')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(context.read<ProfileController>().tr('yes')),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    await _fertilizePlant();
  }

  Future<void> _fertilizePlant() async {
    if (_currentProfile == null) return;
    setState(() => _isLoading = true);
    try {
      final controller = context.read<MyGardenController>();
      final refreshedProfile = await controller.fertilizePlant(
        _currentProfile!,
        notes: null,
      );
      if (mounted) {
        setState(() {
          if (refreshedProfile != null) {
            _currentProfile = refreshedProfile;
            _lastFertilized =
                _currentProfile!.reminderSetting.lastFertilizedAt ??
                _currentProfile!.startDate;
            _fertilizingCycleDays =
                _currentProfile!.reminderSetting.fertilizingCycleDays;
            _daysSinceLastFertilize = DateTime.now()
                .difference(_lastFertilized!)
                .inDays;
          }
        });
        await _loadCareHistory();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.read<ProfileController>().tr('fertilize_success')),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error fertilizing plant: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.read<ProfileController>().tr('fertilize_error').replaceAll('{error}', e.toString())),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getCategoryDisplayName(Category category) {
    switch (category) {
      case Category.all:
        return context.read<ProfileController>().tr('category_all');
      case Category.indoor:
        return context.read<ProfileController>().tr('category_indoor');
      case Category.balcony:
        return context.read<ProfileController>().tr('category_balcony');
      case Category.outdoor:
        return context.read<ProfileController>().tr('category_outdoor');
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 5,
          height: 26,
          margin: const EdgeInsets.only(top: 4, right: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF102A17),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: Color(0xFF587064),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PanelCard extends StatelessWidget {
  const _PanelCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F8F4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE1ECE3)),
      ),
      child: child,
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F4EA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            size: 18,
            color: Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF3E4E43),
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailedInfoCard extends StatelessWidget {
  const _DetailedInfoCard({required this.plant});

  final LibraryPlantItem plant;

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<ProfileController>();
    final String humidity =
        plant.humidityLevel ?? plant.humidity ?? lang.tr('avg_humidity');
    final String temperature =
        plant.temperatureRange ?? plant.temperature ?? '18-30°C';
    final String toxicity = plant.toxicity ?? lang.tr('safe_non_toxic');

    final bool isToxic =
        plant.toxicity != null &&
        (plant.toxicity!.toLowerCase().contains('độc') ||
            plant.toxicity!.toLowerCase().contains('toxic')) &&
        !plant.toxicity!.toLowerCase().contains('không') &&
        !plant.toxicity!.toLowerCase().contains('an toàn');

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _DetailTile(
                icon: isToxic
                    ? Icons.dangerous_rounded
                    : Icons.health_and_safety_rounded,
                iconColor: isToxic
                    ? Colors.orange.shade800
                    : Colors.teal.shade700,
                backgroundColor: isToxic
                    ? const Color(0xFFFFF3E0)
                    : const Color(0xFFE0F2F1),
                label: 'ĐỘC TÍNH',
                value: toxicity,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _DetailTile(
                icon: Icons.thermostat_rounded,
                iconColor: Colors.red.shade700,
                backgroundColor: const Color(0xFFFFEBEE),
                label: 'NHIỆT ĐỘ PHÙ HỢP',
                value: temperature,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DetailTile(
                icon: Icons.water_rounded,
                iconColor: Colors.blue.shade700,
                backgroundColor: const Color(0xFFE3F2FD),
                label: 'ĐỘ ẨM YÊU CẦU',
                value: humidity,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.label,
    required this.value,
    this.isItalicValue = false,
  });

  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String label;
  final String value;
  final bool isItalicValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: iconColor.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF73847A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontStyle: isItalicValue
                        ? FontStyle.italic
                        : FontStyle.normal,
                    color: const Color(0xFF112C16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
