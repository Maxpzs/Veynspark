/// Ce qu'une réussite fait avancer, pour l'écran de réussite.
class SuccessProgress {
  const SuccessProgress({required this.weekSucceeded, this.goal});

  /// Réussites de la semaine, celle-ci comprise.
  final int weekSucceeded;

  /// L'objectif avancé, pour un défi à objectif.
  final GoalProgress? goal;
}

/// Où en est l'objectif après la réussite : « Marathon, 2/3 cette semaine ».
class GoalProgress {
  const GoalProgress({
    required this.title,
    required this.done,
    required this.target,
  });

  final String title;
  final int done;
  final int target;
}
