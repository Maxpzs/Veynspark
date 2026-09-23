/// Repères de calendrier partagés par le moteur. La semaine commence le lundi
/// à minuit, heure locale, et finit le dimanche soir.
library;

/// Le jour de [moment], à minuit.
DateTime dateOnly(DateTime moment) =>
    DateTime(moment.year, moment.month, moment.day);

/// Le lundi, à minuit, de la semaine qui contient [moment].
DateTime weekStartOf(DateTime moment) =>
    DateTime(moment.year, moment.month, moment.day - (moment.weekday - 1));

/// Le lundi suivant [weekStart], à minuit : la fin exclue de la semaine.
DateTime nextWeekStart(DateTime weekStart) =>
    DateTime(weekStart.year, weekStart.month, weekStart.day + 7);

/// Vrai si [moment] tombe dans la semaine qui commence à [weekStart].
bool isInWeek(DateTime moment, DateTime weekStart) =>
    !moment.isBefore(weekStart) && moment.isBefore(nextWeekStart(weekStart));

/// Nombre de jours calendaires de [from] à [to]. Insensible aux changements
/// d'heure.
int daysBetween(DateTime from, DateTime to) => DateTime.utc(
  to.year,
  to.month,
  to.day,
).difference(DateTime.utc(from.year, from.month, from.day)).inDays;

/// Nombre de semaines de celle qui commence à [weekStart] jusqu'à celle qui
/// contient [deadline], les deux comprises. Zéro si l'échéance est passée.
int weeksLeft(DateTime weekStart, DateTime deadline) {
  final days = daysBetween(weekStart, weekStartOf(deadline));
  return days < 0 ? 0 : days ~/ 7 + 1;
}
