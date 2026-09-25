import '../validation/timer_state.dart';

/// Textes du panneau de débogage. Jamais vus en production.
abstract final class DebugContent {
  static const String title = 'DEBUG';

  static const String resetDay = 'Réinitialiser la journée';
  static const String resetAll = 'Réinitialiser toute la base';
  static const String advanceDay = 'Avancer d\'un jour';
  static const String advanceWeek = 'Avancer d\'une semaine';
  static const String fillWeek = 'Remplir la semaine (exemple)';
  static const String backToPresent = 'Revenir à aujourd\'hui';

  static const String sampleGoalId = 'debug-marathon';
  static const String sampleGoalTitle = 'Marathon';

  static const List<String> _weekdays = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche',
  ];

  /// La date de l'app, ex. « Mercredi 23/09, 10:04 · +3 j ».
  static String now(DateTime now, int daysAhead) {
    String two(int n) => n.toString().padLeft(2, '0');
    final date =
        '${_weekdays[now.weekday - 1]} ${two(now.day)}/${two(now.month)}, '
        '${two(now.hour)}:${two(now.minute)}';
    return daysAhead == 0 ? date : '$date · +$daysAhead j';
  }

  /// Ex. « 5 réussites cette semaine · 4 jours restants ».
  static String week(int succeeded, int daysLeft) =>
      '$succeeded réussite${succeeded > 1 ? 's' : ''} cette semaine · '
      '$daysLeft jour${daysLeft > 1 ? 's' : ''} restant${daysLeft > 1 ? 's' : ''}';

  /// Ex. « Marathon 2/3 ».
  static String quota(String goal, int done, int target) =>
      '$goal $done/$target';

  static const String noGoal = 'Aucun objectif ouvert.';

  static const String reviewPending = 'Bilan du dimanche : dimanche, 18 h.';

  /// Ex. « Bilan : 5 réussites, 1/2 quotas atteints ».
  static String review(int succeeded, int reached, int quotas) =>
      'Bilan : $succeeded réussite${succeeded > 1 ? 's' : ''}, '
      '$reached/$quotas quota${quotas > 1 ? 's' : ''} atteint'
      '${reached > 1 ? 's' : ''}';

  /// Ex. « 3 réussites ajoutées ».
  static String filled(int count) => count == 0
      ? 'Rien à remplir avant aujourd\'hui.'
      : '$count réussite${count > 1 ? 's' : ''} ajoutée${count > 1 ? 's' : ''}.';

  static const String simulateLockTitle = 'Simuler le verrouillage';
  static const String simulateLockHint =
      'Chaque sortie de l\'app compte comme un verrouillage. Pour les '
      'appareils sans code, où iOS n\'en signale aucun.';

  /// Ex. « Appareil : déverrouillé · Compteur : tourne · Dernière absence :
  /// verrouillage ».
  static String timerStatus({
    required bool? locked,
    required TimerPhase phase,
    required Absence? lastAbsence,
    required bool simulated,
  }) {
    final device = switch (locked) {
      null => 'inconnu',
      true => 'verrouillé',
      false => 'déverrouillé',
    };
    final counter = switch (phase) {
      TimerPhase.ready => 'pas lancé',
      TimerPhase.counting => 'tourne',
      TimerPhase.interrupted => 'en pause',
      TimerPhase.completed => 'terminé',
      TimerPhase.abandoned => 'abandonné',
    };
    final absence = switch (lastAbsence) {
      null => '',
      Absence.locked => ' · Dernière absence : verrouillage',
      Absence.left => ' · Dernière absence : sortie de l\'app',
    };
    return 'Appareil : $device${simulated ? ' (simulé)' : ''} · '
        'Compteur : $counter$absence';
  }
}
