import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:veynspark_v1/models/challenge.dart';
import 'package:veynspark_v1/models/challenge_log.dart';
import 'package:veynspark_v1/models/goal.dart';
import 'package:veynspark_v1/models/week_quota.dart';

/// Passe par une vraie chaîne JSON, comme le fera la persistance.
Map<String, Object?> _throughJson(Map<String, Object?> json) =>
    jsonDecode(jsonEncode(json)) as Map<String, Object?>;

void main() {
  group('Challenge', () {
    const goalChallenge = Challenge(
      id: 'run-5k',
      title: 'Courir 5 km',
      kind: ChallengeKind.goal,
      domain: ChallengeDomain.move,
      level: 2,
      estimatedDuration: Duration(minutes: 35),
      context: ChallengeContext.outside,
      validation: ValidationMode.health,
      goalReminder: '→ marathon, 1/3 cette semaine',
    );
    const opportunity = Challenge(
      id: 'curry-recipe',
      title: 'Tester une recette au curry',
      kind: ChallengeKind.opportunity,
      domain: ChallengeDomain.cook,
      level: 1,
      estimatedDuration: Duration(minutes: 45),
      context: ChallengeContext.home,
      validation: ValidationMode.declarative,
    );

    test('aller-retour JSON, défi à objectif', () {
      final back = Challenge.fromJson(_throughJson(goalChallenge.toJson()));
      expect(back, goalChallenge);
      expect(back.hashCode, goalChallenge.hashCode);
    });

    test('aller-retour JSON, défi d\'opportunité', () {
      expect(
        Challenge.fromJson(_throughJson(opportunity.toJson())),
        opportunity,
      );
    });

    test('copyWith change un champ et garde les autres', () {
      final harder = goalChallenge.copyWith(level: 3);
      expect(harder.level, 3);
      expect(harder.copyWith(level: 2), goalChallenge);
      expect(harder, isNot(goalChallenge));
    });

    test('copyWith peut retirer le rappel d\'objectif', () {
      final freed = goalChallenge.copyWith(
        kind: ChallengeKind.opportunity,
        goalReminder: () => null,
      );
      expect(freed.goalReminder, isNull);
      expect(freed.kind, ChallengeKind.opportunity);
    });
  });

  group('Goal', () {
    final goal = Goal(
      id: 'marathon',
      title: 'Marathon',
      domain: ChallengeDomain.move,
      deadline: DateTime(2027, 3, 20),
      startingLevel: 2,
      weeklyQuota: 3,
    );

    test('aller-retour JSON', () {
      final back = Goal.fromJson(_throughJson(goal.toJson()));
      expect(back, goal);
      expect(back.hashCode, goal.hashCode);
    });

    test('copyWith', () {
      expect(goal.copyWith(weeklyQuota: 4).weeklyQuota, 4);
      expect(goal.copyWith(weeklyQuota: 4).copyWith(weeklyQuota: 3), goal);
    });
  });

  group('WeekQuota', () {
    final quota = WeekQuota(
      goalId: 'marathon',
      weekStart: DateTime(2026, 9, 21),
      target: 3,
      done: 2,
    );

    test('aller-retour JSON', () {
      final back = WeekQuota.fromJson(_throughJson(quota.toJson()));
      expect(back, quota);
      expect(back.hashCode, quota.hashCode);
    });

    test('atteint quand le compte y est', () {
      expect(quota.isReached, isFalse);
      expect(quota.copyWith(done: 3).isReached, isTrue);
    });
  });

  group('ChallengeLog', () {
    final postponed = ChallengeLog(
      challengeId: 'run-5k',
      date: DateTime(2026, 9, 23),
      status: ChallengeStatus.postponed,
      postponeReason: PostponeReason.tooHard,
    );

    test('aller-retour JSON pour chaque état', () {
      for (final status in ChallengeStatus.values) {
        final log = ChallengeLog(
          challengeId: 'run-5k',
          date: DateTime(2026, 9, 23, 18, 30),
          status: status,
        );
        expect(ChallengeLog.fromJson(_throughJson(log.toJson())), log);
      }
    });

    test('aller-retour JSON avec raison de report', () {
      final back = ChallengeLog.fromJson(_throughJson(postponed.toJson()));
      expect(back, postponed);
      expect(back.hashCode, postponed.hashCode);
    });

    test('copyWith peut retirer la raison de report', () {
      final succeeded = postponed.copyWith(
        status: ChallengeStatus.succeeded,
        postponeReason: () => null,
      );
      expect(succeeded.status, ChallengeStatus.succeeded);
      expect(succeeded.postponeReason, isNull);
    });
  });
}
