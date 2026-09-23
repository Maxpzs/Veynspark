/// Le quota d'un objectif sur une semaine donnée (« Courir 2/3 »).
class WeekQuota {
  const WeekQuota({
    required this.goalId,
    required this.weekStart,
    required this.target,
    this.done = 0,
  }) : assert(target >= 0, 'Un quota ne peut pas être négatif.'),
       assert(done >= 0, 'Un compteur ne peut pas être négatif.');

  factory WeekQuota.fromJson(Map<String, Object?> json) => WeekQuota(
    goalId: json['goalId'] as String,
    weekStart: DateTime.parse(json['weekStart'] as String),
    target: json['target'] as int,
    done: json['done'] as int,
  );

  final String goalId;

  /// Premier jour de la semaine, le lundi.
  final DateTime weekStart;

  /// Nombre de défis prévus sur la semaine.
  final int target;

  /// Nombre de défis réussis sur la semaine. Peut dépasser [target].
  final int done;

  bool get isReached => done >= target;

  WeekQuota copyWith({
    String? goalId,
    DateTime? weekStart,
    int? target,
    int? done,
  }) => WeekQuota(
    goalId: goalId ?? this.goalId,
    weekStart: weekStart ?? this.weekStart,
    target: target ?? this.target,
    done: done ?? this.done,
  );

  Map<String, Object?> toJson() => {
    'goalId': goalId,
    'weekStart': weekStart.toIso8601String(),
    'target': target,
    'done': done,
  };

  @override
  bool operator ==(Object other) =>
      other is WeekQuota &&
      other.goalId == goalId &&
      other.weekStart == weekStart &&
      other.target == target &&
      other.done == done;

  @override
  int get hashCode => Object.hash(goalId, weekStart, target, done);
}
