import 'dart:math' as math;
import 'dart:ui';

/// Une tuile telle que la disposition la voit : un identifiant, un poids qui
/// décide de sa surface, et sa nature.
class BentoSlot {
  const BentoSlot({
    required this.id,
    required this.weight,
    required this.isGoal,
  }) : assert(weight > 0, 'Une tuile a une surface.');

  final String id;

  /// Surface relative. Deux fois plus de poids, deux fois plus de surface,
  /// aux espacements près.
  final double weight;

  final bool isGoal;
}

/// La disposition du bento d'une journée.
///
/// Règles, dans l'ordre du brief :
/// - **La surface suit le poids.** La grille se découpe en deux, puis chaque
///   moitié en deux, et ainsi de suite ; chaque découpe partage la place au
///   prorata des poids. Les surfaces restent donc proportionnelles.
/// - **Au moins une tuile à objectif touche le haut de la grille**, tant
///   qu'il en reste une.
/// - **Des tuiles lisibles.** Aucun côté sous [minSide], aucune tuile plus
///   allongée que [maxAspect]. Quand c'est impossible, ces deux contraintes
///   se relâchent, jamais la précédente.
/// - **Une disposition par jour.** Parmi les dispositions acceptables les
///   mieux proportionnées, [seed] en choisit une : la même toute la journée,
///   une autre le lendemain.
/// - **Une grille qui se referme doucement.** Quand des tuiles quittent la
///   grille, les restantes prennent la disposition acceptable la plus proche
///   de celle du matin. Elle ne dépend que des tuiles restantes, pas de
///   l'ordre de nettoyage : rouvrir l'app rend la même grille.
///
/// Toutes les découpes possibles sont énumérées : c'est raisonnable jusqu'à
/// cinq tuiles, le maximum du bento.
class BentoLayout {
  BentoLayout({
    required List<BentoSlot> day,
    required this.seed,
    required this.gap,
    required this.minSide,
    required this.maxAspect,
  }) : _day = List.unmodifiable(day);

  /// Le lot de la journée, tuiles déjà nettoyées comprises.
  final List<BentoSlot> _day;

  final int seed;

  /// Espace entre deux tuiles.
  final double gap;

  final double minSide;

  final double maxAspect;

  /// Seuils successifs quand aucune disposition ne tient : [minSide] et
  /// [maxAspect] se relâchent jusqu'à disparaître.
  static const List<double> _relaxation = [1, 0.8, 0.6, 0.4, 0];

  /// Part des dispositions acceptables, les mieux proportionnées d'abord,
  /// parmi lesquelles la graine choisit.
  static const double _bestShare = 1 / 3;

  final Map<Size, Map<String, Rect>> _morning = {};
  final Map<(Size, String), Map<String, Rect>> _placed = {};

  /// Une graine qui change chaque jour et reste la même toute la journée
  /// (FNV-1a sur la date).
  static int seedFor(DateTime day) {
    var hash = 0x811c9dc5;
    for (final unit in '${day.year}-${day.month}-${day.day}'.codeUnits) {
      hash = ((hash ^ unit) * 0x01000193) & 0xffffffff;
    }
    return hash;
  }

  /// La place de chaque tuile de [present] dans une grille de taille [size].
  Map<String, Rect> place(Set<String> present, Size size) {
    final slots = [
      for (final slot in _day)
        if (present.contains(slot.id)) slot,
    ];
    if (slots.isEmpty || size.isEmpty) return const {};
    final key = (size, [for (final s in slots) s.id].join('|'));
    return _placed[key] ??= slots.length == _day.length
        ? _morningAt(size)
        : _closestTo(_morningAt(size), slots, size);
  }

  Map<String, Rect> _morningAt(Size size) => _morning[size] ??= () {
    final ranked = _acceptable(_day, size);
    final best = math.max(1, (ranked.length * _bestShare).ceil());
    return ranked[seed % best];
  }();

