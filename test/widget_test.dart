import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:veynspark_v1/app/glyna_app.dart';
import 'package:veynspark_v1/content/bento_content.dart';
import 'package:veynspark_v1/content/challenge_library.dart';
import 'package:veynspark_v1/content/challenge_run_content.dart';
import 'package:veynspark_v1/content/debug_content.dart';
import 'package:veynspark_v1/debug/debug_tools.dart';
import 'package:veynspark_v1/engine/clock.dart';
import 'package:veynspark_v1/models/challenge.dart';
import 'package:veynspark_v1/models/challenge_log.dart';
import 'package:veynspark_v1/models/goal.dart';
import 'package:veynspark_v1/store/glyna_repository.dart';
import 'package:veynspark_v1/store/local/glyna_database.dart';
import 'package:veynspark_v1/widgets/bento_tile.dart';

import 'support/fake_clock.dart';
import 'support/fake_lock_detector.dart';

void main() {
  // Pas de réseau en test : les polices retombent sur la police par défaut.
  GoogleFonts.config.allowRuntimeFetching = false;

  late GlynaRepository repository;
  late FakeClock clock;
  late FakeLockDetector detector;
  final now = DateTime(2026, 9, 23, 10);
  final today = DateTime(2026, 9, 23);
  final tomorrow = DateTime(2026, 9, 24);

  // Du plus petit iPhone encore courant au plus grand.
  const sizes = {'iPhone SE': Size(375, 667), 'iPhone Pro Max': Size(430, 932)};

  Goal goal(String id, ChallengeDomain domain) => Goal(
    id: id,
    title: id,
    domain: domain,
    deadline: DateTime(2027, 3, 20),
    startingLevel: 1,
    weeklyQuota: 3,
  );

  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  setUp(() async {
    clock = FakeClock(now);
    detector = FakeLockDetector();
    repository = GlynaRepository(GlynaDatabase(NativeDatabase.memory()));
    await repository.saveGoal(goal('Marathon', ChallengeDomain.move));
  });

  tearDown(() => repository.close());

  void onPhone(WidgetTester tester, [String name = 'iPhone Pro Max']) {
    tester.view.physicalSize = sizes[name]! * tester.view.devicePixelRatio;
    addTearDown(tester.view.reset);
  }

  Future<void> openApp(WidgetTester tester, {Clock? appClock}) async {
    await tester.pumpWidget(
      GlynaApp(
        repository: repository,
        clock: appClock ?? clock,
        lockDetector: detector,
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Les défis de la grille du jour, dans l'ordre où le moteur les a posés.
  Future<List<Challenge>> grid() async {
    final logs = await repository.logsBetween(today, tomorrow);
    return [
      for (final log in logs)
        if (log.status == ChallengeStatus.proposed)
          ChallengeLibrary.all.firstWhere((c) => c.id == log.challengeId),
    ];
  }

  Future<List<ChallengeStatus>> journalOf(Challenge challenge) async => [
    for (final log in await repository.logsFor(challenge.id)) log.status,
  ];

  /// Tient le téléphone verrouillé pendant [held].
  Future<void> lockFor(WidgetTester tester, Duration held) async {
    detector.lock();
    clock.advance(held);
    detector.unlock();
    await tester.pumpAndSettle();
  }

  /// Nettoie [challenge] comme le ferait la personne : un tap, et pour un
  /// défi à minuteur, le défi en entier jusqu'au retour au bento.
  Future<void> clean(WidgetTester tester, Challenge challenge) async {
    await tester.tap(find.text(challenge.title));
    await tester.pumpAndSettle();
    if (challenge.validation == ValidationMode.lockedTimer) {
      await lockFor(tester, challenge.estimatedDuration);
      await tester.tap(find.text(ChallengeRunContent.done));
      await tester.pumpAndSettle();
    }
  }

  group('le bento', () {
    for (final name in sizes.keys) {
      testWidgets('tient sans débordement sur $name', (tester) async {
        onPhone(tester, name);
        await openApp(tester);

        final challenges = await grid();
        expect(challenges.length, inInclusiveRange(4, 5));
        expect(find.byType(BentoTile), findsNWidgets(challenges.length));
        for (final challenge in challenges) {
          expect(find.text(challenge.title), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('une tuile à objectif touche le haut de la grille', (
      tester,
    ) async {
      onPhone(tester);
      await openApp(tester);

      final tiles = [
        for (final c in await grid())
          (c, tester.getTopLeft(find.byKey(ValueKey(c.id))).dy),
      ];
      final top = tiles.map((t) => t.$2).reduce((a, b) => a < b ? a : b);
      expect(
        tiles.where((t) => t.$1.kind == ChallengeKind.goal && t.$2 == top),
        isNotEmpty,
      );
    });

    testWidgets('un défi plus long occupe plus de place', (tester) async {
      onPhone(tester);
      await openApp(tester);

      final sized = [
        for (final c in await grid())
          (c.estimatedDuration, tester.getSize(find.byKey(ValueKey(c.id)))),
      ]..sort((a, b) => a.$1.compareTo(b.$1));
      final shortest = sized.first;
      final longest = sized.last;
      if (shortest.$1 < longest.$1) {
        expect(
          longest.$2.width * longest.$2.height,
          greaterThan(shortest.$2.width * shortest.$2.height),
        );
      }
    });

    testWidgets('nettoyer toute la grille : vibrations dans l\'ordre, puis '
        'grille vide', (tester) async {
      final moments = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('glyna/haptics'),
        (call) async {
          moments.add(call.arguments as String);
          return null;
        },
      );
      onPhone(tester);
      await openApp(tester);
      final challenges = await grid();

      for (final challenge in challenges) {
        await clean(tester, challenge);
        expect(find.text(challenge.title), findsNothing);
        expect(tester.takeException(), isNull);
      }

      expect(moments, [
        for (final (i, c) in challenges.indexed) ...[
          'tileTap',
          if (c.validation == ValidationMode.lockedTimer) 'challengeAccepted',
          i == challenges.length - 1 ? 'gridCleared' : 'tileCleaned',
        ],
      ]);
      expect(find.text(BentoContent.clearedTitle), findsOneWidget);
    });

    testWidgets('après redémarrage, même grille et tuiles nettoyées absentes', (
      tester,
    ) async {
      onPhone(tester);
      await openApp(tester);
      final challenges = await grid();
      final [cleaned, ...kept] = challenges;
      await clean(tester, cleaned);

      // L'app se ferme, puis se rouvre sur la même base.
      await tester.pumpWidget(const SizedBox.shrink());
      await openApp(tester);

      expect(find.text(cleaned.title), findsNothing);
      for (final challenge in kept) {
        expect(find.text(challenge.title), findsOneWidget);
      }
      expect(await grid(), challenges);
    });
  });

  group('défi à minuteur', () {
    // Un objectif lecture : la tuile à objectif est un défi à minuteur.
    setUp(() async {
      await repository.deleteGoal('Marathon');
      await repository.saveGoal(goal('Guerre et Paix', ChallengeDomain.read));
    });

    Future<Challenge> launch(WidgetTester tester) async {
      onPhone(tester);
      await openApp(tester);
      final challenge = (await grid()).firstWhere(
        (c) => c.kind == ChallengeKind.goal,
      );
      expect(challenge.validation, ValidationMode.lockedTimer);
      await tester.tap(find.text(challenge.title));
      await tester.pumpAndSettle();
      return challenge;
    }

    testWidgets('le lancer montre le temps et la consigne, rien d’autre', (
      tester,
    ) async {
      final challenge = await launch(tester);

      expect(find.text(challenge.title), findsOneWidget);
      expect(
        find.text(ChallengeRunContent.remaining(challenge.estimatedDuration)),
        findsOneWidget,
      );
      expect(find.text(ChallengeRunContent.timerInstruction), findsOneWidget);
      expect(find.byType(BentoTile), findsNothing);
      expect(await journalOf(challenge), [
        ChallengeStatus.proposed,
        ChallengeStatus.accepted,
      ]);
    });

    testWidgets('la durée tenue verrouillé mène à la réussite, puis la tuile '
        'quitte la grille', (tester) async {
      final challenge = await launch(tester);

      await lockFor(tester, challenge.estimatedDuration);

      expect(
        find.text(ChallengeRunContent.successPhrase(challenge.id)),
        findsOneWidget,
      );
      expect(
        find.text(ChallengeRunContent.goalProgress('Guerre et Paix', 1, 2)),
        findsOneWidget,
      );
      // La réussite est enregistrée avant même le retour au bento.
      expect(await journalOf(challenge), contains(ChallengeStatus.succeeded));

      await tester.tap(find.text(ChallengeRunContent.done));
      await tester.pumpAndSettle();

      expect(find.text(challenge.title), findsNothing);
      expect(find.byType(BentoTile), findsWidgets);
      final successes = (await journalOf(
        challenge,
      )).where((s) => s == ChallengeStatus.succeeded);
      expect(successes, hasLength(1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('déverrouiller trop tôt arrête le compteur, sobrement ; on '
        'reprend là où on en était', (tester) async {
      final challenge = await launch(tester);

      await lockFor(tester, const Duration(minutes: 12));

      expect(
        find.text(
          ChallengeRunContent.timerInterrupted(const Duration(minutes: 12)),
        ),
        findsOneWidget,
      );
      await tester.tap(find.text(ChallengeRunContent.resume));
      await tester.pumpAndSettle();

      await lockFor(
        tester,
        challenge.estimatedDuration - const Duration(minutes: 12),
      );
      expect(
        find.text(ChallengeRunContent.successPhrase(challenge.id)),
        findsOneWidget,
      );
    });

    testWidgets('arrêter : un tap, aucune confirmation, la tuile reste', (
      tester,
    ) async {
      final challenge = await launch(tester);

      await tester.tap(find.text(ChallengeRunContent.abandon));
      await tester.pumpAndSettle();

      expect(find.text(challenge.title), findsOneWidget);
      expect(find.text(ChallengeRunContent.timerInstruction), findsNothing);
      expect(await journalOf(challenge), [
        ChallengeStatus.proposed,
        ChallengeStatus.accepted,
        ChallengeStatus.abandoned,
      ]);
      expect(detector.hasListener, isFalse);
    });

    testWidgets('le retour système arrête aussi le défi', (tester) async {
      final challenge = await launch(tester);

      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      await navigator.maybePop();
      await tester.pumpAndSettle();

      expect(find.text(challenge.title), findsOneWidget);
      expect(await journalOf(challenge), contains(ChallengeStatus.abandoned));
    });
  });

  group('panneau de débogage', () {
    testWidgets(
      'sans outils de debug, l’appui long sur le titre ne fait rien',
      (tester) async {
        await openApp(tester);
        await tester.longPress(find.text(BentoContent.title));
        await tester.pumpAndSettle();
        expect(find.text(DebugContent.title), findsNothing);
      },
    );

    testWidgets('un appui long sur le titre l’ouvre ; avancer d’un jour '
        'change la grille', (tester) async {
      onPhone(tester);
      final offset = OffsetClock(base: clock);
      await tester.pumpWidget(
        GlynaApp(
          repository: repository,
          clock: offset,
          lockDetector: detector,
          debugTools: DebugTools(repository: repository, clock: offset),
        ),
      );
      await tester.pumpAndSettle();
      final wednesday = await grid();

      await tester.longPress(find.text(BentoContent.title));
      await tester.pumpAndSettle();
      expect(find.text(DebugContent.title), findsOneWidget);
      expect(find.text(DebugContent.now(now, 0)), findsOneWidget);

      await tester.tap(find.text(DebugContent.advanceDay));
      await tester.pumpAndSettle();

      expect(
        find.text(DebugContent.now(DateTime(2026, 9, 24, 10), 1)),
        findsOneWidget,
      );
      for (final challenge in wednesday) {
        expect(find.text(challenge.title), findsNothing);
      }
      expect(find.byType(BentoTile), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });
}
