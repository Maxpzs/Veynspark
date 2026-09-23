import '../models/goal.dart';
import 'week_calendar.dart';

/// Quota le plus bas proposé pour une semaine où l'objectif est encore ouvert.
const int minWeeklyQuota = 2;

/// Quota le plus haut, jamais dépassé, même dans la dernière ligne droite.
const int maxWeeklyQuota = 5;

/// Nombre de semaines avant l'échéance qui forment la dernière ligne droite.
const int finalStretchWeeks = 4;

/// Le quota d'un objectif pour la semaine qui commence à [weekStart].
///
/// Règle volontairement simple et lisible :
/// - on part du niveau de départ : niveau 1 → 2 défis, niveau 2 → 3, niveau 3
///   et plus → 4 ;
/// - dans les [finalStretchWeeks] dernières semaines, un défi de plus ;
/// - le tout borné entre [minWeeklyQuota] et [maxWeeklyQuota] ;
/// - une fois l'échéance passée, plus de quota.
int weeklyQuotaFor(Goal goal, DateTime weekStart) {
  final left = weeksLeft(weekStart, goal.deadline);
  if (left == 0) return 0;
  final base = goal.startingLevel + 1;
  final stretch = left <= finalStretchWeeks ? 1 : 0;
  return (base + stretch).clamp(minWeeklyQuota, maxWeeklyQuota);
}
