/// Où en est un défi pour une journée donnée.
enum ChallengeStatus {
  proposed,
  accepted,
  succeeded,

  /// Écarté de la grille du jour, pour un autre jour de la semaine.
  postponed,
  abandoned,

  /// Reporté sur ce jour : la date de la ligne est le jour visé, pas le moment
  /// du report. Le défi entrera dans la grille de ce jour-là.
  rescheduled,
}

/// Pourquoi un défi a été reporté. Alimente le moteur de proposition.
enum PostponeReason { wrongMoment, notInTheMood, tooHard, other }

/// Une ligne du journal : ce qui est arrivé à un défi, un jour donné.
class ChallengeLog {
  const ChallengeLog({
    required this.challengeId,
    required this.date,
    required this.status,
    this.postponeReason,
  }) : assert(
         postponeReason == null || status == ChallengeStatus.postponed,
         'Seul un défi reporté porte une raison de report.',
       );

  factory ChallengeLog.fromJson(Map<String, Object?> json) {
    final reason = json['postponeReason'] as String?;
    return ChallengeLog(
      challengeId: json['challengeId'] as String,
      date: DateTime.parse(json['date'] as String),
      status: ChallengeStatus.values.byName(json['status'] as String),
      postponeReason: reason == null
          ? null
          : PostponeReason.values.byName(reason),
    );
  }

  final String challengeId;

  final DateTime date;

  final ChallengeStatus status;

  /// Facultative, même pour un report : la question se pose en un tap, on peut
  /// ne pas y répondre.
  final PostponeReason? postponeReason;

  /// [postponeReason] se passe sous forme de fonction pour pouvoir la remettre
  /// à `null`.
  ChallengeLog copyWith({
    String? challengeId,
    DateTime? date,
    ChallengeStatus? status,
    PostponeReason? Function()? postponeReason,
  }) => ChallengeLog(
    challengeId: challengeId ?? this.challengeId,
    date: date ?? this.date,
    status: status ?? this.status,
    postponeReason: postponeReason != null
        ? postponeReason()
        : this.postponeReason,
  );

  Map<String, Object?> toJson() => {
    'challengeId': challengeId,
    'date': date.toIso8601String(),
    'status': status.name,
    'postponeReason': postponeReason?.name,
  };

  @override
  bool operator ==(Object other) =>
      other is ChallengeLog &&
      other.challengeId == challengeId &&
      other.date == date &&
      other.status == status &&
      other.postponeReason == postponeReason;

  @override
  int get hashCode => Object.hash(challengeId, date, status, postponeReason);
}
