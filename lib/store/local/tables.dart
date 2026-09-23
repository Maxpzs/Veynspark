import 'package:drift/drift.dart';

import '../../analytics/analytics_event.dart';
import '../../models/challenge_log.dart';

@DataClassName('GoalRow')
class Goals extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  DateTimeColumn get deadline => dateTime()();
  IntColumn get startingLevel => integer()();
  IntColumn get weeklyQuota => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Un quota par objectif et par semaine. Abandonner un objectif emporte ses
/// quotas avec lui.
@DataClassName('WeekQuotaRow')
class WeekQuotas extends Table {
  TextColumn get goalId =>
      text().references(Goals, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get weekStart => dateTime()();
  IntColumn get target => integer()();
  IntColumn get done => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {goalId, weekStart};
}

/// Journal en ajout seul : un même défi peut y apparaître plusieurs fois le
/// même jour (proposé, puis accepté, puis réussi).
@DataClassName('ChallengeLogRow')
class ChallengeLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get challengeId => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get status => textEnum<ChallengeStatus>()();
  TextColumn get postponeReason => textEnum<PostponeReason>().nullable()();
}

/// Événements de mesure, en ajout seul. Restent sur l'appareil.
@DataClassName('AnalyticsEventRow')
class AnalyticsEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => textEnum<AnalyticsEventType>()();
  DateTimeColumn get at => dateTime()();
  TextColumn get challengeId => text().nullable()();
  IntColumn get onboardingStep => integer().nullable()();
  TextColumn get feedPostId => text().nullable()();
}
