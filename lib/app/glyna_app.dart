import 'package:flutter/material.dart';

import '../content/app_content.dart';
import '../debug/debug_tools.dart';
import '../engine/clock.dart';
import '../screens/bento/bento_screen.dart';
import '../store/glyna_repository.dart';
import '../theme/theme.dart';
import '../validation/lock_detector.dart';
import '../validation/platform_lock_detector.dart';

/// Racine de l'app. Sombre par défaut.
class GlynaApp extends StatelessWidget {
  const GlynaApp({
    super.key,
    required this.repository,
    this.clock = const SystemClock(),
    this.lockDetector = const PlatformLockDetector(),
    this.debugTools,
  });

  final GlynaRepository repository;

  final Clock clock;

  final LockDetector lockDetector;

  /// Le panneau de débogage. Toujours nul en production.
  final DebugTools? debugTools;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppContent.title,
      debugShowCheckedModeBanner: false,
      theme: GlynaTheme.dark,
      home: BentoScreen(
        repository: repository,
        clock: clock,
        lockDetector: lockDetector,
        debugTools: debugTools,
      ),
    );
  }
}
