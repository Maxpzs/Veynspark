import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veynspark_v1/analytics/analytics_event.dart';
import 'package:veynspark_v1/content/debug_content.dart';
import 'package:veynspark_v1/debug/debug_lock_detector.dart';
import 'package:veynspark_v1/debug/debug_tools.dart';
import 'package:veynspark_v1/engine/clock.dart';
import 'package:veynspark_v1/models/challenge.dart';
import 'package:veynspark_v1/models/challenge_log.dart';
import 'package:veynspark_v1/models/goal.dart';
import 'package:veynspark_v1/store/bento_day.dart';
import 'package:veynspark_v1/store/glyna_repository.dart';
import 'package:veynspark_v1/store/local/glyna_database.dart';

import 'support/fake_clock.dart';
import 'support/fake_lock_detector.dart';

void main() {
  late GlynaRepository repository;
  late FakeClock base;
  late OffsetClock clock;
  late DebugTools tools;

  // Mercredi 23 septembre 2026, 19 h. Semaine du lundi 21 au dimanche 27.
  final monday = DateTime(2026, 9, 21);
  final nextMonday = DateTime(2026, 9, 28);
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

  setUp(() {
    repository = GlynaRepository(GlynaDatabase(NativeDatabase.memory()));
    base = FakeClock(DateTime(2026, 9, 23, 19));
    clock = OffsetClock(base: base);
    tools = DebugTools(
      repository: repository,
      clock: clock,
      lock: DebugLockDetector(FakeLockDetector()),
    );
  });

  tearDown(() => repository.close());

  Future<BentoDay> openBento() async {
    final day = BentoDay(repository: repository, clock: clock);
    await day.load();
    return day;
  }

  Future<List<ChallengeLog>> weekSuccesses() async => [
    for (final log in await repository.logsBetween(monday, nextMonday))
      if (log.status == ChallengeStatus.succeeded) log,
  ];

  group('réinitialiser la journée', () {
    test(
      'efface les tuiles nettoyées et le quota qu’elles avaient compté',
      () async {
        await repository.saveGoal(marathon);
        final day = await openBento();
        final grid = [...day.goals, ...day.opportunities];
        await day.clean(day.goals.first);
        await day.clean(day.opportunities.first);

        await tools.resetDay();

        expect(await repository.logsBetween(monday, nextMonday), isEmpty);
        expect((await repository.weekQuota(marathon.id, monday))?.done, 0);
        final again = await openBento();
        expect([
          ...again.goals,
          ...again.opportunities,
        ], hasLength(grid.length));
        expect(again.isCleared, isFalse);
      },
    );

    test('ne touche pas aux jours précédents', () async {
      await repository.saveGoal(marathon);
      await tools.fillWeek();
      final before = await weekSuccesses();
      final day = await openBento();
      await day.clean(day.goals.first);

      await tools.resetDay();

      expect(await weekSuccesses(), before);
      expect((await repository.weekQuota(marathon.id, monday))?.done, 1);
    });
  });

  test('réinitialiser toute la base efface tout, objectifs compris', () async {
    await repository.saveGoal(marathon);
    await tools.fillWeek();
    await repository.addEvent(
      AnalyticsEvent(type: AnalyticsEventType.appOpened, at: base.now()),
    );

    await tools.resetAll();

    expect(await repository.goals(), isEmpty);
    expect(await repository.weekQuotas(monday), isEmpty);
    expect(await repository.logsBetween(monday, nextMonday), isEmpty);
    expect(await repository.eventsBetween(monday, nextMonday), isEmpty);
  });

  group('voyage dans le temps', () {
    test('avancer d’un jour donne une grille neuve', () async {
      final wednesday = await openBento();
      tools.advanceDay();
      final thursday = await openBento();

      expect((await tools.week()).now, DateTime(2026, 9, 24, 19));
      final seen = {
        for (final c in [...wednesday.goals, ...wednesday.opportunities]) c.id,
      };
      expect(
        [...thursday.goals, ...thursday.opportunities].map((c) => c.id),
        everyElement(isNot(isIn(seen))),
      );
    });

    test('avancer d’une semaine ouvre la semaine suivante', () async {
      tools.advanceWeek();
      final week = await tools.week();
      expect(week.now, DateTime(2026, 9, 30, 19));
      expect(week.daysAhead, 7);
      expect(week.progress.weekStart, nextMonday);
    });

    test('revenir à aujourd’hui annule l’avance', () async {
      tools
        ..advanceWeek()
        ..backToPresent();
      expect((await tools.week()).now, base.now());
    });
  });

  group('remplir la semaine', () {
    test('crée un objectif d’exemple s’il n’y en a aucun', () async {
      await tools.fillWeek();
      final goals = await repository.goals();
      expect(goals.map((g) => g.title), [DebugContent.sampleGoalTitle]);
    });

    test('remplit les jours passés et recompte le quota', () async {
      await repository.saveGoal(marathon);

      // Lundi : un défi à objectif et une opportunité. Mardi : une opportunité.
      expect(await tools.fillWeek(), 3);

      final successes = await weekSuccesses();
      expect(successes, hasLength(3));
      expect(
        successes.every((l) => l.date.isBefore(DateTime(2026, 9, 23))),
        isTrue,
      );
      expect({for (final l in successes) l.challengeId}, hasLength(3));
      expect((await repository.weekQuota(marathon.id, monday))?.done, 1);
    });

    test('relancer ne double rien', () async {
      await repository.saveGoal(marathon);
      await tools.fillWeek();
      expect(await tools.fillWeek(), 0);
      expect(await weekSuccesses(), hasLength(3));
    });

    test('un lundi, il n’y a rien à remplir', () async {
      base.current = DateTime(2026, 9, 21, 19);
      expect(await tools.fillWeek(), 0);
    });

    test('le bilan du dimanche apparaît le dimanche soir', () async {
      await repository.saveGoal(marathon);
      await tools.fillWeek();
      expect((await tools.week()).review, isNull);

      clock.advance(days: 4);
      final review = (await tools.week()).review;

      expect(review, isNotNull);
      expect(review!.succeeded, hasLength(3));
      expect(review.goals.single.done, 1);
    });
  });
}
