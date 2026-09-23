// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'glyna_database.dart';

// ignore_for_file: type=lint
class $GoalsTable extends Goals with TableInfo<$GoalsTable, GoalRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deadlineMeta = const VerificationMeta(
    'deadline',
  );
  @override
  late final GeneratedColumn<DateTime> deadline = GeneratedColumn<DateTime>(
    'deadline',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startingLevelMeta = const VerificationMeta(
    'startingLevel',
  );
  @override
  late final GeneratedColumn<int> startingLevel = GeneratedColumn<int>(
    'starting_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weeklyQuotaMeta = const VerificationMeta(
    'weeklyQuota',
  );
  @override
  late final GeneratedColumn<int> weeklyQuota = GeneratedColumn<int>(
    'weekly_quota',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    deadline,
    startingLevel,
    weeklyQuota,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<GoalRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('deadline')) {
      context.handle(
        _deadlineMeta,
        deadline.isAcceptableOrUnknown(data['deadline']!, _deadlineMeta),
      );
    } else if (isInserting) {
      context.missing(_deadlineMeta);
    }
    if (data.containsKey('starting_level')) {
      context.handle(
        _startingLevelMeta,
        startingLevel.isAcceptableOrUnknown(
          data['starting_level']!,
          _startingLevelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startingLevelMeta);
    }
    if (data.containsKey('weekly_quota')) {
      context.handle(
        _weeklyQuotaMeta,
        weeklyQuota.isAcceptableOrUnknown(
          data['weekly_quota']!,
          _weeklyQuotaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_weeklyQuotaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GoalRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      deadline: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deadline'],
      )!,
      startingLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}starting_level'],
      )!,
      weeklyQuota: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekly_quota'],
      )!,
    );
  }

  @override
  $GoalsTable createAlias(String alias) {
    return $GoalsTable(attachedDatabase, alias);
  }
}

class GoalRow extends DataClass implements Insertable<GoalRow> {
  final String id;
  final String title;
  final DateTime deadline;
  final int startingLevel;
  final int weeklyQuota;
  const GoalRow({
    required this.id,
    required this.title,
    required this.deadline,
    required this.startingLevel,
    required this.weeklyQuota,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['deadline'] = Variable<DateTime>(deadline);
    map['starting_level'] = Variable<int>(startingLevel);
    map['weekly_quota'] = Variable<int>(weeklyQuota);
    return map;
  }

  GoalsCompanion toCompanion(bool nullToAbsent) {
    return GoalsCompanion(
      id: Value(id),
      title: Value(title),
      deadline: Value(deadline),
      startingLevel: Value(startingLevel),
      weeklyQuota: Value(weeklyQuota),
    );
  }

  factory GoalRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      deadline: serializer.fromJson<DateTime>(json['deadline']),
      startingLevel: serializer.fromJson<int>(json['startingLevel']),
      weeklyQuota: serializer.fromJson<int>(json['weeklyQuota']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'deadline': serializer.toJson<DateTime>(deadline),
      'startingLevel': serializer.toJson<int>(startingLevel),
      'weeklyQuota': serializer.toJson<int>(weeklyQuota),
    };
  }

  GoalRow copyWith({
    String? id,
    String? title,
    DateTime? deadline,
    int? startingLevel,
    int? weeklyQuota,
  }) => GoalRow(
    id: id ?? this.id,
    title: title ?? this.title,
    deadline: deadline ?? this.deadline,
    startingLevel: startingLevel ?? this.startingLevel,
    weeklyQuota: weeklyQuota ?? this.weeklyQuota,
  );
  GoalRow copyWithCompanion(GoalsCompanion data) {
    return GoalRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      deadline: data.deadline.present ? data.deadline.value : this.deadline,
      startingLevel: data.startingLevel.present
          ? data.startingLevel.value
          : this.startingLevel,
      weeklyQuota: data.weeklyQuota.present
          ? data.weeklyQuota.value
          : this.weeklyQuota,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('deadline: $deadline, ')
          ..write('startingLevel: $startingLevel, ')
          ..write('weeklyQuota: $weeklyQuota')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, deadline, startingLevel, weeklyQuota);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.deadline == this.deadline &&
          other.startingLevel == this.startingLevel &&
          other.weeklyQuota == this.weeklyQuota);
}

