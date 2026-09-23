import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../content/bento_content.dart';
import '../../debug/debug_panel.dart';
import '../../debug/debug_tools.dart';
import '../../engine/clock.dart';
import '../../feedback/clean_feedback.dart';
import '../../models/challenge.dart';
import '../../store/bento_day.dart';
import '../../store/glyna_repository.dart';
import '../../theme/theme.dart';
import '../../validation/lock_detector.dart';
import '../../validation/platform_lock_detector.dart';
import '../../widgets/bento_grid.dart';
import '../challenge_run/challenge_run_screen.dart';

/// L'écran d'accueil : les défis proposés pour aujourd'hui.
///
/// Les défis viennent du moteur, par [BentoDay] : la grille est tirée une
/// fois par jour et retrouvée telle quelle à chaque ouverture.
///
/// La grille remplit l'écran. Sur un écran trop petit pour
/// [GlynaShape.bentoMinHeight], elle garde cette hauteur et l'écran défile.
class BentoScreen extends StatefulWidget {
  const BentoScreen({
    super.key,
    required this.repository,
    this.clock = const SystemClock(),
    this.lockDetector = const PlatformLockDetector(),
    this.debugTools,
  });

  final GlynaRepository repository;

  final Clock clock;

  /// Pour les défis à minuteur.
  final LockDetector lockDetector;

  /// Le panneau de débogage, ouvert par un appui long sur le titre. Toujours
  /// nul en production.
  final DebugTools? debugTools;

  @override
  State<BentoScreen> createState() => _BentoScreenState();
}

class _BentoScreenState extends State<BentoScreen> {
  late final BentoDay _day = BentoDay(
    repository: widget.repository,
    clock: widget.clock,
  );
  final CleanFeedback _feedback = const CleanFeedback();

  /// Un défi est en cours : un second tap n'en lance pas un autre.
  bool _running = false;

  @override
  void initState() {
    super.initState();
    unawaited(_day.load());
  }

  // TEMPORAIRE : le tap lance directement le défi. Il ouvrira le détail du
  // défi, avec « Faire maintenant », quand cet écran existera.
  Future<void> _onTileTap(Challenge challenge) async {
    if (_running) return;
    _feedback.tileTap();
    final body = ChallengeRunScreen.bodyFor(
      challenge,
      clock: widget.clock,
      lockDetector: widget.lockDetector,
    );
    // TEMPORAIRE : les modes pas encore construits (sport, co-présence,
    // déclaratif) nettoient la tuile directement.
    if (body == null) {
      unawaited(_day.clean(challenge));
      return;
    }

    _feedback.challengeAccepted();
    unawaited(_day.accept(challenge));
    _running = true;
    final outcome = await Navigator.of(context).push(
      MaterialPageRoute<ChallengeRunOutcome>(
        fullscreenDialog: true,
        builder: (context) => ChallengeRunScreen(
          challenge: challenge,
          body: body,
          onValidated: () => _day.validate(challenge),
          onAbandoned: () => unawaited(_day.abandon(challenge)),
        ),
      ),
    );
    _running = false;
    // De retour au bento : la tuile validée le quitte sous les yeux.
    if (outcome == ChallengeRunOutcome.succeeded && mounted) {
      unawaited(_day.clean(challenge));
    }
  }

  void _onTileImpact(Challenge challenge) =>
      _feedback.tileCleaned(_day.cueFor(challenge));

  void _openDebugPanel(DebugTools tools) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => DebugPanel(tools: tools, onChanged: _day.load),
  );

  @override
  void dispose() {
    _day.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            // Pas de rebond quand tout tient à l'écran.
            primary: false,
            padding: const EdgeInsets.all(GlynaSpacing.screenGutter),
            child: SizedBox(
              height: math.max(
                constraints.maxHeight - 2 * GlynaSpacing.screenGutter,
                GlynaShape.bentoMinHeight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onLongPress: switch (widget.debugTools) {
                      final tools? when kDebugMode => () => _openDebugPanel(
                        tools,
                      ),
                      _ => null,
                    },
                    child: Text(
                      BentoContent.title,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ),
                  const SizedBox(height: GlynaSpacing.xl),
                  Expanded(
                    child: ListenableBuilder(
                      listenable: _day,
                      // Rien tant que la grille n'est pas lue : pas de
                      // « grille propre » affichée par erreur.
                      builder: (context, _) => _day.isLoaded
                          ? BentoGrid(
                              day: _day.date!,
                              dayTiles: _day.dayTiles,
                              tiles: _day.tiles,
                              onTileTap: _onTileTap,
                              onTileImpact: _onTileImpact,
                              empty: const _Cleared(),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// La grille est vide. Le rose est le seul de l'écran.
class _Cleared extends StatelessWidget {
  const _Cleared();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = GlynaColors.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: GlynaMotion.medium,
      curve: GlynaMotion.standard,
      builder: (context, opacity, child) =>
          Opacity(opacity: opacity, child: child),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Text(
            BentoContent.clearedTitle,
            style: textTheme.displayMedium?.copyWith(color: colors.accent),
          ),
          const SizedBox(height: GlynaSpacing.md),
          Text(BentoContent.clearedBody, style: textTheme.bodyLarge),
          const Spacer(),
        ],
      ),
    );
  }
}
