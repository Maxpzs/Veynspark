import 'package:flutter_test/flutter_test.dart';

import 'package:veynspark_v1/content/challenge_library.dart';
import 'package:veynspark_v1/models/challenge.dart';

void main() {
  const library = ChallengeLibrary.all;

  test('contient 60 défis aux identifiants uniques', () {
    expect(library, hasLength(60));
    expect(library.map((c) => c.id).toSet(), hasLength(library.length));
  });

  test('aucun champ obligatoire n\'est vide', () {
    for (final c in library) {
      expect(c.id.trim(), isNotEmpty, reason: 'id vide');
      expect(c.title.trim(), isNotEmpty, reason: '${c.id} : titre vide');
      expect(c.level, inInclusiveRange(1, 3), reason: '${c.id} : niveau');
      expect(
        c.estimatedDuration,
        greaterThan(Duration.zero),
        reason: '${c.id} : durée',
      );
      if (c.kind == ChallengeKind.goal) {
        expect(c.goalReminder?.trim(), isNotEmpty, reason: '${c.id} : rappel');
      }
    }
  });

  test('au moins un défi faisable dans chaque contexte', () {
    for (final context in ChallengeContext.values) {
      expect(
        library.where((c) => c.context == context),
        isNotEmpty,
        reason: context.name,
      );
    }
  });

  test('chaque domaine couvre au moins trois niveaux', () {
    for (final domain in ChallengeDomain.values) {
      final levels = library
          .where((c) => c.domain == domain)
          .map((c) => c.level)
          .toSet();
      expect(levels.length, greaterThanOrEqualTo(3), reason: domain.name);
    }
  });

  test('plus de défis d\'opportunité que de défis à objectif', () {
    final goals = library.where((c) => c.kind == ChallengeKind.goal).length;
    expect(goals, greaterThan(0));
    expect(library.length - goals, greaterThan(goals));
  });
}
