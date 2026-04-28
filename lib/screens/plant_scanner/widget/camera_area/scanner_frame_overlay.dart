import 'package:flutter/material.dart';
import 'dart:math' as math;

class ScannerFrameOverlay extends StatefulWidget {
  const ScannerFrameOverlay({super.key});

  @override
  State<ScannerFrameOverlay> createState() => _ScannerFrameOverlayState();
}

class _ScannerFrameOverlayState extends State<ScannerFrameOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scanLineAnim;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanLineAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _pulseAnim = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _FramePainter(
            scanLineProgress: _scanLineAnim.value,
            pulseAlpha: _pulseAnim.value,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _FramePainter extends CustomPainter {
  final double scanLineProgress;
  final double pulseAlpha;

  _FramePainter({required this.scanLineProgress, required this.pulseAlpha});

  @override
  void paint(Canvas canvas, Size size) {
    const frameW = 240.0;
    const frameH = 280.0;
    final left = (size.width - frameW) / 2;
    final top = (size.height - frameH) / 2;
    final right = left + frameW;
    final bottom = top + frameH;
    const cornerLen = 28.0;
    const cornerRadius = 6.0;
    const strokeW = 2.5;

    // Dark overlay outside frame
    final overlayPaint = Paint()..color = Colors.black.withOpacity(0.45);
    final framePath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(left, top, right, bottom),
          const Radius.circular(12),
        ),
      );
    framePath.fillType = PathFillType.evenOdd;
    canvas.drawPath(framePath, overlayPaint);

    // Glowing border (subtle)
    final glowPaint = Paint()
      ..color = const Color(0xFF4CAF50).withOpacity(0.25 * pulseAlpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(left, top, right, bottom),
        const Radius.circular(12),
      ),
      glowPaint,
    );

    // Corner brackets
    final cornerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round;

    _drawCorner(canvas, cornerPaint, left, top, cornerLen, cornerRadius, 0);
    _drawCorner(canvas, cornerPaint, right, top, cornerLen, cornerRadius, 1);
    _drawCorner(canvas, cornerPaint, left, bottom, cornerLen, cornerRadius, 2);
    _drawCorner(canvas, cornerPaint, right, bottom, cornerLen, cornerRadius, 3);

    // Scan line
    final scanY = top + (frameH * scanLineProgress);
    final scanPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF66BB6A).withOpacity(0.9),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTRB(left, scanY, right, scanY + 2));
    canvas.drawLine(
      Offset(left + 8, scanY),
      Offset(right - 8, scanY),
      scanPaint..strokeWidth = 1.5,
    );

    // Center dot indicators on corners
    final dotPaint = Paint()
      ..color = const Color(0xFF66BB6A).withOpacity(pulseAlpha)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(left, top), 4, dotPaint);
    canvas.drawCircle(Offset(right, top), 4, dotPaint);
    canvas.drawCircle(Offset(left, bottom), 4, dotPaint);
    canvas.drawCircle(Offset(right, bottom), 4, dotPaint);
  }

  void _drawCorner(
    Canvas canvas,
    Paint paint,
    double x,
    double y,
    double len,
    double r,
    int corner,
  ) {
    // corner: 0=TL, 1=TR, 2=BL, 3=BR
    final hDir = (corner == 0 || corner == 2) ? 1.0 : -1.0;
    final vDir = (corner == 0 || corner == 1) ? 1.0 : -1.0;

    final path = Path();
    // Horizontal arm
    path.moveTo(x + hDir * r, y);
    path.lineTo(x + hDir * len, y);
    // Vertical arm
    path.moveTo(x, y + vDir * r);
    path.lineTo(x, y + vDir * len);
    // Corner arc
    path.moveTo(x + hDir * r, y);
    path.arcToPoint(
      Offset(x, y + vDir * r),
      radius: Radius.circular(r),
      clockwise: (corner == 0 || corner == 3),
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_FramePainter oldDelegate) =>
      oldDelegate.scanLineProgress != scanLineProgress ||
      oldDelegate.pulseAlpha != pulseAlpha;
}
