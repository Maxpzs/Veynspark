/// Nature d'un défi, qui décide de sa place et de son poids dans le bento.
enum ChallengeKind {
  /// Rattaché à un objectif long, avec un quota hebdomadaire. Mis en avant.
  goal,

  /// Sans objectif, en rotation libre. En retrait.
  opportunity,
}

/// Contexte dans lequel un défi peut se faire.
enum ChallengeContext { home, outside, anywhere }

/// Domaine d'un défi, déduit des duels de l'onboarding.
enum ChallengeDomain {
  /// Bouger : course, marche, vélo, sport.
  move,

  /// Lire.
  read,

  /// Cuisiner.
  cook,

  /// Créer : dessiner, écrire, jouer, bricoler.
  create,

  /// Apprendre.
  learn,

  /// Voir des gens.
  meet,
}

/// Façon dont l'app vérifie qu'un défi a été fait. La photo n'en fait jamais
/// partie.
enum ValidationMode {
  /// Minuteur dans l'app, appareil verrouillé pendant toute la durée.
  lockedTimer,

  /// Activité lue dans HealthKit ou Health Connect.
  health,

  /// QR régénéré toutes les 10 s, scanné mutuellement.
  qrCode,

  /// Déclaratif, assumé comme tel.
  declarative,
}

/// Un défi de la bibliothèque, tel qu'il apparaît dans le bento.
class Challenge {
  const Challenge({
    required this.id,
    required this.title,
    required this.kind,
    required this.domain,
    required this.level,
    required this.estimatedDuration,
    required this.context,
    required this.validation,
    this.goalReminder,
  }) : assert(level >= 1, 'Le niveau commence à 1.'),
       assert(
         (kind == ChallengeKind.goal) == (goalReminder != null),
         'Seuls les défis à objectif portent un rappel de l\'objectif.',
       );

  factory Challenge.fromJson(Map<String, Object?> json) => Challenge(
    id: json['id'] as String,
    title: json['title'] as String,
    kind: ChallengeKind.values.byName(json['kind'] as String),
    domain: ChallengeDomain.values.byName(json['domain'] as String),
    level: json['level'] as int,
    estimatedDuration: Duration(
      seconds: json['estimatedDurationSeconds'] as int,
    ),
    context: ChallengeContext.values.byName(json['context'] as String),
    validation: ValidationMode.values.byName(json['validation'] as String),
    goalReminder: json['goalReminder'] as String?,
  );

  /// Identifiant stable dans la bibliothèque de défis.
  final String id;

  /// Titre court, ex. « Courir 5 km ».
  final String title;

  final ChallengeKind kind;

  final ChallengeDomain domain;

  /// Difficulté, à partir de 1.
  final int level;

  final Duration estimatedDuration;

  /// Contexte requis pour faire le défi.
  final ChallengeContext context;

  final ValidationMode validation;

  /// Rappel de l'objectif, ex. « → Marathon, 1/3 cette semaine ». La
  /// bibliothèque porte un rappel générique ; le bento du jour le remplace par
  /// celui de l'objectif et de son quota.
  final String? goalReminder;

  /// [goalReminder] se passe sous forme de fonction pour pouvoir le remettre à
  /// `null`.
  Challenge copyWith({
    String? id,
    String? title,
    ChallengeKind? kind,
    ChallengeDomain? domain,
    int? level,
    Duration? estimatedDuration,
    ChallengeContext? context,
    ValidationMode? validation,
    String? Function()? goalReminder,
  }) => Challenge(
    id: id ?? this.id,
    title: title ?? this.title,
    kind: kind ?? this.kind,
    domain: domain ?? this.domain,
    level: level ?? this.level,
    estimatedDuration: estimatedDuration ?? this.estimatedDuration,
    context: context ?? this.context,
    validation: validation ?? this.validation,
    goalReminder: goalReminder != null ? goalReminder() : this.goalReminder,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'kind': kind.name,
    'domain': domain.name,
    'level': level,
    'estimatedDurationSeconds': estimatedDuration.inSeconds,
    'context': context.name,
    'validation': validation.name,
    'goalReminder': goalReminder,
  };

  @override
  bool operator ==(Object other) =>
      other is Challenge &&
      other.id == id &&
      other.title == title &&
      other.kind == kind &&
      other.domain == domain &&
      other.level == level &&
      other.estimatedDuration == estimatedDuration &&
      other.context == context &&
      other.validation == validation &&
      other.goalReminder == goalReminder;

  @override
  int get hashCode => Object.hash(
    id,
    title,
    kind,
    domain,
    level,
    estimatedDuration,
    context,
    validation,
    goalReminder,
  );
}
