import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:plant_notebook/controller/plant_scanner_controller.dart';
import 'package:plant_notebook/screens/plant_scanner/widget/camera_area/scan_bottom_bar.dart';
import 'package:plant_notebook/screens/plant_scanner/widget/camera_area/scan_status_chip.dart';
import 'package:plant_notebook/screens/plant_scanner/widget/camera_area/scanner_frame_overlay.dart';
import 'package:plant_notebook/screens/plant_scanner/widget/camera_area/scanner_app_bar.dart';
import 'package:plant_notebook/screens/plant_scanner/widget/camera_area/camera_preview_widget.dart';
import 'package:plant_notebook/screens/plant_scanner/widget/camera_area/scanner_helper_text.dart';
import 'package:plant_notebook/screens/plant_scanner/scan_result_screen.dart';

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

    // Khởi tạo camera khi mở trang
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

  void _navigateToResult(String imagePath) {
    _showSnackBar('Đã chuẩn bị ảnh, đang phân tích...');
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ScanResultScreen(imagePath: imagePath)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlantScannerController>(
      builder: (context, controller, child) {
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
                onCapture: () => controller.onCapture(
                  onSuccess: _navigateToResult,
                  onError: _showError,
                ),
                onGallery: () => controller.onGallery(
                  onSuccess: _navigateToResult,
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
        const Positioned(
          bottom: 50,
          left: 0,
          right: 0,
          child: Center(
            child: Column(children: [ScanStatusChip(), ScannerHelperText()]),
          ),
        ),
      ],
    );
  }
}
