import '../models/challenge.dart';
import '../models/goal.dart';
import 'week_calendar.dart';

/// L'objectif que fait avancer [challenge] pendant la semaine qui commence à
/// [weekStart] : le premier objectif encore ouvert de son domaine, le plus
/// proche de son échéance.
///
/// `null` pour un défi d'opportunité, ou s'il n'y a aucun objectif ouvert dans
/// son domaine.
Goal? creditedGoal(Challenge challenge, List<Goal> goals, DateTime weekStart) {
  if (challenge.kind != ChallengeKind.goal) return null;
  final open = [
    for (final goal in goals)
      if (goal.domain == challenge.domain &&
          weeksLeft(weekStart, goal.deadline) > 0)
        goal,
  ]..sort((a, b) => a.deadline.compareTo(b.deadline));
  return open.firstOrNull;
}
