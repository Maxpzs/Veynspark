import '../content/challenge_library.dart';
import '../content/debug_content.dart';
import '../engine/clock.dart';
import '../engine/goal_credit.dart';
import '../engine/week_calendar.dart';
import '../engine/week_progress.dart';
import '../engine/week_review.dart';
import '../engine/week_service.dart';
import '../models/challenge.dart';
import '../models/challenge_log.dart';
import '../models/goal.dart';
import '../store/glyna_repository.dart';
import 'debug_lock_detector.dart';

/// Heure à laquelle sont datés les résultats d'exemple.
const int sampleResultHour = 18;

/// Échéance de l'objectif d'exemple, en semaines.
const int sampleGoalWeeks = 24;

/// Ce que le panneau de débogage montre de la semaine en cours.
class DebugWeek {
  const DebugWeek({
    required this.now,
    required this.daysAhead,
    required this.progress,
    required this.review,
  });

  /// L'heure qu'il est pour l'app.
  final DateTime now;

  /// Jours d'avance de l'horloge sur l'heure réelle.
  final int daysAhead;

  final WeekProgress progress;

  /// Le bilan du dimanche, dès que la semaine peut être close.
  final WeekReview? review;
}

/// Les actions du panneau de débogage. Réservé au mode debug : `main.dart` ne
/// le crée jamais en production.
class DebugTools {
  DebugTools({
    required GlynaRepository repository,
    required OffsetClock clock,
    required this.lock,
    List<Challenge> library = ChallengeLibrary.all,
  }) : _repository = repository,
       _clock = clock,
       _library = library,
       _weeks = WeekService(clock: clock);

  final GlynaRepository _repository;
  final OffsetClock _clock;
  final List<Challenge> _library;
  final WeekService _weeks;

  /// Le verrouillage simulé, pour les défis à minuteur.
  final DebugLockDetector lock;

  /// Efface tout le journal d'aujourd'hui, défis nettoyés compris, et
  /// recompte les quotas de la semaine. Le bento tirera une grille neuve.
  Future<void> resetDay() async {
    final today = dateOnly(_clock.now());
    await _repository.deleteLogsBetween(
      today,
      DateTime(today.year, today.month, today.day + 1),
    );
    await _recount(weekStartOf(today));
  }

  /// Repart de zéro : la base est vidée, objectifs compris. L'horloge garde
  /// son avance.
  Future<void> resetAll() => _repository.clear();

  void advanceDay() => _clock.advance(days: 1);

  void advanceWeek() => _clock.advance(days: DateTime.daysPerWeek);

  /// Revient à l'heure réelle. Le journal écrit dans le futur reste.
  void backToPresent() => _clock.reset();

  /// Remplit les jours déjà passés de la semaine avec des réussites
  /// d'exemple : un défi d'opportunité par jour, et un jour sur deux un défi
  /// à objectif. Crée un objectif d'exemple s'il n'y en a aucun d'ouvert.
  ///
  /// Un jour qui a déjà des entrées au journal n'est pas touché : relancer ne
  /// double rien. Rend le nombre de réussites ajoutées.
  Future<int> fillWeek() async {
    final now = _clock.now();
    final weekStart = weekStartOf(now);
    final next = nextWeekStart(weekStart);

    var goals = await _repository.goals();
    var open = [
      for (final goal in goals)
        if (weeksLeft(weekStart, goal.deadline) > 0) goal,
    ];
    if (open.isEmpty) {
      final today = dateOnly(now);
      final sample = Goal(
        id: DebugContent.sampleGoalId,
        title: DebugContent.sampleGoalTitle,
        domain: ChallengeDomain.move,
        deadline: DateTime(
          today.year,
          today.month,
          today.day + sampleGoalWeeks * DateTime.daysPerWeek,
        ),
        startingLevel: 1,
        weeklyQuota: 3,
      );
      await _repository.saveGoal(sample);
      goals = [...goals, sample];
      open = [sample];
    }

    final weekLogs = await _repository.logsBetween(weekStart, next);
    final used = {for (final log in weekLogs) log.challengeId};
    final busyDays = {for (final log in weekLogs) dateOnly(log.date)};
    Challenge? take(bool Function(Challenge) test) {
      final pick = _library.where((c) => !used.contains(c.id) && test(c));
      final challenge = pick.firstOrNull;
      if (challenge != null) used.add(challenge.id);
      return challenge;
    }

    final logs = <ChallengeLog>[];
    final pastDays = daysBetween(weekStart, now);
    for (var i = 0; i < pastDays; i++) {
      final day = DateTime(weekStart.year, weekStart.month, weekStart.day + i);
      if (busyDays.contains(day)) continue;
      final at = DateTime(day.year, day.month, day.day, sampleResultHour);
      final goal = open[i ~/ 2 % open.length];
      final picks = [
        if (i.isEven)
          take(
            (c) =>
                c.kind == ChallengeKind.goal &&
                creditedGoal(c, goals, weekStart) == goal,
          ),
        take(
          (c) =>
              c.kind == ChallengeKind.opportunity &&
              c.domain ==
                  ChallengeDomain.values[i % ChallengeDomain.values.length],
        ),
      ];
      for (final challenge in picks.nonNulls) {
        logs
          ..add(
            ChallengeLog(
              challengeId: challenge.id,
              date: at,
              status: ChallengeStatus.proposed,
            ),
          )
          ..add(
            ChallengeLog(
              challengeId: challenge.id,
              date: at,
              status: ChallengeStatus.succeeded,
            ),
          );
      }
    }

    await _repository.addLogs(logs);
    await _recount(weekStart);
    return logs.where((l) => l.status == ChallengeStatus.succeeded).length;
  }

  /// La semaine en cours, et son bilan s'il est disponible.
  Future<DebugWeek> week() async {
    final weekStart = _weeks.currentWeekStart;
    final goals = await _repository.goals();
    final quotas = await _repository.weekQuotas(weekStart);
    final logs = await _repository.logsBetween(
      weekStart,
      nextWeekStart(weekStart),
    );
    return DebugWeek(
      now: _clock.now(),
      daysAhead: _clock.days,
      progress: _weeks.progress(goals: goals, quotas: quotas, logs: logs),
      review: _weeks.canClose(weekStart)
          ? _weeks.close(
              weekStart: weekStart,
              goals: goals,
              quotas: quotas,
              logs: logs,
            )
          : null,
    );
  }

  /// Remet les quotas de la semaine d'accord avec le journal.
  Future<void> _recount(DateTime weekStart) async {
    final quotas = _weeks.recount(
      weekStart: weekStart,
      goals: await _repository.goals(),
      quotas: await _repository.weekQuotas(weekStart),
      logs: await _repository.logsBetween(weekStart, nextWeekStart(weekStart)),
      library: _library,
    );
    for (final quota in quotas) {
      await _repository.saveWeekQuota(quota);
    }
  }
}
