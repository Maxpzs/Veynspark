import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../validation/lock_detector.dart';

/// Un détecteur de verrouillage qu'on peut simuler. Réservé au mode debug :
/// `main.dart` ne le crée jamais en production.
///
/// Sans simulation, il relaie l'appareil. En simulation, chaque passage de
/// l'app en arrière-plan compte comme un verrouillage, et chaque retour comme
/// un déverrouillage. Utile là où l'appareil ne dit rien : sur un iPhone ou
/// un simulateur iOS sans code, les données protégées restent disponibles et
/// aucun verrouillage n'est jamais signalé. Pour tester une sortie de l'app,
/// on coupe la simulation.
///
/// La bascule se fait à chaud : un minuteur déjà lancé passe d'une source à
/// l'autre et reçoit aussitôt l'état de la nouvelle.
class DebugLockDetector implements LockDetector {
  DebugLockDetector(this._device);

  final LockDetector _device;
  final ValueNotifier<bool> _simulating = ValueNotifier<bool>(false);

  /// Vrai quand le verrouillage suit le cycle de vie de l'app, plus
  /// l'appareil.
  ValueListenable<bool> get simulating => _simulating;

  void setSimulating(bool value) => _simulating.value = value;

  @override
  Stream<bool> get lockStates {
    StreamSubscription<bool>? device;
    AppLifecycleListener? lifecycle;
    late final StreamController<bool> controller;

    // Libéré au tour suivant : l'arrêt de l'écoute peut venir d'un
    // changement de cycle de vie en cours de distribution, qui appellerait
    // encore cet écouteur.
    void releaseLifecycle() {
      final listener = lifecycle;
      lifecycle = null;
      if (listener != null) scheduleMicrotask(listener.dispose);
    }

    void follow() {
      if (_simulating.value) {
        unawaited(device?.cancel());
        device = null;
        lifecycle ??= AppLifecycleListener(
          onHide: () => controller.add(true),
          onShow: () => controller.add(false),
        );
        // La bascule se fait depuis l'app : elle est affichée.
        controller.add(false);
      } else {
        releaseLifecycle();
        // L'appareil émet son état courant dès l'abonnement.
        device ??= _device.lockStates.listen(
          controller.add,
          onError: controller.addError,
        );
      }
    }

    controller = StreamController<bool>(
      onListen: () {
        _simulating.addListener(follow);
        follow();
      },
      onCancel: () async {
        _simulating.removeListener(follow);
        releaseLifecycle();
        await device?.cancel();
        device = null;
      },
    );
    return controller.stream;
  }
}
