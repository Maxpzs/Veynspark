import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../content/bento_content.dart';
import '../../feedback/clean_feedback.dart';
import '../../models/challenge.dart';
import '../../store/bento_day.dart';
import '../../theme/theme.dart';
import '../../widgets/bento_grid.dart';

/// L'écran d'accueil : les défis proposés pour aujourd'hui.
///
/// Version statique : les défis viennent de [BentoContent], sans moteur.
///
/// La grille remplit l'écran. Sur un écran trop petit pour
/// [GlynaShape.bentoMinHeight], elle garde cette hauteur et l'écran défile.
class BentoScreen extends StatefulWidget {
  const BentoScreen({super.key});

  @override
  State<BentoScreen> createState() => _BentoScreenState();
}

class _BentoScreenState extends State<BentoScreen> {
  final BentoDay _day = BentoDay(
    goals: BentoContent.goalChallenges,
    opportunities: BentoContent.opportunityChallenges,
  );
  final CleanFeedback _feedback = const CleanFeedback();

  // TEMPORAIRE : le tap nettoie directement la tuile. Il ouvrira le détail du
  // défi quand l'écran existera ; le nettoyage viendra de la validation.
  void _onTileTap(Challenge challenge) {
    _feedback.tileTap();
    _day.clean(challenge);
  }

  void _onTileImpact(Challenge challenge) =>
      _feedback.tileCleaned(_day.cueFor(challenge));

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
                  Text(
                    BentoContent.title,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: GlynaSpacing.xl),
                  Expanded(
                    child: ListenableBuilder(
                      listenable: _day,
                      builder: (context, _) => BentoGrid(
                        goals: _day.goals,
                        opportunities: _day.opportunities,
                        onTileTap: _onTileTap,
                        onTileImpact: _onTileImpact,
                        empty: _Cleared(onReplay: _day.reset),
                      ),
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
  const _Cleared({required this.onReplay});

  final VoidCallback onReplay;

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
          // TEMPORAIRE : pour rejouer le nettoyage pendant la mise au point.
          SizedBox(
            height: GlynaSpacing.minTouchTarget,
            child: TextButton(
              onPressed: onReplay,
              child: Text(
                BentoContent.replayDemo,
                style: textTheme.labelMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
