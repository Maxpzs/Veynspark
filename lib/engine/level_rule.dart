import '../models/challenge.dart';
import '../models/challenge_log.dart';

/// Nombre de réussites dans un domaine qui font monter d'un niveau.
const int successesPerLevel = 3;

/// Le niveau actuel dans [domain], recalculé à partir du journal.
///
/// Règle volontairement simple et lisible :
/// - on part de [startingLevel] ;
/// - chaque [successesPerLevel] réussites dans le domaine, un niveau de plus ;
/// - chaque report pour « trop dur » dans le domaine, un niveau de moins ;
/// - le tout borné entre 1 et [maxLevel].
///
/// [library] sert à retrouver le domaine de chaque défi du journal ; un défi
/// inconnu est ignoré.
int currentLevel({
  required ChallengeDomain domain,
  required int startingLevel,
  required int maxLevel,
  required List<Challenge> library,
  required List<ChallengeLog> logs,
}) {
  final inDomain = {
    for (final c in library)
      if (c.domain == domain) c.id,
  };
  var successes = 0;
  var tooHard = 0;
  for (final log in logs) {
    if (!inDomain.contains(log.challengeId)) continue;
    if (log.status == ChallengeStatus.succeeded) successes++;
    if (log.postponeReason == PostponeReason.tooHard) tooHard++;
  }
  final level = startingLevel + successes ~/ successesPerLevel - tooHard;
  return level.clamp(1, maxLevel < 1 ? 1 : maxLevel);
}
