import 'package:flutter/foundation.dart';

import 'week_calendar.dart';

/// Pourquoi un déplacement a été refusé.
enum MoveRefusal {
  /// Le jour visé est hors de la semaine. Un défi ne sort jamais de sa semaine.
  outsideWeek,

  /// Le défi n'est pas posé dans cette semaine.
  notPlanned,
}

/// Résultat d'une demande de déplacement.
sealed class MoveOutcome {
  const MoveOutcome();
}

class Moved extends MoveOutcome {
  const Moved(this.plan);

  final WeekPlan plan;
}

class MoveRefused extends MoveOutcome {
  const MoveRefused(this.reason);

  final MoveRefusal reason;
}

/// Les défis posés sur les sept jours d'une semaine. Un défi y apparaît une
/// seule fois : le moteur ne propose jamais deux fois le même dans la semaine.
@immutable
class WeekPlan {
  WeekPlan._(this.weekStart, Map<String, DateTime> days, Map<String, int> moves)
    : _days = Map.unmodifiable(days),
      _moves = Map.unmodifiable(moves);

  /// Une semaine vide, qui commence le lundi contenant [anyDay].
  WeekPlan.empty(DateTime anyDay) : this._(weekStartOf(anyDay), {}, {});

  /// Le lundi de la semaine.
  final DateTime weekStart;

  final Map<String, DateTime> _days;

  final Map<String, int> _moves;

  /// Le jour où [challengeId] est posé, ou `null` s'il n'est pas dans la
  /// semaine.
  DateTime? dayOf(String challengeId) => _days[challengeId];

  /// Les défis posés sur [day], dans l'ordre où ils ont été posés.
  List<String> challengesOn(DateTime day) {
    final target = dateOnly(day);
    return [
      for (final entry in _days.entries)
        if (entry.value == target) entry.key,
    ];
  }

  /// Nombre de fois où [challengeId] a changé de jour cette semaine.
  int movesOf(String challengeId) => _moves[challengeId] ?? 0;

  /// Pose [challengeId] sur [day]. Réservé au moteur, qui ne pose jamais un
  /// défi hors de la semaine ni deux fois.
  WeekPlan place(String challengeId, DateTime day) {
    final target = dateOnly(day);
    if (!isInWeek(target, weekStart)) {
      throw ArgumentError.value(day, 'day', 'hors de la semaine');
    }
    if (_days.containsKey(challengeId)) {
      throw ArgumentError.value(challengeId, 'challengeId', 'déjà posé');
    }
    return WeekPlan._(weekStart, {..._days, challengeId: target}, _moves);
  }

  /// Déplace [challengeId] sur [to], autant de fois qu'on veut, à l'intérieur
  /// de la semaine uniquement. Le reposer sur son propre jour ne compte pas
  /// comme un déplacement.
  MoveOutcome move(String challengeId, DateTime to) {
    final from = _days[challengeId];
    if (from == null) return const MoveRefused(MoveRefusal.notPlanned);
    final target = dateOnly(to);
    if (!isInWeek(target, weekStart)) {
      return const MoveRefused(MoveRefusal.outsideWeek);
    }
    if (target == from) return Moved(this);
    return Moved(
      WeekPlan._(
        weekStart,
        {..._days, challengeId: target},
        {..._moves, challengeId: movesOf(challengeId) + 1},
      ),
    );
  }

  /// Remplace [challengeId] par [replacementId], sur le même jour. Le
  /// remplaçant part sans aucun déplacement compté.
  WeekPlan replace(String challengeId, String replacementId) {
    final day = _days[challengeId];
    if (day == null) {
      throw ArgumentError.value(challengeId, 'challengeId', 'pas posé');
    }
    if (_days.containsKey(replacementId)) {
      throw ArgumentError.value(replacementId, 'replacementId', 'déjà posé');
    }
    return WeekPlan._(weekStart, {
      for (final entry in _days.entries)
        if (entry.key == challengeId)
          replacementId: day
        else
          entry.key: entry.value,
    }, {..._moves}..remove(challengeId));
  }

  @override
  bool operator ==(Object other) =>
      other is WeekPlan &&
      other.weekStart == weekStart &&
      mapEquals(other._days, _days) &&
      mapEquals(other._moves, _moves);

  @override
  int get hashCode => Object.hash(
    weekStart,
    Object.hashAllUnordered(_days.entries.map((e) => (e.key, e.value))),
    Object.hashAllUnordered(_moves.entries.map((e) => (e.key, e.value))),
  );
}
