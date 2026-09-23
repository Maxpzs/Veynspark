import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:veynspark_v1/engine/bento_layout.dart';

void main() {
  // La grille d'un iPhone SE, titre de l'écran déduit.
  const size = Size(327, 560);
  const minSide = 112.0;
  const maxAspect = 3.0;

  // Une journée type : deux défis à objectif, trois d'opportunité.
  const day = [
    BentoSlot(id: 'run-5k', weight: 35, isGoal: true),
    BentoSlot(id: 'read-20', weight: 25, isGoal: true),
    BentoSlot(id: 'curry', weight: 45, isGoal: false),
    BentoSlot(id: 'call', weight: 10, isGoal: false),
    BentoSlot(id: 'push-ups', weight: 10, isGoal: false),
  ];
  final all = {for (final s in day) s.id};

  BentoLayout layout({
    List<BentoSlot> slots = day,
    int seed = 0,
    double gap = 0,
  }) => BentoLayout(
    day: slots,
    seed: seed,
    gap: gap,
    minSide: minSide,
    maxAspect: maxAspect,
  );

  double area(Rect r) => r.width * r.height;

  void expectTiled(Map<String, Rect> rects, Set<String> ids) {
    expect(rects.keys.toSet(), ids);
    for (final r in rects.values) {
      expect((Offset.zero & size).inflate(0.01).contains(r.topLeft), isTrue);
      expect(r.right, lessThanOrEqualTo(size.width + 0.01));
      expect(r.bottom, lessThanOrEqualTo(size.height + 0.01));
    }
    final list = rects.values.toList();
    for (var i = 0; i < list.length; i++) {
      for (var j = i + 1; j < list.length; j++) {
        final overlap = list[i].intersect(list[j]);
        expect(overlap.width <= 0.01 || overlap.height <= 0.01, isTrue);
      }
    }
  }

  test('la surface de chaque tuile suit son poids', () {
    final rects = layout().place(all, size);
    final total = day.fold<double>(0, (sum, s) => sum + s.weight);

    expectTiled(rects, all);
    for (final slot in day) {
      expect(
        area(rects[slot.id]!) / (size.width * size.height),
        closeTo(slot.weight / total, 1e-9),
      );
    }
  });

  test('une tuile à objectif touche toujours le haut', () {
    for (var seed = 0; seed < 50; seed++) {
      final rects = layout(seed: seed).place(all, size);
      expect(
        day.where((s) => s.isGoal && rects[s.id]!.top < 0.5),
        isNotEmpty,
        reason: 'graine $seed',
      );
    }
  });

  test('les tuiles restent lisibles quand c’est possible', () {
    for (var seed = 0; seed < 50; seed++) {
      for (final r in layout(seed: seed, gap: 12).place(all, size).values) {
        expect(r.shortestSide, greaterThanOrEqualTo(minSide));
        expect(r.longestSide / r.shortestSide, lessThanOrEqualTo(maxAspect));
      }
    }
  });

  test('même jour, même disposition ; les jours changent de disposition', () {
    final wednesday = BentoLayout.seedFor(DateTime(2026, 9, 23));
    expect(
      layout(seed: wednesday).place(all, size),
      layout(
        seed: BentoLayout.seedFor(DateTime(2026, 9, 23, 22)),
      ).place(all, size),
    );

    final week = {
      for (var d = 21; d <= 27; d++)
        layout(
          seed: BentoLayout.seedFor(DateTime(2026, 9, d)),
        ).place(all, size).toString(),
    };
    expect(week.length, greaterThan(1));
  });

  test('une tuile nettoyée : les autres remplissent la place, sans que la '
      'grille se retourne', () {
    final grid = layout(seed: 7, gap: 12);
    final morning = grid.place(all, size);
    final rest = {...all}..remove('curry');

    final after = grid.place(rest, size);

    expectTiled(after, rest);
    final kept = day.where((s) => s.isGoal && after[s.id]!.top < 0.5);
    expect(kept, isNotEmpty);
    // Les tuiles bougent moins qu'avec une disposition tirée de zéro.
    double moved(Map<String, Rect> rects) => rest.fold(
      0,
      (sum, id) =>
          sum +
          (rects[id]!.center - morning[id]!.center).distance +
          (rects[id]!.size - morning[id]!.size as Offset).distance,
    );
    final fresh = layout(
      slots: [
        for (final s in day)
          if (rest.contains(s.id)) s,
      ],
      seed: 7,
      gap: 12,
    ).place(rest, size);
    expect(moved(after), lessThanOrEqualTo(moved(fresh)));
  });

  test('la disposition ne dépend que des tuiles restantes, pas de l’ordre '
      'de nettoyage', () {
    final rest = {'read-20', 'call', 'push-ups'};
    final curryFirst = layout(seed: 3, gap: 12)
      ..place(all, size)
      ..place(all.difference({'curry'}), size);
    final runFirst = layout(seed: 3, gap: 12)
      ..place(all, size)
      ..place(all.difference({'run-5k'}), size);
    expect(curryFirst.place(rest, size), runFirst.place(rest, size));
    expectTiled(curryFirst.place(rest, size), rest);
  });

  test(
    'quand la lisibilité est impossible, la grille se remplit quand même',
    () {
      final many = [
        for (var i = 0; i < 5; i++)
          BentoSlot(id: 't$i', weight: 1, isGoal: i == 0),
      ];
      const tiny = Size(200, 200);
      final rects = layout(
        slots: many,
      ).place({for (final s in many) s.id}, tiny);
      expect(rects, hasLength(5));
      expect(rects['t0']!.top, lessThan(0.5));
    },
  );
}
