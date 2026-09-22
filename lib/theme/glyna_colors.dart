import 'package:flutter/material.dart';

/// Les cinq rôles de couleur de Glyna, pour un mode donné.
///
/// Le rose ([accent]) ne sert qu'aux moments qui tranchent : une réussite, une
/// bascule. Jamais deux éléments roses en même temps à l'écran.
@immutable
class GlynaColors extends ThemeExtension<GlynaColors> {
  const GlynaColors({
    required this.background,
    required this.surface,
    required this.brand,
    required this.accent,
    required this.text,
  });

  /// Mode sombre, le mode principal.
  static const GlynaColors dark = GlynaColors(
    background: Color(0xFF0C0C0E),
    surface: Color(0xFF1C1024),
    brand: Color(0xFF7C5CFF),
    accent: Color(0xFFFF4D9D),
    text: Color(0xFFEFE3CF),
  );

  /// Mode clair, secondaire.
  static const GlynaColors light = GlynaColors(
    background: Color(0xFFF3EEE3),
    surface: Color(0xFFFFFFFF),
    brand: Color(0xFF6A45F5),
    accent: Color(0xFFC82A6E),
    text: Color(0xFF171019),
  );

  /// Fond de l'app.
  final Color background;

  /// Surfaces et cartes, dont les tuiles du bento.
  final Color surface;

  /// Marque et actions : boutons, bord des tuiles à objectif.
  final Color brand;

  /// Accent rare, réservé aux réussites et aux bascules.
  final Color accent;

  /// Texte principal.
  final Color text;

  /// Raccourci : `GlynaColors.of(context).brand`.
  static GlynaColors of(BuildContext context) =>
      Theme.of(context).extension<GlynaColors>()!;

  @override
  GlynaColors copyWith({
    Color? background,
    Color? surface,
    Color? brand,
    Color? accent,
    Color? text,
  }) {
    return GlynaColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      brand: brand ?? this.brand,
      accent: accent ?? this.accent,
      text: text ?? this.text,
    );
  }

  @override
  GlynaColors lerp(GlynaColors? other, double t) {
    if (other == null) return this;
    return GlynaColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      brand: Color.lerp(brand, other.brand, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      text: Color.lerp(text, other.text, t)!,
    );
  }
}
