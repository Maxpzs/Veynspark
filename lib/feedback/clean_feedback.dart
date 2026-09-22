import 'clean_cue.dart';
import 'haptics.dart';
import 'sound_player.dart';

/// Coordonne son et vibration du bento. La vibration de nettoyage est
/// toujours couplée au son, jamais seule.
class CleanFeedback {
  const CleanFeedback({this.sound = const SilentSoundPlayer()});

  final SoundPlayer sound;

  void tileTap() => Haptics.play(HapticMoment.tileTap);

  /// Au moment où la tuile, enfoncée, quitte la grille.
  void tileCleaned(CleanCue cue) {
    sound.play(cue);
    Haptics.play(
      cue.isResolution ? HapticMoment.gridCleared : HapticMoment.tileCleaned,
    );
  }
}
