import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

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

    final bool isDesktopOrWeb = kIsWeb ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;

    final double width = isDesktopOrWeb
        ? controller!.value.previewSize!.width
        : controller!.value.previewSize!.height;
    final double height = isDesktopOrWeb
        ? controller!.value.previewSize!.height
        : controller!.value.previewSize!.width;

    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: width,
            height: height,
            child: CameraPreview(controller!),
          ),
        ),
      ),
    );
  }
}
