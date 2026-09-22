import 'clean_cue.dart';

/// Joue les sons de nettoyage.
///
/// Toute implémentation doit respecter le mode silencieux du système et ne
/// rien jouer pendant un défi à minuteur en cours. Aucun son pour un échec,
/// un report ou une journée vide : le silence n'est jamais une punition.
abstract interface class SoundPlayer {
  Future<void> play(CleanCue cue);
}

/// En attendant les fichiers audio : ne joue rien.
class SilentSoundPlayer implements SoundPlayer {
  const SilentSoundPlayer();

  @override
  Future<void> play(CleanCue cue) async {}
}
