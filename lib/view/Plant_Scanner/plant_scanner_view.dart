import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_notebook/view/Plant_Scanner/widget/scan_bottom_bar.dart';
import 'package:plant_notebook/view/Plant_Scanner/widget/scan_mode_label.dart';
import 'package:plant_notebook/view/Plant_Scanner/widget/scan_status_chip.dart';
import 'package:plant_notebook/view/Plant_Scanner/widget/scanner_frame_overlay.dart';

class PlantScannerView extends StatefulWidget {
  const PlantScannerView({super.key});

  @override
  State<PlantScannerView> createState() => _PlantScannerViewState();
}

class _PlantScannerViewState extends State<PlantScannerView>
    with WidgetsBindingObserver {
  // ── Camera ──────────────────────────────────────────────
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  int _currentCameraIndex = 0; // 0 = back, 1 = front
  bool _isCameraReady = false;

  // ── Flash ────────────────────────────────────────────────
  bool _isFlashOn = false;

  // ── Scan mode ────────────────────────────────────────────
  ScanMode _currentMode = ScanMode.quetCay;

  // ── Gallery ──────────────────────────────────────────────
  final ImagePicker _imagePicker = ImagePicker();
  File? _pickedImage;

  // ── Flip animation ───────────────────────────────────────
  bool _isFlipping = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    _initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCameraAt(_currentCameraIndex);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  // ── Khởi tạo camera lần đầu ──────────────────────────────
  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;
      await _initCameraAt(0);
    } on CameraException catch (e) {
      _showError('Không thể mở camera: ${e.description}');
    }
  }

  // ── Khởi tạo camera theo index ────────────────────────────
  Future<void> _initCameraAt(int index) async {
    if (_cameras.isEmpty) return;

    final previous = _cameraController;
    if (previous != null) {
      await previous.dispose();
    }

    final controller = CameraController(
      _cameras[index],
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    _cameraController = controller;

    try {
      await controller.initialize();
      // Áp lại flash mode sau khi khởi tạo
      await controller.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );

      if (mounted) {
        setState(() {
          _currentCameraIndex = index;
          _isCameraReady = true;
          _isFlipping = false;
        });
      }
    } on CameraException catch (e) {
      if (mounted) setState(() => _isFlipping = false);
      _showError('Lỗi camera: ${e.description}');
    }
  }

  // ── Đổi camera trước/sau ──────────────────────────────────
  Future<void> _onFlipCamera() async {
    if (_cameras.length < 2 || _isFlipping) return;

    setState(() {
      _isCameraReady = false;
      _isFlipping = true;
    });

    final nextIndex = (_currentCameraIndex + 1) % _cameras.length;
    await _initCameraAt(nextIndex);
  }

  // ── Bật/tắt flash ─────────────────────────────────────────
  Future<void> _onToggleFlash() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    // Camera trước không hỗ trợ flash
    if (_cameras[_currentCameraIndex].lensDirection ==
        CameraLensDirection.front) {
      _showError('Camera trước không hỗ trợ đèn flash');
      return;
    }

    try {
      final newFlash = !_isFlashOn;
      await controller.setFlashMode(newFlash ? FlashMode.torch : FlashMode.off);
      setState(() => _isFlashOn = newFlash);
    } on CameraException catch (e) {
      _showError('Không thể bật đèn: ${e.description}');
    }
  }

  // ── Chụp ảnh ─────────────────────────────────────────────
  Future<void> _onCapture() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.isTakingPicture) return;

    try {
      final XFile photo = await controller.takePicture();
      if (!mounted) return;

      // TODO: Chuyển sang màn hình kết quả và truyền photo.path
      _showSnackBar('Đã chụp ảnh, đang phân tích...');

      // Ví dụ navigate đến màn hình kết quả:
      // Navigator.of(context).push(MaterialPageRoute(
      //   builder: (_) => ScanResultView(imagePath: photo.path),
      // ));
    } on CameraException catch (e) {
      _showError('Chụp ảnh thất bại: ${e.description}');
    }
  }

  // ── Mở thư viện ảnh ──────────────────────────────────────
  Future<void> _onGallery() async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (file == null || !mounted) return;

      setState(() => _pickedImage = File(file.path));

      // TODO: Chuyển sang màn hình kết quả với ảnh từ thư viện
      _showSnackBar('Đã chọn ảnh, đang phân tích...');

      // Ví dụ navigate:
      // Navigator.of(context).push(MaterialPageRoute(
      //   builder: (_) => ScanResultView(imagePath: file.path),
      // ));
    } catch (e) {
      _showError('Không thể mở thư viện: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF2E7D32),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFC62828),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildCameraArea()),
          ScanBottomBar(
            onCapture: _onCapture,
            onGallery: _onGallery,
            onFlipCamera: _onFlipCamera,
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.black26,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
        ),
      ),
      title: const Text(
        'Sổ tay cây trồng',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        // Flash toggle
        GestureDetector(
          onTap: _onToggleFlash,
          child: Container(
            margin: const EdgeInsets.all(8),
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Colors.black26,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: _isFlashOn ? const Color(0xFFFFD54F) : Colors.white,
              size: 20,
            ),
          ),
        ),
        // Info
        Container(
          margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: Colors.black26,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.info_outline, color: Colors.white, size: 20),
        ),
      ],
    );
  }

  Widget _buildCameraArea() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera preview
        _buildCameraPreview(),

        // Hiệu ứng flip overlay
        if (_isFlipping)
          Container(
            color: Colors.black87,
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4CAF50),
                strokeWidth: 2,
              ),
            ),
          ),

        // Scanner frame
        const ScannerFrameOverlay(),

        // Helper text
        Positioned(
          bottom: 140,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Giữ điện thoại ổn định và hướng camera vào tổng quan cây. '
                'Nhấn vào tâm camera để lấy nét cây tốt nhất.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 11.5,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ),

        // Status chip
        const Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          child: Center(child: ScanStatusChip()),
        ),

        // Mode tabs
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: ScanModeTabBar(
            selected: _currentMode,
            onChanged: (mode) => setState(() => _currentMode = mode),
          ),
        ),
      ],
    );
  }

  Widget _buildCameraPreview() {
    final controller = _cameraController;

    if (!_isCameraReady ||
        controller == null ||
        !controller.value.isInitialized) {
      return Container(
        color: const Color(0xFF0A1A0A),
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF4CAF50),
            strokeWidth: 2,
          ),
        ),
      );
    }

    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller.value.previewSize!.height,
            height: controller.value.previewSize!.width,
            child: CameraPreview(controller),
          ),
        ),
      ),
    );
  }
}
