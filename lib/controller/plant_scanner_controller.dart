import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:plant_notebook/data/models/plant_analysis_result.dart';
import 'package:plant_notebook/data/services/plant_scanner_service.dart';

class PlantScannerController extends ChangeNotifier {
  // ── Camera State ─────────────────────────────────────────
  List<CameraDescription> cameras = [];
  CameraController? cameraController;
  int currentCameraIndex = 0;
  bool isCameraReady = false;
  bool isFlipping = false;
  bool isFlashOn = false;

  // ── Analysis State ───────────────────────────────────────
  final PlantScannerService _scannerService = PlantScannerService();
  bool isAnalyzing = true;
  PlantAnalysisResult? analysisResult;
  String? analysisErrorMessage;

  // ── Lifecycle Mgt ────────────────────────────────────────
  Future<void> initCamera({Function(String)? onError}) async {
    try {
      cameras = await availableCameras();
      if (cameras.isEmpty) return;
      await _initCameraAt(0, onError: onError);
    } on CameraException catch (e) {
      onError?.call('Không thể mở camera: ${e.description}');
    }
  }

  Future<void> _initCameraAt(int index, {Function(String)? onError}) async {
    if (cameras.isEmpty) return;

    final previous = cameraController;
    if (previous != null) {
      await previous.dispose();
    }

    final controller = CameraController(
      cameras[index],
      ResolutionPreset.veryHigh,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    cameraController = controller;

    try {
      await controller.initialize();
      await controller.setFlashMode(
        isFlashOn ? FlashMode.torch : FlashMode.off,
      );

      currentCameraIndex = index;
      isCameraReady = true;
      isFlipping = false;
      notifyListeners();
    } on CameraException catch (e) {
      isFlipping = false;
      notifyListeners();
      onError?.call('Lỗi camera: ${e.description}');
    }
  }

  void onChangeAppLifecycleState(AppLifecycleState state) {
    final controller = cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCameraAt(currentCameraIndex);
    }
  }

  Future<void> onFlipCamera({Function(String)? onError}) async {
    if (cameras.length < 2 || isFlipping) return;

    isCameraReady = false;
    isFlipping = true;
    notifyListeners();

    final nextIndex = (currentCameraIndex + 1) % cameras.length;
    await _initCameraAt(nextIndex, onError: onError);
  }

  Future<void> onToggleFlash({Function(String)? onError}) async {
    final controller = cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    if (cameras[currentCameraIndex].lensDirection ==
        CameraLensDirection.front) {
      onError?.call('Camera trước không hỗ trợ đèn flash');
      return;
    }

    try {
      final newFlash = !isFlashOn;
      await controller.setFlashMode(newFlash ? FlashMode.torch : FlashMode.off);
      isFlashOn = newFlash;
      notifyListeners();
    } on CameraException catch (e) {
      onError?.call('Không thể bật đèn: ${e.description}');
    }
  }

  final ImagePicker _imagePicker = ImagePicker();

  Future<void> onCapture({
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    final controller = cameraController;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.isTakingPicture) return;

    try {
      final XFile photo = await controller.takePicture().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw CameraException(
            'Timeout',
            'Camera mất quá nhiều thời gian để chụp',
          );
        },
      );
      onSuccess(photo.path);
    } on CameraException catch (e) {
      onError('Chụp ảnh thất bại: ${e.description}');
    } catch (e) {
      onError('Lỗi chụp ảnh: $e');
    }
  }

  Future<void> onGallery({
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (file != null) {
        onSuccess(file.path);
      }
    } catch (e) {
      onError('Không thể mở thư viện: $e');
    }
  }

  // ── AI Analysis ──────────────────────────────────────────
  Future<void> analyzeImage(String imagePath) async {
    isAnalyzing = true;
    analysisErrorMessage = null;
    analysisResult = null;
    notifyListeners();

    try {
      final file = File(imagePath);
      final result = await _scannerService
          .analyzePlantImage(file)
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              throw Exception('timeout');
            },
          );

      analysisResult = result;
      isAnalyzing = false;
      notifyListeners();
    } catch (e) {
      // Log lỗi chi tiết ra terminal cho dev
      // ignore: avoid_print
      print('[PlantScannerController] analyzeImage ERROR: $e');
      analysisErrorMessage = _mapAnalysisErrorMessage(e);
      isAnalyzing = false;
      notifyListeners();
    }
  }

  String _mapAnalysisErrorMessage(Object error) {
    final raw = error.toString();
    final normalized = raw.toLowerCase();

    // ── Lỗi cứng: thiếu API key ─────────────────────────────────────────────
    if (normalized.contains('missing_ai_api_key')) {
      return 'Chưa cấu hình API key.\nVui lòng thêm GEMINI API key vào file .env và khởi động lại ứng dụng.';
    }

    // ── Tất cả provider đều hết quota ────────────────────────────────────────
    if (normalized.contains('all_providers_exhausted') ||
        normalized.contains('all_ai_keys_rate_limited')) {
      return 'Tất cả dịch vụ AI đang bận.\nHệ thống đã thử nhiều lần nhưng đều bị giới hạn. Vui lòng thử lại sau vài phút.';
    }

    // ── Quá tải / Server bận ──────────────────────────────────────────────────
    if (normalized.contains('503') ||
        normalized.contains('overloaded') ||
        normalized.contains('high demand') ||
        normalized.contains('too many requests')) {
      return 'Máy chủ AI đang quá tải.\nHệ thống đã tự thử lại nhiều lần nhưng chưa thành công. Vui lòng thử lại sau ít phút.';
    }

    // ── Rate limit (429) ──────────────────────────────────────────────────────
    if (normalized.contains('429') ||
        normalized.contains('rate_limit') ||
        normalized.contains('resource_exhausted') ||
        normalized.contains('quota')) {
      return 'Đã đạt giới hạn yêu cầu AI tạm thời.\nVui lòng đợi khoảng 30 giây rồi bấm "Thử Lại".';
    }

    // ── Timeout / Mạng chậm ──────────────────────────────────────────────────
    if (normalized.contains('timeout') ||
        normalized.contains('deadline exceeded') ||
        normalized.contains('timed out')) {
      return 'Kết nối đến dịch vụ AI quá chậm.\nVui lòng kiểm tra mạng và bấm "Thử Lại".';
    }

    // ── API key không hợp lệ (401/403) ───────────────────────────────────────
    if (normalized.contains('401') ||
        normalized.contains('403') ||
        normalized.contains('api_key_invalid') ||
        normalized.contains('invalid api key') ||
        normalized.contains('api key not valid') ||
        normalized.contains('authentication')) {
      return 'API key không hợp lệ.\nVui lòng kiểm tra lại GEMINI_API_KEY trong file .env.';
    }

    // ── Lỗi parse JSON từ AI ──────────────────────────────────────────────────
    if (normalized.contains('json') ||
        normalized.contains('format') ||
        normalized.contains('không đúng định dạng')) {
      return 'AI trả về dữ liệu không đúng định dạng.\nVui lòng thử lại – đôi khi AI cần thêm một lần để phân tích chính xác.';
    }

    // ── Fallback: thông báo chung, ẩn chi tiết kỹ thuật khỏi UI ─────────────
    return 'Không thể phân tích ảnh lúc này.\nVui lòng thử lại sau ít phút.';
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }
}
