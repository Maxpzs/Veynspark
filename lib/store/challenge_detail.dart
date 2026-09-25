import 'package:flutter/foundation.dart';

import 'success_progress.dart';

/// Ce que l'écran de détail montre d'un défi, en plus du défi lui-même.
@immutable
class ChallengeDetail {
  ChallengeDetail({this.goal, required List<DateTime> postponeDays})
    : postponeDays = List.unmodifiable(postponeDays);

  /// L'objectif que le défi fait avancer et son quota de la semaine, pour un
  /// défi à objectif.
  final GoalProgress? goal;

  /// Les jours où l'on peut reporter le défi : les jours restants de la
  /// semaine qui ont encore de la place. Vide le dimanche.
  final List<DateTime> postponeDays;
}
