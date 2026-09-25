import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:veynspark_v1/app/glyna_app.dart';
import 'package:veynspark_v1/content/bento_content.dart';
import 'package:veynspark_v1/content/challenge_detail_content.dart';
import 'package:veynspark_v1/content/challenge_library.dart';
import 'package:veynspark_v1/content/challenge_run_content.dart';
import 'package:veynspark_v1/content/debug_content.dart';
import 'package:veynspark_v1/debug/debug_lock_detector.dart';
import 'package:veynspark_v1/debug/debug_tools.dart';
import 'package:veynspark_v1/engine/clock.dart';
import 'package:veynspark_v1/engine/rescheduled_day.dart';
import 'package:veynspark_v1/models/challenge.dart';
import 'package:veynspark_v1/models/challenge_log.dart';
import 'package:veynspark_v1/models/goal.dart';
import 'package:veynspark_v1/store/glyna_repository.dart';
import 'package:veynspark_v1/store/local/glyna_database.dart';
import 'package:veynspark_v1/theme/theme.dart';
import 'package:veynspark_v1/validation/timer_state.dart';
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

  void lifecycle(WidgetTester tester, List<AppLifecycleState> states) {
    for (final state in states) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
  }

  /// L'app passe en arrière-plan pendant [away] ; l'appareil est verrouillé
  /// si [locked].
  Future<void> awayFor(
    WidgetTester tester,
    Duration away, {
    required bool locked,
  }) async {
    if (locked) detector.lock();
    lifecycle(tester, [AppLifecycleState.inactive, AppLifecycleState.hidden]);
    await tester.pump();
    clock.advance(away);
    if (locked) detector.unlock();
    lifecycle(tester, [AppLifecycleState.inactive, AppLifecycleState.resumed]);
    await tester.pumpAndSettle();
  }

  /// Tient le téléphone verrouillé pendant [held].
  Future<void> lockFor(WidgetTester tester, Duration held) =>
      awayFor(tester, held, locked: true);

  /// Ouvre le détail de [challenge] depuis sa tuile.
  Future<void> openDetail(WidgetTester tester, Challenge challenge) async {
    await tester.tap(find.text(challenge.title));
    await tester.pumpAndSettle();
  }

  /// Lance [challenge] : sa tuile, puis « Faire maintenant ».
  Future<void> doNow(WidgetTester tester, Challenge challenge) async {
    await openDetail(tester, challenge);
    await tester.tap(find.text(ChallengeDetailContent.doNow));
    await tester.pumpAndSettle();
  }

  /// Nettoie [challenge] comme le ferait la personne : sa tuile, « Faire
  /// maintenant », et pour un défi à minuteur, le défi en entier jusqu'au
  /// retour au bento.
  Future<void> clean(WidgetTester tester, Challenge challenge) async {
    await doNow(tester, challenge);
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

  group('détail du défi', () {
    testWidgets('le tap ouvre le détail : titre, durée, contexte, objectif et '
        'quota, sans rien lancer', (tester) async {
      onPhone(tester);
      await openApp(tester);
      final challenge = (await grid()).firstWhere(
        (c) => c.kind == ChallengeKind.goal,
      );

      await openDetail(tester, challenge);

      expect(find.text(challenge.title.toUpperCase()), findsOneWidget);
      expect(
        find.text(ChallengeDetailContent.duration(challenge)),
        findsOneWidget,
      );
      expect(
        find.text(ChallengeDetailContent.goal('Marathon')),
        findsOneWidget,
      );
      // Rien de fait encore cette semaine ; le quota suit l'échéance.
      expect(
        find.textContaining(RegExp(r'^0/\d+ cette semaine$')),
        findsOneWidget,
      );
      expect(find.text(ChallengeDetailContent.doNow), findsOneWidget);
      expect(find.text(ChallengeDetailContent.postpone), findsOneWidget);
      expect(find.byType(BentoTile), findsNothing);
      expect(await journalOf(challenge), [ChallengeStatus.proposed]);
    });

    testWidgets('un défi d’opportunité n’a ni objectif ni quota', (
      tester,
    ) async {
      onPhone(tester);
      await openApp(tester);
      final challenge = (await grid()).firstWhere(
        (c) => c.kind == ChallengeKind.opportunity,
      );

      await openDetail(tester, challenge);

      expect(find.text(challenge.title.toUpperCase()), findsOneWidget);
      expect(find.textContaining('→'), findsNothing);
    });

    testWidgets('fermer le détail ne décide rien', (tester) async {
      onPhone(tester);
      await openApp(tester);
      final challenge = (await grid()).first;

      await openDetail(tester, challenge);
      await tester.tap(find.byTooltip(ChallengeDetailContent.close));
      await tester.pumpAndSettle();

      expect(find.text(challenge.title), findsOneWidget);
      expect(await journalOf(challenge), [ChallengeStatus.proposed]);
    });

    for (final name in sizes.keys) {
      testWidgets('reporter : les jours restants de la semaine, puis la tuile '
          'quitte la grille sans son ni vibration ($name)', (tester) async {
        final moments = <String>[];
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('glyna/haptics'),
          (call) async {
            moments.add(call.arguments as String);
            return null;
          },
        );
        onPhone(tester, name);
        await openApp(tester);
        final challenges = await grid();
        final challenge = challenges.first;

        await openDetail(tester, challenge);
        await tester.tap(find.text(ChallengeDetailContent.postpone));
        await tester.pumpAndSettle();
        // Mercredi : de demain à dimanche.
        expect(
          find.text(ChallengeDetailContent.postponeQuestion),
          findsOneWidget,
        );
        for (final day in ['Demain', 'Vendredi', 'Samedi', 'Dimanche']) {
          expect(find.text(day), findsOneWidget);
        }
        expect(find.text('Mardi'), findsNothing);
        expect(tester.takeException(), isNull);

        await tester.tap(find.text('Vendredi'));
        await tester.pumpAndSettle();

        expect(find.text(challenge.title), findsNothing);
        expect(find.byType(BentoTile), findsNWidgets(challenges.length - 1));
        expect(moments, ['tileTap']);
        expect(await journalOf(challenge), [
          ChallengeStatus.proposed,
          ChallengeStatus.postponed,
          ChallengeStatus.rescheduled,
        ]);
      });
    }

    testWidgets('le dimanche, rien à reporter : le lien n’apparaît pas', (
      tester,
    ) async {
      clock = FakeClock(DateTime(2026, 9, 27, 10));
      onPhone(tester);
      await openApp(tester);

      final challenges = await repository.logsBetween(
        DateTime(2026, 9, 27),
        DateTime(2026, 9, 28),
      );
      final challenge = ChallengeLibrary.all.firstWhere(
        (c) => c.id == challenges.first.challengeId,
      );
      await openDetail(tester, challenge);

      expect(find.text(ChallengeDetailContent.doNow), findsOneWidget);
      expect(find.text(ChallengeDetailContent.postpone), findsNothing);
    });

    testWidgets('tout reporter vide la grille, sobrement, sans rose', (
      tester,
    ) async {
      onPhone(tester);
      await openApp(tester);

      for (final (i, challenge) in (await grid()).indexed) {
        await openDetail(tester, challenge);
        await tester.tap(find.text(ChallengeDetailContent.postpone));
        await tester.pumpAndSettle();
        // Un jour prend au plus trois reports : samedi est plein ensuite.
        final full = i >= maxRescheduledPerDay;
        expect(find.text('Samedi'), full ? findsNothing : findsOneWidget);
        await tester.tap(find.text(full ? 'Dimanche' : 'Samedi'));
        await tester.pumpAndSettle();
      }

      expect(find.text(BentoContent.clearedTitle), findsNothing);
      expect(find.text(BentoContent.emptyTitle), findsOneWidget);
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
      await doNow(tester, challenge);
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

    testWidgets('le compteur tourne dès le lancement, et la durée atteinte '
        'app affichée mène à la réussite', (tester) async {
      final challenge = await launch(tester);

      clock.advance(const Duration(minutes: 1));
      await tester.pump(GlynaMotion.clockTick);
      expect(
        find.text(
          ChallengeRunContent.remaining(
            challenge.estimatedDuration - const Duration(minutes: 1),
          ),
        ),
        findsOneWidget,
      );

      clock.advance(challenge.estimatedDuration);
      await tester.pump(GlynaMotion.clockTick);
      await tester.pumpAndSettle();
      expect(
        find.text(ChallengeRunContent.successPhrase(challenge.id)),
        findsOneWidget,
      );
    });

    testWidgets('quitter l’app arrête le compteur, sobrement ; on reprend là '
        'où on en était', (tester) async {
      final challenge = await launch(tester);

      clock.advance(const Duration(minutes: 12));
      await awayFor(tester, const Duration(minutes: 5), locked: false);

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

    testWidgets('en debug, l’état de l’appareil et du compteur est visible', (
      tester,
    ) async {
      await launch(tester);
      String status(TimerPhase phase, [Absence? absence]) =>
          DebugContent.timerStatus(
            locked: false,
            phase: phase,
            lastAbsence: absence,
            simulated: false,
          );

      expect(find.text(status(TimerPhase.counting)), findsOneWidget);
      await lockFor(tester, const Duration(minutes: 1));
      expect(
        find.text(status(TimerPhase.counting, Absence.locked)),
        findsOneWidget,
      );
      await awayFor(tester, const Duration(minutes: 1), locked: false);
      expect(
        find.text(status(TimerPhase.interrupted, Absence.left)),
        findsOneWidget,
      );
    });

    testWidgets('sans code sur l’appareil, la simulation fait d’une sortie de '
        'l’app un verrouillage', (tester) async {
      // L'appareil ne signale jamais de verrouillage, comme un iPhone sans
      // code.
      final lock = DebugLockDetector(detector);
      onPhone(tester);
      await tester.pumpWidget(
        GlynaApp(
          repository: repository,
          clock: clock,
          lockDetector: lock,
          debugTools: DebugTools(
            repository: repository,
            clock: OffsetClock(base: clock),
            lock: lock,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final challenge = (await grid()).firstWhere(
        (c) => c.kind == ChallengeKind.goal,
      );

      lock.setSimulating(true);
      await doNow(tester, challenge);
      expect(
        find.text(
          DebugContent.timerStatus(
            locked: false,
            phase: TimerPhase.counting,
            lastAbsence: null,
            simulated: true,
          ),
        ),
        findsOneWidget,
      );

      await awayFor(tester, challenge.estimatedDuration, locked: false);
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
          debugTools: DebugTools(
            repository: repository,
            clock: offset,
            lock: DebugLockDetector(detector),
          ),
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
