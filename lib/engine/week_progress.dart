import 'goal_week.dart';

/// Où en est la semaine en cours. Aucune notion de série : chaque semaine se
/// lit seule.
class WeekProgress {
  WeekProgress({
    required this.weekStart,
    required this.daysLeft,
    required List<GoalWeek> goals,
    required this.succeeded,
  }) : goals = List.unmodifiable(goals);

  /// Le lundi de la semaine.
  final DateTime weekStart;

  /// Jours restants, aujourd'hui compris : 7 le lundi, 1 le dimanche.
  final int daysLeft;

  /// Un quota par objectif en cours.
  final List<GoalWeek> goals;

  /// Nombre de défis réussis depuis lundi, objectifs et opportunités confondus.
  final int succeeded;
}
