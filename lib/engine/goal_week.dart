/// Où en est un objectif sur une semaine : « Courir 2/3 ».
class GoalWeek {
  const GoalWeek({
    required this.goalId,
    required this.title,
    required this.target,
    required this.done,
    required this.weeksLeft,
  });

  final String goalId;

  final String title;

  /// Nombre de défis prévus sur la semaine.
  final int target;

  /// Nombre de défis réussis sur la semaine.
  final int done;

  /// Semaines restantes jusqu'à l'échéance, celle-ci comprise.
  final int weeksLeft;

  bool get isReached => done >= target;

  /// Ce qu'il reste à faire cette semaine, jamais négatif.
  int get remaining => done >= target ? 0 : target - done;

  @override
  bool operator ==(Object other) =>
      other is GoalWeek &&
      other.goalId == goalId &&
      other.title == title &&
      other.target == target &&
      other.done == done &&
      other.weeksLeft == weeksLeft;

  @override
  int get hashCode => Object.hash(goalId, title, target, done, weeksLeft);
}
