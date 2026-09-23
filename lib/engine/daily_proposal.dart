import '../models/challenge.dart';

/// Les défis proposés pour une journée : de quoi remplir le bento.
class DailyProposal {
  DailyProposal({
    required List<Challenge> goals,
    required List<Challenge> opportunities,
  }) : goals = List.unmodifiable(goals),
       opportunities = List.unmodifiable(opportunities);

  /// Défis à objectif, du plus pressant au moins pressant. En haut de la
  /// grille.
  final List<Challenge> goals;

  /// Défis d'opportunité, en dessous.
  final List<Challenge> opportunities;

  List<Challenge> get all => [...goals, ...opportunities];
}
