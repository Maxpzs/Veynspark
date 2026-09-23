/// L'heure qu'il est. Tout le code qui a besoin de la date courante la lit
/// ici, jamais par `DateTime.now()` : c'est ce qui permet de voyager dans le
/// temps en mode debug, et de figer l'heure dans les tests.
abstract interface class Clock {
  DateTime now();
}

/// L'heure de l'appareil.
class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}

/// Une horloge en avance d'un nombre de jours calendaires sur [base].
///
/// Le décalage se compte en jours et non en heures : avancer d'un jour garde
/// la même heure le lendemain, même à travers un changement d'heure.
class OffsetClock implements Clock {
  OffsetClock({Clock base = const SystemClock()}) : _base = base;

  final Clock _base;
  int _days = 0;

  /// Nombre de jours d'avance sur [base].
  int get days => _days;

  void advance({required int days}) {
    assert(days >= 0, 'On avance dans le temps, on ne recule pas.');
    _days += days;
  }

  /// Revient à l'heure de [base].
  void reset() => _days = 0;

  @override
  DateTime now() {
    final t = _base.now();
    if (_days == 0) return t;
    final shift = t.isUtc ? DateTime.utc : DateTime.new;
    return shift(
      t.year,
      t.month,
      t.day + _days,
      t.hour,
      t.minute,
      t.second,
      t.millisecond,
      t.microsecond,
    );
  }
}
