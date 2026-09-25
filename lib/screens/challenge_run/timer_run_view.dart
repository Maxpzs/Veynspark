import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../content/challenge_run_content.dart';
import '../../debug/debug_timer_status.dart';
import '../../engine/clock.dart';
import '../../theme/theme.dart';
import '../../validation/lock_detector.dart';
import '../../validation/locked_timer.dart';
import '../../validation/timer_state.dart';

/// Le milieu du défi à minuteur : le temps qui reste, la consigne, rien
/// d'autre.
///
/// Le compteur tourne dès le lancement et continue téléphone verrouillé
/// (voir [LockedTimer]). Quitter l'app avant la fin l'arrête : un message
/// sobre, et de quoi reprendre.
///
/// En mode debug, une ligne d'état en bas : l'appareil vu par l'app, le
/// compteur et la dernière absence ([DebugTimerStatus]).
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

  /// Transmet au minuteur les passages en arrière-plan et les retours.
  late final AppLifecycleListener _lifecycle;

  /// Rafraîchit l'affichage pendant que le compteur tourne.
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _states = _timer.states.listen(_onState);
    _lifecycle = AppLifecycleListener(
      onHide: _timer.appHidden,
      onShow: _timer.appShown,
    );
    if (kDebugMode) _debugWatch.addListener(_onDebugChange);
    _timer.start();
  }

  void _onState(TimerState state) {
    if (!mounted) return;
    _tick?.cancel();
    _tick = state.phase == TimerPhase.counting
        ? Timer.periodic(GlynaMotion.clockTick, (_) => _onTick())
        : null;
    setState(() {});
    if (state.phase == TimerPhase.completed) widget.onValidated();
  }

  void _onTick() {
    _timer.tick();
    if (mounted) setState(() {});
  }

  /// Ce que la ligne d'état de debug suit, en plus de la phase.
  late final Listenable _debugWatch = Listenable.merge([
    _timer.deviceLocked,
    _timer.lastAbsence,
  ]);

  void _onDebugChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    if (kDebugMode) _debugWatch.removeListener(_onDebugChange);
    _lifecycle.dispose();
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
    final phase = _timer.state.phase;
    if (!kDebugMode || _timer.state.isOver) return _body(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _body(context)),
        DebugTimerStatus(
          deviceLocked: _timer.deviceLocked.value,
          phase: phase,
          lastAbsence: _timer.lastAbsence.value,
          lockDetector: widget.lockDetector,
        ),
      ],
    );
  }

  Widget _body(BuildContext context) {
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
      TimerPhase.ready || TimerPhase.counting => Column(
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
