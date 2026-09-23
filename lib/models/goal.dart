/// Un objectif long, nommé à l'onboarding (« Marathon le 20 mars »).
class Goal {
  const Goal({
    required this.id,
    required this.title,
    required this.deadline,
    required this.startingLevel,
    required this.weeklyQuota,
  }) : assert(startingLevel >= 1, 'Le niveau commence à 1.'),
       assert(weeklyQuota >= 0, 'Un quota ne peut pas être négatif.');

  factory Goal.fromJson(Map<String, Object?> json) => Goal(
    id: json['id'] as String,
    title: json['title'] as String,
    deadline: DateTime.parse(json['deadline'] as String),
    startingLevel: json['startingLevel'] as int,
    weeklyQuota: json['weeklyQuota'] as int,
  );

  final String id;

  /// Ce que la personne repousse depuis trop longtemps, ex. « Marathon ».
  final String title;

  /// Échéance posée à l'onboarding.
  final DateTime deadline;

  /// Niveau déclaré au départ, sur la même échelle que `Challenge.level`.
  final int startingLevel;

  /// Nombre de défis à faire par semaine, ex. 3 sorties.
  final int weeklyQuota;

  Goal copyWith({
    String? id,
    String? title,
    DateTime? deadline,
    int? startingLevel,
    int? weeklyQuota,
  }) => Goal(
    id: id ?? this.id,
    title: title ?? this.title,
    deadline: deadline ?? this.deadline,
    startingLevel: startingLevel ?? this.startingLevel,
    weeklyQuota: weeklyQuota ?? this.weeklyQuota,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'deadline': deadline.toIso8601String(),
    'startingLevel': startingLevel,
    'weeklyQuota': weeklyQuota,
  };

  @override
  bool operator ==(Object other) =>
      other is Goal &&
      other.id == id &&
      other.title == title &&
      other.deadline == deadline &&
      other.startingLevel == startingLevel &&
      other.weeklyQuota == weeklyQuota;

  @override
  int get hashCode =>
      Object.hash(id, title, deadline, startingLevel, weeklyQuota);
}
