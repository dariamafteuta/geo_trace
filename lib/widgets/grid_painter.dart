import 'package:flutter/material.dart';

class GridPainter extends CustomPainter {
  final double gridSpacing;
  final Paint gridPaint;

  GridPainter({this.gridSpacing = 20.0})
      : gridPaint = Paint()
          ..color = Colors.blue.withOpacity(0.5)
          ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final pointPaint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += gridSpacing) {
      for (double y = 0; y < size.height; y += gridSpacing) {
        canvas.drawCircle(Offset(x, y), 2.0, pointPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) => false;
}
