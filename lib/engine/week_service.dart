import '../models/challenge_log.dart';
import '../models/goal.dart';
import '../models/week_quota.dart';
import 'goal_week.dart';
import 'week_calendar.dart';
import 'week_progress.dart';
import 'week_review.dart';
import 'weekly_quota_rule.dart';

/// Heure du dimanche à partir de laquelle la semaine peut être close.
const int weekClosingHour = 18;

/// La logique de la semaine : quotas, état de la semaine en cours et bilan du
/// dimanche. Les déplacements de défis vivent dans `WeekPlan`.
///
/// Ne connaît pas la base : on lui passe les objectifs, les quotas et le
/// journal, elle rend des chiffres.
class WeekService {
  WeekService({DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;

  /// Le lundi de la semaine en cours.
  DateTime get currentWeekStart => weekStartOf(_clock());

  /// Le quota de [goal] pour la semaine qui commence à [weekStart], ou pour la
  /// semaine en cours.
  WeekQuota quotaFor(Goal goal, {DateTime? weekStart}) {
    final start = weekStart ?? currentWeekStart;
    return WeekQuota(
      goalId: goal.id,
      weekStart: start,
      target: weeklyQuotaFor(goal, start),
    );
  }

  /// Où en est la semaine en cours. Un objectif sans quota enregistré pour la
  /// semaine reçoit celui de la règle, avec zéro réussite.
  WeekProgress progress({
    required List<Goal> goals,
    required List<WeekQuota> quotas,
    required List<ChallengeLog> logs,
  }) {
    final now = _clock();
    final start = weekStartOf(now);
    return WeekProgress(
      weekStart: start,
      daysLeft: 7 - daysBetween(start, now),
      goals: _goalWeeks(start, goals, quotas),
      succeeded: _succeeded(start, logs).length,
    );
  }

  /// Vrai à partir du dimanche [weekClosingHour] h de la semaine qui commence
  /// à [weekStart], et pour toute semaine déjà passée.
  bool canClose(DateTime weekStart) {
    final sunday = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day + 6,
      weekClosingHour,
    );
    return !_clock().isBefore(sunday);
  }

  /// Ferme la semaine qui commence à [weekStart] et produit son bilan, avec
  /// les quotas de la semaine suivante.
  WeekReview close({
    required DateTime weekStart,
    required List<Goal> goals,
    required List<WeekQuota> quotas,
    required List<ChallengeLog> logs,
  }) {
    if (!canClose(weekStart)) {
      throw StateError('La semaine se ferme le dimanche soir, pas avant.');
    }
    final next = nextWeekStart(weekStart);
    return WeekReview(
      weekStart: weekStart,
      succeeded: _succeeded(weekStart, logs),
      goals: _goalWeeks(weekStart, goals, quotas),
      nextWeek: [
        for (final goal in goals)
          if (weeksLeft(next, goal.deadline) > 0)
            quotaFor(goal, weekStart: next),
      ],
    );
  }

  List<GoalWeek> _goalWeeks(
    DateTime weekStart,
    List<Goal> goals,
    List<WeekQuota> quotas,
  ) => [
    for (final goal in goals)
      if (weeksLeft(weekStart, goal.deadline) > 0)
        _goalWeek(
          goal,
          weekStart,
          quotas
                  .where((q) => q.goalId == goal.id && q.weekStart == weekStart)
                  .firstOrNull ??
              quotaFor(goal, weekStart: weekStart),
        ),
  ];

  GoalWeek _goalWeek(Goal goal, DateTime weekStart, WeekQuota quota) =>
      GoalWeek(
        goalId: goal.id,
        title: goal.title,
        target: quota.target,
        done: quota.done,
        weeksLeft: weeksLeft(weekStart, goal.deadline),
      );

  List<String> _succeeded(DateTime weekStart, List<ChallengeLog> logs) => [
    for (final log in logs)
      if (log.status == ChallengeStatus.succeeded &&
          isInWeek(log.date, weekStart))
        log.challengeId,
  ];
}
