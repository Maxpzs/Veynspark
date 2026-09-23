/// Textes du défi en cours et de la réussite.
///
/// Drôle quand ça réussit, sobre quand ça s'arrête : l'arrêt et l'abandon
/// n'ont jamais de commentaire.
abstract final class ChallengeRunContent {
  /// Arrêter le défi, en un tap, sans confirmation.
  static const String abandon = 'Arrêter';

  static const String timerInstruction =
      'Pose ton téléphone. Il se verrouille, le compteur tourne.';

  static const String resume = 'On reprend';

  static const String done = 'Continuer';

  /// Ex. « Compteur arrêté à 12 minutes. On reprend ? »
  static String timerInterrupted(Duration elapsed) {
    final minutes = elapsed.inMinutes;
    final seconds = elapsed.inSeconds;
    final held = minutes >= 1
        ? '$minutes minute${minutes > 1 ? 's' : ''}'
        : '$seconds seconde${seconds > 1 ? 's' : ''}';
    return 'Compteur arrêté à $held. On reprend ?';
  }

  /// Le temps restant, ex. « 19:42 » ou « 1:05:00 ».
  static String remaining(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final seconds = two(d.inSeconds.remainder(60));
    final minutes = d.inMinutes.remainder(60);
    if (d.inHours == 0) return '$minutes:$seconds';
    return '${d.inHours}:${two(minutes)}:$seconds';
  }

  static const List<String> _successPhrases = [
    'INSTAGRAM N\'A RIEN VU PASSER.',
    'UN POINT POUR LA VRAIE VIE.',
    'LE TÉLÉPHONE A PERDU.',
    'FAIT. PAS PROMIS : FAIT.',
    'PLUS TARD, C\'ÉTAIT MAINTENANT.',
  ];

  /// La phrase de réussite d'un défi. Toujours la même pour un même défi.
  static String successPhrase(String challengeId) =>
      _successPhrases[challengeId.codeUnits.fold(0, (sum, unit) => sum + unit) %
          _successPhrases.length];

  /// Ce que la réussite fait avancer, ex. « Marathon : 2/3 cette semaine ».
  static String goalProgress(String goal, int done, int target) =>
      '$goal : $done/$target cette semaine';

  /// Pour un défi sans objectif, ex. « 3 réussites cette semaine ».
  static String weekProgress(int succeeded) =>
      '$succeeded réussite${succeeded > 1 ? 's' : ''} cette semaine';
}
