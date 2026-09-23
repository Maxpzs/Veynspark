import 'package:veynspark_v1/engine/clock.dart';

/// Horloge simulée, réglée et avancée à la main.
class FakeClock implements Clock {
  FakeClock(this.current);

  DateTime current;

  @override
  DateTime now() => current;

  void advance(Duration duration) => current = current.add(duration);
}
