/// Textes de l'écran du bento. Les défis, eux, viennent du moteur.
abstract final class BentoContent {
  static const String title = 'AUJOURD\'HUI.';

  static const String clearedTitle = 'GRILLE PROPRE.';
  static const String clearedBody = 'Le reste de la journée est à toi.';

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

  /// Rappel de l'objectif sous une tuile à objectif, ex. « → Marathon, 1/3
  /// cette semaine ».
  static String goalReminder(String goal, int done, int target) =>
      '→ $goal, $done/$target cette semaine';
}
