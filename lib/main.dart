import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app/glyna_app.dart';
import 'debug/debug_tools.dart';
import 'engine/clock.dart';
import 'store/glyna_repository.dart';

void main() {
  final repository = GlynaRepository.onDevice();
  if (kDebugMode) {
    // En debug seulement : une horloge qu'on peut avancer, et le panneau qui
    // la pilote.
    final clock = OffsetClock();
    runApp(
      GlynaApp(
        repository: repository,
        clock: clock,
        debugTools: DebugTools(repository: repository, clock: clock),
      ),
    );
  } else {
    runApp(GlynaApp(repository: repository));
  }
}
