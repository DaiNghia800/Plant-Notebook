import 'package:flutter/material.dart';

enum ScanMode { quetCay, sauBenh, nhanDien }

extension ScanModeLabel on ScanMode {
  String get label {
    switch (this) {
      case ScanMode.quetCay:
        return 'QUÉT CÂY';
      case ScanMode.sauBenh:
        return 'SÂU BỆNH';
      case ScanMode.nhanDien:
        return 'NHẬN DIỆN';
    }
  }
}

class ScanModeTabBar extends StatelessWidget {
  final ScanMode selected;
  final ValueChanged<ScanMode> onChanged;

  const ScanModeTabBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: ScanMode.values.map((mode) {
        final isSelected = mode == selected;
        return GestureDetector(
          onTap: () => onChanged(mode),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isSelected ? Colors.white : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Text(
              mode.label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.8,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
