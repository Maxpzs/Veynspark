import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

import '../engine/bento_layout.dart';
import '../models/challenge.dart';
import '../theme/theme.dart';
import 'bento_tile.dart';

/// La grille du bento. Remplit toute la hauteur disponible.
///
/// La surface de chaque tuile suit la durée du défi, et la disposition change
/// chaque jour, avec toujours une tuile à objectif en haut : voir
/// [BentoLayout].
///
/// Quand un défi disparaît de [tiles], la grille joue le
/// nettoyage : la tuile s'enfonce, [onTileImpact] est appelé, elle quitte la
/// grille, et les autres se recomposent avec le ressort
/// [GlynaMotion.gridSpring].
class BentoGrid extends StatefulWidget {
  const BentoGrid({
    super.key,
    required this.day,
    required this.dayTiles,
    required this.tiles,
    required this.onTileTap,
    required this.onTileImpact,
    required this.empty,
  });

  /// Le jour de la grille : il décide de la disposition.
  final DateTime day;

  /// Toute la grille du jour, tuiles déjà nettoyées comprises.
  final List<Challenge> dayTiles;

  /// Les tuiles encore dans la grille.
  final List<Challenge> tiles;

  final ValueChanged<Challenge> onTileTap;

  /// La tuile nettoyée a fini de s'enfoncer : le moment du son et de la
  /// vibration.
  final ValueChanged<Challenge> onTileImpact;

  /// Affiché quand la dernière tuile a quitté la grille.
  final Widget empty;

  @override
  State<BentoGrid> createState() => _BentoGridState();
}

class _BentoGridState extends State<BentoGrid> with TickerProviderStateMixin {
  /// Tuiles disposées dans la grille, y compris celles qui s'enfoncent.
  late List<Challenge> _tiles = [...widget.tiles];
  late BentoLayout _layout = _layoutFor(widget);

  final Map<String, AnimationController> _presses = {};
  final Map<String, _ExitingTile> _exits = {};

  /// Recomposition : chaque tuile va de [_from] à sa place cible. Non borné
  /// pour laisser le ressort dépasser.
  late final AnimationController _spring;
  Map<String, Rect> _from = const {};

  Size _size = Size.zero;

  Iterable<Challenge> get _laidOut => _tiles;

  static BentoLayout _layoutFor(BentoGrid grid) => BentoLayout(
    day: [
      for (final c in grid.dayTiles)
        BentoSlot(
          id: c.id,
          weight: _weight(c.estimatedDuration),
          isGoal: c.kind == ChallengeKind.goal,
        ),
    ],
    seed: BentoLayout.seedFor(grid.day),
    gap: GlynaSpacing.bentoGap,
    minSide: GlynaShape.bentoMinTileSide,
    maxAspect: GlynaShape.bentoMaxTileAspect,
  );

  /// La surface suit la durée, entre [GlynaShape.bentoShortestTile] et
  /// [GlynaShape.bentoLongestTile].
  static double _weight(Duration duration) => duration.inSeconds
      .clamp(
        GlynaShape.bentoShortestTile.inSeconds,
        GlynaShape.bentoLongestTile.inSeconds,
      )
      .toDouble();

  void _tick() => setState(() {});

  @override
  void initState() {
    super.initState();
    _spring = AnimationController.unbounded(vsync: this, value: 1)
      ..addListener(_tick);
  }

  @override
  void didUpdateWidget(BentoGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    final incoming = {for (final c in widget.tiles) c.id};
    final shown = {for (final c in _laidOut) c.id};

    if (widget.day != oldWidget.day ||
        incoming.any((id) => !shown.contains(id))) {
      _resetTo(widget);
      return;
    }
    for (final challenge in _laidOut.toList()) {
      final id = challenge.id;
      if (!incoming.contains(id) && !_presses.containsKey(id)) {
        _press(challenge);
      }
    }
  }

  /// Une nouvelle grille arrive (nouveau jour, démo rejouée) : pas d'animation.
  void _resetTo(BentoGrid grid) {
    for (final press in _presses.values) {
      press.dispose();
    }
    for (final exit in _exits.values) {
      exit.controller.dispose();
    }
    _presses.clear();
    _exits.clear();
    _spring.value = 1;
    _from = const {};
    _tiles = [...grid.tiles];
    _layout = _layoutFor(grid);
  }

  void _press(Challenge challenge) {
    _presses[challenge.id] =
        AnimationController(vsync: this, duration: GlynaMotion.tilePress)
          ..addListener(_tick)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) _leave(challenge);
          })
          ..forward();
  }

  void _leave(Challenge challenge) {
    final id = challenge.id;
    _presses.remove(id)?.dispose();

    final current = _currentRects();
    widget.onTileImpact(challenge);

    final exit =
        AnimationController(vsync: this, duration: GlynaMotion.tileExit)
          ..addListener(_tick)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              setState(() => _exits.remove(id)?.controller.dispose());
            }
          });
    _exits[id] = _ExitingTile(challenge, current[id]!, exit);

    setState(() {
      _from = current;
      _tiles.removeWhere((c) => c.id == id);
    });
    exit.forward();
    _spring.animateWith(SpringSimulation(GlynaMotion.gridSpring, 0, 1, 0));
  }

  /// Place de chaque tuile à cet instant de la recomposition.
  Map<String, Rect> _currentRects() {
    final target = _layout.place({for (final c in _tiles) c.id}, _size);
    return {
      for (final MapEntry(key: id, value: rect) in target.entries)
        id: switch (_from[id]) {
          final from? => Rect.lerp(from, rect, _spring.value)!,
          null => rect,
        },
    };
  }

  double _pressScale(String id) {
    final press = _presses[id];
    if (press == null) return 1;
    final t = GlynaMotion.standard.transform(press.value);
    return 1 + (GlynaMotion.tilePressScale - 1) * t;
  }

  @override
  void dispose() {
    for (final press in _presses.values) {
      press.dispose();
    }
    for (final exit in _exits.values) {
      exit.controller.dispose();
    }
    _spring.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _size = constraints.biggest;
        if (_tiles.isEmpty && _exits.isEmpty) {
          return widget.empty;
        }
        final rects = _currentRects();
        return Stack(
          children: [
            for (final challenge in _laidOut)
              Positioned.fromRect(
                key: ValueKey(challenge.id),
                rect: rects[challenge.id]!,
                child: Transform.scale(
                  scale: _pressScale(challenge.id),
                  child: BentoTile(
                    challenge,
                    onTap: _presses.containsKey(challenge.id)
                        ? null
                        : () => widget.onTileTap(challenge),
                  ),
                ),
              ),
            // Par-dessus les autres : la tuile nettoyée reste le centre de
            // l'attention jusqu'à ce qu'elle ait disparu.
            for (final exit in _exits.values)
              Positioned.fromRect(
                key: ValueKey('exit-${exit.challenge.id}'),
                rect: exit.rect,
                child: IgnorePointer(child: exit.build()),
              ),
          ],
        );
      },
    );
  }
}

class _ExitingTile {
  _ExitingTile(this.challenge, this.rect, this.controller);

  final Challenge challenge;
  final Rect rect;
  final AnimationController controller;

  Widget build() {
    final t = GlynaMotion.exit.transform(controller.value);
    final scale =
        GlynaMotion.tilePressScale +
        (GlynaMotion.tileExitScale - GlynaMotion.tilePressScale) * t;
    return Opacity(
      opacity: 1 - t,
      child: Transform.scale(scale: scale, child: BentoTile(challenge)),
    );
  }
}
