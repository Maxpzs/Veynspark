import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../models/challenge_log.dart';
import 'tables.dart';

part 'glyna_database.g.dart';

/// La base locale. Seul `GlynaRepository` s'en sert : le reste de l'app ne
/// manipule que les modèles de `lib/models/`.
@DriftDatabase(tables: [Goals, WeekQuotas, ChallengeLogs])
class GlynaDatabase extends _$GlynaDatabase {
  GlynaDatabase(super.executor);

  /// Base stockée sur l'appareil.
  GlynaDatabase.onDevice() : super(driftDatabase(name: 'glyna'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
