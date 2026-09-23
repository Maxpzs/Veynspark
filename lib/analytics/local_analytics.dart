import '../engine/clock.dart';
import '../store/glyna_repository.dart';
import 'analytics.dart';
import 'analytics_event.dart';

/// Écrit les événements dans la base de l'appareil. Rien ne sort du
/// téléphone.
class LocalAnalytics implements Analytics {
  LocalAnalytics(this._repository, {Clock clock = const SystemClock()})
    : _clock = clock;

  final GlynaRepository _repository;

  final Clock _clock;

  @override
  Future<void> appOpened() => _record(AnalyticsEventType.appOpened);

  @override
  Future<void> onboardingStepReached(int step) {
    assert(step >= 1, 'Les écrans d’onboarding se comptent à partir de 1.');
    return _record(AnalyticsEventType.onboardingStepReached, step: step);
  }

  @override
  Future<void> onboardingCompleted() =>
      _record(AnalyticsEventType.onboardingCompleted);

  @override
  Future<void> challengeProposed(String challengeId) =>
      _record(AnalyticsEventType.challengeProposed, challengeId: challengeId);

  @override
  Future<void> challengeAccepted(String challengeId) =>
      _record(AnalyticsEventType.challengeAccepted, challengeId: challengeId);

  @override
  Future<void> challengePostponed(String challengeId) =>
      _record(AnalyticsEventType.challengePostponed, challengeId: challengeId);

  @override
  Future<void> feedPostSeen(String postId) =>
      _record(AnalyticsEventType.feedPostSeen, postId: postId);

  @override
  Future<void> challengeTakenUpFromFeed(String postId, String challengeId) =>
      _record(
        AnalyticsEventType.challengeTakenUpFromFeed,
        postId: postId,
        challengeId: challengeId,
      );

  /// Les événements datés de [from] inclus à [to] exclu, dans l'ordre où ils
  /// ont été enregistrés.
  Future<List<AnalyticsEvent>> eventsBetween(DateTime from, DateTime to) =>
      _repository.eventsBetween(from, to);

  Future<void> _record(
    AnalyticsEventType type, {
    String? challengeId,
    int? step,
    String? postId,
  }) => _repository.addEvent(
    AnalyticsEvent(
      type: type,
      at: _clock.now(),
      challengeId: challengeId,
      onboardingStep: step,
      feedPostId: postId,
    ),
  );
}
