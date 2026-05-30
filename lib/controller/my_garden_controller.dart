import 'package:flutter/material.dart';
import 'package:plant_notebook/data/models/library_plant_item.dart';
import 'package:plant_notebook/data/services/my_garden_storage.dart';

/// Controller quản lý danh sách cây trong vườn của người dùng.
///
/// Thay vì dùng seed tĩnh, [savedPlants] nhận vào danh sách cây từ
/// [LibraryPlantController] thông qua phương thức [resolveFrom].
class MyGardenController extends ChangeNotifier {
  MyGardenController({MyGardenStorage? storage})
    : _storage = storage ?? MyGardenStorage();

  final MyGardenStorage _storage;
  final Set<String> _savedPlantIds = <String>{};

  bool _isLoading = true;

  /// Trạng thái tải dữ liệu ban đầu từ local storage.
  bool get isLoading => _isLoading;

  /// ID các cây đã lưu.
  Set<String> get savedPlantIds => Set.unmodifiable(_savedPlantIds);

  /// Resolve danh sách cây đã lưu từ danh sách đầy đủ truyền vào.
  /// Gọi trong UI: `controller.resolveFrom(libraryController.plants)`.
  List<LibraryPlantItem> resolveFrom(List<LibraryPlantItem> allPlants) {
    return allPlants
        .where((plant) => _savedPlantIds.contains(plant.id))
        .toList(growable: false);
  }

  /// Đọc danh sách id đã lưu khi app khởi động.
  Future<void> initialize() async {
    final List<String> ids = await _storage.readSavedPlantIds();
    _savedPlantIds
      ..clear()
      ..addAll(ids);
    _isLoading = false;
    notifyListeners();
  }

  /// Kiểm tra cây đã có trong vườn hay chưa.
  bool containsPlant(String plantId) {
    return _savedPlantIds.contains(plantId);
  }

  /// Thêm cây mới vào vườn, trả về false nếu đã tồn tại.
  Future<bool> addPlant(String plantId) async {
    if (_savedPlantIds.contains(plantId)) {
      return false;
    }

    _savedPlantIds.add(plantId);
    await _persist();
    notifyListeners();
    return true;
  }

  /// Xóa cây khỏi vườn và cập nhật storage.
  Future<void> removePlant(String plantId) async {
    if (!_savedPlantIds.remove(plantId)) {
      return;
    }

    await _persist();
    notifyListeners();
  }

  /// Ghi danh sách id hiện tại xuống local storage.
  Future<void> _persist() async {
    await _storage.writeSavedPlantIds(_savedPlantIds.toList(growable: false));
  }
}
