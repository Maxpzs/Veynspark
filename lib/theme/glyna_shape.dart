/// Formes de Glyna : rayons, bords, proportions du bento.
abstract final class GlynaShape {
  /// Rayon des tuiles du bento.
  static const double tileRadius = 20;

  /// Bord violet des tuiles à objectif.
  static const double goalBorderWidth = 2;

  /// La surface d'une tuile suit la durée du défi. En dessous de cette durée,
  /// une tuile garde la taille d'un défi de cette durée : un défi d'une
  /// minute doit rester lisible et facile à toucher.
  static const Duration bentoShortestTile = Duration(minutes: 10);

  /// Au-delà de cette durée, une tuile ne grandit plus : un défi de trois
  /// heures n'écrase pas le reste de la grille.
  static const Duration bentoLongestTile = Duration(minutes: 90);

  /// Plus petit côté accepté pour une tuile, pour qu'elle garde son titre et
  /// reste un gros élément tactile.
  static const double bentoMinTileSide = 112;

  /// Rapport maximal entre le grand et le petit côté d'une tuile.
  static const double bentoMaxTileAspect = 3;

  /// Hauteur minimale de l'écran du bento, titre compris. Sous cette hauteur
  /// (petits écrans, iPhone SE), l'écran défile au lieu d'écraser les tuiles.
  static const double bentoMinHeight = 660;
}
