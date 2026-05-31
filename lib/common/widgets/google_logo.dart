import 'package:flutter/material.dart';

class GoogleLogoWidget extends StatelessWidget {
  const GoogleLogoWidget({super.key, this.size = 24});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    canvas.save();
    canvas.scale(w / 48.0, h / 48.0);

    // Red Part
    final Paint redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final Path redPath = Path()
      ..moveTo(24, 9.5)
      ..cubicTo(27.54, 9.5, 30.71, 10.72, 33.21, 13.1)
      ..lineTo(40.06, 6.25)
      ..cubicTo(35.9, 2.38, 30.47, 0, 24, 0)
      ..cubicTo(14.62, 0, 6.51, 5.38, 2.56, 13.22)
      ..lineTo(10.54, 19.41)
      ..cubicTo(12.43, 13.72, 17.74, 9.5, 24, 9.5)
      ..close();
    canvas.drawPath(redPath, redPaint);

    // Yellow Part
    final Paint yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final Path yellowPath = Path()
      ..moveTo(10.54, 28.59)
      ..cubicTo(10.06, 27.14, 9.78, 25.6, 9.78, 24)
      ..cubicTo(9.78, 22.4, 10.06, 20.86, 10.54, 19.41)
      ..lineTo(2.56, 13.22)
      ..cubicTo(0.92, 16.46, 0, 20.12, 0, 24)
      ..cubicTo(0, 27.88, 0.92, 31.54, 2.56, 34.78)
      ..lineTo(10.54, 28.59)
      ..close();
    canvas.drawPath(yellowPath, yellowPaint);

    // Green Part
    final Paint greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final Path greenPath = Path()
      ..moveTo(24, 38.5)
      ..cubicTo(17.74, 38.5, 12.43, 34.28, 10.54, 28.59)
      ..lineTo(2.56, 34.78)
      ..cubicTo(6.51, 42.62, 14.62, 48, 24, 48)
      ..cubicTo(29.84, 48, 35.23, 46.08, 39.35, 42.76)
      ..lineTo(32.17, 37.19)
      ..cubicTo(29.86, 38.62, 26.95, 38.5, 24, 38.5)
      ..close();
    canvas.drawPath(greenPath, greenPaint);

    // Blue Part
    final Paint bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final Path bluePath = Path()
      ..moveTo(46.5, 24)
      ..cubicTo(46.5, 22.37, 46.35, 20.8, 46.08, 19.27)
      ..lineTo(24, 19.27)
      ..lineTo(24, 28.27)
      ..lineTo(36.75, 28.27)
      ..cubicTo(36.2, 31.23, 34.53, 33.75, 32.02, 35.44)
      ..lineTo(32.17, 37.19)
      ..lineTo(39.35, 42.76)
      ..cubicTo(43.54, 38.9, 46.5, 33.21, 46.5, 24)
      ..close();
    canvas.drawPath(bluePath, bluePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
