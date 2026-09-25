import 'package:flutter/foundation.dart';

/// Où en est un défi à minuteur.
enum TimerPhase {
  /// Pas encore lancé.
  ready,

  /// Le compteur tourne : l'app est affichée, ou l'appareil verrouillé.
  counting,

  /// L'app a été quittée avant la fin : le compteur est arrêté, on peut
  /// reprendre.
  interrupted,

  /// Durée atteinte.
  completed,

  /// Arrêté par la personne. Aucune conséquence.
  abandoned,
}

/// Ce qu'a été une absence de l'app pendant le défi.
enum Absence {
  /// L'appareil a été verrouillé : le compteur a continué.
  locked,

  /// La personne est allée ailleurs : le compteur s'est arrêté à son départ.
  left,
}

/// Un instantané du minuteur, immuable.
///
/// Pendant [TimerPhase.counting], le temps écoulé dépend de l'heure : il se lit
/// avec [elapsedAt].
@immutable
class TimerState {
  const TimerState({
    required this.phase,
    required this.target,
    this.elapsed = Duration.zero,
    this.countingSince,
  }) : assert(
         (phase == TimerPhase.counting) == (countingSince != null),
         'Seul un compteur qui tourne a un point de départ.',
       );

  final TimerPhase phase;

  /// Durée à tenir.
  final Duration target;

  /// Temps tenu avant la dernière reprise.
  final Duration elapsed;

  /// Depuis quand le compteur tourne, pendant [TimerPhase.counting].
  final DateTime? countingSince;

  bool get isActive =>
      phase == TimerPhase.counting || phase == TimerPhase.interrupted;

  bool get isOver =>
      phase == TimerPhase.completed || phase == TimerPhase.abandoned;

  /// Temps tenu à [now], jamais au-delà de [target].
  Duration elapsedAt(DateTime now) {
    final since = countingSince;
    if (since == null) return elapsed;
    final total = elapsed + now.difference(since);
    if (total < Duration.zero) return elapsed;
    return total > target ? target : total;
  }

  /// Temps restant à [now].
  Duration remainingAt(DateTime now) => target - elapsedAt(now);

  TimerState copyWith({
    TimerPhase? phase,
    Duration? elapsed,
    DateTime? Function()? countingSince,
  }) => TimerState(
    phase: phase ?? this.phase,
    target: target,
    elapsed: elapsed ?? this.elapsed,
    countingSince: countingSince != null ? countingSince() : this.countingSince,
  );

  @override
  bool operator ==(Object other) =>
      other is TimerState &&
      other.phase == phase &&
      other.target == target &&
      other.elapsed == elapsed &&
      other.countingSince == countingSince;

  @override
  int get hashCode => Object.hash(phase, target, elapsed, countingSince);

  @override
  String toString() =>
      'TimerState($phase, $elapsed / $target, depuis $countingSince)';
}
