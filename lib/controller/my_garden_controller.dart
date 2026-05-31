import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:plant_notebook/data/models/category.dart';
import 'package:plant_notebook/data/services/my_garden_service.dart';
import 'package:plant_notebook/data/models/garden_plant.dart';
import 'package:plant_notebook/data/models/care_history.dart';

class MyGardenController extends ChangeNotifier {
  MyGardenController({MyGardenService? apiService})
    : _apiService = apiService ?? MyGardenService();

  final MyGardenService _apiService;
  final Set<String> _savedPlantIds = <String>{};
  final List<GardenPlantProfile> _plantProfiles = <GardenPlantProfile>[];
  final List<GardenCategory> _plantCategories = <GardenCategory>[];
  final Map<String, List<PlantCareHistory>> _careHistoryCache =
      <String, List<PlantCareHistory>>{};

  bool _isLoading = true;
  String? _errorMessage;

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

  /// Đọc danh sách id đã lưu khi app khởi động.
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
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

  /// Kiểm tra cây đã có trong vườn hay chưa.
  bool containsPlant(String plantId) {
    return _savedPlantIds.contains(plantId);
  }

  // Thêm cây mới vào vườn, trả về false nếu đã tồn tại.
  Future<bool> addPlant(String plantId) async {
    if (_savedPlantIds.contains(plantId)) {
      return false;
    }

    // final GardenPlantProfile? option = _findCatalogOption(plantId);
    // if (option == null) {
    //   return false;
    // }

    // final GardenPlantProfile profile = _catalogToProfile(option);
    try {
      // await _apiService.createPlantProfile(profile);
      // _savedPlantIds.add(plantId);
      // _plantProfiles.add(profile);
      // notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Xóa cây khỏi vườn và cập nhật storage.
  Future<void> removePlant(String plantId) async {
    final int index = _plantProfiles.indexWhere(
      (profile) => profile.plantId == plantId || profile.id == plantId,
    );
    if (index < 0) {
      return;
    }
    final GardenPlantProfile profile = _plantProfiles[index];
    final String savedPlantKey = profile.plantId;
    _savedPlantIds.remove(savedPlantKey);

    try {
      await _apiService.deletePlantProfile(profile.id ?? profile.plantId);
      _plantProfiles.removeAt(index);
      notifyListeners();
    } catch (_) {
      _savedPlantIds.add(savedPlantKey);
    }
  }

  Future<GardenPlantProfile?> upsertPlantProfile(
    GardenPlantProfile profile,
  ) async {
    final int index = _plantProfiles.indexWhere((item) {
      if (profile.id != null && item.id != null) {
        return item.id == profile.id;
      }
      return item.plantId == profile.plantId;
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
}
