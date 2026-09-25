import 'package:flutter_test/flutter_test.dart';

import 'package:veynspark_v1/engine/daily_proposal.dart';
import 'package:veynspark_v1/engine/rescheduled_day.dart';
import 'package:veynspark_v1/models/challenge.dart';

void main() {
  Challenge challenge(String id, ChallengeKind kind) => Challenge(
    id: id,
    title: id,
    domain: ChallengeDomain.read,
    kind: kind,
    level: 1,
    estimatedDuration: const Duration(minutes: 20),
    context: ChallengeContext.anywhere,
    validation: ValidationMode.declarative,
    goalReminder: kind == ChallengeKind.goal ? '→ $id' : null,
  );
  Challenge goal(String id) => challenge(id, ChallengeKind.goal);
  Challenge opportunity(String id) => challenge(id, ChallengeKind.opportunity);

  List<String> ids(List<Challenge> list) => [for (final c in list) c.id];

  final engine = DailyProposal(
    goals: [goal('g1'), goal('g2')],
    opportunities: [opportunity('o1'), opportunity('o2'), opportunity('o3')],
  );

  test('sans défi reporté, la proposition du moteur telle quelle', () {
    expect(withRescheduled(engine, const []), same(engine));
  });

  test('un défi reporté passe avant le moteur, à sa place', () {
    final day = withRescheduled(engine, [opportunity('r')]);
    expect(ids(day.goals), ['g1', 'g2']);
    expect(ids(day.opportunities), ['r', 'o1', 'o2']);
    expect(day.all, hasLength(maxTiles));
  });

  test('une tuile à objectif reportée prend la place d\'une du moteur', () {
    final day = withRescheduled(engine, [goal('r')]);
    expect(ids(day.goals), ['r', 'g1']);
    expect(day.all, hasLength(maxTiles));
  });

  test('une grille de quatre gagne une tuile, sans dépasser cinq', () {
    final small = DailyProposal(
      goals: [goal('g1')],
      opportunities: [opportunity('o1'), opportunity('o2'), opportunity('o3')],
    );
    final day = withRescheduled(small, [opportunity('r')]);
    expect(ids(day.all), ['g1', 'r', 'o1', 'o2', 'o3']);
  });

  test(
    'les défis reportés restent tous, même au-delà des quotas de tuiles',
    () {
      final day = withRescheduled(engine, [goal('r1'), goal('r2'), goal('r3')]);
      expect(ids(day.goals), ['r1', 'r2', 'r3']);
      expect(day.all, hasLength(maxTiles));
    },
  );
}
