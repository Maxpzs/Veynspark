import 'package:flutter/foundation.dart';

/// Le son d'une tuile nettoyée.
///
/// Chaque tuile joue la même note, un demi-ton plus haut que la précédente :
/// nettoyer la grille compose une gamme ascendante. La dernière tuile ne joue
/// pas de note, elle joue l'accord de résolution.
///
/// Les fichiers vivent dans `assets/sounds/` :
/// - `clean_note_0.wav` à `clean_note_3.wav`, chacun un demi-ton au-dessus du
///   précédent ;
/// - `clean_resolve.wav`, l'accord de résolution.
///
/// Quatre notes suffisent : le bento compte au plus cinq tuiles, et la
/// cinquième joue la résolution.
@immutable
class CleanCue {
  const CleanCue._(this.semitones, {required this.isResolution});

  /// Le son de la tuile nettoyée en position [index] (à partir de 0) sur une
  /// grille de [total] tuiles.
  factory CleanCue.forClean({required int index, required int total}) {
    assert(index >= 0 && index < total);
    if (index == total - 1) {
      return CleanCue._(index, isResolution: true);
    }
    return CleanCue._(index, isResolution: false);
  }

  static const int noteCount = 4;
  static const String _directory = 'assets/sounds';
  static const String _extension = 'wav';

  /// Écart en demi-tons avec la première note.
  final int semitones;

  /// Vrai pour la dernière tuile de la grille.
  final bool isResolution;

  /// Chemin du fichier à jouer. Au-delà de [noteCount] notes, la plus haute
  /// est rejouée.
  String get assetPath {
    if (isResolution) return '$_directory/clean_resolve.$_extension';
    final note = semitones < noteCount ? semitones : noteCount - 1;
    return '$_directory/clean_note_$note.$_extension';
  }

  @override
  bool operator ==(Object other) =>
      other is CleanCue &&
      other.semitones == semitones &&
      other.isResolution == isResolution;

  @override
  int get hashCode => Object.hash(semitones, isResolution);

  @override
  String toString() =>
      isResolution ? 'CleanCue.resolution' : 'CleanCue.note(+$semitones)';
}
