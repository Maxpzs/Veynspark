/// Source de l'état de verrouillage de l'appareil.
///
/// Le minuteur ne connaît que cette interface : la plateforme la fournit en
/// vrai (`PlatformLockDetector`), les tests la simulent.
abstract interface class LockDetector {
  /// Vrai quand l'appareil se verrouille, faux quand il se déverrouille.
  ///
  /// Le premier événement donne l'état courant, dès l'abonnement. Un même état
  /// peut être répété : c'est à l'écouteur d'ignorer les doublons.
  Stream<bool> get lockStates;
}
