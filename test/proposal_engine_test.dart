import 'package:flutter_test/flutter_test.dart';

import 'package:veynspark_v1/content/challenge_library.dart';
import 'package:veynspark_v1/engine/daily_proposal.dart';
import 'package:veynspark_v1/engine/day_moment.dart';
import 'package:veynspark_v1/engine/goal_track.dart';
import 'package:veynspark_v1/engine/goal_week.dart';
import 'package:veynspark_v1/engine/level_rule.dart';
import 'package:veynspark_v1/engine/proposal_engine.dart';
import 'package:veynspark_v1/models/challenge.dart';
import 'package:veynspark_v1/models/challenge_log.dart';
import 'package:veynspark_v1/models/goal.dart';

void main() {
  const library = ChallengeLibrary.all;
  final engine = ProposalEngine(library: library);

  // Mercredi 23 septembre 2026, 10 h. Semaine du lundi 21 au dimanche 27.
  final now = DateTime(2026, 9, 23, 10);
  final monday = DateTime(2026, 9, 21);

  GoalTrack track(
    String id,
    ChallengeDomain domain, {
    int target = 3,
    int done = 0,
    int weeksLeft = 20,
    int startingLevel = 1,
  }) => GoalTrack(
    goal: Goal(
      id: id,
      title: id,
      deadline: DateTime(2027, 3, 20),
      startingLevel: startingLevel,
      weeklyQuota: target,
    ),
    domain: domain,
    week: GoalWeek(
      goalId: id,
      title: id,
      target: target,
      done: done,
      weeksLeft: weeksLeft,
    ),
  );

  Challenge byId(String id) => library.firstWhere((c) => c.id == id);

  group('composition du bento', () {
    test('4 à 5 tuiles, 1 à 2 à objectif, 2 à 3 d\'opportunité', () {
      for (final goals in [
        <GoalTrack>[],
        [track('marathon', ChallengeDomain.move)],
        [
          track('marathon', ChallengeDomain.move),
          track('lire', ChallengeDomain.read),
        ],
      ]) {
        final proposal = engine.propose(now: now, goals: goals, logs: []);
        expect(proposal.all.length, inInclusiveRange(4, 5));
        expect(
          proposal.goals.every((c) => c.kind == ChallengeKind.goal),
          isTrue,
        );
        expect(
          proposal.opportunities.every(
            (c) => c.kind == ChallengeKind.opportunity,
          ),
          isTrue,
        );
        if (goals.isNotEmpty) {
          expect(proposal.goals.length, inInclusiveRange(1, 2));
          expect(proposal.opportunities.length, inInclusiveRange(2, 3));
        }
      }
    });

    test('les défis à objectif viennent du domaine de l\'objectif', () {
      final proposal = engine.propose(
        now: now,
        goals: [track('marathon', ChallengeDomain.move)],
        logs: [],
      );
      expect(proposal.goals.single.domain, ChallengeDomain.move);
    });

    test('même journée, même bento', () {
      final goals = [track('marathon', ChallengeDomain.move)];
      final a = engine.propose(now: now, goals: goals, logs: []);
      final b = engine.propose(
        now: now.add(const Duration(minutes: 5)),
        goals: goals,
        logs: [],
      );
      expect(b.all, a.all);
    });
  });

  group('variété des contextes', () {
    test('au moins une tuile dehors et une partout, tous les jours', () {
      final goalSets = [
        <GoalTrack>[],
        [track('marathon', ChallengeDomain.move)],
        [track('cuisine', ChallengeDomain.cook)],
        [
          track('lire', ChallengeDomain.read),
          track('guitare', ChallengeDomain.create),
        ],
      ];
      for (var d = 0; d < 7; d++) {
        final day = monday.add(Duration(days: d, hours: 10));
        for (final goals in goalSets) {
          final contexts = engine
              .propose(now: day, goals: goals, logs: [])
              .all
              .map((c) => c.context)
              .toSet();
          expect(contexts, contains(ChallengeContext.outside));
          expect(contexts, contains(ChallengeContext.anywhere));
        }
      }
    });

    test('tient aussi quand les intérêts sont restreints', () {
      final proposal = engine.propose(
        now: now,
        goals: [track('lire', ChallengeDomain.read)],
        logs: [],
        interests: {ChallengeDomain.read, ChallengeDomain.cook},
      );
      final contexts = proposal.all.map((c) => c.context).toSet();
      expect(contexts, contains(ChallengeContext.outside));
      expect(contexts, contains(ChallengeContext.anywhere));
      expect(
        proposal.opportunities.every(
          (c) =>
              {ChallengeDomain.read, ChallengeDomain.cook}.contains(c.domain),
        ),
        isTrue,
      );
    });
  });

  group('historique', () {
    test('jamais deux fois le même défi dans la semaine', () {
      final goals = [
        track('marathon', ChallengeDomain.move),
        track('lire', ChallengeDomain.read),
      ];
      final logs = <ChallengeLog>[];
      for (var d = 0; d < 7; d++) {
        final day = monday.add(Duration(days: d, hours: 9));
        final proposal = engine.propose(now: day, goals: goals, logs: logs);
        for (final c in proposal.all) {
          expect(
            logs.map((l) => l.challengeId),
            isNot(contains(c.id)),
            reason: '${c.id} reproposé le jour $d',
          );
          logs.add(
            ChallengeLog(
              challengeId: c.id,
              date: day,
              status: ChallengeStatus.proposed,
            ),
          );
        }
      }
    });

    test('un défi de la semaine précédente peut revenir', () {
      final first = engine.propose(now: now, goals: [], logs: []).all.first;
      final lastWeek = ChallengeLog(
        challengeId: first.id,
        date: monday.subtract(const Duration(days: 2)),
        status: ChallengeStatus.proposed,
      );
      final proposal = engine.propose(now: now, goals: [], logs: [lastWeek]);
      expect(proposal.all.map((c) => c.id), contains(first.id));
    });
  });

  group('échéances et quota restant', () {
    test('l\'objectif proche de son échéance passe en premier', () {
      final far = track('lire', ChallengeDomain.read, weeksLeft: 30);
      final near = track('marathon', ChallengeDomain.move, weeksLeft: 2);
      final proposal = engine.propose(now: now, goals: [far, near], logs: []);
      expect(proposal.goals.first.domain, ChallengeDomain.move);
    });

    test('avec trois objectifs, le plus lointain cède sa place', () {
      final proposal = engine.propose(
        now: now,
        goals: [
          track('lire', ChallengeDomain.read, weeksLeft: 30),
          track('marathon', ChallengeDomain.move, weeksLeft: 2),
          track('cuisine', ChallengeDomain.cook, weeksLeft: 5),
        ],
        logs: [],
      );
      expect(proposal.goals.map((c) => c.domain), [
        ChallengeDomain.move,
        ChallengeDomain.cook,
      ]);
    });

    test('un quota déjà tenu laisse passer celui qui reste à faire', () {
      final proposal = engine.propose(
        now: now,
        goals: [
          track('marathon', ChallengeDomain.move, weeksLeft: 2, done: 3),
          track('lire', ChallengeDomain.read, weeksLeft: 30),
        ],
        logs: [],
      );
      expect(proposal.goals, hasLength(1));
      expect(proposal.goals.single.domain, ChallengeDomain.read);
    });
  });

  group('niveau', () {
    test('le niveau de départ choisit le défi à objectif', () {
      for (final level in [1, 2, 3]) {
        final proposal = engine.propose(
          now: now,
          goals: [
            track('marathon', ChallengeDomain.move, startingLevel: level),
          ],
          logs: [],
        );
        expect(proposal.goals.single.level, level);
      }
    });

    test('monte avec les réussites, baisse avec « trop dur »', () {
      List<ChallengeLog> logs(
        ChallengeStatus status,
        int n, [
        PostponeReason? reason,
      ]) => [
        for (var i = 0; i < n; i++)
          ChallengeLog(
            challengeId: 'run-2k',
            date: DateTime(2026, 9, 1 + i),
            status: status,
            postponeReason: reason,
          ),
      ];
      int level(List<ChallengeLog> l, {int start = 1}) => currentLevel(
        domain: ChallengeDomain.move,
        startingLevel: start,
        maxLevel: 3,
        library: library,
        logs: l,
      );

      expect(level([]), 1);
      expect(level(logs(ChallengeStatus.succeeded, 3)), 2);
      expect(level(logs(ChallengeStatus.succeeded, 30)), 3);
      expect(
        level(
          logs(ChallengeStatus.postponed, 1, PostponeReason.tooHard),
          start: 2,
        ),
        1,
      );
      expect(
        level(logs(ChallengeStatus.postponed, 5, PostponeReason.tooHard)),
        1,
      );
    });

    test('un report « trop dur » fait redescendre le défi proposé', () {
      final proposal = engine.propose(
        now: now,
        goals: [track('marathon', ChallengeDomain.move, startingLevel: 2)],
        logs: [
          ChallengeLog(
            challengeId: 'run-5k',
            date: DateTime(2026, 9, 18),
            status: ChallengeStatus.postponed,
            postponeReason: PostponeReason.tooHard,
          ),
        ],
      );
      expect(proposal.goals.single.level, 1);
    });
  });

  group('moment de la journée et reports', () {
    test('les moments de la journée', () {
      expect(DayMoment.of(DateTime(2026, 9, 23, 7)), DayMoment.morning);
      expect(DayMoment.of(DateTime(2026, 9, 23, 14)), DayMoment.afternoon);
      expect(DayMoment.of(DateTime(2026, 9, 23, 20)), DayMoment.evening);
      expect(DayMoment.of(DateTime(2026, 9, 23, 23)), DayMoment.night);
      expect(DayMoment.of(DateTime(2026, 9, 23, 3)), DayMoment.night);
    });

    // La tuile dehors est imposée par la variété des contextes, et aucune
    // opportunité dehors ne tient en quelques minutes : on ne compte que les
    // autres.
    int longOpportunities(DailyProposal proposal) => proposal.opportunities
        .where(
          (c) =>
              c.context != ChallengeContext.outside &&
              c.estimatedDuration > shortChallenge,
        )
        .length;

    test('hors des créneaux libres, les défis courts passent devant', () {
      final free = engine.propose(
        now: now,
        goals: [],
        logs: [],
        freeMoments: {DayMoment.morning},
      );
      final busy = engine.propose(
        now: now,
        goals: [],
        logs: [],
        freeMoments: {DayMoment.evening},
      );
      expect(
        longOpportunities(busy),
        lessThanOrEqualTo(longOpportunities(free)),
      );
      expect(longOpportunities(busy), 0);
    });

    test('des reports « pas le bon moment » répétés font de même', () {
      final logs = [
        for (var d = 14; d <= 15; d++)
          ChallengeLog(
            challengeId: 'run-2k',
            date: DateTime(2026, 9, d),
            status: ChallengeStatus.postponed,
            postponeReason: PostponeReason.wrongMoment,
          ),
      ];
      final proposal = engine.propose(now: now, goals: [], logs: logs);
      expect(longOpportunities(proposal), 0);
    });

    test(
      'un report « pas envie » écarte le défi le temps de quelques jours',
      () {
        final first = engine.propose(now: now, goals: [], logs: []).all.first;
        final proposal = engine.propose(
          now: now,
          goals: [],
          logs: [
            ChallengeLog(
              challengeId: first.id,
              date: DateTime(2026, 9, 18),
              status: ChallengeStatus.postponed,
              postponeReason: PostponeReason.notInTheMood,
            ),
          ],
        );
        expect(proposal.all, isNot(contains(byId(first.id))));
      },
    );
  });
}
