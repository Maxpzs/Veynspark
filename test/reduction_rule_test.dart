import 'package:flutter_test/flutter_test.dart';

import 'package:veynspark_v1/content/challenge_library.dart';
import 'package:veynspark_v1/engine/reduction_ledger.dart';
import 'package:veynspark_v1/engine/reduction_rule.dart';
import 'package:veynspark_v1/engine/week_plan.dart';

void main() {
  // Semaine du lundi 21 au dimanche 27 septembre 2026.
  final monday = DateTime(2026, 9, 21);
  final tuesday = DateTime(2026, 9, 22);
  final wednesday = DateTime(2026, 9, 23);
  final thursday = DateTime(2026, 9, 24);
  final friday = DateTime(2026, 9, 25);

  final rule = ReductionRule(library: ChallengeLibrary.all);

  final start = WeekPlan.empty(
    monday,
  ).place('run-5k', monday).place('curry-recipe', tuesday);

  WeekPlan moveTo(WeekPlan plan, String id, DateTime day) =>
      (plan.move(id, day) as Moved).plan;

  /// Déplace [id] sur chacun de [days] et rend les propositions obtenues après
  /// chaque déplacement.
  ({WeekPlan plan, ReductionLedger ledger, List<bool> offered}) moveAll(
    String id,
    List<DateTime> days, {
    WeekPlan? plan,
    ReductionLedger? ledger,
  }) {
    var current = plan ?? start;
    var registry = ledger ?? ReductionLedger();
    final offered = <bool>[];
    for (final day in days) {
      current = moveTo(current, id, day);
      final result = rule.afterMove(
        challengeId: id,
        plan: current,
        ledger: registry,
      );
      offered.add(result.offer != null);
      registry = result.ledger;
    }
    return (plan: current, ledger: registry, offered: offered);
  }

  group('compteur de reports', () {
    test('rien avant le troisième déplacement', () {
      final result = moveAll('run-5k', [tuesday, wednesday]);
      expect(result.plan.movesOf('run-5k'), 2);
      expect(result.offered, [false, false]);
      expect(result.ledger, ReductionLedger());
    });

    test('la proposition tombe au troisième déplacement', () {
      final result = moveAll('run-5k', [tuesday, wednesday, thursday]);
      expect(result.offered, [false, false, true]);
      expect(result.ledger.wasOffered('run-5k'), isTrue);
    });

    test('reposer un défi sur son jour ne compte pas', () {
      final result = moveAll('run-5k', [tuesday, tuesday, wednesday]);
      expect(result.plan.movesOf('run-5k'), 2);
      expect(result.offered, [false, false, false]);
    });

    test('les reports d\'un défi ne comptent pas pour un autre', () {
      var plan = moveTo(start, 'run-5k', tuesday);
      plan = moveTo(plan, 'run-5k', wednesday);
      plan = moveTo(plan, 'curry-recipe', thursday);
      final result = rule.afterMove(
        challengeId: 'curry-recipe',
        plan: plan,
        ledger: ReductionLedger(),
      );
      expect(result.offer, isNull);
    });
  });

  group('la version réduite', () {
    test('même domaine, un cran plus bas, le même mode de validation', () {
      var plan = start;
      for (final day in [tuesday, wednesday, thursday]) {
        plan = moveTo(plan, 'run-5k', day);
      }
      final offer = rule
          .afterMove(
            challengeId: 'run-5k',
            plan: plan,
            ledger: ReductionLedger(),
          )
          .offer!;
      expect(offer.original.id, 'run-5k');
      expect(offer.reduced.id, 'run-2k');
      expect(offer.reduced.domain, offer.original.domain);
      expect(offer.reduced.kind, offer.original.kind);
      expect(offer.reduced.level, lessThan(offer.original.level));
    });

    test('jamais un défi déjà posé dans la semaine', () {
      final plan = start.place('run-2k', friday);
      final result = moveAll('run-5k', [
        tuesday,
        wednesday,
        thursday,
      ], plan: plan);
      expect(result.offered.last, isTrue);
      final offer = rule
          .afterMove(
            challengeId: 'run-5k',
            plan: result.plan,
            ledger: ReductionLedger(),
          )
          .offer!;
      expect(offer.reduced.id, isNot('run-2k'));
      expect(offer.reduced.id, 'walk-45');
    });

    test('rien à réduire au niveau 1, et rien n\'est consommé', () {
      final plan = WeekPlan.empty(monday).place('run-2k', monday);
      final result = moveAll('run-2k', [
        tuesday,
        wednesday,
        thursday,
      ], plan: plan);
      expect(result.offered, [false, false, false]);
      expect(result.ledger.wasOffered('run-2k'), isFalse);
    });

    test('acceptée, elle prend la place du défi le même jour', () {
      var plan = start;
      for (final day in [tuesday, wednesday, thursday]) {
        plan = moveTo(plan, 'run-5k', day);
      }
      final offer = rule
          .afterMove(
            challengeId: 'run-5k',
            plan: plan,
            ledger: ReductionLedger(),
          )
          .offer!;
      final accepted = rule.accept(offer, plan);
      expect(accepted.dayOf('run-5k'), isNull);
      expect(accepted.dayOf('run-2k'), thursday);
      expect(accepted.movesOf('run-2k'), 0);
      expect(accepted.dayOf('curry-recipe'), tuesday);
    });
  });

  group('non-répétition', () {
    test('refusée, elle ne revient pas aux déplacements suivants', () {
      final result = moveAll('run-5k', [
        tuesday,
        wednesday,
        thursday,
        friday,
        monday,
        tuesday,
      ]);
      expect(result.offered, [false, false, true, false, false, false]);
      expect(result.plan.movesOf('run-5k'), 6);
    });

    test('refuser ne change rien au plan', () {
      final result = moveAll('run-5k', [tuesday, wednesday, thursday]);
      expect(result.plan.dayOf('run-5k'), thursday);
      expect(result.plan.dayOf('run-2k'), isNull);
      // Le défi reste déplaçable, sans limite.
      expect(result.plan.move('run-5k', friday), isA<Moved>());
    });

    test('ne revient pas la semaine suivante', () {
      final first = moveAll('run-5k', [tuesday, wednesday, thursday]);
      final nextWeek = WeekPlan.empty(
        DateTime(2026, 9, 28),
      ).place('run-5k', DateTime(2026, 9, 28));
      final second = moveAll(
        'run-5k',
        [DateTime(2026, 9, 29), DateTime(2026, 9, 30), DateTime(2026, 10, 1)],
        plan: nextWeek,
        ledger: first.ledger,
      );
      expect(second.offered, [false, false, false]);
    });

    test('le registre se sérialise aller-retour', () {
      final ledger = ReductionLedger().record('run-5k').record('read-45-min');
      expect(ReductionLedger.fromJson(ledger.toJson()), ledger);
    });
  });

  group('WeekPlan.replace', () {
    test('refuse un remplaçant déjà posé ou un défi absent', () {
      expect(
        () => start.replace('run-5k', 'curry-recipe'),
        throwsArgumentError,
      );
      expect(() => start.replace('guitar', 'run-2k'), throwsArgumentError);
    });
  });
}
