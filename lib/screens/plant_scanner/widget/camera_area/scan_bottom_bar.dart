import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plant_notebook/controller/profile_controller.dart';

class ScanBottomBar extends StatelessWidget {
  final VoidCallback? onCapture;
  final VoidCallback? onGallery;
  final VoidCallback? onFlipCamera;

  const ScanBottomBar({
    super.key,
    this.onCapture,
    this.onGallery,
    this.onFlipCamera,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<ProfileController>();
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Gallery
          _SideButton(
            icon: Icons.photo_library_outlined,
            label: lang.tr('gallery'),
            onTap: onGallery,
          ),
          // Capture button
          _CaptureButton(onTap: onCapture),
          // Flip camera
          _SideButton(
            icon: Icons.flip_camera_ios_outlined,
            label: lang.tr('switch_camera'),
            onTap: onFlipCamera,
          ),
        ],
      ),
    );
  }
}

class _CaptureButton extends StatefulWidget {
  final VoidCallback? onTap;
  const _CaptureButton({this.onTap});

  @override
  State<_CaptureButton> createState() => _CaptureButtonState();
}

class _CaptureButtonState extends State<_CaptureButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.9,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _controller.reverse();
  void _onTapUp(_) {
    _controller.forward();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onTap == null;
    return Opacity(
      opacity: isDisabled ? 0.4 : 1.0,
      child: GestureDetector(
        onTapDown: isDisabled ? null : _onTapDown,
        onTapUp: isDisabled ? null : _onTapUp,
        onTapCancel: isDisabled ? null : () => _controller.forward(),
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF4CAF50), width: 3),
            ),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF4CAF50),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SideButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _SideButton({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;
    return Opacity(
      opacity: isDisabled ? 0.4 : 1.0,
      child: GestureDetector(
        onTap: isDisabled ? null : onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white70, size: 22),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
