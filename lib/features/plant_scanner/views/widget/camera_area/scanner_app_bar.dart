import 'package:flutter/material.dart';

class ScannerAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isFlashOn;
  final VoidCallback onToggleFlash;

  const ScannerAppBar({
    super.key,
    required this.isFlashOn,
    required this.onToggleFlash,
  });

  @override
  Widget build(BuildContext context) {
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
          onTap: onToggleFlash,
          child: Container(
            margin: const EdgeInsets.all(8),
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Colors.black26,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: isFlashOn ? const Color(0xFFFFD54F) : Colors.white,
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

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
