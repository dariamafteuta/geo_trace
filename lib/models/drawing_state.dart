import 'package:flutter/material.dart';

class DrawingState {
  final List<List<Offset>> history;
  final int currentIndex;
  final double currentAngleDegrees;
  final bool isPolygonClosed;
  final bool snapToGridEnabled;

  DrawingState({
    required this.history,
    required this.currentIndex,
    this.currentAngleDegrees = 0.0,
    this.isPolygonClosed = false,
    this.snapToGridEnabled = false,
  });

  List<Offset> get currentPoints =>
      history.isNotEmpty && history.length > currentIndex
          ? history[currentIndex]
          : [];

  DrawingState addPoint(Offset point) {
    final newHistory = history.sublist(0, currentIndex + 1);
    final currentPoints = List<Offset>.from(newHistory.last);
    currentPoints.add(point);
    newHistory.add(currentPoints);

    return DrawingState(
        history: newHistory, currentIndex: newHistory.length - 1);
  }

  DrawingState undo() {
    if (currentIndex > 0) {
      return DrawingState(history: history, currentIndex: currentIndex - 1);
    }
    return this;
  }

  DrawingState redo() {
    if (currentIndex < history.length - 1) {
      return DrawingState(history: history, currentIndex: currentIndex + 1);
    }
    return this;
  }

  factory DrawingState.initial() {
    return DrawingState(history: [[]], currentIndex: 0);
  }

  DrawingState copyWith({
    List<List<Offset>>? history,
    int? currentIndex,
    bool? isPolygonClosed,
    bool? snapToGridEnabled,
  }) {
    return DrawingState(
      history: history ?? this.history,
      currentIndex: currentIndex ?? this.currentIndex,
      isPolygonClosed: isPolygonClosed ?? this.isPolygonClosed,
      snapToGridEnabled: snapToGridEnabled ?? this.snapToGridEnabled,
    );
  }
}