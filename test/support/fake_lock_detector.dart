import 'dart:async';

import 'package:veynspark_v1/validation/lock_detector.dart';

/// Détecteur simulé : l'état courant est émis dès l'abonnement, puis chaque
/// changement, de façon synchrone.
class FakeLockDetector implements LockDetector {
  FakeLockDetector({bool locked = false}) : _locked = locked;

  bool _locked;
  late final StreamController<bool> _controller = StreamController.broadcast(
    sync: true,
    onListen: () => _controller.add(_locked),
  );

  bool get hasListener => _controller.hasListener;

  @override
  Stream<bool> get lockStates => _controller.stream;

  void lock() => _set(true);
  void unlock() => _set(false);

  void _set(bool locked) {
    _locked = locked;
    _controller.add(locked);
  }
}
