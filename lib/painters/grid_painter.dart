import 'package:flutter/material.dart';

class GridPainter extends CustomPainter {
  const GridPainter({this.opacity = 0.1, this.gap = 24.0});

  final double opacity;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00F5FF).withValues(alpha: opacity)
      ..strokeWidth = 0.5;

    for (double x = 0; x < size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) {
    return oldDelegate.opacity != opacity || oldDelegate.gap != gap;
  }
}
