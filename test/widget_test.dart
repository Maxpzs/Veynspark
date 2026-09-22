import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:veynspark_v1/app/glyna_app.dart';
import 'package:veynspark_v1/content/bento_content.dart';
import 'package:veynspark_v1/models/challenge.dart';

void main() {
  // Pas de réseau en test : les polices retombent sur la police par défaut.
  GoogleFonts.config.allowRuntimeFetching = false;

  final challenges = <Challenge>[
    ...BentoContent.goalChallenges,
    ...BentoContent.opportunityChallenges,
  ];

  // Du plus petit iPhone encore courant au plus grand.
  const sizes = {'iPhone SE': Size(375, 667), 'iPhone Pro Max': Size(430, 932)};

  for (final MapEntry(key: name, value: size) in sizes.entries) {
    testWidgets('le bento tient sans débordement sur $name', (tester) async {
      tester.view.physicalSize = size * tester.view.devicePixelRatio;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const GlynaApp());

      for (final challenge in challenges) {
        expect(find.text(challenge.title), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'nettoyer la grille : vibrations dans l\'ordre, puis grille vide',
    (tester) async {
      final moments = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('glyna/haptics'),
        (call) async {
          moments.add(call.arguments as String);
          return null;
        },
      );

      tester.view.physicalSize =
          sizes['iPhone Pro Max']! * tester.view.devicePixelRatio;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const GlynaApp());

      for (final challenge in challenges) {
        await tester.tap(find.text(challenge.title));
        // La tuile s'enfonce : toujours là, pas encore d'impact.
        await tester.pump();
        expect(moments.last, 'tileTap');
        await tester.pumpAndSettle();
        expect(find.text(challenge.title), findsNothing);
        expect(tester.takeException(), isNull);
      }

      expect(moments, [
        for (var i = 0; i < challenges.length - 1; i++) ...[
          'tileTap',
          'tileCleaned',
        ],
        'tileTap',
        'gridCleared',
      ]);
      expect(find.text(BentoContent.clearedTitle), findsOneWidget);

      await tester.tap(find.text(BentoContent.replayDemo));
      await tester.pumpAndSettle();
      for (final challenge in challenges) {
        expect(find.text(challenge.title), findsOneWidget);
      }
    },
  );
}
