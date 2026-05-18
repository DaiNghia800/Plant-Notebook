import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:plant_notebook/data/models/plant_analysis_result.dart';
import 'package:plant_notebook/data/services/gemini_scanner_service.dart';

class PlantScannerController extends ChangeNotifier {
  // ── Camera State ─────────────────────────────────────────
  List<CameraDescription> cameras = [];
  CameraController? cameraController;
  int currentCameraIndex = 0;
  bool isCameraReady = false;
  bool isFlipping = false;
  bool isFlashOn = false;

  // ── Analysis State ───────────────────────────────────────
  final GeminiScannerService _scannerService = GeminiScannerService();
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
          .timeout(const Duration(seconds: 45));

      analysisResult = result;
      isAnalyzing = false;
      notifyListeners();
    } catch (e) {
      analysisErrorMessage = _mapAnalysisErrorMessage(e);
      isAnalyzing = false;
      notifyListeners();
    }
  }

  String _mapAnalysisErrorMessage(Object error) {
    final raw = error.toString();
    final normalized = raw.toLowerCase();

    if (normalized.contains('all_ai_keys_rate_limited')) {
      return 'Các API key AI hiện đang bị giới hạn tạm thời (429/503). Vui lòng bấm "Thử Lại" sau ít phút, hệ thống sẽ tự chuyển sang key khả dụng tiếp theo.';
    }

    if (normalized.contains('503') ||
        normalized.contains('unavailable') ||
        normalized.contains('high demand')) {
      return 'Máy chủ AI đang quá tải tạm thời. Hệ thống đã tự thử lại, nhưng vẫn chưa thành công. Vui lòng bấm "Thử Lại" sau ít phút.';
    }

    if (normalized.contains('429') ||
        normalized.contains('resource_exhausted')) {
      return 'Bạn đang gửi yêu cầu quá nhanh hoặc đã chạm giới hạn tạm thời. Vui lòng chờ một chút rồi thử lại.';
    }

    if (normalized.contains('timeout') ||
        normalized.contains('deadline exceeded')) {
      return 'Kết nối đến dịch vụ AI bị chậm. Vui lòng kiểm tra mạng và thử lại.';
    }

    // Chỉ bắt lỗi API key khi rõ ràng là thiếu key (do chúng ta tự throw)
    if (normalized.contains('missing_ai_api_key')) {
      return 'Thiếu API key trong file .env (Gemini/Groq). Vui lòng kiểm tra cấu hình.';
    }

    // Lỗi authentication rõ ràng từ API (401/403)
    if (normalized.contains('401') ||
        normalized.contains('403') ||
        normalized.contains('api_key_invalid') ||
        normalized.contains('invalid api key') ||
        normalized.contains('api key not valid')) {
      return 'API key không hợp lệ hoặc không có quyền truy cập. Vui lòng kiểm tra lại API key trong file .env.';
    }

    // Hiển thị lỗi gốc để dễ debug
    return 'Lỗi phân tích: $raw';
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }
}
