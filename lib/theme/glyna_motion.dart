import 'package:flutter/widgets.dart';

/// Durées et courbes d'animation de Glyna.
///
/// Animations courtes, 200 à 400 ms, jamais bloquantes. Une seule animation
/// célébratoire par réussite.
abstract final class GlynaMotion {
  /// Retour immédiat : pression, changement d'état léger.
  static const Duration fast = Duration(milliseconds: 200);

  /// Transition standard entre deux états.
  static const Duration medium = Duration(milliseconds: 300);

  /// Plus longue durée autorisée pour une animation courante.
  static const Duration slow = Duration(milliseconds: 400);

  /// Enfoncement d'une tuile validée avant qu'elle ne quitte la grille.
  static const Duration tilePress = Duration(milliseconds: 120);

  /// Disparition d'une tuile nettoyée.
  static const Duration tileExit = Duration(milliseconds: 200);

  /// Recomposition de la grille après une tuile nettoyée, environ 350 ms.
  static const Duration gridSettle = Duration(milliseconds: 350);

  /// Durée maximale d'un son. Pas une animation, mais une contrainte de rythme
  /// que le mouvement ne doit pas dépasser.
  static const Duration maxSound = Duration(milliseconds: 400);

  /// Rafraîchissement d'un compteur affiché à la seconde. Pas une animation.
  static const Duration clockTick = Duration(seconds: 1);

  /// Échelle de départ de l'écran de réussite, qui s'ouvre en grandissant.
  static const double successStartScale = 0.9;

  /// Échelle d'une tuile qui s'enfonce légèrement.
  static const double tilePressScale = 0.94;

  /// Échelle d'une tuile nettoyée à la fin de sa disparition.
  static const double tileExitScale = 0.8;

  /// Courbe par défaut.
  static const Curve standard = Curves.easeOutCubic;

  /// Courbe de sortie d'une tuile.
  static const Curve exit = Curves.easeInCubic;

  /// Ressort de la grille qui se referme : amorti, léger dépassement, stabilisé
  /// en environ 350 ms. C'est le mouvement signature du produit.
  static final SpringDescription gridSpring =
      SpringDescription.withDampingRatio(mass: 1, stiffness: 230, ratio: 0.75);
}
