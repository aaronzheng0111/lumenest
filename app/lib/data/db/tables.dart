import 'package:drift/drift.dart';

/// Local tables for sdd/02. UI must not import generated Drift code.
/// Enum wire values: `sdd/02-local-storage-and-domain/fixtures/enums.json`.

/// t_user — local multi-account (active id in SharedPreferences).
class Users extends Table {
  IntColumn get id => integer()();

  TextColumn get nickname => text().withDefault(const Constant('妈妈'))();

  /// PREP | PREGNANT | DELIVERY | POSTPARTUM
  TextColumn get stage => text().withDefault(const Constant('PREP'))();

  /// L3 sensitive health field.
  DateTimeColumn get lastMenstruationDate => dateTime().nullable()();

  /// L3 sensitive health field.
  DateTimeColumn get dueDate => dateTime().nullable()();

  /// L3 sensitive health field.
  DateTimeColumn get birthDate => dateTime().nullable()();

  IntColumn get pregnancyWeek => integer().nullable()();

  IntColumn get postpartumWeek => integer().nullable()();

  /// Rich optional profile JSON ([RichUserProfile.encode]).
  TextColumn get profileJson => text().withDefault(const Constant('{}'))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Conversations extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get userId => integer()();

  /// AgentRole: XIAONUAN | LIN | SUXIN | AMA
  TextColumn get role => text()();

  /// ConversationType: SOLO | GROUP
  TextColumn get type => text()();

  DateTimeColumn get createdAt => dateTime()();
}

class Messages extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get conversationId => integer()();

  /// MessageRole: user | assistant | system
  TextColumn get role => text()();

  /// AgentRole when assistant speaks in GROUP; nullable for user/system.
  TextColumn get speakerRole => text().nullable()();

  /// L3 sensitive content.
  TextColumn get content => text()();

  TextColumn get imageRef => text().nullable()();

  IntColumn get tokenCost => integer().nullable()();

  TextColumn get agentReplyRef => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();
}

class ProfileEvents extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get userId => integer()();

  DateTimeColumn get weekStart => dateTime()();

  IntColumn get weekValue => integer()();

  /// WeekUnit: PREGNANCY_WEEK | POSTPARTUM_WEEK
  TextColumn get weekUnit => text()();

  /// ProfileCategory: MOOD | SYMPTOM | EXAM | FEEDING | HABIT | SUMMARY
  TextColumn get category => text()();

  /// L3 sensitive summary.
  TextColumn get summary => text()();

  TextColumn get rawRef => text().nullable()();

  /// L4 audit-sensitive score.
  RealColumn get riskScore => real().nullable()();
}

class TaskCards extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get userId => integer()();

  DateTimeColumn get localDate => dateTime()();

  TextColumn get stage => text()();

  IntColumn get weekValue => integer().nullable()();

  TextColumn get payloadJson => text()();

  /// TaskStatus: PENDING | DONE | SKIPPED
  TextColumn get status => text()();
}

class Subscriptions extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get userId => integer()();

  /// Plan: FREE | COMPANION | FULLCARE | ANNUAL
  TextColumn get plan => text()();

  DateTimeColumn get startAt => dateTime()();

  DateTimeColumn get expireAt => dateTime().nullable()();

  IntColumn get dailyChatQuota => integer()();

  IntColumn get monthlyReportQuota => integer()();

  BoolColumn get groupConsultEnabled =>
      boolean().withDefault(const Constant(false))();
}

/// Tracks app schema version alongside Drift's user_version.
class SchemaMeta extends Table {
  IntColumn get id => integer()();

  IntColumn get version => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
