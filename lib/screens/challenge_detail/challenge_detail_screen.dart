import 'package:flutter/material.dart';

import '../../content/challenge_detail_content.dart';
import '../../engine/week_calendar.dart';
import '../../models/challenge.dart';
import '../../store/challenge_detail.dart';
import '../../theme/theme.dart';
import '../../widgets/context_icon.dart';

/// Ce que la personne décide depuis le détail d'un défi. Fermer l'écran ne
/// décide rien.
sealed class ChallengeDetailChoice {
  const ChallengeDetailChoice();
}

/// Lancer le défi tout de suite.
final class DoNow extends ChallengeDetailChoice {
  const DoNow();
}

/// Reporter le défi sur [day], un autre jour de la semaine.
final class PostponeTo extends ChallengeDetailChoice {
  const PostponeTo(this.day);

  final DateTime day;
}

/// Le détail d'un défi, ouvert par un tap sur sa tuile : titre, durée,
/// contexte, et pour un défi à objectif son objectif et le quota de la
/// semaine.
///
/// Une seule action principale, « Faire maintenant ». Reporter est discret :
/// un lien, puis les jours restants de la semaine, sans confirmation ni
/// commentaire. Sans jour possible (le dimanche), le lien n'apparaît pas.
///
/// Rend un [ChallengeDetailChoice], ou `null` si l'écran est fermé.
class ChallengeDetailScreen extends StatefulWidget {
  const ChallengeDetailScreen({
    super.key,
    required this.challenge,
    required this.detail,
    required this.today,
  });

  final Challenge challenge;

  final ChallengeDetail detail;

  /// Pour nommer « Demain ».
  final DateTime today;

  @override
  State<ChallengeDetailScreen> createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends State<ChallengeDetailScreen> {
  /// Les jours où reporter sont affichés.
  bool _choosingDay = false;

  void _choose(ChallengeDetailChoice choice) =>
      Navigator.of(context).pop(choice);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = GlynaColors.of(context);
    final challenge = widget.challenge;
    final goal = widget.detail.goal;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(GlynaSpacing.screenGutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox.square(
                  dimension: GlynaSpacing.minTouchTarget,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: ChallengeDetailContent.close,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  ContextIcon(challenge.context),
                  const SizedBox(width: GlynaSpacing.xs),
                  Expanded(
                    child: Text(
                      ChallengeDetailContent.duration(challenge),
                      style: textTheme.labelLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: GlynaSpacing.md),
              Text(
                challenge.title.toUpperCase(),
                style: textTheme.displayMedium,
              ),
              if (goal != null) ...[
                const SizedBox(height: GlynaSpacing.lg),
                Text(
                  ChallengeDetailContent.goal(goal.title),
                  style: textTheme.titleMedium?.copyWith(color: colors.brand),
                ),
                const SizedBox(height: GlynaSpacing.xxs),
                Text(
                  ChallengeDetailContent.quota(goal.done, goal.target),
                  style: textTheme.bodyMedium,
                ),
              ],
              const Spacer(),
              SizedBox(
                height: GlynaSpacing.minTouchTarget,
                child: FilledButton(
                  onPressed: () => _choose(const DoNow()),
                  child: Text(
                    ChallengeDetailContent.doNow,
                    style: textTheme.labelLarge,
                  ),
                ),
              ),
              if (widget.detail.postponeDays.isNotEmpty) ...[
                const SizedBox(height: GlynaSpacing.xs),
                AnimatedSize(
                  duration: GlynaMotion.fast,
                  curve: GlynaMotion.standard,
                  alignment: Alignment.topCenter,
                  child: _choosingDay ? _days(textTheme) : _postpone(textTheme),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _postpone(TextTheme textTheme) => SizedBox(
    height: GlynaSpacing.minTouchTarget,
    child: TextButton(
      onPressed: () => setState(() => _choosingDay = true),
      child: Text(
        ChallengeDetailContent.postpone,
        style: textTheme.labelMedium,
      ),
    ),
  );

  Widget _days(TextTheme textTheme) {
    final today = dateOnly(widget.today);
    final tomorrow = DateTime(today.year, today.month, today.day + 1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: GlynaSpacing.xs),
        Text(
          ChallengeDetailContent.postponeQuestion,
          style: textTheme.labelMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: GlynaSpacing.xs),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: GlynaSpacing.xs,
          runSpacing: GlynaSpacing.xs,
          children: [
            for (final day in widget.detail.postponeDays)
              SizedBox(
                height: GlynaSpacing.minTouchTarget,
                child: OutlinedButton(
                  onPressed: () => _choose(PostponeTo(day)),
                  child: Text(
                    ChallengeDetailContent.day(
                      day,
                      isTomorrow: day == tomorrow,
                    ),
                    style: textTheme.labelMedium,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
