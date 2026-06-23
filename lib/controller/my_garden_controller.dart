import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:plant_notebook/data/models/category.dart';
import 'package:plant_notebook/data/services/my_garden_service.dart';
import 'package:plant_notebook/data/models/garden_plant.dart';
import 'package:plant_notebook/data/models/care_history.dart';
import 'package:plant_notebook/data/my_garden_seed.dart';
import 'package:plant_notebook/data/library_plant_seed.dart';
import 'package:plant_notebook/data/models/library_plant_item.dart';
import 'package:plant_notebook/data/models/my_garden_item.dart';
import 'package:plant_notebook/data/services/my_garden_storage.dart';

/// Controller quản lý danh sách cây trong vườn của người dùng.
///
/// Thay vì dùng seed tĩnh, [savedPlants] nhận vào danh sách cây từ
/// [LibraryPlantController] thông qua phương thức [resolveFrom].
class MyGardenController extends ChangeNotifier {
  MyGardenController({MyGardenService? apiService, MyGardenStorage? storage})
    : _apiService = apiService ?? MyGardenService(),
      _storage = storage ?? MyGardenStorage();

  final MyGardenService _apiService;
  final Set<String> _savedPlantIds = <String>{};
  final List<GardenPlantProfile> _plantProfiles = <GardenPlantProfile>[];
  final List<GardenCategory> _plantCategories = <GardenCategory>[];
  final Map<String, List<PlantCareHistory>> _careHistoryCache =
      <String, List<PlantCareHistory>>{};
  final MyGardenStorage _storage;
  final List<MyGardenItem> _savedPlants = <MyGardenItem>[];

  bool _isLoading = true;
  String? _errorMessage;

  String _searchQuery = '';
  String _sortBy = 'dateAdded';

  String get searchQuery => _searchQuery;
  set searchQuery(String value) {
    if (_searchQuery != value) {
      _searchQuery = value;
      notifyListeners();
    }
  }

  String get sortBy => _sortBy;
  set sortBy(String value) {
    if (_sortBy != value) {
      _sortBy = value;
      notifyListeners();
    }
  }

  bool _isGridView = true;
  bool get isGridView => _isGridView;
  set isGridView(bool value) {
    if (_isGridView != value) {
      _isGridView = value;
      notifyListeners();
    }
  }

  /// Trạng thái tải dữ liệu ban đầu từ local storage.
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<GardenPlantProfile> get plantProfiles {
    return List<GardenPlantProfile>.unmodifiable(_plantProfiles);
  }

  List<GardenCategory> get plantCategory {
    return List<GardenCategory>.unmodifiable(_plantCategories);
  }

  List<PlantCareHistory> getCareHistory(String gardenPlantId) {
    return _careHistoryCache[gardenPlantId] ?? [];
  }

  /// ID các cây đã lưu.
  Set<String> get savedPlantIds => Set.unmodifiable(_savedPlantIds);

  /// Resolve danh sách cây đã lưu từ danh sách đầy đủ truyền vào.
  /// Gọi trong UI: `controller.resolveFrom(libraryController.plants)`.
  List<LibraryPlantItem> resolveFrom(List<LibraryPlantItem> allPlants) {
    return allPlants
        .where((plant) => _savedPlantIds.contains(plant.id))
        .toList(growable: false);
  }

  /// Danh sách cây đã lưu (instances của MyGardenItem).
  List<MyGardenItem> get savedPlants {
    return List.unmodifiable(_savedPlants);
  }

