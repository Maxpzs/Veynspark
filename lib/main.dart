import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app/glyna_app.dart';
import 'debug/debug_lock_detector.dart';
import 'debug/debug_tools.dart';
import 'engine/clock.dart';
import 'store/glyna_repository.dart';
import 'validation/platform_lock_detector.dart';

void main() {
  final repository = GlynaRepository.onDevice();
  if (kDebugMode) {
    // En debug seulement : une horloge qu'on peut avancer, un verrouillage
    // qu'on peut simuler, et le panneau qui les pilote.
    final clock = OffsetClock();
    final lock = DebugLockDetector(const PlatformLockDetector());
    runApp(
      GlynaApp(
        repository: repository,
        clock: clock,
        lockDetector: lock,
        debugTools: DebugTools(
          repository: repository,
          clock: clock,
          lock: lock,
        ),
      ),
    );
  } else {
    runApp(GlynaApp(repository: repository));
  }
}
