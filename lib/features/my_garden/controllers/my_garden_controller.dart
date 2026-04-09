import 'package:flutter/material.dart';
import 'package:plant_notebook/features/library-plant/data/library_plant_seed.dart';
import 'package:plant_notebook/features/library-plant/models/library_plant_item.dart';
import 'package:plant_notebook/features/my_garden/services/my_garden_storage.dart';

class MyGardenController extends ChangeNotifier {
  MyGardenController({MyGardenStorage? storage})
    : _storage = storage ?? MyGardenStorage();

  final MyGardenStorage _storage;
  final Set<String> _savedPlantIds = <String>{};

  bool _isLoading = true;

  /// Trạng thái tải dữ liệu ban đầu từ local storage.
  bool get isLoading => _isLoading;

  /// Danh sách cây đã lưu, ánh xạ từ id sang dữ liệu seed hiện có.
  List<LibraryPlantItem> get savedPlants {
    return libraryPlantSeed
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
