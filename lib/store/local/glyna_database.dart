import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../analytics/analytics_event.dart';
import '../../models/challenge.dart';
import '../../models/challenge_log.dart';
import 'tables.dart';

part 'glyna_database.g.dart';

/// La base locale. Seul `GlynaRepository` s'en sert : le reste de l'app ne
/// manipule que les modèles de `lib/models/`.
@DriftDatabase(tables: [Goals, WeekQuotas, ChallengeLogs, AnalyticsEvents])
class GlynaDatabase extends _$GlynaDatabase {
  GlynaDatabase(super.executor);

  /// Base stockée sur l'appareil.
  GlynaDatabase.onDevice() : super(driftDatabase(name: 'glyna'));

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(analyticsEvents);
      }
      if (from < 3) {
        // Aucune version antérieure n'écrit d'objectif : la table est vide, la
        // valeur de remplissage ne sert qu'à satisfaire SQLite.
        await migrator.alterTable(
          TableMigration(
            goals,
            newColumns: [goals.domain],
            columnTransformer: {
              goals.domain: Constant(ChallengeDomain.move.name),
            },
          ),
        );
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
