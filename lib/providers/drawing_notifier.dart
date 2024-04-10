import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/drawing_state.dart';

class DrawingNotifier extends StateNotifier<DrawingState> {
  final double pixelRatio;
  final double gridSpacing;

  DrawingNotifier(this.pixelRatio, this.gridSpacing)
      : super(DrawingState.initial());

  int orientation(Offset p, Offset q, Offset r) {
    double val = (q.dy - p.dy) * (r.dx - q.dx) - (q.dx - p.dx) * (r.dy - q.dy);
    if (val == 0) return 0;
    return (val > 0) ? 1 : 2;
  }

  bool onSegment(Offset p, Offset q, Offset r) {
    if (q.dx <= max(p.dx, r.dx) &&
        q.dx >= min(p.dx, r.dx) &&
        q.dy <= max(p.dy, r.dy) &&
        q.dy >= min(p.dy, r.dy)) {
      return true;
    }
    return false;
  }

  bool doIntersect(Offset p1, Offset q1, Offset p2, Offset q2) {
    int o1 = orientation(p1, q1, p2);
    int o2 = orientation(p1, q1, q2);
    int o3 = orientation(p2, q2, p1);
    int o4 = orientation(p2, q2, q1);

    if (o1 != o2 && o3 != o4) return true;
    if (o1 == 0 && onSegment(p1, p2, q1)) return true;
    if (o2 == 0 && onSegment(p1, q2, q1)) return true;
    if (o3 == 0 && onSegment(p2, p1, q2)) return true;
    if (o4 == 0 && onSegment(p2, q1, q2)) return true;

    return false;
  }

  bool canAddPoint(Offset newPoint) {
    if (state.currentPoints.length > 1) {
      final Offset lastPoint = state.currentPoints.last;
      for (int i = 0; i < state.currentPoints.length - 2; i++) {
        if (doIntersect(lastPoint, newPoint, state.currentPoints[i],
            state.currentPoints[i + 1])) {
          return false;
        }
      }
    }
    return true;
  }

  void addPointAndConnect(Offset point) {
    if (state.history.every((pointsList) => pointsList.isEmpty)) {
      final Offset firstPoint =
      state.snapToGridEnabled ? snapToGrid(point, gridSpacing) : point;
      state = state.addPoint(firstPoint);

      const double lineLengthPixels = 140;
      final Offset secondPoint =
      Offset(firstPoint.dx + lineLengthPixels, firstPoint.dy);

      state = state.addPoint(secondPoint);
    } else {
      final Offset finalPoint =
      state.snapToGridEnabled ? snapToGrid(point, gridSpacing) : point;

      if (state.isPolygonClosed) return;

      if (canAddPoint(finalPoint)) {
        if (state.currentPoints.isNotEmpty &&
            (state.currentPoints.first - finalPoint).distance < 150.0) {
          if ((state.currentPoints.first - finalPoint).distance > 10.0) {
            state = state.addPoint(finalPoint);
          }

          state = state.copyWith(isPolygonClosed: true);
        } else {
          state = state.addPoint(finalPoint);

          if (state.history.every((pointsList) => pointsList.length <= 1)) {
            const double lineLengthPixels = 100;
            final Offset secondPoint =
            Offset(finalPoint.dx + lineLengthPixels, finalPoint.dy);
            state = state.addPoint(secondPoint);
          }
        }
      }
    }
  }

  Offset snapToGrid(Offset point, double gridSpacing) {
    final double x = (point.dx / gridSpacing).round() * gridSpacing;
    final double y = (point.dy / gridSpacing).round() * gridSpacing;
    return Offset(x, y);
  }

  void toggleSnapToGrid() {
    state = state.copyWith(snapToGridEnabled: !state.snapToGridEnabled);

    if (state.snapToGridEnabled) {
      for (var i = 0; i < state.history.length; i++) {
        for (var j = 0; j < state.history[i].length; j++) {
          state.history[i][j] = snapToGrid(state.history[i][j], gridSpacing);
        }
      }
    }
  }

  void undo() {
    state = state.undo();
  }

  void redo() {
    state = state.redo();
  }

  void updatePoint(int index, Offset newPoint) {
    final newHistory = List<List<Offset>>.from(state.history);
    newHistory[state.currentIndex] =
    List<Offset>.from(newHistory[state.currentIndex]);

    if (index >= 0 && index < newHistory[state.currentIndex].length) {
      final Offset proposedNewPoint = state.snapToGridEnabled
          ? snapToGrid(newPoint, gridSpacing)
          : newPoint;

      List<Offset> newPoints =
      List<Offset>.from(newHistory[state.currentIndex]);
      newPoints[index] = proposedNewPoint;

      bool isIntersecting = false;
      for (int i = 0; i < newPoints.length; i++) {
        int nextIndex = (i + 1) % newPoints.length;
        if (nextIndex == index || i == index) continue;
        if (doIntersect(newPoints[i], newPoints[nextIndex],
            newHistory[state.currentIndex][index], proposedNewPoint)) {
          isIntersecting = true;
          break;
        }
      }

      if (!isIntersecting) {
        newHistory[state.currentIndex][index] = proposedNewPoint;
        state = state.copyWith(history: newHistory);
      }
    }
  }
}
