import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class DrawingPainter extends CustomPainter {
  final List<Offset> points;
  final double devicePixelRatio;
  final bool isPolygonClosed;
  final int? activePointIndex;

  DrawingPainter(this.points, this.devicePixelRatio, this.isPolygonClosed, this.activePointIndex);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 7.0;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    const textStyle = TextStyle(color: Colors.blue, fontSize: 14);

    if (points.isNotEmpty && isPolygonClosed) {
      final path = Path()..addPolygon(points, true);
      final paint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, paint);
    }

    if (isPolygonClosed && points.length > 1) {
      final firstPoint = points.first;
      final lastPoint = points.last;
      final distanceInPixels = (lastPoint - firstPoint).distance;
      final distanceInCm = distanceInPixels / (devicePixelRatio * 160 / 2.54);
      final distanceText = "${distanceInCm.toStringAsFixed(2)} см";

      final midPoint = Offset((lastPoint.dx + firstPoint.dx) / 2,
          (lastPoint.dy + firstPoint.dy) / 2);
      final angle =
          atan2(firstPoint.dy - lastPoint.dy, firstPoint.dx - lastPoint.dx);

      final textSpan = TextSpan(text: distanceText, style: textStyle);
      textPainter.text = textSpan;
      textPainter.layout();

      const double textPadding = 10.0;

      canvas.save();
      canvas.translate(midPoint.dx, midPoint.dy);
      canvas.rotate(angle);
      final yOffset = angle.abs() > pi / 2
          ? -textPadding - textPainter.height
          : textPadding;
      textPainter.paint(canvas, Offset(-textPainter.width / 2, yOffset));
      canvas.restore();

      final linePaint = Paint()
        ..color = Colors.black
        ..strokeWidth = 7.0;
      if (points.length > 1) {
        canvas.drawLine(points.first, points.last, linePaint);
      }
    }

    if (activePointIndex != null && activePointIndex! < points.length) {
      final activePoint = points[activePointIndex!];
      _drawIconAtPoint(canvas, activePoint);
    }

    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);

      final distanceInPixels = (points[i] - points[i + 1]).distance;
      final distanceInCm = distanceInPixels / (devicePixelRatio * 160 / 2.54);
      final distanceText = "${distanceInCm.toStringAsFixed(2)} см";

      final midPoint = Offset((points[i].dx + points[i + 1].dx) / 2,
          (points[i].dy + points[i + 1].dy) / 2);

      final angle = atan2(
          points[i + 1].dy - points[i].dy, points[i + 1].dx - points[i].dx);

      const double textPadding = 10.0;

      final textSpan = TextSpan(text: distanceText, style: textStyle);
      textPainter.text = textSpan;
      textPainter.layout();
      canvas.save();
      canvas.translate(midPoint.dx, midPoint.dy);
      canvas.rotate(angle);
      textPainter.paint(
          canvas,
          Offset(
              -textPainter.width / 2,
              angle.abs() > pi / 2
                  ? -textPadding - textPainter.height
                  : textPadding));
      canvas.restore();
    }

    if (!isPolygonClosed && points.isNotEmpty) {
      final lastPoint = points.last;

      _drawIconAtPoint(canvas, lastPoint);
      const icon = Icons.open_with;
      TextSpan span = TextSpan(
        style: TextStyle(
          fontSize: 50.0,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: Colors.blue,
        ),
        text: String.fromCharCode(icon.codePoint),
      );

      TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      tp.layout();

      Offset iconPosition =
          Offset(lastPoint.dx - tp.width / 2, lastPoint.dy - tp.height / 2);
      tp.paint(canvas, iconPosition);
    }

    final pointPaint = Paint()
      ..color = isPolygonClosed ? Colors.white : Colors.blue
      ..style = PaintingStyle.fill;
    final pointOutlinePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (final point in points) {
      canvas.drawCircle(point, 7.0, pointPaint);
      canvas.drawCircle(point, 7.0, pointOutlinePaint);
    }
  }

  void _drawIconAtPoint(Canvas canvas, Offset point) {
    const icon = Icons.open_with;
    TextSpan span = TextSpan(
      style: TextStyle(
        fontSize: 50.0,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        color: Colors.blue,
      ),
      text: String.fromCharCode(icon.codePoint),
    );

    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    tp.layout();

    Offset iconPosition =
    Offset(point.dx - tp.width / 2, point.dy - tp.height / 2);
    tp.paint(canvas, iconPosition);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
