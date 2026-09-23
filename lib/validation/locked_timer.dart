import 'dart:async';

import 'lock_detector.dart';
import 'timer_state.dart';

/// Le minuteur des défis de lecture, de travail et de déconnexion.
///
/// Le compteur ne progresse que pendant que l'appareil est verrouillé. Un
/// déverrouillage avant la fin l'arrête ; la personne peut reprendre, le temps
/// déjà tenu est gardé. On peut abandonner à tout moment, sans conséquence.
///
/// L'app est souvent suspendue pendant le verrouillage : le temps écoulé se
/// calcule à l'horloge, au déverrouillage, et non en comptant des tics. C'est
/// donc au déverrouillage qu'on sait si la durée a été atteinte.
///
/// Logique seule : l'interface écoute [states].
class LockedTimer {
  LockedTimer({
    required Duration target,
    required LockDetector detector,
    DateTime Function()? clock,
  }) : assert(target > Duration.zero, 'Un minuteur dure plus de zéro.'),
       _detector = detector,
       _clock = clock ?? DateTime.now,
       _state = TimerState(phase: TimerPhase.ready, target: target);

  final LockDetector _detector;
  final DateTime Function() _clock;
  final StreamController<TimerState> _states =
      StreamController<TimerState>.broadcast();
  StreamSubscription<bool>? _lockSubscription;
  TimerState _state;

  /// L'état courant.
  TimerState get state => _state;

  /// Chaque changement d'état, à partir de l'abonnement.
  Stream<TimerState> get states => _states.stream;

  /// Temps verrouillé cumulé, maintenant.
  Duration get elapsed => _state.elapsedAt(_clock());

  /// Lance le minuteur. Il attend le verrouillage pour compter.
  void start() {
    if (_state.phase != TimerPhase.ready) {
      throw StateError('Le minuteur a déjà été lancé.');
    }
    _emit(_state.copyWith(phase: TimerPhase.waitingForLock));
    _lockSubscription = _detector.lockStates.listen(_onLockChanged);
  }

  /// Reprend après un déverrouillage, avec le temps déjà tenu.
  void resume() {
    if (_state.phase != TimerPhase.interrupted) {
      throw StateError('Seul un compteur arrêté se reprend.');
    }
    _emit(_state.copyWith(phase: TimerPhase.waitingForLock));
  }

  /// Arrête le défi. Toujours possible, jamais reproché. Sans effet si le
  /// minuteur n'a pas été lancé ou est déjà terminé.
  void stop() {
    if (!_state.isActive) return;
    _finish(
      _state.copyWith(
        phase: TimerPhase.abandoned,
        elapsed: elapsed,
        countingSince: () => null,
      ),
    );
  }

  /// Libère l'écoute du verrouillage et le flux d'état.
  Future<void> dispose() async {
    await _lockSubscription?.cancel();
    _lockSubscription = null;
    await _states.close();
  }

  void _onLockChanged(bool locked) {
    final now = _clock();
    switch (_state.phase) {
      case TimerPhase.waitingForLock when locked:
        _emit(
          _state.copyWith(phase: TimerPhase.counting, countingSince: () => now),
        );
      case TimerPhase.counting when !locked:
        final total = _state.elapsedAt(now);
        final stopped = _state.copyWith(
          phase: total >= _state.target
              ? TimerPhase.completed
              : TimerPhase.interrupted,
          elapsed: total,
          countingSince: () => null,
        );
        if (stopped.isOver) {
          _finish(stopped);
        } else {
          _emit(stopped);
        }
      default:
        // Doublon, ou verrouillage pendant un arrêt : la reprise se demande.
        break;
    }
  }

  void _finish(TimerState state) {
    _lockSubscription?.cancel();
    _lockSubscription = null;
    _emit(state);
  }

  void _emit(TimerState state) {
    _state = state;
    if (!_states.isClosed) _states.add(state);
  }
}
