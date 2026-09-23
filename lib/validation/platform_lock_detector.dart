import 'package:flutter/services.dart';

import 'lock_detector.dart';

/// L'état de verrouillage lu par un canal natif, selon la note technique du
/// brief (« Faire un défi, et le valider ») :
///
/// - iOS : `UIApplication.isProtectedDataAvailable` et ses notifications,
///   dans `ios/Runner/AppDelegate.swift` ;
/// - Android : diffusions d'état d'écran et de verrouillage, dans
///   `android/.../GlynaLockStream.kt`.
///
/// Aucune autorisation spéciale requise.
class PlatformLockDetector implements LockDetector {
  const PlatformLockDetector();

  static const EventChannel _channel = EventChannel('glyna/lock');

  @override
  Stream<bool> get lockStates =>
      _channel.receiveBroadcastStream().map((event) => event as bool);
}
