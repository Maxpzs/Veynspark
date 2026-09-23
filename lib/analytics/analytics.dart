/// Journal des événements qui décident de la suite du projet. L'app appelle
/// ces méthodes sans savoir où les événements vont.
abstract interface class Analytics {
  Future<void> appOpened();

  /// [step] est le numéro de l'écran, de 1 à 12.
  Future<void> onboardingStepReached(int step);

  Future<void> onboardingCompleted();

  Future<void> challengeProposed(String challengeId);

  Future<void> challengeAccepted(String challengeId);

  Future<void> challengePostponed(String challengeId);

  Future<void> feedPostSeen(String postId);

  Future<void> challengeTakenUpFromFeed(String postId, String challengeId);
}
