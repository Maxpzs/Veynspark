import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veynspark_v1/content/bento_content.dart';
import 'package:veynspark_v1/engine/rescheduled_day.dart';
import 'package:veynspark_v1/engine/weekly_quota_rule.dart';
import 'package:veynspark_v1/models/challenge.dart';
import 'package:veynspark_v1/models/challenge_log.dart';
import 'package:veynspark_v1/models/goal.dart';
import 'package:veynspark_v1/store/bento_day.dart';
import 'package:veynspark_v1/store/glyna_repository.dart';
import 'package:veynspark_v1/store/local/glyna_database.dart';

import 'support/fake_clock.dart';

void main() {
  late GlynaRepository repository;
  late FakeClock clock;

  // Semaine du lundi 21 au dimanche 27 septembre 2026.
  final monday = DateTime(2026, 9, 21);
  final marathon = Goal(
    id: 'marathon',
    title: 'Marathon',
    domain: ChallengeDomain.move,
    deadline: DateTime(2027, 3, 20),
    startingLevel: 1,
    weeklyQuota: 3,
  );

  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  setUp(() async {
    clock = FakeClock(DateTime(2026, 9, 23, 10));
    repository = GlynaRepository(GlynaDatabase(NativeDatabase.memory()));
    await repository.saveGoal(marathon);
  });

  tearDown(() => repository.close());

  /// Ouvre l'app : une grille neuve, lue ou tirée depuis la base.
  Future<BentoDay> open() async {
    final day = BentoDay(repository: repository, clock: clock);
    await day.load();
    return day;
  }

  List<Challenge> all(BentoDay day) => [...day.goals, ...day.opportunities];

  Future<List<ChallengeLog>> todayLogs(ChallengeStatus status) async {
    final now = clock.now();
    final logs = await repository.logsBetween(
      DateTime(now.year, now.month, now.day),
      DateTime(now.year, now.month, now.day + 1),
    );
    return logs.where((l) => l.status == status).toList();
  }

  group('grille du jour', () {
    test('tirée par le moteur, puis gardée dans le journal', () async {
      final day = await open();

      expect(day.total, inInclusiveRange(4, 5));
      expect(day.goals, isNotEmpty);
      expect(day.goals.every((c) => c.domain == ChallengeDomain.move), isTrue);
      final proposed = await todayLogs(ChallengeStatus.proposed);
      expect(proposed.map((l) => l.challengeId), all(day).map((c) => c.id));
    });

    test('le rappel d\'objectif vient du quota de la semaine', () async {
      final day = await open();

      expect(
        day.goals.first.goalReminder,
        BentoContent.goalReminder(
          marathon.title,
          0,
          weeklyQuotaFor(marathon, monday),
        ),
      );
    });

    test('relancer l\'app le même jour rend la même grille', () async {
      final first = await open();
      // Le soir, le moteur préférerait des défis courts : la grille ne bouge
      // pas pour autant.
      clock.current = DateTime(2026, 9, 23, 23);
      final second = await open();

      expect(second.goals, first.goals);
      expect(second.opportunities, first.opportunities);
      expect(await todayLogs(ChallengeStatus.proposed), hasLength(first.total));
    });

    test('le lendemain, une grille neuve sans défi déjà vu', () async {
      final wednesday = await open();
      clock.current = DateTime(2026, 9, 24, 10);
      final thursday = await open();

      final seen = {for (final c in all(wednesday)) c.id};
      expect(all(thursday), isNotEmpty);
      expect(all(thursday).where((c) => seen.contains(c.id)), isEmpty);
    });
  });

  group('nettoyer', () {
    test('une tuile à objectif s\'inscrit au journal et au quota', () async {
      final day = await open();
      final goal = day.goals.first;

      await day.clean(goal);

      expect(day.goals, isNot(contains(goal)));
      final succeeded = await todayLogs(ChallengeStatus.succeeded);
      expect(succeeded.map((l) => l.challengeId), [goal.id]);
      final quota = await repository.weekQuota(marathon.id, monday);
      expect(quota?.done, 1);
      expect(quota?.target, weeklyQuotaFor(marathon, monday));
    });

    test('une tuile d\'opportunité ne touche à aucun quota', () async {
      final day = await open();

      await day.clean(day.opportunities.first);

      expect(await todayLogs(ChallengeStatus.succeeded), hasLength(1));
      expect(await repository.weekQuota(marathon.id, monday), isNull);
    });

    test('le quota existant de la semaine est incrémenté', () async {
      final day = await open();
      await day.clean(day.goals.first);
      clock.current = DateTime(2026, 9, 24, 10);
      final next = await open();

      await next.clean(next.goals.first);

      expect((await repository.weekQuota(marathon.id, monday))?.done, 2);
    });

    test('après redémarrage, les tuiles nettoyées restent nettoyées', () async {
      final first = await open();
      final goal = first.goals.first;
      final opportunity = first.opportunities.first;
      await first.clean(goal);
      await first.clean(opportunity);

      final second = await open();

      expect(second.total, first.total);
      final ids = all(second).map((c) => c.id);
      expect(ids, isNot(contains(goal.id)));
      expect(ids, isNot(contains(opportunity.id)));
      expect(all(second), hasLength(first.total - 2));
      // La gamme reprend où elle s'était arrêtée.
      final third = all(second).first;
      await second.clean(third);
      expect(second.cueFor(third).semitones, 2);
    });

    test('une grille propre le reste après redémarrage', () async {
      final first = await open();
      for (final c in all(first)) {
        await first.clean(c);
      }

      final second = await open();

      expect(second.isCleared, isTrue);
    });
  });

  group('le son', () {
    test('suit l\'ordre de nettoyage, pas la place dans la grille', () async {
      final day = await open();
      final last = day.opportunities.last;
      final first = day.goals.first;

      await day.clean(last);
      await day.clean(first);

      expect(day.cueFor(last).semitones, 0);
      expect(day.cueFor(first).semitones, 1);
      expect(day.cueFor(first).isResolution, isFalse);
    });

    test('la dernière tuile joue la résolution et vide la grille', () async {
      final day = await open();
      final tiles = all(day);
      for (final c in tiles) {
        await day.clean(c);
      }

      expect(day.isCleared, isTrue);
      expect(day.cueFor(tiles.last).isResolution, isTrue);
    });

    test('nettoyer deux fois le même défi ne compte qu\'une fois', () async {
      final day = await open();
      final [first, second, ...] = all(day);
      await day.clean(first);
      await day.clean(first);
      await day.clean(second);

      expect(day.cueFor(second).semitones, 1);
      expect(await todayLogs(ChallengeStatus.succeeded), hasLength(2));
    });
  });

  group('défi en cours', () {
    Future<List<ChallengeStatus>> journalOf(Challenge c) async => [
      for (final log in await repository.logsFor(c.id)) log.status,
    ];

    test('lancer puis arrêter s’inscrit au journal ; la tuile reste', () async {
      final day = await open();
      final challenge = day.goals.first;

      await day.accept(challenge);
      await day.abandon(challenge);

      expect(await journalOf(challenge), [
        ChallengeStatus.proposed,
        ChallengeStatus.accepted,
        ChallengeStatus.abandoned,
      ]);
      expect(day.tiles, contains(challenge));
      expect(await repository.weekQuota(marathon.id, monday), isNull);
    });

    test('valider enregistre la réussite et rend ce qu’elle fait avancer, '
        'sans retirer la tuile', () async {
      final day = await open();
      final challenge = day.goals.first;

      final progress = await day.validate(challenge);

      expect(progress.goal?.title, marathon.title);
      expect(progress.goal?.done, 1);
      expect(progress.goal?.target, weeklyQuotaFor(marathon, monday));
      expect(progress.weekSucceeded, 1);
      expect(day.tiles, contains(challenge));
      expect(await journalOf(challenge), contains(ChallengeStatus.succeeded));
    });

    test('une opportunité validée ne fait avancer que la semaine', () async {
      final day = await open();
      final progress = await day.validate(day.opportunities.first);
      expect(progress.goal, isNull);
      expect(progress.weekSucceeded, 1);
    });

    test('nettoyer une tuile validée ne compte pas deux fois', () async {
      final day = await open();
      final challenge = day.goals.first;
      await day.validate(challenge);

      await day.clean(challenge);

      expect(day.tiles, isNot(contains(challenge)));
      final statuses = await journalOf(challenge);
      expect(
        statuses.where((s) => s == ChallengeStatus.succeeded),
        hasLength(1),
      );
      expect((await repository.weekQuota(marathon.id, monday))?.done, 1);
    });

    test(
      'une tuile validée puis l’app fermée est nettoyée au retour',
      () async {
        final first = await open();
        final challenge = first.goals.first;
        await first.validate(challenge);

        final second = await open();

        expect(second.tiles.map((c) => c.id), isNot(contains(challenge.id)));
        expect(second.dayTiles.map((c) => c.id), contains(challenge.id));
      },
    );
  });

  group('reporter', () {
    final friday = DateTime(2026, 9, 25);

    test(
      'le défi quitte la grille, au journal : reporté, et prévu vendredi',
      () async {
        final day = await open();
        final challenge = all(day).first;
        final total = day.total;

        await day.postpone(challenge, friday);

        expect(all(day), isNot(contains(challenge)));
        expect(day.tiles, isNot(contains(challenge)));
        expect(day.postponed, {challenge.id});
        expect(day.total, total - 1);
        expect(day.cleanedCount, 0);
        final logs = await repository.logsFor(challenge.id);
        expect(logs.map((l) => l.status), [
          ChallengeStatus.proposed,
          ChallengeStatus.postponed,
          ChallengeStatus.rescheduled,
        ]);
        expect(logs.last.date, friday);
      },
    );

    test(
      'après redémarrage, le défi reporté reste hors de la grille',
      () async {
        final first = await open();
        final challenge = all(first).first;
        await first.postpone(challenge, friday);

        final second = await open();
        expect(all(second), isNot(contains(challenge)));
        expect(second.postponed, {challenge.id});
      },
    );

    test(
      'la dernière tuile nettoyée joue la résolution, reports exclus',
      () async {
        final day = await open();
        final [postponed, ...rest] = all(day);
        await day.postpone(postponed, friday);
        for (final c in rest) {
          await day.clean(c);
        }
        expect(day.isCleared, isTrue);
        expect(day.cueFor(rest.last).isResolution, isTrue);
      },
    );

    test(
      'le jour visé, le défi revient dans la grille, sans la dépasser',
      () async {
        final wednesday = await open();
        final challenge = all(wednesday).first;
        await wednesday.postpone(challenge, friday);

        clock.advance(const Duration(days: 2));
        final day = await open();
        expect(day.dayTiles.map((c) => c.id), contains(challenge.id));
        expect(day.total, lessThanOrEqualTo(maxTiles));
        expect(day.postponed, isEmpty);
      },
    );

    test('seulement dans la semaine, jamais aujourd\'hui', () async {
      final day = await open();
      final challenge = all(day).first;
      expect(
        () => day.postpone(challenge, DateTime(2026, 9, 23)),
        throwsArgumentError,
      );
      expect(
        () => day.postpone(challenge, DateTime(2026, 9, 28)),
        throwsArgumentError,
      );
    });

    test(
      'les jours proposés : les jours restants qui ont de la place',
      () async {
        final day = await open();
        final challenges = all(day);

        final detail = await day.detailOf(challenges.first);
        expect(detail.postponeDays, [
          DateTime(2026, 9, 24),
          friday,
          DateTime(2026, 9, 26),
          DateTime(2026, 9, 27),
        ]);

        for (final c in challenges.take(maxRescheduledPerDay)) {
          await day.postpone(c, friday);
        }
        final after = await day.detailOf(challenges.last);
        expect(after.postponeDays, isNot(contains(friday)));
      },
    );

    test('le dimanche, aucun jour où reporter', () async {
      clock = FakeClock(DateTime(2026, 9, 27, 10));
      final day = await open();
      final detail = await day.detailOf(all(day).first);
      expect(detail.postponeDays, isEmpty);
    });

    test(
      'le détail d\'un défi à objectif porte l\'objectif et le quota',
      () async {
        final day = await open();
        final goalTile = day.goals.first;
        final detail = await day.detailOf(goalTile);
        expect(detail.goal?.title, 'Marathon');
        expect(detail.goal?.done, 0);

        final opportunity = await day.detailOf(day.opportunities.first);
        expect(opportunity.goal, isNull);
      },
    );
  });
}
