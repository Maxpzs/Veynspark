import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typographie de Glyna.
///
/// **Anton** pour les titres : capitales, très gros, interlignage serré.
/// **Archivo** pour tout le reste : discret.
/// Le contraste entre les deux est l'essentiel de l'identité.
///
/// Flutter ne sait pas forcer les capitales depuis un [TextStyle] : les textes
/// de titre sont écrits en capitales dans `lib/content/`.
///
/// Les deux polices sont servies par `google_fonts`. [display] et [body] sont
/// leurs noms Google Fonts, pas des familles enregistrées telles quelles : pour
/// obtenir un style, passer par [textTheme] ou [bodyFamily].
abstract final class GlynaTypography {
  static const String display = 'Anton';
  static const String body = 'Archivo';

  /// Famille Archivo telle qu'enregistrée par `google_fonts`, pour le
  /// `fontFamily` par défaut du thème.
  static String? get bodyFamily => GoogleFonts.getFont(body).fontFamily;

  /// Interlignage serré des titres.
  static const double _displayHeight = 0.95;

  /// Construit le [TextTheme] complet dans la couleur de texte donnée.
  static TextTheme textTheme(Color color) {
    TextStyle anton(double size) => GoogleFonts.getFont(
      display,
      textStyle: TextStyle(
        fontSize: size,
        height: _displayHeight,
        letterSpacing: 0,
        color: color,
      ),
    );

    TextStyle archivo(
      double size, {
      FontWeight weight = FontWeight.w400,
      double height = 1.4,
    }) => GoogleFonts.getFont(
      body,
      textStyle: TextStyle(
        fontSize: size,
        fontWeight: weight,
        height: height,
        color: color,
      ),
    );

    return TextTheme(
      // Titres Anton : accroche, révélation, réussite.
      displayLarge: anton(88),
      displayMedium: anton(64),
      displaySmall: anton(48),
      headlineLarge: anton(40),
      headlineMedium: anton(32),
      headlineSmall: anton(26),
      // Archivo : tout le reste.
      titleLarge: archivo(22, weight: FontWeight.w600, height: 1.25),
      titleMedium: archivo(18, weight: FontWeight.w600, height: 1.3),
      titleSmall: archivo(15, weight: FontWeight.w600, height: 1.3),
      bodyLarge: archivo(17),
      bodyMedium: archivo(15),
      bodySmall: archivo(13),
      labelLarge: archivo(17, weight: FontWeight.w600, height: 1.2),
      labelMedium: archivo(14, weight: FontWeight.w500, height: 1.2),
      labelSmall: archivo(12, weight: FontWeight.w500, height: 1.2),
    );
  }
}
