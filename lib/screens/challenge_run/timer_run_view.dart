import 'dart:async';

import 'package:flutter/material.dart';

import '../../content/challenge_run_content.dart';
import '../../engine/clock.dart';
import '../../theme/theme.dart';
import '../../validation/lock_detector.dart';
import '../../validation/locked_timer.dart';
import '../../validation/timer_state.dart';

/// Le milieu du défi à minuteur : le temps qui reste, la consigne, rien
/// d'autre.
///
/// Le compteur ne tourne que téléphone verrouillé (voir [LockedTimer]). Un
/// déverrouillage avant la fin l'arrête : un message sobre, et de quoi
/// reprendre.
class TimerRunView extends StatefulWidget {
  const TimerRunView({
    super.key,
    required this.target,
    required this.clock,
    required this.lockDetector,
    required this.onValidated,
  });

  final Duration target;
  final Clock clock;
  final LockDetector lockDetector;

  /// La durée est atteinte.
  final VoidCallback onValidated;

  @override
  State<TimerRunView> createState() => _TimerRunViewState();
}

class _TimerRunViewState extends State<TimerRunView> {
  late final LockedTimer _timer = LockedTimer(
    target: widget.target,
    detector: widget.lockDetector,
    clock: widget.clock,
  );
  late final StreamSubscription<TimerState> _states;

  /// Rafraîchit l'affichage pendant que le compteur tourne.
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _states = _timer.states.listen(_onState);
    _timer.start();
  }

  void _onState(TimerState state) {
    if (!mounted) return;
    _tick?.cancel();
    _tick = state.phase == TimerPhase.counting
        ? Timer.periodic(GlynaMotion.clockTick, (_) => setState(() {}))
        : null;
    setState(() {});
    if (state.phase == TimerPhase.completed) widget.onValidated();
  }

  @override
  void dispose() {
    _tick?.cancel();
    unawaited(_states.cancel());
    // Quitter l'écran arrête le compteur, sans rien enregistrer ici :
    // l'enveloppe s'en charge.
    _timer.stop();
    unawaited(_timer.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final state = _timer.state;
    return switch (state.phase) {
      TimerPhase.interrupted => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            ChallengeRunContent.timerInterrupted(state.elapsed),
            style: textTheme.titleLarge,
          ),
          const SizedBox(height: GlynaSpacing.lg),
          SizedBox(
            height: GlynaSpacing.minTouchTarget,
            child: FilledButton(
              onPressed: _timer.resume,
              child: Text(
                ChallengeRunContent.resume,
                style: textTheme.labelLarge,
              ),
            ),
          ),
        ],
      ),
      TimerPhase.completed || TimerPhase.abandoned => const SizedBox.shrink(),
      TimerPhase.ready ||
      TimerPhase.waitingForLock ||
      TimerPhase.counting => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              ChallengeRunContent.remaining(
                state.remainingAt(widget.clock.now()),
              ),
              style: textTheme.displayLarge,
            ),
          ),
          const SizedBox(height: GlynaSpacing.lg),
          Text(
            ChallengeRunContent.timerInstruction,
            style: textTheme.bodyLarge,
          ),
        ],
      ),
    };
  }
}
