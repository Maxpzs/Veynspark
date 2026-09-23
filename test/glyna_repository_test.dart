import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:veynspark_v1/models/challenge.dart';
import 'package:veynspark_v1/models/challenge_log.dart';
import 'package:veynspark_v1/models/goal.dart';
import 'package:veynspark_v1/models/week_quota.dart';
import 'package:veynspark_v1/store/glyna_repository.dart';
import 'package:veynspark_v1/store/local/glyna_database.dart';

import 'support/legacy_schema.dart';

void main() {
  late GlynaRepository repository;

  final marathon = Goal(
    id: 'marathon',
    title: 'Marathon',
    domain: ChallengeDomain.move,
    deadline: DateTime(2027, 3, 20),
    startingLevel: 1,
    weeklyQuota: 3,
  );
  final reading = Goal(
    id: 'reading',
    title: 'Finir Guerre et Paix',
    domain: ChallengeDomain.read,
    deadline: DateTime(2026, 12, 31),
    startingLevel: 2,
    weeklyQuota: 5,
  );
  final monday = DateTime(2026, 9, 21);
  final nextMonday = DateTime(2026, 9, 28);

  setUpAll(() {
    // Chaque test ouvre sa propre base en mémoire.
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  setUp(() {
    repository = GlynaRepository(GlynaDatabase(NativeDatabase.memory()));
  });

  tearDown(() => repository.close());

  group('Objectifs', () {
    test('un objectif écrit se relit à l’identique', () async {
      await repository.saveGoal(marathon);
      expect(await repository.goal('marathon'), marathon);
    });

    test('un objectif inconnu renvoie null', () async {
      expect(await repository.goal('inconnu'), isNull);
    });

    test('réécrire un objectif le remplace', () async {
      await repository.saveGoal(marathon);
      final later = marathon.copyWith(deadline: DateTime(2027, 4, 10));
      await repository.saveGoal(later);
      expect(await repository.goals(), [later]);
    });

    test('les objectifs sortent par échéance', () async {
      await repository.saveGoal(marathon);
      await repository.saveGoal(reading);
      expect(await repository.goals(), [reading, marathon]);
    });

    test('abandonner un objectif emporte ses quotas', () async {
      await repository.saveGoal(marathon);
      await repository.saveWeekQuota(
        WeekQuota(goalId: 'marathon', weekStart: monday, target: 3),
      );
      await repository.deleteGoal('marathon');
      expect(await repository.goals(), isEmpty);
      expect(await repository.weekQuotas(monday), isEmpty);
    });
  });

  group('Quotas hebdomadaires', () {
    setUp(() async {
      await repository.saveGoal(marathon);
      await repository.saveGoal(reading);
    });

    test('un quota écrit se relit à l’identique', () async {
      final quota = WeekQuota(
        goalId: 'marathon',
        weekStart: monday,
        target: 3,
        done: 2,
      );
      await repository.saveWeekQuota(quota);
      expect(await repository.weekQuota('marathon', monday), quota);
    });

    test('réécrire un quota le met à jour', () async {
      final quota = WeekQuota(goalId: 'marathon', weekStart: monday, target: 3);
      await repository.saveWeekQuota(quota);
      await repository.saveWeekQuota(quota.copyWith(done: 1));
      expect(
        await repository.weekQuota('marathon', monday),
        quota.copyWith(done: 1),
      );
    });

    test('les quotas se lisent semaine par semaine', () async {
      final running = WeekQuota(
        goalId: 'marathon',
        weekStart: monday,
        target: 3,
      );
      final books = WeekQuota(goalId: 'reading', weekStart: monday, target: 5);
      final nextWeek = running.copyWith(weekStart: nextMonday);
      await repository.saveWeekQuota(running);
      await repository.saveWeekQuota(books);
      await repository.saveWeekQuota(nextWeek);

      expect(
        await repository.weekQuotas(monday),
        unorderedEquals([running, books]),
      );
      expect(await repository.weekQuotas(nextMonday), [nextWeek]);
    });

    test('un quota sans objectif est refusé', () async {
      expect(
        repository.saveWeekQuota(
          WeekQuota(goalId: 'fantome', weekStart: monday, target: 1),
        ),
        throwsA(isA<SqliteException>()),
      );
    });
  });

  group('Journal des défis', () {
    test('une entrée écrite se relit à l’identique', () async {
      final log = ChallengeLog(
        challengeId: 'run-5k',
        date: DateTime(2026, 9, 22, 7, 30),
        status: ChallengeStatus.postponed,
        postponeReason: PostponeReason.wrongMoment,
      );
      await repository.addLog(log);
      expect(await repository.logsFor('run-5k'), [log]);
    });

    test('un même défi garde toutes ses étapes, dans l’ordre', () async {
      final at = DateTime(2026, 9, 22, 18);
      final steps = [
        ChallengeLog(
          challengeId: 'run-5k',
          date: at,
          status: ChallengeStatus.proposed,
        ),
        ChallengeLog(
          challengeId: 'run-5k',
          date: at,
          status: ChallengeStatus.accepted,
        ),
        ChallengeLog(
          challengeId: 'run-5k',
          date: at,
          status: ChallengeStatus.succeeded,
        ),
      ];
      for (final step in steps) {
        await repository.addLog(step);
      }
      expect(await repository.logsFor('run-5k'), steps);
    });

    test('la lecture par période inclut le début et exclut la fin', () async {
      final sunday = ChallengeLog(
        challengeId: 'read-30',
        date: DateTime(2026, 9, 20, 23, 59),
        status: ChallengeStatus.succeeded,
      );
      final firstDay = ChallengeLog(
        challengeId: 'read-30',
        date: monday,
        status: ChallengeStatus.succeeded,
      );
      final lastDay = ChallengeLog(
        challengeId: 'curry',
        date: DateTime(2026, 9, 27, 21),
        status: ChallengeStatus.abandoned,
      );
      final followingWeek = ChallengeLog(
        challengeId: 'curry',
        date: nextMonday,
        status: ChallengeStatus.proposed,
      );
      for (final log in [followingWeek, lastDay, sunday, firstDay]) {
        await repository.addLog(log);
      }

      expect(await repository.logsBetween(monday, nextMonday), [
        firstDay,
        lastDay,
      ]);
    });

    test('une grille écrite d’un coup se relit dans son ordre', () async {
      final at = DateTime(2026, 9, 23, 10);
      final grid = [
        for (final id in ['run-5k', 'curry', 'ten-push-ups'])
          ChallengeLog(
            challengeId: id,
            date: at,
            status: ChallengeStatus.proposed,
          ),
      ];
      await repository.addLogs(grid);
      expect(await repository.logsBetween(monday, nextMonday), grid);
    });

    test('la lecture jusqu’à une date exclut cette date', () async {
      final before = ChallengeLog(
        challengeId: 'run-5k',
        date: DateTime(2025, 1, 6, 8),
        status: ChallengeStatus.succeeded,
      );
      final after = ChallengeLog(
        challengeId: 'curry',
        date: nextMonday,
        status: ChallengeStatus.proposed,
      );
      await repository.addLogs([after, before]);
      expect(await repository.logsBefore(nextMonday), [before]);
    });
  });

  group('Réussites', () {
    final success = ChallengeLog(
      challengeId: 'run-5k',
      date: DateTime(2026, 9, 23, 19),
      status: ChallengeStatus.succeeded,
    );

    test('une réussite sans objectif ne touche à aucun quota', () async {
      await repository.saveGoal(marathon);
      await repository.addSuccess(success);
      expect(await repository.logsFor('run-5k'), [success]);
      expect(await repository.weekQuotas(monday), isEmpty);
    });

    test('la première réussite de la semaine crée le quota', () async {
      await repository.saveGoal(marathon);
      await repository.addSuccess(
        success,
        quota: WeekQuota(goalId: 'marathon', weekStart: monday, target: 3),
      );
      expect(
        await repository.weekQuota('marathon', monday),
        WeekQuota(goalId: 'marathon', weekStart: monday, target: 3, done: 1),
      );
    });

    test('les suivantes incrémentent le quota existant', () async {
      await repository.saveGoal(marathon);
      await repository.saveWeekQuota(
        WeekQuota(goalId: 'marathon', weekStart: monday, target: 4, done: 2),
      );
      await repository.addSuccess(
        success,
        quota: WeekQuota(goalId: 'marathon', weekStart: monday, target: 3),
      );
      expect(
        await repository.weekQuota('marathon', monday),
        WeekQuota(goalId: 'marathon', weekStart: monday, target: 4, done: 3),
      );
    });

    test('si le quota ne peut pas s’écrire, la réussite non plus', () async {
      await expectLater(
        repository.addSuccess(
          success,
          quota: WeekQuota(goalId: 'inconnu', weekStart: monday, target: 3),
        ),
        throwsA(anything),
      );
      expect(await repository.logsFor('run-5k'), isEmpty);
    });
  });

  test('une base de la version 2 gagne le domaine des objectifs', () async {
    final upgraded = GlynaRepository(
      GlynaDatabase(NativeDatabase.memory(setup: LegacySchema.at(2))),
    );
    addTearDown(upgraded.close);

    await upgraded.saveGoal(reading);
    expect(await upgraded.goal('reading'), reading);
  });
}
