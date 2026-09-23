/// Ce qui mérite d'être compté, et rien de plus. Chaque type sert l'une des
/// mesures de la section « La mesure » du brief.
///
/// Aucun événement ne mesure le temps passé dans l'app : ce n'est pas un
/// objectif, donc ce n'est pas une mesure.
enum AnalyticsEventType {
  /// L'app est ouverte. Suffit pour la rétention J1, J7, J30 et le ratio
  /// actifs quotidiens sur actifs mensuels.
  appOpened,

  /// Un écran de l'onboarding s'affiche. Donne la complétion écran par écran.
  onboardingStepReached,

  /// L'onboarding est allé au bout.
  onboardingCompleted,

  /// Un défi apparaît dans le bento.
  challengeProposed,

  /// Un défi est lancé.
  challengeAccepted,

  /// Un défi est déplacé à plus tard.
  challengePostponed,

  /// Une publication d'ami est vue dans le feed.
  feedPostSeen,

  /// Un défi est relevé depuis une publication du feed. Avec [feedPostSeen],
  /// donne le taux de reprise.
  challengeTakenUpFromFeed,
}

/// Un événement daté. Ne porte que des identifiants internes à l'app : rien
/// qui désigne la personne.
class AnalyticsEvent {
  const AnalyticsEvent({
    required this.type,
    required this.at,
    this.challengeId,
    this.onboardingStep,
    this.feedPostId,
  });

  factory AnalyticsEvent.fromJson(Map<String, Object?> json) => AnalyticsEvent(
    type: AnalyticsEventType.values.byName(json['type'] as String),
    at: DateTime.parse(json['at'] as String),
    challengeId: json['challengeId'] as String?,
    onboardingStep: json['onboardingStep'] as int?,
    feedPostId: json['feedPostId'] as String?,
  );

  final AnalyticsEventType type;

  final DateTime at;

  /// Pour les événements qui concernent un défi.
  final String? challengeId;

  /// Numéro de l'écran d'onboarding, de 1 à 12.
  final int? onboardingStep;

  /// Pour les événements du feed.
  final String? feedPostId;

  Map<String, Object?> toJson() => {
    'type': type.name,
    'at': at.toIso8601String(),
    'challengeId': challengeId,
    'onboardingStep': onboardingStep,
    'feedPostId': feedPostId,
  };

  @override
  bool operator ==(Object other) =>
      other is AnalyticsEvent &&
      other.type == type &&
      other.at == at &&
      other.challengeId == challengeId &&
      other.onboardingStep == onboardingStep &&
      other.feedPostId == feedPostId;

  @override
  int get hashCode =>
      Object.hash(type, at, challengeId, onboardingStep, feedPostId);

  @override
  String toString() =>
      'AnalyticsEvent(${type.name}, $at, challenge: $challengeId, '
      'step: $onboardingStep, post: $feedPostId)';
}
