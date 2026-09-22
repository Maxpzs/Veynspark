import 'package:flutter/services.dart';

/// Les moments qui vibrent, d'après le tableau du brief
/// (« Le plaisir de nettoyer »).
///
/// Le rendu exact par plateforme est dans le code natif :
/// `ios/Runner/AppDelegate.swift` et `android/.../GlynaHaptics.kt`.
enum HapticMoment {
  /// iOS : impact léger. Android : `EFFECT_TICK`.
  tileTap,

  /// iOS : impact moyen. Android : `EFFECT_CLICK`.
  challengeAccepted,

  /// iOS : impact lourd. Android : `EFFECT_HEAVY_CLICK`.
  tileCleaned,

  /// iOS : impact lourd puis retour de succès. Android : deux impulsions.
  gridCleared,

  /// Prise d'un défi en glisser-déposer. iOS : léger. Android : `EFFECT_TICK`.
  dragPickUp,

  /// Pose d'un défi en glisser-déposer. iOS : moyen. Android : `EFFECT_CLICK`.
  dragDrop,
}

/// Déclenche les vibrations par un canal natif.
///
/// `HapticFeedback` de Flutter ne donne ni les effets prédéfinis d'Android ni
/// le retour de succès d'iOS, d'où le canal.
abstract final class Haptics {
  static const MethodChannel _channel = MethodChannel('glyna/haptics');

  static Future<void> play(HapticMoment moment) async {
    try {
      await _channel.invokeMethod<void>('play', moment.name);
    } on MissingPluginException {
      // Plateforme sans implémentation (tests, cibles non mobiles) : rien.
    } on PlatformException {
      // Une vibration ratée ne doit jamais interrompre l'app.
    }
  }
}
