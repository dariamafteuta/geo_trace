import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geo_trace/providers/providers.dart';
import 'package:geo_trace/widgets/my_app_bar.dart';

import '../providers/drawing_notifier.dart';
import '../widgets/drawing_board.dart';

class DrawingScreen extends StatelessWidget {
  const DrawingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    const double gridSpacing = 20.0;

    return ProviderScope(
      overrides: [
        drawingProvider2.overrideWith(
              (ref) => DrawingNotifier(devicePixelRatio, gridSpacing),
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(226, 226, 226, 1),
        extendBodyBehindAppBar: true,
        appBar: const MyAppBar(),
        body: DrawingBoard(),
      ),
    );
  }
}