import 'package:flutter/material.dart';

import '../../content/challenge_run_content.dart';
import '../../store/success_progress.dart';
import '../../theme/theme.dart';

/// La réussite : le seul endroit où l'app se lâche. Le rose prend tout
/// l'écran, une phrase avec du caractère, puis ce que ça fait avancer.
///
/// Une seule animation : l'écran s'ouvre en grandissant.
class SuccessView extends StatelessWidget {
  const SuccessView({
    super.key,
    required this.challengeId,
    required this.progress,
    required this.onDone,
  });

  final String challengeId;

  /// Nul tant que la réussite s'enregistre.
  final SuccessProgress? progress;

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final colors = GlynaColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final onAccent = colors.background;
    final progress = this.progress;
    final line = switch (progress) {
      null => null,
      SuccessProgress(goal: final goal?) => ChallengeRunContent.goalProgress(
        goal.title,
        goal.done,
        goal.target,
      ),
      SuccessProgress(:final weekSucceeded) => ChallengeRunContent.weekProgress(
        weekSucceeded,
      ),
    };

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: GlynaMotion.slow,
      curve: GlynaMotion.standard,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.scale(
          scale:
              GlynaMotion.successStartScale +
              (1 - GlynaMotion.successStartScale) * t,
          child: child,
        ),
      ),
      child: ColoredBox(
        color: colors.accent,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(GlynaSpacing.screenGutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Text(
                  ChallengeRunContent.successPhrase(challengeId),
                  style: textTheme.displayMedium?.copyWith(color: onAccent),
                ),
                const SizedBox(height: GlynaSpacing.lg),
                // La ligne garde sa place pendant l'enregistrement : rien ne
                // saute quand elle arrive.
                Text(
                  line ?? '',
                  style: textTheme.titleMedium?.copyWith(color: onAccent),
                ),
                const Spacer(),
                SizedBox(
                  height: GlynaSpacing.minTouchTarget,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: onAccent,
                      foregroundColor: colors.text,
                    ),
                    onPressed: onDone,
                    child: Text(
                      ChallengeRunContent.done,
                      style: textTheme.labelLarge,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
