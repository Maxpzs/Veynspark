import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:veynspark_v1/validation/lock_detector.dart';
import 'package:veynspark_v1/validation/locked_timer.dart';
import 'package:veynspark_v1/validation/timer_state.dart';

/// Détecteur simulé : l'état courant est émis dès l'abonnement, puis chaque
/// changement, de façon synchrone.
class FakeLockDetector implements LockDetector {
  FakeLockDetector({bool locked = false}) : _locked = locked;

  bool _locked;
  late final StreamController<bool> _controller = StreamController.broadcast(
    sync: true,
    onListen: () => _controller.add(_locked),
  );

  bool get hasListener => _controller.hasListener;

  @override
  Stream<bool> get lockStates => _controller.stream;

  void lock() => _set(true);
  void unlock() => _set(false);

  void _set(bool locked) {
    _locked = locked;
    _controller.add(locked);
  }
}

/// Horloge simulée, avancée à la main.
class FakeClock {
  DateTime now = DateTime(2026, 9, 23, 21);

  void advance(Duration duration) => now = now.add(duration);
}

void main() {
  const target = Duration(minutes: 20);
  late FakeClock clock;
  late FakeLockDetector detector;
  late LockedTimer timer;

  setUp(() {
    clock = FakeClock();
    detector = FakeLockDetector();
    timer = LockedTimer(
      target: target,
      detector: detector,
      clock: () => clock.now,
    );
  });

  tearDown(() => timer.dispose());

  group('démarrage', () {
    test('prêt, sans écouter le verrouillage', () {
      expect(timer.state.phase, TimerPhase.ready);
      expect(timer.elapsed, Duration.zero);
      expect(detector.hasListener, isFalse);
    });

    test('lancé, il attend le verrouillage sans compter', () {
      timer.start();
      clock.advance(const Duration(minutes: 3));
      expect(timer.state.phase, TimerPhase.waitingForLock);
      expect(timer.elapsed, Duration.zero);
    });

    test('ne se lance pas deux fois', () {
      timer.start();
      expect(timer.start, throwsStateError);
    });

    test('compte tout de suite si l\'appareil est déjà verrouillé', () {
      detector = FakeLockDetector(locked: true);
      timer = LockedTimer(
        target: target,
        detector: detector,
        clock: () => clock.now,
      );
      timer.start();
      expect(timer.state.phase, TimerPhase.counting);
    });
  });

  group('le compteur ne progresse que verrouillé', () {
    test('verrouillé, le temps passe', () {
      timer.start();
      detector.lock();
      clock.advance(const Duration(minutes: 7));
      expect(timer.state.phase, TimerPhase.counting);
      expect(timer.elapsed, const Duration(minutes: 7));
      expect(timer.state.remainingAt(clock.now), const Duration(minutes: 13));
    });

    test('jamais au-delà de la durée visée', () {
      timer.start();
      detector.lock();
      clock.advance(const Duration(hours: 2));
      expect(timer.elapsed, target);
    });

    test('un verrouillage répété ne remet pas le compteur à zéro', () {
      timer.start();
      detector.lock();
      clock.advance(const Duration(minutes: 5));
      detector.lock();
      clock.advance(const Duration(minutes: 5));
      expect(timer.elapsed, const Duration(minutes: 10));
    });
  });

  group('arrêt au déverrouillage', () {
    test('déverrouillé avant la fin : compteur arrêté au temps tenu', () {
      timer.start();
      detector.lock();
      clock.advance(const Duration(minutes: 12));
      detector.unlock();
      expect(timer.state.phase, TimerPhase.interrupted);
      expect(timer.elapsed, const Duration(minutes: 12));

      clock.advance(const Duration(minutes: 10));
      expect(timer.elapsed, const Duration(minutes: 12));
    });

    test('un nouveau verrouillage ne reprend pas tout seul', () {
      timer.start();
      detector.lock();
      clock.advance(const Duration(minutes: 12));
      detector.unlock();
      detector.lock();
      clock.advance(const Duration(minutes: 5));
      expect(timer.state.phase, TimerPhase.interrupted);
      expect(timer.elapsed, const Duration(minutes: 12));
    });

    test('déverrouillé après la durée : réussi', () {
      timer.start();
      detector.lock();
      clock.advance(const Duration(minutes: 25));
      detector.unlock();
      expect(timer.state.phase, TimerPhase.completed);
      expect(timer.elapsed, target);
      expect(detector.hasListener, isFalse);
    });
  });

  group('reprise', () {
    test('le temps déjà tenu est gardé', () {
      timer.start();
      detector.lock();
      clock.advance(const Duration(minutes: 12));
      detector.unlock();

      timer.resume();
      expect(timer.state.phase, TimerPhase.waitingForLock);
      clock.advance(const Duration(minutes: 1));
      expect(timer.elapsed, const Duration(minutes: 12));

      detector.lock();
      clock.advance(const Duration(minutes: 8));
      detector.unlock();
      expect(timer.state.phase, TimerPhase.completed);
      expect(timer.elapsed, target);
    });

    test('seul un compteur arrêté se reprend', () {
      expect(timer.resume, throwsStateError);
      timer.start();
      expect(timer.resume, throwsStateError);
      detector.lock();
      expect(timer.resume, throwsStateError);
    });
  });

  group('abandon', () {
    test('possible à tout moment, avec le temps tenu', () {
      timer.start();
      detector.lock();
      clock.advance(const Duration(minutes: 4));
      timer.stop();
      expect(timer.state.phase, TimerPhase.abandoned);
      expect(timer.elapsed, const Duration(minutes: 4));
      expect(detector.hasListener, isFalse);
    });

    test('possible pendant un arrêt', () {
      timer.start();
      detector.lock();
      detector.unlock();
      timer.stop();
      expect(timer.state.phase, TimerPhase.abandoned);
    });

    test('sans effet avant le lancement ou après la fin', () {
      timer.stop();
      expect(timer.state.phase, TimerPhase.ready);

      timer.start();
      detector.lock();
      clock.advance(target);
      detector.unlock();
      timer.stop();
      expect(timer.state.phase, TimerPhase.completed);
    });

    test('plus rien ne bouge après l\'abandon', () {
      timer.start();
      timer.stop();
      detector.lock();
      clock.advance(target);
      detector.unlock();
      expect(timer.state.phase, TimerPhase.abandoned);
      expect(timer.elapsed, Duration.zero);
    });
  });

  test('le flux d\'état suit chaque étape', () async {
    final phases = <TimerPhase>[];
    final subscription = timer.states.listen((s) => phases.add(s.phase));

    timer.start();
    detector.lock();
    clock.advance(const Duration(minutes: 12));
    detector.unlock();
    timer.resume();
    detector.lock();
    clock.advance(const Duration(minutes: 8));
    detector.unlock();
    await pumpEventQueue();
    await subscription.cancel();

    expect(phases, [
      TimerPhase.waitingForLock,
      TimerPhase.counting,
      TimerPhase.interrupted,
      TimerPhase.waitingForLock,
      TimerPhase.counting,
      TimerPhase.completed,
    ]);
  });

  test('l\'état est comparable par valeur', () {
    final since = DateTime(2026, 9, 23, 21);
    expect(
      TimerState(
        phase: TimerPhase.counting,
        target: target,
        countingSince: since,
      ),
      TimerState(
        phase: TimerPhase.counting,
        target: target,
        countingSince: since,
      ),
    );
  });
}
