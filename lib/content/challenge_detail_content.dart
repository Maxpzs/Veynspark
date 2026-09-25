import '../models/challenge.dart';
import 'bento_content.dart';

/// Textes de l'écran de détail d'un défi.
///
/// Reporter n'est pas un échec : aucun commentaire, ni avant ni après.
abstract final class ChallengeDetailContent {
  static const String doNow = 'Faire maintenant';

  static const String postpone = 'Reporter à un autre jour';

  static const String postponeQuestion = 'Quel jour ?';

  static const String close = 'Fermer';

  static const String tomorrow = 'Demain';

  static const List<String> _weekdays = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche',
  ];

  /// Durée et contexte, ex. « 35 min · Dehors ».
  static String duration(Challenge challenge) =>
      '${BentoContent.duration(challenge.estimatedDuration)} · '
      '${switch (challenge.context) {
        ChallengeContext.home => BentoContent.contextHome,
        ChallengeContext.outside => BentoContent.contextOutside,
        ChallengeContext.anywhere => BentoContent.contextAnywhere,
      }}';

  /// Le rattachement d'un défi à objectif, ex. « → Marathon ».
  static String goal(String title) => '→ $title';

  /// L'avancement du quota, ex. « 1/3 cette semaine ».
  static String quota(int done, int target) => '$done/$target cette semaine';

  /// Un jour où reporter, ex. « Demain », « Vendredi ».
  static String day(DateTime day, {required bool isTomorrow}) =>
      isTomorrow ? tomorrow : _weekdays[day.weekday - 1];
}
