import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:plant_notebook/controller/profile_controller.dart';

import 'package:plant_notebook/controller/plant_scanner_controller.dart';
import 'package:plant_notebook/controller/scan_upload_controller.dart';
import 'package:plant_notebook/screens/plant_scanner/widget/camera_area/scan_bottom_bar.dart';
import 'package:plant_notebook/screens/plant_scanner/widget/camera_area/scan_status_chip.dart';
import 'package:plant_notebook/screens/plant_scanner/widget/camera_area/scanner_frame_overlay.dart';
import 'package:plant_notebook/screens/plant_scanner/widget/camera_area/scanner_app_bar.dart';
import 'package:plant_notebook/screens/plant_scanner/widget/camera_area/camera_preview_widget.dart';
import 'package:plant_notebook/screens/plant_scanner/widget/camera_area/scanner_helper_text.dart';

class PlantScannerScreen extends StatefulWidget {
  const PlantScannerScreen({super.key});

  @override
  State<PlantScannerScreen> createState() => _PlantScannerScreenState();
}

class _PlantScannerScreenState extends State<PlantScannerScreen>
    with WidgetsBindingObserver {
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlantScannerController>().initCamera(onError: _showError);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    context.read<PlantScannerController>().onChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
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

  /// Khi user chụp/chọn ảnh: upload lên server → nhận taskId → hiện thông báo → quay lại
  Future<void> _onImageSelected(String imagePath) async {
    if (!mounted) return;

    final uploadController = context.read<ScanUploadController>();

    // Hiện dialog "đang tải ảnh lên" tạm thời
    _showUploadingBanner();

    await uploadController.uploadAndScan(
      imagePath: imagePath,
      onSuccess: (taskId) {
        if (!mounted) return;
        // Ẩn tất cả snackbar cũ
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        // Thông báo đã gửi xong, chờ AI xử lý
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Ảnh đã được gửi đi!\nBạn sẽ nhận thông báo khi AI phân tích xong.',
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF2E7D32),
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        // Quay lại màn hình trước để user tự do làm việc khác
        if (mounted) Navigator.of(context).pop();
      },
      onError: (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        _showError('Lỗi gửi ảnh: $error');
      },
    );
  }

  void _showUploadingBanner() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text('Đang tải ảnh lên server...'),
          ],
        ),
        backgroundColor: const Color(0xFF1B5E20),
        duration: const Duration(seconds: 30),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<PlantScannerController, ScanUploadController>(
      builder: (context, controller, uploadController, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          extendBodyBehindAppBar: true,
          appBar: ScannerAppBar(
            isFlashOn: controller.isFlashOn,
            onToggleFlash: () => controller.onToggleFlash(onError: _showError),
          ),
          body: Column(
            children: [
              Expanded(child: _buildCameraArea(controller)),
              ScanBottomBar(
                // Khoá nút trong khi đang upload
                onCapture: uploadController.isUploading
                    ? null
                    : () => controller.onCapture(
                          onSuccess: _onImageSelected,
                          onError: _showError,
                        ),
                onGallery: uploadController.isUploading
                    ? null
                    : () => controller.onGallery(
                          onSuccess: _onImageSelected,
                          onError: _showError,
                        ),
                onFlipCamera: () =>
                    controller.onFlipCamera(onError: _showError),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCameraArea(PlantScannerController controller) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreviewWidget(
          controller: controller.cameraController,
          isCameraReady: controller.isCameraReady,
        ),
        if (controller.isFlipping)
          Container(
            color: Colors.black87,
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4CAF50),
                strokeWidth: 2,
              ),
            ),
          ),
        const ScannerFrameOverlay(),
        Positioned(
          bottom: 50,
          left: 0,
          right: 0,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScanStatusChip(
                  label: context
                      .watch<ProfileController>()
                      .tr('scan')
                      .toUpperCase(),
                ),
                const SizedBox(height: 12),
                const ScannerHelperText(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
