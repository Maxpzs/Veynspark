import 'package:flutter/material.dart';

import 'glyna_colors.dart';
import 'glyna_typography.dart';

/// Assemble le [ThemeData] de Glyna. Sombre par défaut.
abstract final class GlynaTheme {
  static ThemeData get dark => _build(GlynaColors.dark, Brightness.dark);

  static ThemeData get light => _build(GlynaColors.light, Brightness.light);

  static ThemeData _build(GlynaColors colors, Brightness brightness) {
    // Le rose reste hors du ColorScheme : aucun composant Material ne doit
    // l'utiliser par défaut. On le demande explicitement via GlynaColors.
    // Les erreurs sont sobres, jamais roses.
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: colors.brand,
      onPrimary: colors.text,
      secondary: colors.brand,
      onSecondary: colors.text,
      error: colors.text,
      onError: colors.background,
      surface: colors.surface,
      onSurface: colors.text,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.background,
      canvasColor: colors.background,
      fontFamily: GlynaTypography.bodyFamily,
      textTheme: GlynaTypography.textTheme(colors.text),
      splashFactory: NoSplash.splashFactory,
      extensions: <ThemeExtension<dynamic>>[colors],
    );
  }
}
