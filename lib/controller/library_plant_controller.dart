import 'package:flutter/material.dart';
import 'package:plant_notebook/data/models/library_plant_item.dart';
import 'package:plant_notebook/data/services/library_plant_api_service.dart';

/// Trạng thái load dữ liệu thư viện cây.
enum LibraryLoadStatus { idle, loading, success, error }

/// Controller quản lý dữ liệu thư viện cây từ API.
/// Đăng ký qua Provider (ChangeNotifierProvider) trong main.dart.
class LibraryPlantController extends ChangeNotifier {
  LibraryPlantController({LibraryPlantApiService? apiService})
      : _apiService = apiService ?? LibraryPlantApiService();

  final LibraryPlantApiService _apiService;

  // ── State ──────────────────────────────────────────────────────────────────
  LibraryLoadStatus _status = LibraryLoadStatus.idle;
  List<LibraryPlantItem> _plants = [];
  String? _errorMessage;

  // ── Getters ────────────────────────────────────────────────────────────────
  LibraryLoadStatus get status => _status;
  List<LibraryPlantItem> get plants => _plants;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == LibraryLoadStatus.loading;
  bool get hasError => _status == LibraryLoadStatus.error;
  bool get isEmpty =>
      _status == LibraryLoadStatus.success && _plants.isEmpty;

  // ── Actions ────────────────────────────────────────────────────────────────

  /// Gọi lần đầu khi màn hình Library mở — fetch toàn bộ cây đã approved.
  Future<void> loadPlants({bool forceRefresh = false}) async {
    // Tránh fetch lại nếu đã có data và không bắt buộc refresh.
    if (_status == LibraryLoadStatus.success &&
        _plants.isNotEmpty &&
        !forceRefresh) {
      return;
    }

    _setLoading();

    try {
      final List<LibraryPlantItem> result =
          await _apiService.getAllPlants(approvalStatus: 'approved');
      _plants = result;
      _status = LibraryLoadStatus.success;
      _errorMessage = null;
    } on LibraryPlantApiException catch (e) {
      _status = LibraryLoadStatus.error;
      _errorMessage = 'Lỗi từ server (${e.statusCode}): ${e.message}';
    } catch (e) {
      // ignore: avoid_print
      print('[LibraryPlantController] loadPlants error: $e');
      _status = LibraryLoadStatus.error;
      _errorMessage =
          'Không thể kết nối tới server. Vui lòng kiểm tra kết nối mạng.';
    }

    notifyListeners();
  }

  /// Refresh — kéo để tải lại dữ liệu.
  Future<void> refresh() => loadPlants(forceRefresh: true);

  /// Lấy cây theo ID từ danh sách đã load (không cần gọi API lại).
  LibraryPlantItem? findById(String id) {
    try {
      return _plants.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  void _setLoading() {
    _status = LibraryLoadStatus.loading;
    // notifyListeners();
  }
}
