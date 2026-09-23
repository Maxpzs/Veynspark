import 'package:drift/native.dart';

/// Le schéma tel que les versions précédentes de l'app l'ont laissé sur
/// l'appareil, pour tester les migrations sur une base réaliste.
abstract final class LegacySchema {
  /// Version 1 : objectifs sans domaine, quotas, journal.
  static const List<String> _v1 = [
    '''
    CREATE TABLE goals (
      id TEXT NOT NULL,
      title TEXT NOT NULL,
      deadline TEXT NOT NULL,
      starting_level INTEGER NOT NULL,
      weekly_quota INTEGER NOT NULL,
      PRIMARY KEY (id)
    )''',
    '''
    CREATE TABLE week_quotas (
      goal_id TEXT NOT NULL REFERENCES goals (id) ON DELETE CASCADE,
      week_start TEXT NOT NULL,
      target INTEGER NOT NULL,
      done INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY (goal_id, week_start)
    )''',
    '''
    CREATE TABLE challenge_logs (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      challenge_id TEXT NOT NULL,
      date TEXT NOT NULL,
      status TEXT NOT NULL,
      postpone_reason TEXT NULL
    )''',
  ];

  /// Version 2 : la version 1, plus les événements de mesure.
  static const List<String> _v2 = [
    ..._v1,
    '''
    CREATE TABLE analytics_events (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      type TEXT NOT NULL,
      at TEXT NOT NULL,
      challenge_id TEXT NULL,
      onboarding_step INTEGER NULL,
      feed_post_id TEXT NULL
    )''',
  ];

  /// Prépare une base vide comme l'a laissée la version [version].
  static DatabaseSetup at(int version) {
    final statements = switch (version) {
      1 => _v1,
      2 => _v2,
      _ => throw ArgumentError.value(version, 'version', 'inconnue'),
    };
    return (db) {
      statements.forEach(db.execute);
      db.userVersion = version;
    };
  }
}
