/// Formes de Glyna : rayons, bords, proportions du bento.
abstract final class GlynaShape {
  /// Rayon des tuiles du bento.
  static const double tileRadius = 20;

  /// Bord violet des tuiles à objectif.
  static const double goalBorderWidth = 2;

  /// Hauteur relative d'une tuile à objectif dans la grille.
  static const int bentoGoalFlex = 4;

  /// Hauteur relative de la zone des tuiles d'opportunité. Rapportée à
  /// [bentoGoalFlex], elle garde les tuiles d'opportunité plus petites.
  static const int bentoOpportunityFlex = 6;

  /// Hauteur minimale de l'écran du bento, titre compris. Sous cette hauteur
  /// (petits écrans, iPhone SE), l'écran défile au lieu d'écraser les tuiles.
  static const double bentoMinHeight = 660;
}
