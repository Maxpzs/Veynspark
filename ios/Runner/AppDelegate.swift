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
///
/// iOS ne rend les données protégées indisponibles qu'une dizaine de secondes
/// après le verrouillage, alors qu'une app en arrière-plan est suspendue en
/// quelques secondes. Tant que le flux est écouté (un défi à minuteur est en
/// cours), on demande donc un délai d'arrière-plan au départ de l'app, rendu
/// dès que le verrouillage est signalé ou que l'app revient.
///
/// Sans code sur l'appareil, les données protégées restent toujours
/// disponibles : aucun verrouillage n'est jamais signalé.
final class GlynaLockStream: NSObject, FlutterStreamHandler {
  private var sink: FlutterEventSink?
  private var observers: [NSObjectProtocol] = []
  private var backgroundTask: UIBackgroundTaskIdentifier = .invalid

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    sink = events
    let center = NotificationCenter.default
    observers = [
      center.addObserver(
        forName: UIApplication.protectedDataWillBecomeUnavailableNotification,
        object: nil, queue: .main
      ) { [weak self] _ in
        self?.sink?(true)
        self?.endBackgroundTask()
      },
      center.addObserver(
        forName: UIApplication.protectedDataDidBecomeAvailableNotification,
        object: nil, queue: .main
      ) { [weak self] _ in self?.sink?(false) },
      center.addObserver(
        forName: UIApplication.didEnterBackgroundNotification,
        object: nil, queue: .main
      ) { [weak self] _ in self?.beginBackgroundTask() },
      center.addObserver(
        forName: UIApplication.willEnterForegroundNotification,
        object: nil, queue: .main
      ) { [weak self] _ in self?.endBackgroundTask() },
    ]
    events(!UIApplication.shared.isProtectedDataAvailable)
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    observers.forEach(NotificationCenter.default.removeObserver)
    observers = []
    sink = nil
    endBackgroundTask()
    return nil
  }

  private func beginBackgroundTask() {
    guard backgroundTask == .invalid else { return }
    backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "GlynaLock") {
      [weak self] in self?.endBackgroundTask()
    }
  }

  private func endBackgroundTask() {
    guard backgroundTask != .invalid else { return }
    UIApplication.shared.endBackgroundTask(backgroundTask)
    backgroundTask = .invalid
  }
}
