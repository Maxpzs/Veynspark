import '../models/challenge.dart';
import '../models/challenge_log.dart';
import 'daily_proposal.dart';
import 'day_moment.dart';
import 'goal_track.dart';
import 'level_rule.dart';
import 'week_calendar.dart';

/// Nombre maximal de tuiles à objectif par jour.
const int maxGoalTiles = 2;

/// Au-delà de cette durée, un défi n'est pas « court ».
const Duration shortChallenge = Duration(minutes: 15);

/// Fenêtre dans laquelle les raisons de report comptent pour le moment de la
/// journée et l'envie.
const int recentPostponeDays = 14;

/// Nombre de reports « pas le bon moment » récents à partir duquel le moteur
/// privilégie les défis courts.
const int wrongMomentThreshold = 2;

/// Choisit les 4 à 5 défis du jour.
///
/// Règles simples et lisibles, dans l'ordre du brief :
/// 1. **Échéances et quota restant.** Les objectifs qui ont encore un quota à
///    tenir passent devant, le plus proche de son échéance d'abord. Deux
///    tuiles à objectif s'il y a au moins deux objectifs en retard sur leur
///    quota, sinon une.
/// 2. **Moment de la journée et créneaux libres.** La nuit, ou hors des
///    créneaux libres déclarés, les défis courts passent devant.
/// 3. **Niveau.** Recalculé à partir du journal (voir `currentLevel`). Un défi
///    plus dur que le niveau actuel est fortement pénalisé, un défi plus
///    facile un peu.
/// 4. **Historique.** Un défi déjà présent dans le journal de la semaine n'est
///    jamais reproposé.
/// 5. **Raisons de report.** « Trop dur » fait baisser le niveau ; « pas le bon
///    moment », répété, fait passer les défis courts devant ; « pas envie »
///    pénalise le défi concerné.
/// 6. **Variété des contextes.** Au moins une tuile faisable dehors et une
///    faisable partout, puis des domaines variés.
///
/// À score égal, l'ordre change d'un jour à l'autre, mais reste le même pour
/// une journée donnée.
class ProposalEngine {
  ProposalEngine({required List<Challenge> library})
    : _library = List.unmodifiable(library);

  final List<Challenge> _library;