  Map<String, Rect> _closestTo(
    Map<String, Rect> morning,
    List<BentoSlot> slots,
    Size size,
  ) {
    double distance(Map<String, Rect> layout) {
      var total = 0.0;
      for (final MapEntry(key: id, value: rect) in layout.entries) {
        final from = morning[id]!;
        total +=
            (rect.left - from.left).abs() +
            (rect.top - from.top).abs() +
            (rect.right - from.right).abs() +
            (rect.bottom - from.bottom).abs();
      }
      return total;
    }

    Map<String, Rect>? closest;
    var shortest = double.infinity;
    for (final layout in _acceptable(slots, size)) {
      final d = distance(layout);
      if (d < shortest) {
        closest = layout;
        shortest = d;
      }
    }
    return closest!;
  }

  /// Les dispositions acceptables, les mieux proportionnées d'abord. Jamais
  /// vide : les contraintes de lisibilité se relâchent au besoin.
  List<Map<String, Rect>> _acceptable(List<BentoSlot> slots, Size size) {
    final goals = {
      for (final s in slots)
        if (s.isGoal) s.id,
    };
    bool goalOnTop(Map<String, Rect> layout) =>
        goals.isEmpty || goals.any((id) => layout[id]!.top < _epsilon);

    for (final factor in _relaxation) {
      final side = minSide * factor;
      final aspect = factor == 0 ? double.infinity : maxAspect / factor;
      final found = _layouts(
        slots,
        Offset.zero & size,
        null,
        side,
        aspect,
      ).where(goalOnTop).toList();
      if (found.isEmpty) continue;
      final scored = [for (final layout in found) (_score(layout), layout)]
        ..sort((a, b) => a.$1.compareTo(b.$1));
      return [for (final (_, layout) in scored) layout];
    }
    throw StateError('Aucune disposition possible.');
  }

  /// Toutes les découpes de [rect] entre [slots]. [forbidden] interdit de
  /// recouper la première moitié dans le sens de la découpe qui l'a créée :
  /// une même disposition n'est ainsi produite qu'une fois.
  Iterable<Map<String, Rect>> _layouts(
    List<BentoSlot> slots,
    Rect rect,
    _Cut? forbidden,
    double side,
    double aspect,
  ) sync* {
    if (rect.width < side || rect.height < side) return;
    if (slots.length == 1) {
      final long = math.max(rect.width, rect.height);
      final short = math.min(rect.width, rect.height);
      if (short > 0 && long / short <= aspect) yield {slots.single.id: rect};
      return;
    }
    final n = slots.length;
    for (final axis in _Cut.values) {
      if (axis == forbidden) continue;
      final length = (axis == _Cut.sideBySide ? rect.width : rect.height) - gap;
      if (length <= 0) continue;
      // Chaque sous-ensemble strict et non vide forme la première moitié.
      for (var mask = 1; mask < (1 << n) - 1; mask++) {
        final first = [
          for (var i = 0; i < n; i++)
            if (mask & (1 << i) != 0) slots[i],
        ];
        final second = [
          for (var i = 0; i < n; i++)
            if (mask & (1 << i) == 0) slots[i],
        ];
        final share = _weight(first) / (_weight(first) + _weight(second));
        final cut = length * share;
        final (a, b) = axis == _Cut.sideBySide
            ? (
                Rect.fromLTWH(rect.left, rect.top, cut, rect.height),
                Rect.fromLTRB(
                  rect.left + cut + gap,
                  rect.top,
                  rect.right,
                  rect.bottom,
                ),
              )
            : (
                Rect.fromLTWH(rect.left, rect.top, rect.width, cut),
                Rect.fromLTRB(
                  rect.left,
                  rect.top + cut + gap,
                  rect.right,
                  rect.bottom,
                ),
              );
        for (final left in _layouts(first, a, axis, side, aspect)) {
          for (final right in _layouts(second, b, null, side, aspect)) {
            yield {...left, ...right};
          }
        }
      }
    }
  }

  static double _weight(List<BentoSlot> slots) =>
      slots.fold(0, (sum, s) => sum + s.weight);

  /// Plus c'est bas, plus les tuiles sont proches du carré.
  static double _score(Map<String, Rect> layout) => layout.values.fold(
    0,
    (sum, r) =>
        sum +
        math.log(math.max(r.width, r.height) / math.min(r.width, r.height)),
  );

  static const double _epsilon = 0.5;
}

/// Sens d'une découpe.
enum _Cut {
  /// Les deux moitiés côte à côte.
  sideBySide,

  /// L'une sur l'autre.
  stacked,
}
