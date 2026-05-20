import 'package:flutter/material.dart';
import 'package:plant_notebook/data/library_plant_seed.dart';
import 'package:plant_notebook/data/models/library_plant_item.dart';
import 'package:plant_notebook/data/models/my_garden_item.dart';
import 'package:plant_notebook/data/services/my_garden_storage.dart';

class MyGardenController extends ChangeNotifier {
  MyGardenController({MyGardenStorage? storage})
    : _storage = storage ?? MyGardenStorage();

  final MyGardenStorage _storage;
  final List<MyGardenItem> _savedPlants = <MyGardenItem>[];

  bool _isLoading = true;

  /// Trạng thái tải dữ liệu ban đầu từ local storage.
  bool get isLoading => _isLoading;

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
    return _savedPlants.any((plant) => plant.libraryPlantId == libraryPlantId);
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
    if (index == -1) {
      return;
    }

    _savedPlants.removeAt(index);
    await _persist();
    notifyListeners();
  }

  /// Thêm nhật ký chăm sóc.
  Future<void> addCareLog(String gardenPlantId, PlantCareLogEntry log) async {
    final int index = _savedPlants.indexWhere((p) => p.id == gardenPlantId);
    if (index == -1) return;

    final plant = _savedPlants[index];
    final updatedLogs = List<PlantCareLogEntry>.from(plant.careLogs)..insert(0, log);
    
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
  Future<void> addGrowthSnapshot(String gardenPlantId, PlantGrowthSnapshot snapshot) async {
    final int index = _savedPlants.indexWhere((p) => p.id == gardenPlantId);
    if (index == -1) return;

    final plant = _savedPlants[index];
    final updatedTimeline = List<PlantGrowthSnapshot>.from(plant.growthTimeline)..insert(0, snapshot);
    
    _savedPlants[index] = plant.copyWith(growthTimeline: updatedTimeline);

    await _persist();
    notifyListeners();
  }

  /// Cập nhật sức khỏe hoặc thông tin khác.
  Future<void> updatePlantStatus(String gardenPlantId, {String? healthStatus}) async {
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