class GoalsCompanion extends UpdateCompanion<GoalRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<DateTime> deadline;
  final Value<int> startingLevel;
  final Value<int> weeklyQuota;
  final Value<int> rowid;
  const GoalsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.deadline = const Value.absent(),
    this.startingLevel = const Value.absent(),
    this.weeklyQuota = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoalsCompanion.insert({
    required String id,
    required String title,
    required DateTime deadline,
    required int startingLevel,
    required int weeklyQuota,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       deadline = Value(deadline),
       startingLevel = Value(startingLevel),
       weeklyQuota = Value(weeklyQuota);
  static Insertable<GoalRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<DateTime>? deadline,
    Expression<int>? startingLevel,
    Expression<int>? weeklyQuota,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (deadline != null) 'deadline': deadline,
      if (startingLevel != null) 'starting_level': startingLevel,
      if (weeklyQuota != null) 'weekly_quota': weeklyQuota,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoalsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<DateTime>? deadline,
    Value<int>? startingLevel,
    Value<int>? weeklyQuota,
    Value<int>? rowid,
  }) {
    return GoalsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      deadline: deadline ?? this.deadline,
      startingLevel: startingLevel ?? this.startingLevel,
      weeklyQuota: weeklyQuota ?? this.weeklyQuota,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (deadline.present) {
      map['deadline'] = Variable<DateTime>(deadline.value);
    }
    if (startingLevel.present) {
      map['starting_level'] = Variable<int>(startingLevel.value);
    }
    if (weeklyQuota.present) {
      map['weekly_quota'] = Variable<int>(weeklyQuota.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('deadline: $deadline, ')
          ..write('startingLevel: $startingLevel, ')
          ..write('weeklyQuota: $weeklyQuota, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WeekQuotasTable extends WeekQuotas
    with TableInfo<$WeekQuotasTable, WeekQuotaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeekQuotasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _goalIdMeta = const VerificationMeta('goalId');
  @override
  late final GeneratedColumn<String> goalId = GeneratedColumn<String>(
    'goal_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES goals (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _weekStartMeta = const VerificationMeta(
    'weekStart',
  );
  @override
  late final GeneratedColumn<DateTime> weekStart = GeneratedColumn<DateTime>(
    'week_start',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetMeta = const VerificationMeta('target');
  @override
  late final GeneratedColumn<int> target = GeneratedColumn<int>(
    'target',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doneMeta = const VerificationMeta('done');
  @override
  late final GeneratedColumn<int> done = GeneratedColumn<int>(
    'done',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [goalId, weekStart, target, done];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'week_quotas';
  @override
  VerificationContext validateIntegrity(
    Insertable<WeekQuotaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('goal_id')) {
      context.handle(
        _goalIdMeta,
        goalId.isAcceptableOrUnknown(data['goal_id']!, _goalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_goalIdMeta);
    }
    if (data.containsKey('week_start')) {
      context.handle(
        _weekStartMeta,
        weekStart.isAcceptableOrUnknown(data['week_start']!, _weekStartMeta),
      );
    } else if (isInserting) {
      context.missing(_weekStartMeta);
    }
    if (data.containsKey('target')) {
      context.handle(
        _targetMeta,
        target.isAcceptableOrUnknown(data['target']!, _targetMeta),
      );
    } else if (isInserting) {
      context.missing(_targetMeta);
    }
    if (data.containsKey('done')) {
      context.handle(
        _doneMeta,
        done.isAcceptableOrUnknown(data['done']!, _doneMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {goalId, weekStart};
  @override
  WeekQuotaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeekQuotaRow(
      goalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal_id'],
      )!,
      weekStart: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}week_start'],
      )!,
      target: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target'],
      )!,
      done: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}done'],
      )!,
    );
  }

  @override
  $WeekQuotasTable createAlias(String alias) {
    return $WeekQuotasTable(attachedDatabase, alias);
  }
}

class WeekQuotaRow extends DataClass implements Insertable<WeekQuotaRow> {
  final String goalId;
  final DateTime weekStart;
  final int target;
  final int done;
  const WeekQuotaRow({
    required this.goalId,
    required this.weekStart,
    required this.target,
    required this.done,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['goal_id'] = Variable<String>(goalId);
    map['week_start'] = Variable<DateTime>(weekStart);
    map['target'] = Variable<int>(target);
    map['done'] = Variable<int>(done);
    return map;
  }

  WeekQuotasCompanion toCompanion(bool nullToAbsent) {
    return WeekQuotasCompanion(
      goalId: Value(goalId),
      weekStart: Value(weekStart),
      target: Value(target),
      done: Value(done),
    );
  }

  factory WeekQuotaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeekQuotaRow(
      goalId: serializer.fromJson<String>(json['goalId']),
      weekStart: serializer.fromJson<DateTime>(json['weekStart']),
      target: serializer.fromJson<int>(json['target']),
      done: serializer.fromJson<int>(json['done']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'goalId': serializer.toJson<String>(goalId),
      'weekStart': serializer.toJson<DateTime>(weekStart),
      'target': serializer.toJson<int>(target),
      'done': serializer.toJson<int>(done),
    };
  }

  WeekQuotaRow copyWith({
    String? goalId,
    DateTime? weekStart,
    int? target,
    int? done,
  }) => WeekQuotaRow(
    goalId: goalId ?? this.goalId,
    weekStart: weekStart ?? this.weekStart,
    target: target ?? this.target,
    done: done ?? this.done,
  );
  WeekQuotaRow copyWithCompanion(WeekQuotasCompanion data) {
    return WeekQuotaRow(
      goalId: data.goalId.present ? data.goalId.value : this.goalId,
      weekStart: data.weekStart.present ? data.weekStart.value : this.weekStart,
      target: data.target.present ? data.target.value : this.target,
      done: data.done.present ? data.done.value : this.done,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeekQuotaRow(')
          ..write('goalId: $goalId, ')
          ..write('weekStart: $weekStart, ')
          ..write('target: $target, ')
          ..write('done: $done')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(goalId, weekStart, target, done);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeekQuotaRow &&
          other.goalId == this.goalId &&
          other.weekStart == this.weekStart &&
          other.target == this.target &&
          other.done == this.done);
}

class WeekQuotasCompanion extends UpdateCompanion<WeekQuotaRow> {
  final Value<String> goalId;
  final Value<DateTime> weekStart;
  final Value<int> target;
  final Value<int> done;
  final Value<int> rowid;
  const WeekQuotasCompanion({
    this.goalId = const Value.absent(),
    this.weekStart = const Value.absent(),
    this.target = const Value.absent(),
    this.done = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WeekQuotasCompanion.insert({
    required String goalId,
    required DateTime weekStart,
    required int target,
    this.done = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : goalId = Value(goalId),
       weekStart = Value(weekStart),
       target = Value(target);
  static Insertable<WeekQuotaRow> custom({
    Expression<String>? goalId,
    Expression<DateTime>? weekStart,
    Expression<int>? target,
    Expression<int>? done,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (goalId != null) 'goal_id': goalId,
      if (weekStart != null) 'week_start': weekStart,
      if (target != null) 'target': target,
      if (done != null) 'done': done,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WeekQuotasCompanion copyWith({
    Value<String>? goalId,
    Value<DateTime>? weekStart,
    Value<int>? target,
    Value<int>? done,
    Value<int>? rowid,
  }) {
    return WeekQuotasCompanion(
      goalId: goalId ?? this.goalId,
      weekStart: weekStart ?? this.weekStart,
      target: target ?? this.target,
      done: done ?? this.done,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (goalId.present) {
      map['goal_id'] = Variable<String>(goalId.value);
    }
    if (weekStart.present) {
      map['week_start'] = Variable<DateTime>(weekStart.value);
    }
    if (target.present) {
      map['target'] = Variable<int>(target.value);
    }
    if (done.present) {
      map['done'] = Variable<int>(done.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeekQuotasCompanion(')
          ..write('goalId: $goalId, ')
          ..write('weekStart: $weekStart, ')
          ..write('target: $target, ')
          ..write('done: $done, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChallengeLogsTable extends ChallengeLogs
    with TableInfo<$ChallengeLogsTable, ChallengeLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChallengeLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _challengeIdMeta = const VerificationMeta(
    'challengeId',
  );
  @override
  late final GeneratedColumn<String> challengeId = GeneratedColumn<String>(
    'challenge_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ChallengeStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ChallengeStatus>($ChallengeLogsTable.$converterstatus);
  @override
  late final GeneratedColumnWithTypeConverter<PostponeReason?, String>
  postponeReason =
      GeneratedColumn<String>(
        'postpone_reason',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<PostponeReason?>(
        $ChallengeLogsTable.$converterpostponeReasonn,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    challengeId,
    date,
    status,
    postponeReason,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'challenge_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChallengeLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('challenge_id')) {
      context.handle(
        _challengeIdMeta,
        challengeId.isAcceptableOrUnknown(
          data['challenge_id']!,
          _challengeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_challengeIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChallengeLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChallengeLogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      challengeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}challenge_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      status: $ChallengeLogsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      postponeReason: $ChallengeLogsTable.$converterpostponeReasonn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}postpone_reason'],
        ),
      ),
    );
  }

  @override
  $ChallengeLogsTable createAlias(String alias) {
    return $ChallengeLogsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ChallengeStatus, String, String> $converterstatus =
      const EnumNameConverter<ChallengeStatus>(ChallengeStatus.values);
  static JsonTypeConverter2<PostponeReason, String, String>
  $converterpostponeReason = const EnumNameConverter<PostponeReason>(
    PostponeReason.values,
  );
  static JsonTypeConverter2<PostponeReason?, String?, String?>
  $converterpostponeReasonn = JsonTypeConverter2.asNullable(
    $converterpostponeReason,
  );
}

class ChallengeLogRow extends DataClass implements Insertable<ChallengeLogRow> {
  final int id;
  final String challengeId;
  final DateTime date;
  final ChallengeStatus status;
  final PostponeReason? postponeReason;
  const ChallengeLogRow({
    required this.id,
    required this.challengeId,
    required this.date,
    required this.status,
    this.postponeReason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['challenge_id'] = Variable<String>(challengeId);
    map['date'] = Variable<DateTime>(date);
    {
      map['status'] = Variable<String>(
        $ChallengeLogsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || postponeReason != null) {
      map['postpone_reason'] = Variable<String>(
        $ChallengeLogsTable.$converterpostponeReasonn.toSql(postponeReason),
      );
    }
    return map;
  }

  ChallengeLogsCompanion toCompanion(bool nullToAbsent) {
    return ChallengeLogsCompanion(
      id: Value(id),
      challengeId: Value(challengeId),
      date: Value(date),
      status: Value(status),
      postponeReason: postponeReason == null && nullToAbsent
          ? const Value.absent()
          : Value(postponeReason),
    );
  }

  factory ChallengeLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChallengeLogRow(
      id: serializer.fromJson<int>(json['id']),
      challengeId: serializer.fromJson<String>(json['challengeId']),
      date: serializer.fromJson<DateTime>(json['date']),
      status: $ChallengeLogsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      postponeReason: $ChallengeLogsTable.$converterpostponeReasonn.fromJson(
        serializer.fromJson<String?>(json['postponeReason']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'challengeId': serializer.toJson<String>(challengeId),
      'date': serializer.toJson<DateTime>(date),
      'status': serializer.toJson<String>(
        $ChallengeLogsTable.$converterstatus.toJson(status),
      ),
      'postponeReason': serializer.toJson<String?>(
        $ChallengeLogsTable.$converterpostponeReasonn.toJson(postponeReason),
      ),
    };
  }

  ChallengeLogRow copyWith({
    int? id,
    String? challengeId,
    DateTime? date,
    ChallengeStatus? status,
    Value<PostponeReason?> postponeReason = const Value.absent(),
  }) => ChallengeLogRow(
    id: id ?? this.id,
    challengeId: challengeId ?? this.challengeId,
    date: date ?? this.date,
    status: status ?? this.status,
    postponeReason: postponeReason.present
        ? postponeReason.value
        : this.postponeReason,
  );
  ChallengeLogRow copyWithCompanion(ChallengeLogsCompanion data) {
    return ChallengeLogRow(
      id: data.id.present ? data.id.value : this.id,
      challengeId: data.challengeId.present
          ? data.challengeId.value
          : this.challengeId,
      date: data.date.present ? data.date.value : this.date,
      status: data.status.present ? data.status.value : this.status,
      postponeReason: data.postponeReason.present
          ? data.postponeReason.value
          : this.postponeReason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChallengeLogRow(')
          ..write('id: $id, ')
          ..write('challengeId: $challengeId, ')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('postponeReason: $postponeReason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, challengeId, date, status, postponeReason);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChallengeLogRow &&
          other.id == this.id &&
          other.challengeId == this.challengeId &&
          other.date == this.date &&
          other.status == this.status &&
          other.postponeReason == this.postponeReason);
}

class ChallengeLogsCompanion extends UpdateCompanion<ChallengeLogRow> {
  final Value<int> id;
  final Value<String> challengeId;
  final Value<DateTime> date;
  final Value<ChallengeStatus> status;
  final Value<PostponeReason?> postponeReason;
  const ChallengeLogsCompanion({
    this.id = const Value.absent(),
    this.challengeId = const Value.absent(),
    this.date = const Value.absent(),
    this.status = const Value.absent(),
    this.postponeReason = const Value.absent(),
  });
  ChallengeLogsCompanion.insert({
    this.id = const Value.absent(),
    required String challengeId,
    required DateTime date,
    required ChallengeStatus status,
    this.postponeReason = const Value.absent(),
  }) : challengeId = Value(challengeId),
       date = Value(date),
       status = Value(status);
  static Insertable<ChallengeLogRow> custom({
    Expression<int>? id,
    Expression<String>? challengeId,
    Expression<DateTime>? date,
    Expression<String>? status,
    Expression<String>? postponeReason,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (challengeId != null) 'challenge_id': challengeId,
      if (date != null) 'date': date,
      if (status != null) 'status': status,
      if (postponeReason != null) 'postpone_reason': postponeReason,
    });
  }

  ChallengeLogsCompanion copyWith({
    Value<int>? id,
    Value<String>? challengeId,
    Value<DateTime>? date,
    Value<ChallengeStatus>? status,
    Value<PostponeReason?>? postponeReason,
  }) {
    return ChallengeLogsCompanion(
      id: id ?? this.id,
      challengeId: challengeId ?? this.challengeId,
      date: date ?? this.date,
      status: status ?? this.status,
      postponeReason: postponeReason ?? this.postponeReason,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (challengeId.present) {
      map['challenge_id'] = Variable<String>(challengeId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $ChallengeLogsTable.$converterstatus.toSql(status.value),
      );
    }
    if (postponeReason.present) {
      map['postpone_reason'] = Variable<String>(
        $ChallengeLogsTable.$converterpostponeReasonn.toSql(
          postponeReason.value,
        ),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChallengeLogsCompanion(')
          ..write('id: $id, ')
          ..write('challengeId: $challengeId, ')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('postponeReason: $postponeReason')
          ..write(')'))
        .toString();
  }
}

abstract class _$GlynaDatabase extends GeneratedDatabase {
  _$GlynaDatabase(QueryExecutor e) : super(e);
  $GlynaDatabaseManager get managers => $GlynaDatabaseManager(this);
  late final $GoalsTable goals = $GoalsTable(this);
  late final $WeekQuotasTable weekQuotas = $WeekQuotasTable(this);
  late final $ChallengeLogsTable challengeLogs = $ChallengeLogsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    goals,
    weekQuotas,
    challengeLogs,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'goals',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('week_quotas', kind: UpdateKind.delete)],
    ),
  ]);
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$GoalsTableCreateCompanionBuilder =
    GoalsCompanion Function({
      required String id,
      required String title,
      required DateTime deadline,
      required int startingLevel,
      required int weeklyQuota,
      Value<int> rowid,
    });
typedef $$GoalsTableUpdateCompanionBuilder =
    GoalsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<DateTime> deadline,
      Value<int> startingLevel,
      Value<int> weeklyQuota,
      Value<int> rowid,
    });

final class $$GoalsTableReferences
    extends BaseReferences<_$GlynaDatabase, $GoalsTable, GoalRow> {
  $$GoalsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WeekQuotasTable, List<WeekQuotaRow>>
  _weekQuotasRefsTable(_$GlynaDatabase db) => MultiTypedResultKey.fromTable(
    db.weekQuotas,
    aliasName: $_aliasNameGenerator(db.goals.id, db.weekQuotas.goalId),
  );

  $$WeekQuotasTableProcessedTableManager get weekQuotasRefs {
    final manager = $$WeekQuotasTableTableManager(
      $_db,
      $_db.weekQuotas,
    ).filter((f) => f.goalId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_weekQuotasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GoalsTableFilterComposer
    extends Composer<_$GlynaDatabase, $GoalsTable> {
  $$GoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startingLevel => $composableBuilder(
    column: $table.startingLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weeklyQuota => $composableBuilder(
    column: $table.weeklyQuota,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> weekQuotasRefs(
    Expression<bool> Function($$WeekQuotasTableFilterComposer f) f,
  ) {
    final $$WeekQuotasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.weekQuotas,
      getReferencedColumn: (t) => t.goalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WeekQuotasTableFilterComposer(
            $db: $db,
            $table: $db.weekQuotas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GoalsTableOrderingComposer
    extends Composer<_$GlynaDatabase, $GoalsTable> {
  $$GoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startingLevel => $composableBuilder(
    column: $table.startingLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weeklyQuota => $composableBuilder(
    column: $table.weeklyQuota,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GoalsTableAnnotationComposer
    extends Composer<_$GlynaDatabase, $GoalsTable> {
  $$GoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => column);

  GeneratedColumn<int> get startingLevel => $composableBuilder(
    column: $table.startingLevel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get weeklyQuota => $composableBuilder(
    column: $table.weeklyQuota,
    builder: (column) => column,
  );

  Expression<T> weekQuotasRefs<T extends Object>(
    Expression<T> Function($$WeekQuotasTableAnnotationComposer a) f,
  ) {
    final $$WeekQuotasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.weekQuotas,
      getReferencedColumn: (t) => t.goalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WeekQuotasTableAnnotationComposer(
            $db: $db,
            $table: $db.weekQuotas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GoalsTableTableManager
    extends
        RootTableManager<
          _$GlynaDatabase,
          $GoalsTable,
          GoalRow,
          $$GoalsTableFilterComposer,
          $$GoalsTableOrderingComposer,
          $$GoalsTableAnnotationComposer,
          $$GoalsTableCreateCompanionBuilder,
          $$GoalsTableUpdateCompanionBuilder,
          (GoalRow, $$GoalsTableReferences),
          GoalRow,
          PrefetchHooks Function({bool weekQuotasRefs})
        > {
  $$GoalsTableTableManager(_$GlynaDatabase db, $GoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime> deadline = const Value.absent(),
                Value<int> startingLevel = const Value.absent(),
                Value<int> weeklyQuota = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalsCompanion(
                id: id,
                title: title,
                deadline: deadline,
                startingLevel: startingLevel,
                weeklyQuota: weeklyQuota,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required DateTime deadline,
                required int startingLevel,
                required int weeklyQuota,
                Value<int> rowid = const Value.absent(),
              }) => GoalsCompanion.insert(
                id: id,
                title: title,
                deadline: deadline,
                startingLevel: startingLevel,
                weeklyQuota: weeklyQuota,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$GoalsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({weekQuotasRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (weekQuotasRefs) db.weekQuotas],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (weekQuotasRefs)
                    await $_getPrefetchedData<
                      GoalRow,
                      $GoalsTable,
                      WeekQuotaRow
                    >(
                      currentTable: table,
                      referencedTable: $$GoalsTableReferences
                          ._weekQuotasRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$GoalsTableReferences(db, table, p0).weekQuotasRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.goalId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$GoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$GlynaDatabase,
      $GoalsTable,
      GoalRow,
      $$GoalsTableFilterComposer,
      $$GoalsTableOrderingComposer,
      $$GoalsTableAnnotationComposer,
      $$GoalsTableCreateCompanionBuilder,
      $$GoalsTableUpdateCompanionBuilder,
      (GoalRow, $$GoalsTableReferences),
      GoalRow,
      PrefetchHooks Function({bool weekQuotasRefs})
    >;
typedef $$WeekQuotasTableCreateCompanionBuilder =
    WeekQuotasCompanion Function({
      required String goalId,
      required DateTime weekStart,
      required int target,
      Value<int> done,
      Value<int> rowid,
    });
typedef $$WeekQuotasTableUpdateCompanionBuilder =
    WeekQuotasCompanion Function({
      Value<String> goalId,
      Value<DateTime> weekStart,
      Value<int> target,
      Value<int> done,
      Value<int> rowid,
    });

final class $$WeekQuotasTableReferences
    extends BaseReferences<_$GlynaDatabase, $WeekQuotasTable, WeekQuotaRow> {
  $$WeekQuotasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GoalsTable _goalIdTable(_$GlynaDatabase db) => db.goals.createAlias(
    $_aliasNameGenerator(db.weekQuotas.goalId, db.goals.id),
  );

  $$GoalsTableProcessedTableManager get goalId {
    final $_column = $_itemColumn<String>('goal_id')!;

    final manager = $$GoalsTableTableManager(
      $_db,
      $_db.goals,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_goalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WeekQuotasTableFilterComposer
    extends Composer<_$GlynaDatabase, $WeekQuotasTable> {
  $$WeekQuotasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnFilters(column),
  );

  $$GoalsTableFilterComposer get goalId {
    final $$GoalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalsTableFilterComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WeekQuotasTableOrderingComposer
    extends Composer<_$GlynaDatabase, $WeekQuotasTable> {
  $$WeekQuotasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnOrderings(column),
  );

  $$GoalsTableOrderingComposer get goalId {
    final $$GoalsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalsTableOrderingComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WeekQuotasTableAnnotationComposer
    extends Composer<_$GlynaDatabase, $WeekQuotasTable> {
  $$WeekQuotasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get weekStart =>
      $composableBuilder(column: $table.weekStart, builder: (column) => column);

  GeneratedColumn<int> get target =>
      $composableBuilder(column: $table.target, builder: (column) => column);

  GeneratedColumn<int> get done =>
      $composableBuilder(column: $table.done, builder: (column) => column);

  $$GoalsTableAnnotationComposer get goalId {
    final $$GoalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalsTableAnnotationComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WeekQuotasTableTableManager
    extends
        RootTableManager<
          _$GlynaDatabase,
          $WeekQuotasTable,
          WeekQuotaRow,
          $$WeekQuotasTableFilterComposer,
          $$WeekQuotasTableOrderingComposer,
          $$WeekQuotasTableAnnotationComposer,
          $$WeekQuotasTableCreateCompanionBuilder,
          $$WeekQuotasTableUpdateCompanionBuilder,
          (WeekQuotaRow, $$WeekQuotasTableReferences),
          WeekQuotaRow,
          PrefetchHooks Function({bool goalId})
        > {
  $$WeekQuotasTableTableManager(_$GlynaDatabase db, $WeekQuotasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeekQuotasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeekQuotasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeekQuotasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> goalId = const Value.absent(),
                Value<DateTime> weekStart = const Value.absent(),
                Value<int> target = const Value.absent(),
                Value<int> done = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WeekQuotasCompanion(
                goalId: goalId,
                weekStart: weekStart,
                target: target,
                done: done,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String goalId,
                required DateTime weekStart,
                required int target,
                Value<int> done = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WeekQuotasCompanion.insert(
                goalId: goalId,
                weekStart: weekStart,
                target: target,
                done: done,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WeekQuotasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({goalId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (goalId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.goalId,
                                referencedTable: $$WeekQuotasTableReferences
                                    ._goalIdTable(db),
                                referencedColumn: $$WeekQuotasTableReferences
                                    ._goalIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WeekQuotasTableProcessedTableManager =
    ProcessedTableManager<
      _$GlynaDatabase,
      $WeekQuotasTable,
      WeekQuotaRow,
      $$WeekQuotasTableFilterComposer,
      $$WeekQuotasTableOrderingComposer,
      $$WeekQuotasTableAnnotationComposer,
      $$WeekQuotasTableCreateCompanionBuilder,
      $$WeekQuotasTableUpdateCompanionBuilder,
      (WeekQuotaRow, $$WeekQuotasTableReferences),
      WeekQuotaRow,
      PrefetchHooks Function({bool goalId})
    >;
typedef $$ChallengeLogsTableCreateCompanionBuilder =
    ChallengeLogsCompanion Function({
      Value<int> id,
      required String challengeId,
      required DateTime date,
      required ChallengeStatus status,
      Value<PostponeReason?> postponeReason,
    });
typedef $$ChallengeLogsTableUpdateCompanionBuilder =
    ChallengeLogsCompanion Function({
      Value<int> id,
      Value<String> challengeId,
      Value<DateTime> date,
      Value<ChallengeStatus> status,
      Value<PostponeReason?> postponeReason,
    });

class $$ChallengeLogsTableFilterComposer
    extends Composer<_$GlynaDatabase, $ChallengeLogsTable> {
  $$ChallengeLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get challengeId => $composableBuilder(
    column: $table.challengeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ChallengeStatus, ChallengeStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<PostponeReason?, PostponeReason, String>
  get postponeReason => $composableBuilder(
    column: $table.postponeReason,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$ChallengeLogsTableOrderingComposer
    extends Composer<_$GlynaDatabase, $ChallengeLogsTable> {
  $$ChallengeLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get challengeId => $composableBuilder(
    column: $table.challengeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get postponeReason => $composableBuilder(
    column: $table.postponeReason,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChallengeLogsTableAnnotationComposer
    extends Composer<_$GlynaDatabase, $ChallengeLogsTable> {
  $$ChallengeLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get challengeId => $composableBuilder(
    column: $table.challengeId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ChallengeStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PostponeReason?, String>
  get postponeReason => $composableBuilder(
    column: $table.postponeReason,
    builder: (column) => column,
  );
}

class $$ChallengeLogsTableTableManager
    extends
        RootTableManager<
          _$GlynaDatabase,
          $ChallengeLogsTable,
          ChallengeLogRow,
          $$ChallengeLogsTableFilterComposer,
          $$ChallengeLogsTableOrderingComposer,
          $$ChallengeLogsTableAnnotationComposer,
          $$ChallengeLogsTableCreateCompanionBuilder,
          $$ChallengeLogsTableUpdateCompanionBuilder,
          (
            ChallengeLogRow,
            BaseReferences<
              _$GlynaDatabase,
              $ChallengeLogsTable,
              ChallengeLogRow
            >,
          ),
          ChallengeLogRow,
          PrefetchHooks Function()
        > {
  $$ChallengeLogsTableTableManager(
    _$GlynaDatabase db,
    $ChallengeLogsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChallengeLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChallengeLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChallengeLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> challengeId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<ChallengeStatus> status = const Value.absent(),
                Value<PostponeReason?> postponeReason = const Value.absent(),
              }) => ChallengeLogsCompanion(
                id: id,
                challengeId: challengeId,
                date: date,
                status: status,
                postponeReason: postponeReason,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String challengeId,
                required DateTime date,
                required ChallengeStatus status,
                Value<PostponeReason?> postponeReason = const Value.absent(),
              }) => ChallengeLogsCompanion.insert(
                id: id,
                challengeId: challengeId,
                date: date,
                status: status,
                postponeReason: postponeReason,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChallengeLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$GlynaDatabase,
      $ChallengeLogsTable,
      ChallengeLogRow,
      $$ChallengeLogsTableFilterComposer,
      $$ChallengeLogsTableOrderingComposer,
      $$ChallengeLogsTableAnnotationComposer,
      $$ChallengeLogsTableCreateCompanionBuilder,
      $$ChallengeLogsTableUpdateCompanionBuilder,
      (
        ChallengeLogRow,
        BaseReferences<_$GlynaDatabase, $ChallengeLogsTable, ChallengeLogRow>,
      ),
      ChallengeLogRow,
      PrefetchHooks Function()
    >;

class $GlynaDatabaseManager {
  final _$GlynaDatabase _db;
  $GlynaDatabaseManager(this._db);
  $$GoalsTableTableManager get goals =>
      $$GoalsTableTableManager(_db, _db.goals);
  $$WeekQuotasTableTableManager get weekQuotas =>
      $$WeekQuotasTableTableManager(_db, _db.weekQuotas);
  $$ChallengeLogsTableTableManager get challengeLogs =>
      $$ChallengeLogsTableTableManager(_db, _db.challengeLogs);
}
