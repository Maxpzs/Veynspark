import 'package:drift/drift.dart';

import '../analytics/analytics_event.dart';
import '../models/challenge_log.dart';
import '../models/goal.dart';
import '../models/week_quota.dart';
import 'local/glyna_database.dart';

/// Lecture et écriture des données de la personne. N'expose que des modèles :
/// la base et ses lignes restent un détail d'implémentation.
class GlynaRepository {
  GlynaRepository(this._db);

  /// Ouvre la base stockée sur l'appareil.
  factory GlynaRepository.onDevice() =>
      GlynaRepository(GlynaDatabase.onDevice());

  final GlynaDatabase _db;

  Future<void> close() => _db.close();

  // Objectifs

  /// Crée l'objectif, ou le remplace s'il existe déjà.
  Future<void> saveGoal(Goal goal) => _db
      .into(_db.goals)
      .insertOnConflictUpdate(
        GoalsCompanion.insert(
          id: goal.id,
          title: goal.title,
          domain: goal.domain,
          deadline: goal.deadline,
          startingLevel: goal.startingLevel,
          weeklyQuota: goal.weeklyQuota,
        ),
      );

  Future<Goal?> goal(String id) async {
    final row = await (_db.select(
      _db.goals,
    )..where((g) => g.id.equals(id))).getSingleOrNull();
    return row == null ? null : _goalFromRow(row);
  }

  /// Les objectifs, du plus proche de son échéance au plus lointain.
  Future<List<Goal>> goals() async {
    final rows = await (_db.select(
      _db.goals,
    )..orderBy([(g) => OrderingTerm.asc(g.deadline)])).get();
    return rows.map(_goalFromRow).toList();
  }

  /// Abandonne un objectif, sans cérémonie. Ses quotas partent avec lui ; le
  /// journal des défis, lui, reste.
  Future<void> deleteGoal(String id) =>
      (_db.delete(_db.goals)..where((g) => g.id.equals(id))).go();

  // Quotas hebdomadaires

  /// Crée le quota de la semaine, ou le remplace s'il existe déjà.
  Future<void> saveWeekQuota(WeekQuota quota) => _db
      .into(_db.weekQuotas)
      .insertOnConflictUpdate(
        WeekQuotasCompanion.insert(
          goalId: quota.goalId,
          weekStart: quota.weekStart,
          target: quota.target,
          done: Value(quota.done),
        ),
      );

  Future<WeekQuota?> weekQuota(String goalId, DateTime weekStart) async {
    final row =
        await (_db.select(_db.weekQuotas)..where(
              (q) => q.goalId.equals(goalId) & q.weekStart.equals(weekStart),
            ))
            .getSingleOrNull();
    return row == null ? null : _quotaFromRow(row);
  }

  /// Les quotas de tous les objectifs pour la semaine qui commence à
  /// [weekStart].
  Future<List<WeekQuota>> weekQuotas(DateTime weekStart) async {
    final rows = await (_db.select(
      _db.weekQuotas,
    )..where((q) => q.weekStart.equals(weekStart))).get();
    return rows.map(_quotaFromRow).toList();
  }

  // Journal des défis

  Future<void> addLog(ChallengeLog log) =>
      _db.into(_db.challengeLogs).insert(_logCompanion(log));

  /// Écrit toutes les entrées, dans l'ordre, ou aucune.
  Future<void> addLogs(List<ChallengeLog> logs) => _db.batch(
    (batch) =>
        batch.insertAll(_db.challengeLogs, logs.map(_logCompanion).toList()),
  );

  /// Enregistre une réussite et, si elle fait avancer un objectif, compte un
  /// défi de plus dans son quota de la semaine. Les deux, ou rien.
  ///
  /// [quota] est le quota tel qu'il serait créé s'il n'existe pas encore en
  /// base ; son compteur `done` est ignoré s'il existe déjà.
  Future<void> addSuccess(ChallengeLog log, {WeekQuota? quota}) {
    assert(
      log.status == ChallengeStatus.succeeded,
      'Une réussite, pas autre chose.',
    );
    return _db.transaction(() async {
      await addLog(log);
      if (quota == null) return;
      final current = await weekQuota(quota.goalId, quota.weekStart) ?? quota;
      await saveWeekQuota(current.copyWith(done: current.done + 1));
    });
  }

