import 'package:flutter/material.dart';

import '../content/debug_content.dart';
import '../validation/lock_detector.dart';
import '../validation/timer_state.dart';
import 'debug_lock_detector.dart';

/// Sous le minuteur, en mode debug seulement : ce que l'app croit de
/// l'appareil (verrouillé ou non), ce que fait le compteur, et comment elle a
/// jugé la dernière absence.
class DebugTimerStatus extends StatelessWidget {
  const DebugTimerStatus({
    super.key,
    required this.deviceLocked,
    required this.phase,
    required this.lastAbsence,
    required this.lockDetector,
  });

  /// `null` tant que le détecteur n'a rien émis.
  final bool? deviceLocked;

  final TimerPhase phase;

  /// `null` tant que l'app n'a pas été quittée.
  final Absence? lastAbsence;

  final LockDetector lockDetector;

  @override
  Widget build(BuildContext context) => switch (lockDetector) {
    final DebugLockDetector simulator => ValueListenableBuilder<bool>(
      valueListenable: simulator.simulating,
      builder: (context, simulating, _) =>
          _status(context, simulated: simulating),
    ),
    _ => _status(context, simulated: false),
  };

  Widget _status(BuildContext context, {required bool simulated}) => Text(
    DebugContent.timerStatus(
      locked: deviceLocked,
      phase: phase,
      lastAbsence: lastAbsence,
      simulated: simulated,
    ),
    style: Theme.of(context).textTheme.labelMedium,
  );
}
