import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let haptics = GlynaHaptics()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let registrar = registrar(forPlugin: "GlynaHaptics") {
      let channel = FlutterMethodChannel(
        name: "glyna/haptics", binaryMessenger: registrar.messenger())
      channel.setMethodCallHandler { [haptics] call, result in
        guard call.method == "play", let moment = call.arguments as? String else {
          result(FlutterMethodNotImplemented)
          return
        }
        haptics.play(moment)
        result(nil)
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

/// Vibrations de Glyna, selon le tableau du brief (« Le plaisir de nettoyer »).
/// Les noms des moments sont ceux de `HapticMoment` côté Dart.
final class GlynaHaptics {
  private let light = UIImpactFeedbackGenerator(style: .light)
  private let medium = UIImpactFeedbackGenerator(style: .medium)
  private let heavy = UIImpactFeedbackGenerator(style: .heavy)
  private let notification = UINotificationFeedbackGenerator()

  /// Écart entre l'impact lourd et le retour de succès, grille nettoyée.
  private let successDelay: TimeInterval = 0.09

  func play(_ moment: String) {
    switch moment {
    case "tileTap", "dragPickUp":
      light.impactOccurred()
      // La tuile touchée sera peut-être nettoyée : on prépare l'impact lourd.
      heavy.prepare()
    case "challengeAccepted", "dragDrop":
      medium.impactOccurred()
    case "tileCleaned":
      heavy.impactOccurred()
    case "gridCleared":
      heavy.impactOccurred()
      notification.prepare()
      DispatchQueue.main.asyncAfter(deadline: .now() + successDelay) { [notification] in
        notification.notificationOccurred(.success)
      }
    default:
      break
    }
  }
}
