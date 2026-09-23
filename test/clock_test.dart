import 'package:flutter_test/flutter_test.dart';
import 'package:veynspark_v1/engine/clock.dart';

import 'support/fake_clock.dart';

void main() {
  group('OffsetClock', () {
    test('sans avance, rend l’heure de sa base', () {
      final base = FakeClock(DateTime(2026, 9, 23, 10, 4));
      expect(OffsetClock(base: base).now(), base.now());
    });

    test('avance en jours calendaires, à la même heure', () {
      final clock = OffsetClock(base: FakeClock(DateTime(2026, 9, 23, 10, 4)))
        ..advance(days: 1);
      expect(clock.now(), DateTime(2026, 9, 24, 10, 4));
      clock.advance(days: 7);
      expect(clock.now(), DateTime(2026, 10, 1, 10, 4));
      expect(clock.days, 8);
    });

    test('garde l’heure à travers un changement d’heure', () {
      // Nuit du 24 au 25 octobre 2026 : passage à l’heure d’hiver en Europe.
      final clock = OffsetClock(base: FakeClock(DateTime(2026, 10, 24, 23, 30)))
        ..advance(days: 1);
      expect(clock.now(), DateTime(2026, 10, 25, 23, 30));
    });

    test('suit sa base quand elle avance', () {
      final base = FakeClock(DateTime(2026, 9, 23, 10));
      final clock = OffsetClock(base: base)..advance(days: 2);
      base.advance(const Duration(minutes: 30));
      expect(clock.now(), DateTime(2026, 9, 25, 10, 30));
    });

    test('revient à l’heure réelle', () {
      final base = FakeClock(DateTime(2026, 9, 23, 10));
      final clock = OffsetClock(base: base)
        ..advance(days: 3)
        ..reset();
      expect(clock.now(), base.now());
    });

    test('une heure UTC reste en UTC', () {
      final clock = OffsetClock(base: FakeClock(DateTime.utc(2026, 9, 23, 10)))
        ..advance(days: 1);
      expect(clock.now(), DateTime.utc(2026, 9, 24, 10));
    });
  });
}
