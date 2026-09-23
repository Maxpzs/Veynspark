import 'package:flutter/material.dart';

import '../content/bento_content.dart';
import '../models/challenge.dart';
import '../theme/theme.dart';
import 'context_icon.dart';

/// Une tuile du bento. Remplit l'espace que la grille lui donne : sa taille
/// dit la durée du défi.
///
/// Tuile à objectif : bord violet et rappel de l'objectif. C'est la seule
/// différence avec une tuile d'opportunité.
class BentoTile extends StatelessWidget {
  const BentoTile(this.challenge, {super.key, this.onTap});

  final Challenge challenge;

  /// Nul pendant que la tuile quitte la grille.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = GlynaColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final isGoal = challenge.kind == ChallengeKind.goal;
    final reminder = challenge.goalReminder;

    return Semantics(
      button: onTap != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: _surface(colors, textTheme, isGoal, reminder),
      ),
    );
  }

  Widget _surface(
    GlynaColors colors,
    TextTheme textTheme,
    bool isGoal,
    String? reminder,
  ) {
    return Container(
      padding: const EdgeInsets.all(GlynaSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(GlynaShape.tileRadius),
        border: isGoal
            ? Border.all(color: colors.brand, width: GlynaShape.goalBorderWidth)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ContextIcon(challenge.context),
              const SizedBox(width: GlynaSpacing.xs),
              Expanded(
                child: Text(
                  BentoContent.duration(challenge.estimatedDuration),
                  style: textTheme.labelMedium,
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          // Dans une petite tuile, le titre cède de la place au lieu de
          // déborder.
          Expanded(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      challenge.title,
                      style: textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (reminder != null) ...[
                    const SizedBox(height: GlynaSpacing.xxs),
                    Text(
                      reminder,
                      style: textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
