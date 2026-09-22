import 'package:flutter_test/flutter_test.dart';
import 'package:veynspark_v1/content/bento_content.dart';
import 'package:veynspark_v1/store/bento_day.dart';

void main() {
  BentoDay day() => BentoDay(
    goals: BentoContent.goalChallenges,
    opportunities: BentoContent.opportunityChallenges,
  );

  test('le son suit l\'ordre de nettoyage, pas la place dans la grille', () {
    final d = day();
    final last = BentoContent.opportunityChallenges.last;
    final first = BentoContent.goalChallenges.first;

    d.clean(last);
    d.clean(first);

    expect(d.cueFor(last).semitones, 0);
    expect(d.cueFor(first).semitones, 1);
    expect(d.cueFor(first).isResolution, isFalse);
  });

  test('la dernière tuile nettoyée joue la résolution et vide la grille', () {
    final d = day();
    final all = [
      ...BentoContent.goalChallenges,
      ...BentoContent.opportunityChallenges,
    ];
    for (final c in all) {
      d.clean(c);
    }

    expect(d.isCleared, isTrue);
    expect(d.cueFor(all.last).isResolution, isTrue);
  });

  test('nettoyer deux fois le même défi ne compte qu\'une fois', () {
    final d = day();
    final c = BentoContent.goalChallenges.first;
    d.clean(c);
    d.clean(c);
    d.clean(BentoContent.goalChallenges.last);

    expect(d.cueFor(BentoContent.goalChallenges.last).semitones, 1);
  });
}
