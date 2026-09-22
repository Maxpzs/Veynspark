/// Espacements de Glyna, sur une base de 4.
///
/// Beaucoup de vide : les marges généreuses font partie de la marque.
abstract final class GlynaSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;

  /// Marge latérale des écrans.
  static const double screenGutter = lg;

  /// Écart entre les tuiles du bento.
  static const double bentoGap = sm;

  /// Taille minimale d'une cible tactile. On utilise Glyna debout, en manteau,
  /// entre deux choses : plus large que les 48 dp recommandés.
  static const double minTouchTarget = 56;
}
