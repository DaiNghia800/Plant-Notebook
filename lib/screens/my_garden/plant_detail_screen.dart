import 'package:flutter/material.dart';
import 'package:plant_notebook/controller/my_garden_controller.dart';
import 'package:plant_notebook/data/models/category.dart';
import 'package:plant_notebook/data/models/garden_plant.dart';
import 'package:plant_notebook/data/models/care_history.dart';
import 'package:plant_notebook/screens/my_garden/widget/plant_detail/care_card.dart';
import 'package:plant_notebook/screens/my_garden/widget/plant_detail/plant_action_progress.dart';
import 'package:plant_notebook/screens/my_garden/widget/plant_detail/status_badge.dart';
import 'package:provider/provider.dart';

class PlantDetailScreen extends StatefulWidget {
  const PlantDetailScreen({super.key, required this.profile});

  final GardenPlantProfile profile;

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  late GardenPlantProfile _currentProfile;
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
    _currentProfile = widget.profile;
    _careHistory = [];
    _lastWatered =
        _currentProfile.reminderSetting.lastWateredAt ??
        _currentProfile.startDate;
    _lastFertilized =
        _currentProfile.reminderSetting.lastFertilizedAt ??
        _currentProfile.startDate;
    _wateringCycleDays = _currentProfile.reminderSetting.wateringCycleDays;
    _fertilizingCycleDays =
        _currentProfile.reminderSetting.fertilizingCycleDays;
    _loadCareHistory();
  }

  bool isReadyToWater(DateTime lastWateredAt, int frequencyDays) {
    double cooldownHours = (frequencyDays * 24) * 0.3;

    DateTime earliestAllowedTime = lastWateredAt.add(
      Duration(minutes: (cooldownHours * 60).toInt()),
    );

    return DateTime.now().isAfter(earliestAllowedTime);
  }

  void _updateCareActionTimings() {
    _lastWatered =
        _currentProfile.reminderSetting.lastWateredAt ??
        _currentProfile.startDate;
    _lastFertilized =
        _currentProfile.reminderSetting.lastFertilizedAt ??
        _currentProfile.startDate;
    _wateringCycleDays = _currentProfile.reminderSetting.wateringCycleDays;
    _fertilizingCycleDays =
        _currentProfile.reminderSetting.fertilizingCycleDays;
    _daysSinceLastWater = DateTime.now().difference(_lastWatered!).inDays;
    _daysSinceLastFertilize = DateTime.now()
        .difference(_lastFertilized!)
        .inDays;
  }

  Future<void> _loadCareHistory() async {
    try {
      final controller = context.read<MyGardenController>();
      await controller.initialize();
      await controller.fetchCareHistory(
        _currentProfile.id ?? _currentProfile.plantId,
      );
      if (mounted) {
        setState(() {
          try {
            _currentProfile = controller.plantProfiles.firstWhere(
              (p) => p.id == _currentProfile.id || p.plantId == _currentProfile.plantId,
            );
          } catch (_) {}
          _careHistory = controller.getCareHistory(
            _currentProfile.id ?? _currentProfile.plantId,
          );
          _updateCareActionTimings();
        });
      }
    } catch (e) {
      debugPrint('Error loading care history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = _currentProfile;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadCareHistory,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF2E7D32),
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white, shadows: [Shadow(color: Colors.black45, blurRadius: 4)]),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: profile.id ?? profile.plantId,
                    child: Image.network(
                      profile.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFFE6EFE8),
                          child: const Icon(
                            Icons.local_florist,
                            size: 80,
                            color: Color(0xFF2E7D32),
                          ),
                        );
                      },
                    ),
                  ),
                  // Dark gradient from top for back button readability
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
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
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
                // Floating Title Card (now a normal card)
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
                                profile.name,
                                style: const TextStyle(
                                  fontSize: 28,
                                  height: 1.1,
                                  color: Color(0xFF102A17),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                profile.latinName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontStyle: FontStyle.italic,
                                  color: Color(0xFF587064),
                                ),
                              ),
                            ],
                          ),
                        ),
                        StatusBadge(status: profile.status),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                  // Care metrics
                  Row(
                    children: [
                      Expanded(
                        child: CareCard(
                          label: 'Chu kỳ',
                          value:
                              '${profile.reminderSetting.wateringCycleDays} ngày',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CareCard(
                          label: 'Lần cuối',
                          value: profile.lastWateredAt != null
                              ? '${DateTime.now().difference(_lastWatered!).inDays} ngày trước'
                              : 'Chưa tưới',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CareCard(
                          label: 'Vị trí',
                          value: _getCategoryDisplayName(profile.category.name),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Progress indicators
                  const Text(
                    'Tiến độ chăm sóc',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  if (profile.reminderSetting.wateringCycleDays > 0)
                    PlantActionProgress(
                      label: "Tưới nước",
                      lastActionDate: _lastWatered!,
                      cycleDays: _wateringCycleDays,
                      activeColor: Colors.blue,
                    ),
                  if (profile.reminderSetting.fertilizingCycleDays > 0) ...[
                    const SizedBox(height: 16),
                    PlantActionProgress(
                      label: "Bón Phân",
                      lastActionDate: _lastFertilized!,
                      cycleDays: _fertilizingCycleDays,
                      activeColor: Colors.green,
                    ),
                  ],
                  const SizedBox(height: 32),

                  // Water button
                  Container(
                    width: double.infinity,
                    height: 58,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isReadyToWater(_lastWatered!, _wateringCycleDays) && !_isLoading
                          ? [
                              BoxShadow(
                                color: const Color(0xFF2196F3).withOpacity(0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              )
                            ]
                          : [],
                      gradient: isReadyToWater(_lastWatered!, _wateringCycleDays) && !_isLoading
                          ? const LinearGradient(
                              colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isReadyToWater(_lastWatered!, _wateringCycleDays) && !_isLoading
                          ? null
                          : const Color(0xFFE3E9E5),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _isLoading || !isReadyToWater(_lastWatered!, _wateringCycleDays)
                            ? null
                            : () => _waterPlant(context),
                        child: Center(
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isReadyToWater(_lastWatered!, _wateringCycleDays)
                                          ? Icons.water_drop
                                          : Icons.check_circle,
                                      color: isReadyToWater(_lastWatered!, _wateringCycleDays)
                                          ? Colors.white
                                          : const Color(0xFF7A9384),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isReadyToWater(_lastWatered!, _wateringCycleDays)
                                          ? 'TƯỚI NƯỚC'
                                          : 'ĐÃ TƯỚI (${DateTime.now().difference(_lastWatered!).inHours > 24 ? "${DateTime.now().difference(_lastWatered!).inDays} ngày" : "${DateTime.now().difference(_lastWatered!).inHours}h"} trước)',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                        color: isReadyToWater(_lastWatered!, _wateringCycleDays)
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
                  const SizedBox(height: 16),

                  // Fertilizer button
                  Container(
                    width: double.infinity,
                    height: 58,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isReadyToWater(_lastFertilized!, _fertilizingCycleDays) && !_isLoading
                          ? [
                              BoxShadow(
                                color: const Color(0xFF4CAF50).withOpacity(0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              )
                            ]
                          : [],
                      gradient: isReadyToWater(_lastFertilized!, _fertilizingCycleDays) && !_isLoading
                          ? const LinearGradient(
                              colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isReadyToWater(_lastFertilized!, _fertilizingCycleDays) && !_isLoading
                          ? null
                          : const Color(0xFFE3E9E5),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _isLoading || !isReadyToWater(_lastFertilized!, _fertilizingCycleDays)
                            ? null
                            : () => _showFertilizerDialog(context),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isReadyToWater(_lastFertilized!, _fertilizingCycleDays)
                                    ? Icons.eco
                                    : Icons.check_circle,
                                color: isReadyToWater(_lastFertilized!, _fertilizingCycleDays)
                                    ? Colors.white
                                    : const Color(0xFF7A9384),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isReadyToWater(_lastFertilized!, _fertilizingCycleDays)
                                    ? 'BÓN PHÂN'
                                    : 'ĐÃ BÓN (${DateTime.now().difference(_lastFertilized!).inHours > 24 ? "${DateTime.now().difference(_lastFertilized!).inDays} ngày" : "${DateTime.now().difference(_lastFertilized!).inHours}h"} trước)',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: isReadyToWater(_lastFertilized!, _fertilizingCycleDays)
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

                  // Care history section
                  const Text(
                    'Lịch sử chăm sóc',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  _buildCareHistoryTimeline(),
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
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa cây này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _deletePlant(context);
    }
  }

  Future<void> _waterPlant(BuildContext context) async {
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
            title: const Text('Tưới sớm cho cây?'),
            content: Text(
              'Vẫn chưa đến lịch tưới tiếp theo. Bạn có chắc muốn xác nhận đã tưới sớm cho ${_currentProfile.name} không?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Không'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Có'),
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
      final refreshedProfile = await controller.waterPlant(_currentProfile);
      debugPrint(
        "current: ${_currentProfile.reminderSetting.lastWateredAt},  refresh: ${refreshedProfile!.reminderSetting.lastWateredAt}",
      );
      if (mounted) {
        setState(() {
          if (refreshedProfile != null) {
            _currentProfile = refreshedProfile;
            _lastWatered = _currentProfile.reminderSetting.lastWateredAt!;
            _wateringCycleDays =
                _currentProfile.reminderSetting.wateringCycleDays;
            _daysSinceLastWater = DateTime.now()
                .difference(_lastWatered!)
                .inDays;
          }
        });
        await _loadCareHistory();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Đã cập nhật tưới nước'),
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
            content: Text('Lỗi: Không thể tưới nước ($e)'),
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
    final controller = context.read<MyGardenController>();
    await controller.removePlant(_currentProfile.plantId);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Widget _buildCareHistoryTimeline() {
    if (_careHistory.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(Icons.history, size: 40, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'Chưa có lịch sử chăm sóc',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Sort by date descending
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
      timeAgo = '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      timeAgo = '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      timeAgo = '${difference.inMinutes} phút trước';
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
    final notesController = TextEditingController();

    // Check if already fertilized recently
    final lastFertilizerAction = _careHistory
        .where((h) => h.actionType == CareActionType.fertilizing)
        .firstOrNull;

    bool shouldAskConfirmation = false;
    int hoursSinceLastAction = 0;

    if (lastFertilizerAction != null) {
      hoursSinceLastAction = DateTime.now()
          .difference(lastFertilizerAction.actionDate)
          .inHours;
      shouldAskConfirmation = hoursSinceLastAction < 2;
    }

    DateTime nextFertilizeringTime = _lastFertilized!.add(
      Duration(days: _fertilizingCycleDays),
    );

    if (DateTime.now().isBefore(nextFertilizeringTime)) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Bón phân sớm cho cây?'),
          content: Text(
            'Vẫn chưa đến lịch bón phân tiếp theo. Bạn có chắc muốn xác nhận đã bón phân sớm cho cây ${_currentProfile.name} không?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Không'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Có'),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận bón phân'),
        content: TextField(
          controller: notesController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Thêm ghi chú (tùy chọn)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _fertilizePlant(context, notesController.text.trim());
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
            ),
            child: const Text(
              'Xác nhận',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    notesController.dispose();
  }

  Future<void> _fertilizePlant(BuildContext context, String notes) async {
    setState(() => _isLoading = true);
    try {
      final controller = context.read<MyGardenController>();
      final refreshedProfile = await controller.fertilizePlant(
        _currentProfile,
        notes: notes.isEmpty ? null : notes,
      );
      if (mounted) {
        setState(() {
          if (refreshedProfile != null) {
            _currentProfile = refreshedProfile;
            _lastFertilized =
                _currentProfile.reminderSetting.lastFertilizedAt ??
                _currentProfile.startDate;
            _fertilizingCycleDays =
                _currentProfile.reminderSetting.fertilizingCycleDays;
            _daysSinceLastFertilize = DateTime.now()
                .difference(_lastFertilized!)
                .inDays;
          }
        });
        await _loadCareHistory();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Đã cập nhật bón phân'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error fertilizing plant: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: Không thể bón phân ($e)'),
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
        return 'Tất cả';
      case Category.indoor:
        return 'Trong nhà';
      case Category.balcony:
        return 'Ban công';
      case Category.outdoor:
        return 'Ngoài trời';
    }
  }
}