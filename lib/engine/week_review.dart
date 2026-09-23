import '../models/week_quota.dart';
import 'goal_week.dart';

/// Le bilan du dimanche : des chiffres, rien d'autre. Une semaine à zéro se lit
/// exactement comme les autres.
class WeekReview {
  WeekReview({
    required this.weekStart,
    required List<String> succeeded,
    required List<GoalWeek> goals,
    required List<WeekQuota> nextWeek,
  }) : succeeded = List.unmodifiable(succeeded),
       goals = List.unmodifiable(goals),
       nextWeek = List.unmodifiable(nextWeek);

  /// Le lundi de la semaine close.
  final DateTime weekStart;

  /// Les défis réussis dans la semaine, dans l'ordre où ils l'ont été.
  final List<String> succeeded;

  /// Quota atteint ou non, et avancement vers chaque objectif.
  final List<GoalWeek> goals;

  /// Les quotas de la semaine qui s'ouvre, pour les objectifs encore ouverts.
  final List<WeekQuota> nextWeek;
}
