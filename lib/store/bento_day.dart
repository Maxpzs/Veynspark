import 'package:flutter/foundation.dart';

import '../feedback/clean_cue.dart';
import '../models/challenge.dart';

/// Le bento du jour : les défis encore dans la grille, et l'ordre dans lequel
/// les autres ont été nettoyés.
class BentoDay extends ChangeNotifier {
  BentoDay({
    required List<Challenge> goals,
    required List<Challenge> opportunities,
  }) : _initialGoals = List.unmodifiable(goals),
       _initialOpportunities = List.unmodifiable(opportunities),
       _goals = [...goals],
       _opportunities = [...opportunities];

  final List<Challenge> _initialGoals;
  final List<Challenge> _initialOpportunities;
  List<Challenge> _goals;
  List<Challenge> _opportunities;
  final List<String> _cleaned = [];

  List<Challenge> get goals => List.unmodifiable(_goals);

  List<Challenge> get opportunities => List.unmodifiable(_opportunities);

  /// Nombre de tuiles de la grille en début de journée.
  int get total => _initialGoals.length + _initialOpportunities.length;

  bool get isCleared => _goals.isEmpty && _opportunities.isEmpty;

  /// Retire le défi de la grille.
  void clean(Challenge challenge) {
    final removed =
        _goals.remove(challenge) || _opportunities.remove(challenge);
    if (!removed) return;
    _cleaned.add(challenge.id);
    notifyListeners();
  }

  /// Le son d'un défi nettoyé, selon sa place dans l'ordre de nettoyage.
  CleanCue cueFor(Challenge challenge) =>
      CleanCue.forClean(index: _cleaned.indexOf(challenge.id), total: total);

  /// TEMPORAIRE : remet la grille du jour à zéro, pour rejouer le nettoyage.
  void reset() {
    _goals = [..._initialGoals];
    _opportunities = [..._initialOpportunities];
    _cleaned.clear();
    notifyListeners();
  }
}