  /// Les entrées datées de [from] inclus à [to] exclu, dans l'ordre où elles
  /// ont été écrites.
  Future<List<ChallengeLog>> logsBetween(DateTime from, DateTime to) async {
    final rows =
        await (_db.select(_db.challengeLogs)
              ..where(
                (l) =>
                    l.date.isBiggerOrEqualValue(from) &
                    l.date.isSmallerThanValue(to),
              )
              ..orderBy([
                (l) => OrderingTerm.asc(l.date),
                (l) => OrderingTerm.asc(l.id),
              ]))
            .get();
    return rows.map(_logFromRow).toList();
  }

  /// Tout le journal jusqu'à [to] exclu, dans l'ordre où il a été écrit.
  Future<List<ChallengeLog>> logsBefore(DateTime to) async {
    final rows =
        await (_db.select(_db.challengeLogs)
              ..where((l) => l.date.isSmallerThanValue(to))
              ..orderBy([
                (l) => OrderingTerm.asc(l.date),
                (l) => OrderingTerm.asc(l.id),
              ]))
            .get();
    return rows.map(_logFromRow).toList();
  }

  /// Efface les entrées datées de [from] inclus à [to] exclu. Réservé au
  /// panneau de débogage : en usage normal, le journal ne fait que grandir.
  Future<void> deleteLogsBetween(DateTime from, DateTime to) =>
      (_db.delete(_db.challengeLogs)..where(
            (l) =>
                l.date.isBiggerOrEqualValue(from) &
                l.date.isSmallerThanValue(to),
          ))
          .go();

  /// Tout l'historique d'un défi, du plus ancien au plus récent.
  Future<List<ChallengeLog>> logsFor(String challengeId) async {
    final rows =
        await (_db.select(_db.challengeLogs)
              ..where((l) => l.challengeId.equals(challengeId))
              ..orderBy([
                (l) => OrderingTerm.asc(l.date),
                (l) => OrderingTerm.asc(l.id),
              ]))
            .get();
    return rows.map(_logFromRow).toList();
  }

  // Mesure

  Future<void> addEvent(AnalyticsEvent event) => _db
      .into(_db.analyticsEvents)
      .insert(
        AnalyticsEventsCompanion.insert(
          type: event.type,
          at: event.at,
          challengeId: Value(event.challengeId),
          onboardingStep: Value(event.onboardingStep),
          feedPostId: Value(event.feedPostId),
        ),
      );

  /// Les événements datés de [from] inclus à [to] exclu, dans l'ordre où ils
  /// ont été écrits.
  Future<List<AnalyticsEvent>> eventsBetween(DateTime from, DateTime to) async {
    final rows =
        await (_db.select(_db.analyticsEvents)
              ..where(
                (e) =>
                    e.at.isBiggerOrEqualValue(from) &
                    e.at.isSmallerThanValue(to),
              )
              ..orderBy([
                (e) => OrderingTerm.asc(e.at),
                (e) => OrderingTerm.asc(e.id),
              ]))
            .get();
    return rows.map(_eventFromRow).toList();
  }

  // Remise à zéro

  /// Efface tout : objectifs, quotas, journal et mesure. La base repart comme
  /// au premier lancement.
  Future<void> clear() => _db.transaction(() async {
    for (final table in _db.allTables) {
      await _db.delete(table).go();
    }
  });

  static ChallengeLogsCompanion _logCompanion(ChallengeLog log) =>
      ChallengeLogsCompanion.insert(
        challengeId: log.challengeId,
        date: log.date,
        status: log.status,
        postponeReason: Value(log.postponeReason),
      );

  static Goal _goalFromRow(GoalRow row) => Goal(
    id: row.id,
    title: row.title,
    domain: row.domain,
    deadline: row.deadline,
    startingLevel: row.startingLevel,
    weeklyQuota: row.weeklyQuota,
  );

  static WeekQuota _quotaFromRow(WeekQuotaRow row) => WeekQuota(
    goalId: row.goalId,
    weekStart: row.weekStart,
    target: row.target,
    done: row.done,
  );

  static ChallengeLog _logFromRow(ChallengeLogRow row) => ChallengeLog(
    challengeId: row.challengeId,
    date: row.date,
    status: row.status,
    postponeReason: row.postponeReason,
  );

  static AnalyticsEvent _eventFromRow(AnalyticsEventRow row) => AnalyticsEvent(
    type: row.type,
    at: row.at,
    challengeId: row.challengeId,
    onboardingStep: row.onboardingStep,
    feedPostId: row.feedPostId,
  );
}
