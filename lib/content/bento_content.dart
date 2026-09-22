import '../models/challenge.dart';

/// Textes de l'écran du bento.
abstract final class BentoContent {
  static const String title = 'AUJOURD\'HUI.';

  static const String clearedTitle = 'GRILLE PROPRE.';
  static const String clearedBody = 'Le reste de la journée est à toi.';

  /// TEMPORAIRE : remet la grille à zéro pour rejouer le nettoyage.
  static const String replayDemo = 'Rejouer (démo)';

  static const String contextHome = 'Chez soi';
  static const String contextOutside = 'Dehors';
  static const String contextAnywhere = 'N\'importe où';

  /// Durée estimée, ex. « 1 min », « 35 min », « 1 h », « 1 h 15 ».
  static String duration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    if (hours == 0) return '$minutes min';
    if (minutes == 0) return '$hours h';
    return '$hours h ${minutes.toString().padLeft(2, '0')}';
  }

  /// Défis à objectif du bento statique, en haut de la grille.
  static const List<Challenge> goalChallenges = [
    Challenge(
      id: 'run-5k',
      title: 'Courir 5 km',
      kind: ChallengeKind.goal,
      estimatedDuration: Duration(minutes: 35),
      context: ChallengeContext.outside,
      goalReminder: '→ marathon, 1/3 cette semaine',
    ),
    Challenge(
      id: 'read-20-pages',
      title: 'Lire 20 pages',
      kind: ChallengeKind.goal,
      estimatedDuration: Duration(minutes: 25),
      context: ChallengeContext.anywhere,
      goalReminder: '→ lecture, 2/5 cette semaine',
    ),
  ];

  /// Défis d'opportunité du bento statique, sous les défis à objectif. Le
  /// dernier se fait dans la minute.
  static const List<Challenge> opportunityChallenges = [
    Challenge(
      id: 'curry-recipe',
      title: 'Tester une recette au curry',
      kind: ChallengeKind.opportunity,
      estimatedDuration: Duration(minutes: 45),
      context: ChallengeContext.home,
    ),
    Challenge(
      id: 'call-grandma',
      title: 'Appeler ta grand-mère',
      kind: ChallengeKind.opportunity,
      estimatedDuration: Duration(minutes: 10),
      context: ChallengeContext.anywhere,
    ),
    Challenge(
      id: 'ten-push-ups',
      title: 'Dix pompes, là',
      kind: ChallengeKind.opportunity,
      estimatedDuration: Duration(minutes: 1),
      context: ChallengeContext.anywhere,
    ),
  ];
}
