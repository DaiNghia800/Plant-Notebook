import 'package:flutter/material.dart';

class ScannerHelperText extends StatelessWidget {
  const ScannerHelperText({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
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
    );
  }
}
