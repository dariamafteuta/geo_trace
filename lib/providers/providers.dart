import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/drawing_state.dart';
import 'drawing_notifier.dart';

final drawingProvider2 = StateNotifierProvider<DrawingNotifier, DrawingState>((ref) {
  final pixelRatio = ref.watch(pixelRatioProvider);
  const double gridSpacing = 20.0;

  return DrawingNotifier(pixelRatio, gridSpacing);
});

final pixelRatioProvider = Provider<double>((ref) {
  throw UnimplementedError('PixelRatioProvider должно быть переопределено.');
});

