import '../models/challenge.dart';
import '../models/challenge_log.dart';
import '../models/goal.dart';
import '../models/week_quota.dart';
import 'clock.dart';
import 'goal_credit.dart';
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
  WeekService({Clock clock = const SystemClock()}) : _clock = clock;

  final Clock _clock;

  /// Le lundi de la semaine en cours.
  DateTime get currentWeekStart => weekStartOf(_clock.now());

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
    final now = _clock.now();
    final start = weekStartOf(now);
    return WeekProgress(
      weekStart: start,
      daysLeft: 7 - daysBetween(start, now),
      goals: _goalWeeks(start, goals, quotas),
      succeeded: _succeeded(start, logs).length,
    );
  }

  /// Les quotas de la semaine qui commence à [weekStart], recomptés à partir
  /// des réussites du journal. Un objectif ouvert sans quota enregistré
  /// reçoit celui de la règle.
  ///
  /// Sert à remettre les compteurs d'aplomb quand le journal a été retouché à
  /// la main. [library] permet de retrouver le défi de chaque entrée.
  List<WeekQuota> recount({
    required DateTime weekStart,
    required List<Goal> goals,
    required List<WeekQuota> quotas,
    required List<ChallengeLog> logs,
    required List<Challenge> library,
  }) {
    final byId = {for (final c in library) c.id: c};
    final done = <String, int>{};
    for (final id in _succeeded(weekStart, logs)) {
      final challenge = byId[id];
      if (challenge == null) continue;
      final goal = creditedGoal(challenge, goals, weekStart);
      if (goal == null) continue;
      done[goal.id] = (done[goal.id] ?? 0) + 1;
    }
    return [
      for (final goal in goals)
        if (weeksLeft(weekStart, goal.deadline) > 0)
          (quotas
                      .where(
                        (q) => q.goalId == goal.id && q.weekStart == weekStart,
                      )
                      .firstOrNull ??
                  quotaFor(goal, weekStart: weekStart))
              .copyWith(done: done[goal.id] ?? 0),
    ];
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
    return !_clock.now().isBefore(sunday);
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
