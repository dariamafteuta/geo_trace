import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/drawing_state.dart';
import 'drawing_painter.dart';
import '../providers/providers.dart';
import 'grid_painter.dart';

class DrawingBoard extends ConsumerWidget {
  final _activePointIndex = StateProvider<int?>((ref) => null);

  DrawingBoard({super.key});

  void _onPanStart(
      BuildContext context, DragStartDetails details, WidgetRef ref) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);

    final points = ref.watch(drawingProvider2).currentPoints;

    int? closestIndex;
    double closestDistance = double.infinity;
    for (int i = 0; i < points.length; i++) {
      final distance = (points[i] - localPosition).distance;
      if (distance < closestDistance) {
        closestDistance = distance;
        closestIndex = i;
      }
    }

    if (closestIndex != null && closestDistance < 30.0) {
      ref.read(_activePointIndex.notifier).state = closestIndex;
    }
  }

  void _onPanUpdate(
      BuildContext context, DragUpdateDetails details, WidgetRef ref) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);

    final activePointIndex = ref.watch(_activePointIndex);

    if (activePointIndex != null) {
      ref
          .read(drawingProvider2.notifier)
          .updatePoint(activePointIndex, localPosition);
    }
  }

  void _onTapUp(BuildContext context, TapUpDetails details, WidgetRef ref,
      DrawingState drawingState) {
    if (!drawingState.isPolygonClosed) {
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final localPosition = renderBox.globalToLocal(details.globalPosition);
      ref.read(drawingProvider2.notifier).addPointAndConnect(localPosition);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final drawingState = ref.watch(drawingProvider2);

    final List<Offset> points = drawingState.history.isNotEmpty &&
            drawingState.history.length > drawingState.currentIndex
        ? List<Offset>.from(drawingState.history[drawingState.currentIndex])
        : [];

    return GestureDetector(
        onPanStart: (details) => _onPanStart(context, details, ref),
        onPanUpdate: (details) => _onPanUpdate(context, details, ref),
        onTapUp: (details) => _onTapUp(context, details, ref, drawingState),
        child: CustomPaint(
          size: Size.infinite,
          painter: GridPainter(gridSpacing: 20.0),
          foregroundPainter:
              DrawingPainter(points, pixelRatio, drawingState.isPolygonClosed),
        ));
  }
}