  /// Đọc danh sách cây đã lưu khi app khởi động.
  Future<void> initialize() async {
    final List<MyGardenItem> plants = await _storage.readSavedPlants();
    _savedPlants
      ..clear()
      ..addAll(plants);
    _isLoading = false;
    notifyListeners();

    try {
      // Gọi API đồng thời để tiết kiệm thời gian
      final results = await Future.wait([
        _apiService.fetchPlantProfiles(),
        _apiService.fetchPlantCategory(),
      ]);

      final List<GardenPlantProfile> profiles =
          results[0] as List<GardenPlantProfile>;
      final List<GardenCategory> categories =
          results[1] as List<GardenCategory>;
      _plantProfiles
        ..clear()
        ..addAll(profiles);
      _plantCategories
        ..clear()
        ..addAll(categories);

      _savedPlantIds
        ..clear()
        ..addAll(profiles.map((profile) => profile.plantId));
    } catch (error, stackTrace) {
      // Log chi tiết lỗi để debug
      debugPrint('LỖI MyGardenController initialize: $error $stackTrace');
      _errorMessage = _mapErrorMessage(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tìm cây gốc trong library.
  LibraryPlantItem? getLibraryPlant(String libraryPlantId) {
    try {
      return libraryPlantSeed.firstWhere((p) => p.id == libraryPlantId);
    } catch (_) {
      return null;
    }
  }

  /// Kiểm tra cây đã có trong vườn hay chưa (dựa trên libraryPlantId để tránh trùng lặp loài).
  bool containsLibraryPlant(String libraryPlantId) {
    return _plantProfiles.any((profile) => profile.plantId == libraryPlantId);
  }

  /// Lấy thông tin cây trong vườn dựa vào ID của thư viện.
  GardenPlantProfile? getPlantProfileByLibraryId(String libraryPlantId) {
    try {
      return _plantProfiles.firstWhere((profile) => profile.plantId == libraryPlantId);
    } catch (_) {
      return null;
    }
  }

  /// Thêm cây mới vào vườn, trả về false nếu đã tồn tại.
  Future<bool> addPlant(String libraryPlantId) async {
    if (containsLibraryPlant(libraryPlantId)) {
      return false;
    }

    final newGardenItem = createDefaultGardenItem(libraryPlantId);
    _savedPlants.insert(0, newGardenItem);
    await _persist();
    notifyListeners();
    return true;
  }

  /// Xóa cây khỏi vườn (dựa trên garden item id) và cập nhật storage.
  Future<void> removePlant(String gardenPlantId) async {
    final int index = _savedPlants.indexWhere((p) => p.id == gardenPlantId);
    if (index != -1) {
      _savedPlants.removeAt(index);
      await _persist();
    }

    final int profileIndex = _plantProfiles.indexWhere(
      (p) => p.plantId == gardenPlantId || p.id == gardenPlantId,
    );
    if (profileIndex != -1) {
      final GardenPlantProfile profile = _plantProfiles[profileIndex];
      final String savedPlantKey = profile.plantId;
      _savedPlantIds.remove(savedPlantKey);
      _plantProfiles.removeAt(profileIndex);
      notifyListeners();

      try {
        await _apiService.deletePlantProfile(profile.id ?? profile.plantId);
      } catch (e) {
        debugPrint('Lỗi khi xóa cây trên server: $e');
      }
    }
  }

  Future<GardenPlantProfile?> upsertPlantProfile(
    GardenPlantProfile profile,
  ) async {
    // Chỉ tìm cây hiện có nếu profile có id hợp lệ hoặc plantId không rỗng
    final bool hasValidId = profile.id != null && profile.id!.isNotEmpty;
    final bool hasValidPlantId = profile.plantId.isNotEmpty;

    final int index = _plantProfiles.indexWhere((item) {
      if (hasValidId && item.id != null) {
        return item.id == profile.id;
      }
      if (hasValidPlantId) {
        return item.plantId == profile.plantId;
      }
      return false;
    });
    try {
      if (index >= 0) {
        final GardenPlantProfile updatedProfile = await _apiService
            .updatePlantProfile(profile);
        _plantProfiles[index] = updatedProfile;
        _savedPlantIds.add(updatedProfile.plantId);
        notifyListeners();
        return updatedProfile;
      } else {
        final GardenPlantProfile createdProfile = await _apiService
            .createPlantProfile(profile);
        _plantProfiles.add(createdProfile);
        _savedPlantIds.add(createdProfile.plantId);
        notifyListeners();
        return createdProfile;
      }
    } catch (_) {
      return null;
    }
  }


  Future<void> updatePlantStatus(
    String plantId,
    GardenPlantStatus status,
  ) async {
    final int index = _plantProfiles.indexWhere(
      (profile) => profile.plantId == plantId,
    );
    if (index < 0) {
      return;
    }
    final GardenPlantProfile updated = _plantProfiles[index].copyWith(
      status: status,
    );
    try {
      final GardenPlantProfile refreshed = await _apiService.updatePlantProfile(
        updated,
      );
      _plantProfiles[index] = refreshed;
      notifyListeners();
    } catch (_) {
      return;
    }
  }

  Future<GardenPlantProfile?> waterPlant(GardenPlantProfile profile) async {
    final now = DateTime.now();
    final nextWateredAt = now.add(
      Duration(days: profile.reminderSetting.wateringCycleDays),
    );

    final updatedReminder = profile.reminderSetting.copyWith(
      lastWateredAt: now,
      nextWateredAt: nextWateredAt,
    );

    final updatedProfile = profile.copyWith(
      reminderSetting: updatedReminder,
      status: GardenPlantStatus.healthy,
    );

    try {
      final String gardenPlantId = profile.id ?? profile.plantId;
      await recordCareAction(gardenPlantId, CareActionType.watering);

      final int index = _plantProfiles.indexWhere(
        (p) => p.plantId == profile.plantId || p.id == profile.id,
      );
      if (index >= 0) {
        _plantProfiles[index] = updatedProfile;
        notifyListeners();
      }

      return updatedProfile;
    } catch (error) {
      debugPrint('Error watering plant: $error');
      return null;
    }
  }

  Future<GardenPlantProfile?> fertilizePlant(
    GardenPlantProfile profile, {
    String? notes,
  }) async {
    final now = DateTime.now();
    final nextFertilizedAt = now.add(
      Duration(days: profile.reminderSetting.fertilizingCycleDays),
    );

    final updatedReminder = profile.reminderSetting.copyWith(
      lastFertilizedAt: now,
      nextFertilizedAt: nextFertilizedAt,
    );

    final updatedProfile = profile.copyWith(
      reminderSetting: updatedReminder,
      status: GardenPlantStatus.healthy,
    );

    try {
      final String gardenPlantId = profile.id ?? profile.plantId;
      await recordCareAction(
        gardenPlantId,
        CareActionType.fertilizing,
        notes: notes,
      );

      final int index = _plantProfiles.indexWhere(
        (p) => p.plantId == profile.plantId || p.id == profile.id,
      );
      if (index >= 0) {
        _plantProfiles[index] = updatedProfile;
        notifyListeners();
      }

      return updatedProfile;
    } catch (error) {
      debugPrint('Error fertilizing plant: $error');
      return null;
    }
  }

  Future<void> fetchCareHistory(String gardenPlantId) async {
    try {
      final history = await _apiService.fetchPlantCareHistory(gardenPlantId);
      _careHistoryCache[gardenPlantId] = history;
      notifyListeners();
    } catch (error) {
      debugPrint('Error fetching care history: $error');
    }
  }

  Future<void> recordCareAction(
    String gardenPlantId,
    CareActionType actionType, {
    String? notes,
  }) async {
    try {
      await _apiService.createCareHistory(gardenPlantId, actionType, notes);
      await fetchCareHistory(gardenPlantId);
      notifyListeners();
    } catch (error) {
      debugPrint('Error recording care action: $error');
    }
  }

  void clearData() {
    _savedPlantIds.clear();
    _plantProfiles.clear();
    _plantCategories.clear();
    _careHistoryCache.clear();
    _savedPlants.clear();
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
  }

  String _mapErrorMessage(Object error) {
    final String normalized = error.toString().toLowerCase();
    if (normalized.contains('missing_api_base_url')) {
      return 'Thieu API_BASE_URL trong file .env';
    }
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }

    return 'Lỗi: ${error.toString()}';
  }

  /// Thêm nhật ký chăm sóc.
  Future<void> addCareLog(String gardenPlantId, PlantCareLogEntry log) async {
    final int index = _savedPlants.indexWhere((p) => p.id == gardenPlantId);
    if (index == -1) return;

    final plant = _savedPlants[index];
    final updatedLogs = List<PlantCareLogEntry>.from(plant.careLogs)
      ..insert(0, log);

    // Cập nhật last watered nếu là tưới nước
    String newLastWatered = plant.lastWateredLabel;
    if (log.title == 'Đã tưới nước') {
      newLastWatered = 'Vừa xong';
    }

    _savedPlants[index] = plant.copyWith(
      careLogs: updatedLogs,
      lastWateredLabel: newLastWatered,
    );

    await _persist();
    notifyListeners();
  }

  /// Thêm ảnh sinh trưởng.
  Future<void> addGrowthSnapshot(
    String gardenPlantId,
    PlantGrowthSnapshot snapshot,
  ) async {
    final int index = _savedPlants.indexWhere((p) => p.id == gardenPlantId);
    if (index == -1) return;

    final plant = _savedPlants[index];
    final updatedTimeline = List<PlantGrowthSnapshot>.from(plant.growthTimeline)
      ..insert(0, snapshot);

    _savedPlants[index] = plant.copyWith(growthTimeline: updatedTimeline);

    await _persist();
    notifyListeners();
  }

  /// Cập nhật sức khỏe hoặc thông tin khác.
  Future<void> updatePlantHealthStatus(
    String gardenPlantId, {
    String? healthStatus,
  }) async {
    final int index = _savedPlants.indexWhere((p) => p.id == gardenPlantId);
    if (index == -1) return;

    final plant = _savedPlants[index];
    _savedPlants[index] = plant.copyWith(healthStatus: healthStatus);

    await _persist();
    notifyListeners();
  }

  /// Ghi danh sách hiện tại xuống local storage.
  Future<void> _persist() async {
    await _storage.writeSavedPlants(_savedPlants);
  }
}
