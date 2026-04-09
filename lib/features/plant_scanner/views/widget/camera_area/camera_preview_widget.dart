import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPreviewWidget extends StatelessWidget {
  final CameraController? controller;
  final bool isCameraReady;

  const CameraPreviewWidget({
    super.key,
    required this.controller,
    required this.isCameraReady,
  });

  @override
  Widget build(BuildContext context) {
    if (!isCameraReady || controller == null || !controller!.value.isInitialized) {
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
            width: controller!.value.previewSize!.height,
            height: controller!.value.previewSize!.width,
            child: CameraPreview(controller!),
          ),
        ),
      ),
    );
  }
}
