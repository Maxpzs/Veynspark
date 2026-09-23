/// Les quatre moments de la journée, ceux de la grille « Apprends-moi ta
/// semaine ».
enum DayMoment {
  /// De 5 h à midi.
  morning,

  /// De midi à 18 h.
  afternoon,

  /// De 18 h à 22 h.
  evening,

  /// De 22 h à 5 h.
  night;

  /// Le moment qui contient [time].
  static DayMoment of(DateTime time) => switch (time.hour) {
    >= 5 && < 12 => morning,
    >= 12 && < 18 => afternoon,
    >= 18 && < 22 => evening,
    _ => night,
  };
}
