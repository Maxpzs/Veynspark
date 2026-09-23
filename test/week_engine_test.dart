import 'package:flutter_test/flutter_test.dart';

import 'package:veynspark_v1/content/challenge_library.dart';
import 'package:veynspark_v1/engine/week_calendar.dart';
import 'package:veynspark_v1/engine/week_plan.dart';
import 'package:veynspark_v1/engine/week_service.dart';
import 'package:veynspark_v1/engine/weekly_quota_rule.dart';
import 'package:veynspark_v1/models/challenge.dart';
import 'package:veynspark_v1/models/challenge_log.dart';
import 'package:veynspark_v1/models/goal.dart';
import 'package:veynspark_v1/models/week_quota.dart';

import 'support/fake_clock.dart';

void main() {
  // Semaine du lundi 21 au dimanche 27 septembre 2026.
  final monday = DateTime(2026, 9, 21);
  final wednesday = DateTime(2026, 9, 23);
  final sunday = DateTime(2026, 9, 27);
  final nextMonday = DateTime(2026, 9, 28);

  final marathon = Goal(
    id: 'marathon',
    title: 'Marathon',
    domain: ChallengeDomain.move,
    deadline: DateTime(2027, 3, 20),
    startingLevel: 1,
    weeklyQuota: 2,
  );
  final reading = Goal(
    id: 'reading',
    title: 'Finir Guerre et Paix',
    domain: ChallengeDomain.read,
    deadline: DateTime(2026, 10, 10),
    startingLevel: 2,
    weeklyQuota: 3,
  );

  WeekService serviceAt(DateTime now) => WeekService(clock: FakeClock(now));

  group('calendrier', () {
    test('la semaine commence le lundi à minuit', () {
      expect(weekStartOf(DateTime(2026, 9, 23, 15, 30)), monday);
      expect(weekStartOf(monday), monday);
      expect(weekStartOf(DateTime(2026, 9, 27, 23, 59)), monday);
      expect(weekStartOf(nextMonday), nextMonday);
    });

    test('le dimanche soir est encore dans la semaine, pas le lundi', () {
      expect(isInWeek(DateTime(2026, 9, 27, 23, 59), monday), isTrue);
      expect(isInWeek(nextMonday, monday), isFalse);
      expect(isInWeek(DateTime(2026, 9, 20, 23, 59), monday), isFalse);
    });

    test('semaines restantes jusqu\'à l\'échéance, bornes comprises', () {
      expect(weeksLeft(monday, sunday), 1);
      expect(weeksLeft(monday, nextMonday), 2);
      expect(weeksLeft(nextMonday, sunday), 0);
      // Traverse le passage à l'heure d'hiver.
      expect(weeksLeft(monday, DateTime(2026, 11, 2)), 7);
    });
  });

  group('quota hebdomadaire', () {
    test('suit le niveau de départ', () {
      expect(weeklyQuotaFor(marathon, monday), 2);
      expect(weeklyQuotaFor(marathon.copyWith(startingLevel: 2), monday), 3);
      expect(weeklyQuotaFor(marathon.copyWith(startingLevel: 3), monday), 4);
    });

    test('monte d\'un cran dans la dernière ligne droite', () {
      // Échéance le 10 octobre : il reste 3 semaines.
      expect(weeklyQuotaFor(reading, monday), 4);
      expect(weeklyQuotaFor(reading, DateTime(2026, 9, 7)), 3);
    });

    test('ne dépasse jamais le plafond', () {
      final expert = reading.copyWith(startingLevel: 9);
      expect(weeklyQuotaFor(expert, monday), maxWeeklyQuota);
    });

    test('tombe à zéro une fois l\'échéance passée', () {
      expect(weeklyQuotaFor(reading, DateTime(2026, 10, 12)), 0);
    });

    test('le service le rend pour la semaine en cours', () {
      final quota = serviceAt(wednesday).quotaFor(marathon);
      expect(
        quota,
        WeekQuota(goalId: 'marathon', weekStart: monday, target: 2),
      );
    });
  });

  group('semaine en cours', () {
    test('compte les jours restants et les réussites de la semaine', () {
      final progress = serviceAt(DateTime(2026, 9, 23, 20)).progress(
        goals: [marathon],
        quotas: [
          WeekQuota(goalId: 'marathon', weekStart: monday, target: 2, done: 1),
        ],
        logs: [
          ChallengeLog(
            challengeId: 'run-5k',
            date: monday,
            status: ChallengeStatus.succeeded,
          ),
          ChallengeLog(
            challengeId: 'curry',
            date: wednesday,
            status: ChallengeStatus.postponed,
            postponeReason: PostponeReason.wrongMoment,
          ),
          // Semaine précédente : ne compte pas.
          ChallengeLog(
            challengeId: 'read-20',
            date: DateTime(2026, 9, 20),
            status: ChallengeStatus.succeeded,
          ),
        ],
      );

      expect(progress.weekStart, monday);
      expect(progress.daysLeft, 5);
      expect(progress.succeeded, 1);
      expect(progress.goals.single.done, 1);
      expect(progress.goals.single.remaining, 1);
      expect(progress.goals.single.isReached, isFalse);
    });

    test('un objectif sans quota enregistré reçoit celui de la règle', () {
      final progress = serviceAt(
        sunday,
      ).progress(goals: [reading], quotas: const [], logs: const []);
      expect(progress.daysLeft, 1);
      expect(progress.goals.single.target, 4);
      expect(progress.goals.single.done, 0);
    });
  });

  group('déplacement d\'un défi', () {
    final plan = WeekPlan.empty(
      wednesday,
    ).place('run-5k', monday).place('curry', wednesday);

    test('se fait librement à l\'intérieur de la semaine', () {
      final first = plan.move('run-5k', DateTime(2026, 9, 24, 18));
      expect(first, isA<Moved>());
      final moved = (first as Moved).plan;
      expect(moved.dayOf('run-5k'), DateTime(2026, 9, 24));
      expect(moved.challengesOn(monday), isEmpty);
      expect(moved.movesOf('run-5k'), 1);

      final second = moved.move('run-5k', sunday) as Moved;
      expect(second.plan.dayOf('run-5k'), sunday);
      expect(second.plan.movesOf('run-5k'), 2);
      expect(second.plan.movesOf('curry'), 0);
    });

    test('est refusé hors de la semaine', () {
      final later = plan.move('run-5k', nextMonday);
      expect(later, isA<MoveRefused>());
      expect((later as MoveRefused).reason, MoveRefusal.outsideWeek);

      final earlier = plan.move('run-5k', DateTime(2026, 9, 20, 22));
      expect((earlier as MoveRefused).reason, MoveRefusal.outsideWeek);

      // Le plan d'origine n'a pas bougé.
      expect(plan.dayOf('run-5k'), monday);
      expect(plan.movesOf('run-5k'), 0);
    });

    test('est refusé pour un défi absent de la semaine', () {
      final outcome = plan.move('guitar', wednesday) as MoveRefused;
      expect(outcome.reason, MoveRefusal.notPlanned);
    });

    test('reposer un défi sur son jour ne compte pas', () {
      final outcome = plan.move('curry', wednesday) as Moved;
      expect(outcome.plan, plan);
      expect(outcome.plan.movesOf('curry'), 0);
    });

    test('le moteur ne peut pas poser un défi hors de la semaine', () {
      expect(() => plan.place('guitar', nextMonday), throwsArgumentError);
      expect(() => plan.place('curry', monday), throwsArgumentError);
    });
  });

  group('bilan du dimanche', () {
    test('la semaine ne se ferme pas avant le dimanche soir', () {
      expect(
        serviceAt(DateTime(2026, 9, 27, 17, 59)).canClose(monday),
        isFalse,
      );
      expect(serviceAt(DateTime(2026, 9, 27, 18)).canClose(monday), isTrue);
      expect(
        () => serviceAt(wednesday).close(
          weekStart: monday,
          goals: [marathon],
          quotas: const [],
          logs: const [],
        ),
        throwsStateError,
      );
    });

    test('une semaine à zéro donne des chiffres, rien d\'autre', () {
      final review = serviceAt(DateTime(2026, 9, 27, 21)).close(
        weekStart: monday,
        goals: [marathon, reading],
        quotas: [
          WeekQuota(goalId: 'marathon', weekStart: monday, target: 2),
          WeekQuota(goalId: 'reading', weekStart: monday, target: 4),
        ],
        logs: [
          ChallengeLog(
            challengeId: 'run-5k',
            date: wednesday,
            status: ChallengeStatus.postponed,
          ),
          ChallengeLog(
            challengeId: 'read-20',
            date: sunday,
            status: ChallengeStatus.abandoned,
          ),
        ],
      );

      expect(review.weekStart, monday);
      expect(review.succeeded, isEmpty);
      expect(review.goals.map((g) => g.done), [0, 0]);
      expect(review.goals.every((g) => !g.isReached), isTrue);
      expect(review.goals.map((g) => g.weeksLeft), [26, 3]);
      // La semaine suivante s'ouvre normalement, sans rattrapage.
      expect(review.nextWeek, [
        WeekQuota(goalId: 'marathon', weekStart: nextMonday, target: 2),
        WeekQuota(goalId: 'reading', weekStart: nextMonday, target: 4),
      ]);
    });

    test('une semaine remplie liste ses réussites et ses quotas atteints', () {
      final review = serviceAt(nextMonday).close(
        weekStart: monday,
        goals: [marathon],
        quotas: [
          WeekQuota(goalId: 'marathon', weekStart: monday, target: 2, done: 3),
        ],
        logs: [
          ChallengeLog(
            challengeId: 'run-5k',
            date: monday,
            status: ChallengeStatus.succeeded,
          ),
          ChallengeLog(
            challengeId: 'curry',
            date: DateTime(2026, 9, 27, 23),
            status: ChallengeStatus.succeeded,
          ),
          ChallengeLog(
            challengeId: 'run-8k',
            date: nextMonday,
            status: ChallengeStatus.succeeded,
          ),
        ],
      );

      expect(review.succeeded, ['run-5k', 'curry']);
      expect(review.goals.single.isReached, isTrue);
      expect(review.goals.single.remaining, 0);
    });

    test('un objectif arrivé à échéance n\'a pas de semaine suivante', () {
      final lastWeek = DateTime(2026, 10, 5);
      final review = serviceAt(DateTime(2026, 10, 11, 20)).close(
        weekStart: lastWeek,
        goals: [reading],
        quotas: const [],
        logs: const [],
      );
      expect(review.goals.single.weeksLeft, 1);
      expect(review.nextWeek, isEmpty);
    });
  });

  group('recompte des quotas', () {
    const library = ChallengeLibrary.all;
    Challenge first(ChallengeKind kind, ChallengeDomain domain) =>
        library.firstWhere((c) => c.kind == kind && c.domain == domain);
    ChallengeLog success(Challenge c, DateTime at) => ChallengeLog(
      challengeId: c.id,
      date: at,
      status: ChallengeStatus.succeeded,
    );

    test('seules les réussites à objectif de la semaine comptent', () {
      final run = first(ChallengeKind.goal, ChallengeDomain.move);
      final book = first(ChallengeKind.goal, ChallengeDomain.read);
      final curry = first(ChallengeKind.opportunity, ChallengeDomain.cook);
      final quotas = serviceAt(DateTime(2026, 9, 23)).recount(
        weekStart: monday,
        goals: [marathon, reading],
        quotas: [
          WeekQuota(goalId: marathon.id, weekStart: monday, target: 4, done: 9),
        ],
        logs: [
          success(run, DateTime(2026, 9, 21, 7)),
          success(book, DateTime(2026, 9, 22, 21)),
          success(book, DateTime(2026, 9, 20, 21)),
          success(curry, DateTime(2026, 9, 22, 20)),
        ],
        library: library,
      );

      expect(quotas, [
        WeekQuota(goalId: marathon.id, weekStart: monday, target: 4, done: 1),
        WeekQuota(
          goalId: reading.id,
          weekStart: monday,
          target: weeklyQuotaFor(reading, monday),
          done: 1,
        ),
      ]);
    });
  });
}
