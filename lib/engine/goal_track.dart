import '../models/challenge.dart';
import '../models/goal.dart';
import 'goal_week.dart';

/// Un objectif tel que le moteur de proposition le voit : l'objectif, le
/// domaine dont il tire ses défis, et où en est sa semaine.
class GoalTrack {
  const GoalTrack({
    required this.goal,
    required this.domain,
    required this.week,
  });

  final Goal goal;

  /// Domaine des défis à objectif qui font avancer [goal].
  final ChallengeDomain domain;

  /// Quota et avancement de la semaine en cours, tels que rendus par
  /// `WeekService.progress`.
  final GoalWeek week;
}
