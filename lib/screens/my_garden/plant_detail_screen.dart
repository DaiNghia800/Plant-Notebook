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
      await controller.fetchCareHistory(
        _currentProfile.id ?? _currentProfile.plantId,
      );
      if (mounted) {
        setState(() {
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: screenHeight / 3,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: profile.id ?? profile.plantId,
                child: Image.network(
                  profile.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _showDeleteDialog(context),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plant name and status
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profile.latinName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      StatusBadge(status: profile.status),
                    ],
                  ),
                  const SizedBox(height: 24),

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
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: _isLoading
                        ? ElevatedButton(
                            onPressed: null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[300],
                              foregroundColor: Colors.white,
                            ),
                            child: const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          )
                        : ElevatedButton(
                            onPressed:
                                isReadyToWater(
                                  _lastWatered!,
                                  _wateringCycleDays,
                                )
                                ? () => _waterPlant(context)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isReadyToWater(
                                    _lastWatered!,
                                    _wateringCycleDays,
                                  )
                                  ? const Color(0xFF2E7D32)
                                  : Colors.grey[300],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              isReadyToWater(_lastWatered!, _wateringCycleDays)
                                  ? 'XÁC NHẬN ĐÃ TƯỚI'
                                  : 'ĐÃ TƯỚI (${DateTime.now().difference(_lastWatered!).inHours > 24 ? "${DateTime.now().difference(_lastWatered!).inDays} ngày" : "${DateTime.now().difference(_lastWatered!).inHours}h"} trước)',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),

                  // Fertilizer button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: _isLoading
                        ? OutlinedButton(
                            onPressed: null,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Colors.grey,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF2E7D32),
                                ),
                              ),
                            ),
                          )
                        : OutlinedButton(
                            onPressed:
                                isReadyToWater(
                                  _lastFertilized!,
                                  _fertilizingCycleDays,
                                )
                                ? () => _showFertilizerDialog(context)
                                : null,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color:
                                    isReadyToWater(
                                      _lastFertilized!,
                                      _fertilizingCycleDays,
                                    )
                                    ? const Color(0xFF2E7D32)
                                    : Colors.grey,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              isReadyToWater(
                                    _lastFertilized!,
                                    _fertilizingCycleDays,
                                  )
                                  ? 'XÁC NHẬN ĐÃ BÓN PHÂN'
                                  : 'ĐÃ BÓN (${DateTime.now().difference(_lastFertilized!).inHours > 24 ? "${DateTime.now().difference(_lastFertilized!).inDays} ngày" : "${DateTime.now().difference(_lastFertilized!).inHours}h"} trước)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color:
                                    isReadyToWater(
                                      _lastFertilized!,
                                      _fertilizingCycleDays,
                                    )
                                    ? const Color(0xFF2E7D32)
                                    : Colors.grey,
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
          ),
        ],
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              if (!isLast)
                Container(width: 2, height: 40, color: Colors.grey[300]),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  history.actionTypeLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeAgo,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                if (history.notes != null && history.notes!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    history.notes!,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ],
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