  /// Les défis du jour à [now].
  ///
  /// [logs] contient au moins le journal de la semaine en cours ; plus il
  /// remonte loin, plus le niveau est juste. [freeMoments] vaut `null` tant
  /// que la personne n'a pas déclaré sa semaine. [interests] filtre les défis
  /// d'opportunité ; vide, tous les domaines sont proposés.
  DailyProposal propose({
    required DateTime now,
    required List<GoalTrack> goals,
    required List<ChallengeLog> logs,
    Set<DayMoment>? freeMoments,
    Set<ChallengeDomain> interests = const {},
  }) {
    final day = dateOnly(now);
    final weekStart = weekStartOf(now);
    final alreadyThisWeek = {
      for (final log in logs)
        if (isInWeek(log.date, weekStart)) log.challengeId,
    };
    final recent = [
      for (final log in logs)
        if (log.status == ChallengeStatus.postponed &&
            !log.date.isAfter(now) &&
            daysBetween(log.date, now) < recentPostponeDays)
          log,
    ];
    final notInTheMood = {
      for (final log in recent)
        if (log.postponeReason == PostponeReason.notInTheMood) log.challengeId,
    };
    final preferShort =
        DayMoment.of(now) == DayMoment.night ||
        (freeMoments != null && !freeMoments.contains(DayMoment.of(now))) ||
        recent
                .where((l) => l.postponeReason == PostponeReason.wrongMoment)
                .length >=
            wrongMomentThreshold;

    final startingLevels = <ChallengeDomain, int>{};
    for (final track in goals) {
      final known = startingLevels[track.domain];
      if (known == null || track.goal.startingLevel < known) {
        startingLevels[track.domain] = track.goal.startingLevel;
      }
    }
    final levels = {
      for (final domain in ChallengeDomain.values)
        domain: currentLevel(
          domain: domain,
          startingLevel: startingLevels[domain] ?? 1,
          maxLevel: _maxLevel(domain),
          library: _library,
          logs: logs,
        ),
    };

    int score(Challenge c) {
      final target = levels[c.domain]!;
      var s = c.level > target ? (c.level - target) * 3 : target - c.level;
      if (preferShort && c.estimatedDuration > shortChallenge) s += 2;
      if (notInTheMood.contains(c.id)) s += 2;
      return s;
    }

    int compare(Challenge a, Challenge b) {
      final byScore = score(a).compareTo(score(b));
      if (byScore != 0) return byScore;
      return _dailyOrder(a.id, day).compareTo(_dailyOrder(b.id, day));
    }

    final available = [
      for (final c in _library)
        if (!alreadyThisWeek.contains(c.id)) c,
    ]..sort(compare);

    // 1. Les tuiles à objectif.
    final ranked = [...goals]..sort(_byUrgency);
    final behind = ranked.where((t) => t.week.remaining > 0).length;
    final goalTiles = behind >= maxGoalTiles ? maxGoalTiles : 1;
    final pickedGoals = <Challenge>[];
    for (final track in ranked) {
      if (pickedGoals.length >= goalTiles) break;
      final best = available
          .where(
            (c) =>
                c.kind == ChallengeKind.goal &&
                c.domain == track.domain &&
                !pickedGoals.contains(c),
          )
          .firstOrNull;
      if (best != null) pickedGoals.add(best);
    }

    // 2. Les tuiles d'opportunité, en complétant les contextes manquants.
    final opportunityTiles = pickedGoals.length >= maxGoalTiles
        ? 3
        : 4 - pickedGoals.length;
    final pool = [
      for (final c in available)
        if (c.kind == ChallengeKind.opportunity &&
            (interests.isEmpty || interests.contains(c.domain)))
          c,
    ];
    final pickedOpportunities = <Challenge>[];
    bool covered(ChallengeContext context) => [
      ...pickedGoals,
      ...pickedOpportunities,
    ].any((c) => c.context == context);
    for (final required in const [
      ChallengeContext.outside,
      ChallengeContext.anywhere,
    ]) {
      if (pickedOpportunities.length >= opportunityTiles) break;
      if (covered(required)) continue;
      final best = pool.where((c) => c.context == required).firstOrNull;
      if (best == null) continue;
      pickedOpportunities.add(best);
      pool.remove(best);
    }
    while (pickedOpportunities.length < opportunityTiles && pool.isNotEmpty) {
      final domains = {
        for (final c in [...pickedGoals, ...pickedOpportunities]) c.domain,
      };
      final best = pool.firstWhere(
        (c) => !domains.contains(c.domain),
        orElse: () => pool.first,
      );
      pickedOpportunities.add(best);
      pool.remove(best);
    }

    return DailyProposal(
      goals: pickedGoals,
      opportunities: pickedOpportunities,
    );
  }

  int _maxLevel(ChallengeDomain domain) => _library
      .where((c) => c.domain == domain)
      .fold(1, (max, c) => c.level > max ? c.level : max);

  /// Les objectifs en retard sur leur quota d'abord, puis le plus proche de
  /// son échéance, puis celui à qui il reste le plus à faire.
  static int _byUrgency(GoalTrack a, GoalTrack b) {
    final aBehind = a.week.remaining > 0 ? 0 : 1;
    final bBehind = b.week.remaining > 0 ? 0 : 1;
    if (aBehind != bBehind) return aBehind.compareTo(bBehind);
    final byDeadline = a.week.weeksLeft.compareTo(b.week.weeksLeft);
    if (byDeadline != 0) return byDeadline;
    return b.week.remaining.compareTo(a.week.remaining);
  }

  /// Un ordre stable pour une journée, différent d'un jour à l'autre
  /// (FNV-1a sur l'identifiant et la date).
  static int _dailyOrder(String id, DateTime day) {
    var hash = 0x811c9dc5;
    for (final unit in '$id|${day.year}-${day.month}-${day.day}'.codeUnits) {
      hash = ((hash ^ unit) * 0x01000193) & 0xffffffff;
    }
    return hash;
  }
}
