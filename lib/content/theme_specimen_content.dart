/// Textes de l'écran de démonstration du thème.
///
/// TEMPORAIRE : à supprimer avec `lib/screens/theme_specimen/`.
abstract final class ThemeSpecimenContent {
  static const String typeSection = 'Typographie';
  static const String colorSection = 'Couleurs';

  static const String switchToLight = 'Voir le thème clair';
  static const String switchToDark = 'Voir le thème sombre';

  /// Échantillon des styles Anton, en capitales comme dans l'app.
  static const String displaySample = 'PLUS TARD, C\'EST MAINTENANT.';

  /// Échantillon des styles Archivo.
  static const String bodySample = 'Instagram t\'attend. Il attendra.';

  /// Noms des styles du [TextTheme], dans l'ordre de l'échelle.
  static const List<String> styleNames = [
    'displayLarge',
    'displayMedium',
    'displaySmall',
    'headlineLarge',
    'headlineMedium',
    'headlineSmall',
    'titleLarge',
    'titleMedium',
    'titleSmall',
    'bodyLarge',
    'bodyMedium',
    'bodySmall',
    'labelLarge',
    'labelMedium',
    'labelSmall',
  ];

  /// Nombre de styles Anton en tête de [styleNames].
  static const int displayStyleCount = 6;

  static const String background = 'Fond';
  static const String surface = 'Surfaces';
  static const String brand = 'Marque, actions';
  static const String accent = 'Accent rare';
  static const String text = 'Texte';

  /// Taille, graisse et interlignage d'un style, ex. « 88 · w400 · 0.95 ».
  static String styleSpec(double size, int weight, double height) =>
      '${_trim(size)} · w$weight · ${_trim(height)}';

  static String _trim(double value) =>
      value == value.roundToDouble() ? value.toInt().toString() : '$value';
}
