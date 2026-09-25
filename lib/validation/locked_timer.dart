import 'dart:async';

import 'package:flutter/foundation.dart';

import '../engine/clock.dart';
import 'lock_detector.dart';
import 'timer_state.dart';

/// Le minuteur des défis de lecture, de travail et de déconnexion.
///
/// Le compteur tourne dès le lancement, et continue appareil verrouillé. Seule
/// une sortie de l'app l'arrête : la personne peut reprendre, le temps déjà
/// tenu est gardé. On peut abandonner à tout moment, sans conséquence.
///
/// Quand l'app passe en arrière-plan ([appHidden]), on ne sait pas encore
/// pourquoi. Le compteur continue ; au retour ([appShown]), on regarde si le
/// détecteur a signalé un verrouillage entre-temps. Oui : rien à dire. Non :
/// la personne est allée ailleurs, le compteur s'arrête à son départ et le
/// temps d'absence ne compte pas.
///
/// L'app est souvent suspendue en arrière-plan : le temps se calcule à
/// l'horloge, et non en comptant des tics. Pendant que l'app est affichée,
/// [tick] termine le défi quand la durée est atteinte.
///
/// Logique seule : l'interface écoute [states] et transmet le cycle de vie.
class LockedTimer {
  LockedTimer({
    required Duration target,
    required LockDetector detector,
    Clock clock = const SystemClock(),
  }) : assert(target > Duration.zero, 'Un minuteur dure plus de zéro.'),
       _detector = detector,
       _clock = clock,
       _state = TimerState(phase: TimerPhase.ready, target: target);

  final LockDetector _detector;
  final Clock _clock;
  final StreamController<TimerState> _states =
      StreamController<TimerState>.broadcast();
  StreamSubscription<bool>? _lockSubscription;
  final ValueNotifier<bool?> _deviceLocked = ValueNotifier<bool?>(null);
  final ValueNotifier<Absence?> _lastAbsence = ValueNotifier<Absence?>(null);
  TimerState _state;

  /// Départ de l'app en cours, pendant que le compteur tourne.
  DateTime? _awaySince;

  /// Un verrouillage a été signalé depuis le dernier retour dans l'app.
  bool _lockSeen = false;

  /// L'état courant.
  TimerState get state => _state;

  /// Chaque changement d'état, à partir de l'abonnement.
  Stream<TimerState> get states => _states.stream;

  /// Le dernier état de verrouillage reçu du détecteur, `null` tant qu'aucun
  /// n'est arrivé.
  ValueListenable<bool?> get deviceLocked => _deviceLocked;

  /// Ce qu'a été la dernière absence de l'app, `null` s'il n'y en a pas eu.
  ValueListenable<Absence?> get lastAbsence => _lastAbsence;

  /// Temps tenu, maintenant.
  Duration get elapsed => _state.elapsedAt(_clock.now());

  /// Lance le minuteur. Le compteur tourne aussitôt.
  void start() {
    if (_state.phase != TimerPhase.ready) {
      throw StateError('Le minuteur a déjà été lancé.');
    }
    _count();
    _lockSubscription = _detector.lockStates.listen(_onLockChanged);
  }

  /// Reprend après une sortie de l'app, avec le temps déjà tenu.
  void resume() {
    if (_state.phase != TimerPhase.interrupted) {
      throw StateError('Seul un compteur arrêté se reprend.');
    }
    _count();
  }

  /// Termine le défi si la durée est atteinte. À appeler pendant que l'app
  /// est affichée ; sans effet pendant une absence, jugée au retour.
  void tick() {
    if (_state.phase != TimerPhase.counting || _awaySince != null) return;
    _completeIfReached();
  }

  /// L'app n'est plus affichée : verrouillage, ou départ ailleurs.
  void appHidden() {
    if (_state.phase != TimerPhase.counting || _awaySince != null) return;
    _awaySince = _clock.now();
  }

  /// L'app est de nouveau affichée : on juge l'absence.
  void appShown() {
    final awaySince = _awaySince;
    final lockSeen = _lockSeen;
    _awaySince = null;
    _lockSeen = false;
    if (awaySince == null || _state.phase != TimerPhase.counting) return;

    if (lockSeen) {
      _lastAbsence.value = Absence.locked;
      _completeIfReached();
      return;
    }
    _lastAbsence.value = Absence.left;
    final held = _state.elapsedAt(awaySince);
    final stopped = _state.copyWith(
      phase: held >= _state.target
          ? TimerPhase.completed
          : TimerPhase.interrupted,
      elapsed: held,
      countingSince: () => null,
    );
    if (stopped.isOver) {
      _finish(stopped);
    } else {
      _emit(stopped);
    }
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
    _deviceLocked.dispose();
    _lastAbsence.dispose();
  }

  void _count() {
    _lockSeen = false;
    _emit(
      _state.copyWith(
        phase: TimerPhase.counting,
        countingSince: () => _clock.now(),
      ),
    );
  }

  void _onLockChanged(bool locked) {
    _deviceLocked.value = locked;
    if (locked) _lockSeen = true;
  }

  void _completeIfReached() {
    if (_state.elapsedAt(_clock.now()) < _state.target) return;
    _finish(
      _state.copyWith(
        phase: TimerPhase.completed,
        elapsed: _state.target,
        countingSince: () => null,
      ),
    );
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
