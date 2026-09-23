import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:veynspark_v1/analytics/analytics_event.dart';
import 'package:veynspark_v1/analytics/local_analytics.dart';
import 'package:veynspark_v1/store/glyna_repository.dart';
import 'package:veynspark_v1/store/local/glyna_database.dart';

void main() {
  late GlynaRepository repository;
  late LocalAnalytics analytics;
  late DateTime now;

  final monday = DateTime(2026, 9, 21);
  final nextMonday = DateTime(2026, 9, 28);

  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  setUp(() {
    now = DateTime(2026, 9, 21, 8);
    repository = GlynaRepository(GlynaDatabase(NativeDatabase.memory()));
    analytics = LocalAnalytics(repository, clock: () => now);
  });

  tearDown(() => repository.close());

  group('Enregistrement et relecture', () {
    test(
      'chaque méthode écrit l’événement attendu, daté par l’horloge',
      () async {
        await analytics.appOpened();
        now = now.add(const Duration(minutes: 1));
        await analytics.onboardingStepReached(3);
        await analytics.onboardingCompleted();
        await analytics.challengeProposed('courir-5km');
        await analytics.challengeAccepted('courir-5km');
        await analytics.challengePostponed('lire-30min');
        await analytics.feedPostSeen('post-1');
        await analytics.challengeTakenUpFromFeed('post-1', 'curry');

        final later = DateTime(2026, 9, 21, 8, 1);
        expect(await analytics.eventsBetween(monday, nextMonday), [
          AnalyticsEvent(
            type: AnalyticsEventType.appOpened,
            at: DateTime(2026, 9, 21, 8),
          ),
          AnalyticsEvent(
            type: AnalyticsEventType.onboardingStepReached,
            at: later,
            onboardingStep: 3,
          ),
          AnalyticsEvent(
            type: AnalyticsEventType.onboardingCompleted,
            at: later,
          ),
          AnalyticsEvent(
            type: AnalyticsEventType.challengeProposed,
            at: later,
            challengeId: 'courir-5km',
          ),
          AnalyticsEvent(
            type: AnalyticsEventType.challengeAccepted,
            at: later,
            challengeId: 'courir-5km',
          ),
          AnalyticsEvent(
            type: AnalyticsEventType.challengePostponed,
            at: later,
            challengeId: 'lire-30min',
          ),
          AnalyticsEvent(
            type: AnalyticsEventType.feedPostSeen,
            at: later,
            feedPostId: 'post-1',
          ),
          AnalyticsEvent(
            type: AnalyticsEventType.challengeTakenUpFromFeed,
            at: later,
            challengeId: 'curry',
            feedPostId: 'post-1',
          ),
        ]);
      },
    );

    test('un même événement répété est gardé à chaque fois', () async {
      await analytics.appOpened();
      await analytics.appOpened();
      expect(await analytics.eventsBetween(monday, nextMonday), hasLength(2));
    });

    test('la relecture ne garde que la période demandée, bornes comprises '
        'au début et exclues à la fin', () async {
      now = DateTime(2026, 9, 20, 23, 59);
      await analytics.appOpened();
      now = monday;
      await analytics.appOpened();
      now = DateTime(2026, 9, 27, 22);
      await analytics.appOpened();
      now = nextMonday;
      await analytics.appOpened();

      final week = await analytics.eventsBetween(monday, nextMonday);
      expect(week.map((e) => e.at), [monday, DateTime(2026, 9, 27, 22)]);
    });

    test('les événements sortent dans l’ordre chronologique', () async {
      now = DateTime(2026, 9, 23);
      await analytics.challengeProposed('b');
      now = DateTime(2026, 9, 22);
      await analytics.challengeProposed('a');

      final events = await analytics.eventsBetween(monday, nextMonday);
      expect(events.map((e) => e.challengeId), ['a', 'b']);
    });

    test('une base vide ne renvoie rien', () async {
      expect(await analytics.eventsBetween(monday, nextMonday), isEmpty);
    });
  });

  test('une base de la version 1 gagne la table des événements', () async {
    final upgraded = GlynaRepository(
      GlynaDatabase(NativeDatabase.memory(setup: (db) => db.userVersion = 1)),
    );
    addTearDown(upgraded.close);

    final event = AnalyticsEvent(
      type: AnalyticsEventType.appOpened,
      at: monday,
    );
    await upgraded.addEvent(event);
    expect(await upgraded.eventsBetween(monday, nextMonday), [event]);
  });

  test('un événement survit à l’aller-retour JSON', () {
    final event = AnalyticsEvent(
      type: AnalyticsEventType.challengeTakenUpFromFeed,
      at: DateTime(2026, 9, 21, 8, 30),
      challengeId: 'curry',
      feedPostId: 'post-1',
    );
    expect(AnalyticsEvent.fromJson(event.toJson()), event);

    final step = AnalyticsEvent(
      type: AnalyticsEventType.onboardingStepReached,
      at: DateTime(2026, 9, 21),
      onboardingStep: 6,
    );
    expect(AnalyticsEvent.fromJson(step.toJson()), step);
  });
}
