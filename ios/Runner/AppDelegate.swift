import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let haptics = GlynaHaptics()
  private let lockStream = GlynaLockStream()

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
    if let registrar = registrar(forPlugin: "GlynaLock") {
      FlutterEventChannel(name: "glyna/lock", binaryMessenger: registrar.messenger())
        .setStreamHandler(lockStream)
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

/// État de verrouillage de l'appareil, pour les défis à minuteur.
///
/// Verrouillé tant que les données protégées sont indisponibles
/// (`isProtectedDataAvailable`). Émet l'état courant dès l'abonnement, puis
/// chaque changement. Aucune autorisation requise.
final class GlynaLockStream: NSObject, FlutterStreamHandler {
  private var sink: FlutterEventSink?
  private var observers: [NSObjectProtocol] = []

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    sink = events
    let center = NotificationCenter.default
    observers = [
      center.addObserver(
        forName: UIApplication.protectedDataWillBecomeUnavailableNotification,
        object: nil, queue: .main
      ) { [weak self] _ in self?.sink?(true) },
      center.addObserver(
        forName: UIApplication.protectedDataDidBecomeAvailableNotification,
        object: nil, queue: .main
      ) { [weak self] _ in self?.sink?(false) },
    ]
    events(!UIApplication.shared.isProtectedDataAvailable)
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    observers.forEach(NotificationCenter.default.removeObserver)
    observers = []
    sink = nil
    return nil
  }
}
