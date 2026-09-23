import 'package:flutter/foundation.dart';

import '../content/bento_content.dart';
import '../content/challenge_library.dart';
import '../engine/clock.dart';
import '../engine/goal_credit.dart';
import '../engine/goal_track.dart';
import '../engine/proposal_engine.dart';
import '../engine/week_calendar.dart';
import '../engine/week_service.dart';
import '../feedback/clean_cue.dart';
import '../models/challenge.dart';
import '../models/challenge_log.dart';
import '../models/goal.dart';
import 'glyna_repository.dart';
import 'success_progress.dart';

/// Le bento du jour : les défis encore dans la grille, et l'ordre dans lequel
/// les autres ont été nettoyés.
///
/// La grille est tirée par le moteur une seule fois par jour, puis gardée dans
/// le journal sous l'état « proposé ». Relancer l'app rend donc la même
/// grille, et les défis déjà réussis aujourd'hui n'y reviennent pas.
class BentoDay extends ChangeNotifier {
  BentoDay({
    required GlynaRepository repository,
    List<Challenge> library = ChallengeLibrary.all,
    Clock clock = const SystemClock(),
  }) : _repository = repository,
       _library = {for (final c in library) c.id: c},
       _engine = ProposalEngine(library: library),
       _clock = clock,
       _weeks = WeekService(clock: clock);

  final GlynaRepository _repository;
  final Map<String, Challenge> _library;
  final ProposalEngine _engine;
  final Clock _clock;
  final WeekService _weeks;

  DateTime? _date;
  List<Challenge> _dayTiles = const [];
  List<Challenge> _goals = [];
  List<Challenge> _opportunities = [];
  final List<String> _cleaned = [];

  /// Défis validés dont la réussite est déjà enregistrée, mais qui n'ont pas
  /// encore quitté la grille.
  final Set<String> _validated = {};
  bool _isLoaded = false;
  bool _isDisposed = false;

  /// L'objectif que fait avancer chaque défi à objectif de la grille.
  Map<String, Goal> _goalOf = const {};

  /// Faux tant que la grille du jour n'a pas été lue ou tirée.
  bool get isLoaded => _isLoaded;

  List<Challenge> get goals => List.unmodifiable(_goals);

  List<Challenge> get opportunities => List.unmodifiable(_opportunities);

  /// Le jour de la grille.
  DateTime? get date => _date;

  /// Toute la grille du jour, tuiles déjà nettoyées comprises, dans l'ordre
  /// du moteur.
  List<Challenge> get dayTiles => _dayTiles;

  /// Les tuiles encore dans la grille, dans l'ordre du moteur.
  List<Challenge> get tiles => [
    for (final c in _dayTiles)
      if (!_cleaned.contains(c.id)) c,
  ];

  /// Nombre de tuiles de la grille en début de journée.
  int get total => _dayTiles.length;

  bool get isCleared => _isLoaded && _goals.isEmpty && _opportunities.isEmpty;

