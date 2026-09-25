import 'package:flutter_test/flutter_test.dart';

import 'package:veynspark_v1/validation/locked_timer.dart';
import 'package:veynspark_v1/validation/timer_state.dart';

import 'support/fake_clock.dart';
import 'support/fake_lock_detector.dart';

void main() {
  const target = Duration(minutes: 20);
  late FakeClock clock;
  late FakeLockDetector detector;
  late LockedTimer timer;

  setUp(() {
    clock = FakeClock(DateTime(2026, 9, 23, 21));
    detector = FakeLockDetector();
    timer = LockedTimer(target: target, detector: detector, clock: clock);
  });

  tearDown(() => timer.dispose());

  /// L'appareil est verrouillé pendant [held], puis on revient dans l'app.
  void lockFor(Duration held) {
    detector.lock();
    timer.appHidden();
    clock.advance(held);
    detector.unlock();
    timer.appShown();
  }

  /// La personne va dans une autre app pendant [away], puis revient.
  void leaveFor(Duration away) {
    timer.appHidden();
    clock.advance(away);
    timer.appShown();
  }

  group('démarrage', () {
    test('prêt, sans écouter le verrouillage', () {
      expect(timer.state.phase, TimerPhase.ready);
      expect(timer.elapsed, Duration.zero);
      expect(detector.hasListener, isFalse);
    });

    test('lancé, le compteur tourne aussitôt', () {
      timer.start();
      clock.advance(const Duration(minutes: 3));
      expect(timer.state.phase, TimerPhase.counting);
      expect(timer.elapsed, const Duration(minutes: 3));
      expect(timer.state.remainingAt(clock.now()), const Duration(minutes: 17));
    });

    test('ne se lance pas deux fois', () {
      timer.start();
      expect(timer.start, throwsStateError);
    });

    test('jamais au-delà de la durée visée', () {
      timer.start();
      clock.advance(const Duration(hours: 2));
      expect(timer.elapsed, target);
    });
  });

  group('app affichée', () {
    test('la durée atteinte termine le défi au tic suivant', () {
      timer.start();
      clock.advance(const Duration(minutes: 19));
      timer.tick();
      expect(timer.state.phase, TimerPhase.counting);
      clock.advance(const Duration(minutes: 1));
      timer.tick();
      expect(timer.state.phase, TimerPhase.completed);
      expect(timer.elapsed, target);
      expect(detector.hasListener, isFalse);
    });
  });

  group('appareil verrouillé', () {
    test('le compteur continue pendant le verrouillage', () {
      timer.start();
      clock.advance(const Duration(minutes: 2));
      lockFor(const Duration(minutes: 10));
      expect(timer.state.phase, TimerPhase.counting);
      expect(timer.elapsed, const Duration(minutes: 12));
      expect(timer.lastAbsence.value, Absence.locked);
    });

    test('la durée atteinte verrouillé : réussi au retour', () {
      timer.start();
      lockFor(const Duration(minutes: 25));
      expect(timer.state.phase, TimerPhase.completed);
      expect(timer.elapsed, target);
    });

    test('un verrouillage signalé juste avant le départ compte aussi', () {
      timer.start();
      detector.lock();
      timer.appHidden();
      clock.advance(const Duration(minutes: 5));
      timer.appShown();
      expect(timer.state.phase, TimerPhase.counting);
    });

    test('pendant l\'absence, un tic ne juge rien', () {
      timer.start();
      timer.appHidden();
      clock.advance(const Duration(minutes: 30));
      timer.tick();
      expect(timer.state.phase, TimerPhase.counting);
    });
  });

  group('sortie de l\'app', () {
    test('arrête le compteur à son départ, l\'absence ne compte pas', () {
      timer.start();
      clock.advance(const Duration(minutes: 12));
      leaveFor(const Duration(minutes: 10));
      expect(timer.state.phase, TimerPhase.interrupted);
      expect(timer.elapsed, const Duration(minutes: 12));
      expect(timer.lastAbsence.value, Absence.left);

      clock.advance(const Duration(minutes: 10));
      expect(timer.elapsed, const Duration(minutes: 12));
    });

    test('un verrouillage d\'une absence passée ne couvre pas la suivante', () {
      timer.start();
      lockFor(const Duration(minutes: 5));
      leaveFor(const Duration(minutes: 5));
      expect(timer.state.phase, TimerPhase.interrupted);
      expect(timer.elapsed, const Duration(minutes: 5));
    });

    test('partir une fois la durée tenue : réussi', () {
      timer.start();
      clock.advance(target);
      leaveFor(const Duration(minutes: 5));
      expect(timer.state.phase, TimerPhase.completed);
    });

    test('un nouveau départ pendant l\'arrêt ne change rien', () {
      timer.start();
      clock.advance(const Duration(minutes: 12));
      leaveFor(const Duration(minutes: 1));
      lockFor(const Duration(minutes: 5));
      expect(timer.state.phase, TimerPhase.interrupted);
      expect(timer.elapsed, const Duration(minutes: 12));
    });
  });

  group('reprise', () {
    test('le temps déjà tenu est gardé, le compteur repart aussitôt', () {
      timer.start();
      clock.advance(const Duration(minutes: 12));
      leaveFor(const Duration(minutes: 3));

      timer.resume();
      expect(timer.state.phase, TimerPhase.counting);
      clock.advance(const Duration(minutes: 8));
      timer.tick();
      expect(timer.state.phase, TimerPhase.completed);
      expect(timer.elapsed, target);
    });

    test('seul un compteur arrêté se reprend', () {
      expect(timer.resume, throwsStateError);
      timer.start();
      expect(timer.resume, throwsStateError);
    });
  });

  group('abandon', () {
    test('possible à tout moment, avec le temps tenu', () {
      timer.start();
      clock.advance(const Duration(minutes: 4));
      timer.stop();
      expect(timer.state.phase, TimerPhase.abandoned);
      expect(timer.elapsed, const Duration(minutes: 4));
      expect(detector.hasListener, isFalse);
    });

    test('possible pendant un arrêt', () {
      timer.start();
      leaveFor(const Duration(minutes: 1));
      timer.stop();
      expect(timer.state.phase, TimerPhase.abandoned);
    });

    test('sans effet avant le lancement ou après la fin', () {
      timer.stop();
      expect(timer.state.phase, TimerPhase.ready);

      timer.start();
      lockFor(target);
      timer.stop();
      expect(timer.state.phase, TimerPhase.completed);
    });

    test('plus rien ne bouge après l\'abandon', () {
      timer.start();
      timer.stop();
      lockFor(target);
      timer.tick();
      expect(timer.state.phase, TimerPhase.abandoned);
      expect(timer.elapsed, Duration.zero);
    });
  });

  test('le dernier état de verrouillage reçu reste lisible', () {
    expect(timer.deviceLocked.value, isNull);
    timer.start();
    expect(timer.deviceLocked.value, isFalse);
    detector.lock();
    expect(timer.deviceLocked.value, isTrue);
  });

  test('le flux d\'état suit chaque étape', () async {
    final phases = <TimerPhase>[];
    final subscription = timer.states.listen((s) => phases.add(s.phase));

    timer.start();
    clock.advance(const Duration(minutes: 12));
    leaveFor(const Duration(minutes: 1));
    timer.resume();
    lockFor(const Duration(minutes: 8));
    await pumpEventQueue();
    await subscription.cancel();

    expect(phases, [
      TimerPhase.counting,
      TimerPhase.interrupted,
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
