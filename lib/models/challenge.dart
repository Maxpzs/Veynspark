/// Nature d'un défi, qui décide de sa place et de son poids dans le bento.
enum ChallengeKind {
  /// Rattaché à un objectif long, avec un quota hebdomadaire. Mis en avant.
  goal,

  /// Sans objectif, en rotation libre. En retrait.
  opportunity,
}

/// Contexte dans lequel un défi peut se faire.
enum ChallengeContext { home, outside, anywhere }

/// Un défi tel qu'il apparaît dans le bento.
class Challenge {
  const Challenge({
    required this.id,
    required this.title,
    required this.kind,
    required this.estimatedDuration,
    required this.context,
    this.goalReminder,
  }) : assert(
         (kind == ChallengeKind.goal) == (goalReminder != null),
         'Seuls les défis à objectif portent un rappel de l\'objectif.',
       );

  /// Identifiant stable dans la bibliothèque de défis.
  final String id;

  /// Titre court, ex. « Courir 5 km ».
  final String title;

  final ChallengeKind kind;

  final Duration estimatedDuration;

  final ChallengeContext context;

  /// Rappel de l'objectif, ex. « → marathon, 1/3 cette semaine ». Écrit en dur
  /// pour l'instant, il sera calculé par le moteur à partir du quota.
  final String? goalReminder;
}