  /// Lit la grille du jour, ou la fait tirer par le moteur si elle n'existe
  /// pas encore.
  Future<void> load() async {
    final now = _clock.now();
    final today = dateOnly(now);
    final tomorrow = DateTime(today.year, today.month, today.day + 1);

    final goals = await _repository.goals();
    final quotas = await _repository.weekQuotas(weekStartOf(now));
    final logs = await _repository.logsBefore(tomorrow);
    final todayLogs = [
      for (final log in logs)
        if (!log.date.isBefore(today)) log,
    ];

    final week = _weeks.progress(goals: goals, quotas: quotas, logs: logs);
    final tracks = [
      for (final goalWeek in week.goals)
        for (final goal in goals)
          if (goal.id == goalWeek.goalId)
            GoalTrack(goal: goal, domain: goal.domain, week: goalWeek),
    ];

    var grid = [
      for (final id in _idsWith(todayLogs, ChallengeStatus.proposed))
        ?_library[id],
    ];
    if (grid.isEmpty) {
      grid = _engine.propose(now: now, goals: tracks, logs: logs).all;
      await _repository.addLogs([
        for (final c in grid)
          ChallengeLog(
            challengeId: c.id,
            date: now,
            status: ChallengeStatus.proposed,
          ),
      ]);
    }

    final goalOf = <String, Goal>{};
    for (final (i, c) in grid.indexed) {
      final goal = creditedGoal(c, goals, week.weekStart);
      if (goal == null) continue;
      final goalWeek = week.goals.firstWhere((w) => w.goalId == goal.id);
      goalOf[c.id] = goal;
      grid[i] = c.copyWith(
        goalReminder: () => BentoContent.goalReminder(
          goal.title,
          goalWeek.done,
          goalWeek.target,
        ),
      );
    }

    final inGrid = {for (final c in grid) c.id};
    final cleaned = [
      for (final id in _idsWith(todayLogs, ChallengeStatus.succeeded))
        if (inGrid.contains(id)) id,
    ];

    if (_isDisposed) return;
    _goalOf = goalOf;
    _date = today;
    _dayTiles = List.unmodifiable(grid);
    _validated.clear();
    _cleaned
      ..clear()
      ..addAll(cleaned);
    _goals = [
      for (final c in grid)
        if (c.kind == ChallengeKind.goal && !cleaned.contains(c.id)) c,
    ];
    _opportunities = [
      for (final c in grid)
        if (c.kind == ChallengeKind.opportunity && !cleaned.contains(c.id)) c,
    ];
    _isLoaded = true;
    notifyListeners();
  }

  /// Le défi est lancé.
  Future<void> accept(Challenge challenge) =>
      _log(challenge, ChallengeStatus.accepted);

  /// Le défi est arrêté en cours. Il reste dans la grille, sans conséquence.
  Future<void> abandon(Challenge challenge) =>
      _log(challenge, ChallengeStatus.abandoned);

  /// Le défi est validé : la réussite est enregistrée tout de suite, et le
  /// quota de son objectif avance. La tuile, elle, ne quitte la grille qu'au
  /// [clean], quand la personne revient au bento.
  Future<SuccessProgress> validate(Challenge challenge) async {
    if (_validated.add(challenge.id)) await _recordSuccess(challenge);
    final weekStart = _weeks.currentWeekStart;
    final logs = await _repository.logsBetween(
      weekStart,
      nextWeekStart(weekStart),
    );
    final goal = _goalOf[challenge.id];
    final quota = goal == null
        ? null
        : await _repository.weekQuota(goal.id, weekStart);
    return SuccessProgress(
      weekSucceeded: logs
          .where((l) => l.status == ChallengeStatus.succeeded)
          .length,
      goal: goal == null || quota == null
          ? null
          : GoalProgress(
              title: goal.title,
              done: quota.done,
              target: quota.target,
            ),
    );
  }

  /// Retire le défi de la grille tout de suite. S'il n'a pas été validé
  /// avant, enregistre aussi la réussite.
  Future<void> clean(Challenge challenge) async {
    final removed =
        _goals.remove(challenge) || _opportunities.remove(challenge);
    if (!removed) return;
    _cleaned.add(challenge.id);
    notifyListeners();
    if (!_validated.remove(challenge.id)) await _recordSuccess(challenge);
  }

  Future<void> _recordSuccess(Challenge challenge) {
    final goal = _goalOf[challenge.id];
    return _repository.addSuccess(
      ChallengeLog(
        challengeId: challenge.id,
        date: _clock.now(),
        status: ChallengeStatus.succeeded,
      ),
      quota: goal == null ? null : _weeks.quotaFor(goal),
    );
  }

  Future<void> _log(Challenge challenge, ChallengeStatus status) =>
      _repository.addLog(
        ChallengeLog(
          challengeId: challenge.id,
          date: _clock.now(),
          status: status,
        ),
      );

  /// Le son d'un défi nettoyé, selon sa place dans l'ordre de nettoyage.
  CleanCue cueFor(Challenge challenge) =>
      CleanCue.forClean(index: _cleaned.indexOf(challenge.id), total: total);

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// Les défis qui ont reçu [status], sans doublon, dans l'ordre du journal.
  static List<String> _idsWith(
    List<ChallengeLog> logs,
    ChallengeStatus status,
  ) => {
    for (final log in logs)
      if (log.status == status) log.challengeId,
  }.toList();
}
