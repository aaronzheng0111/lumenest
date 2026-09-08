// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _nicknameMeta =
      const VerificationMeta('nickname');
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
      'nickname', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('妈妈'));
  static const VerificationMeta _stageMeta = const VerificationMeta('stage');
  @override
  late final GeneratedColumn<String> stage = GeneratedColumn<String>(
      'stage', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('PREP'));
  static const VerificationMeta _lastMenstruationDateMeta =
      const VerificationMeta('lastMenstruationDate');
  @override
  late final GeneratedColumn<DateTime> lastMenstruationDate =
      GeneratedColumn<DateTime>('last_menstruation_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _birthDateMeta =
      const VerificationMeta('birthDate');
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
      'birth_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _pregnancyWeekMeta =
      const VerificationMeta('pregnancyWeek');
  @override
  late final GeneratedColumn<int> pregnancyWeek = GeneratedColumn<int>(
      'pregnancy_week', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _postpartumWeekMeta =
      const VerificationMeta('postpartumWeek');
  @override
  late final GeneratedColumn<int> postpartumWeek = GeneratedColumn<int>(
      'postpartum_week', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        nickname,
        stage,
        lastMenstruationDate,
        dueDate,
        birthDate,
        pregnancyWeek,
        postpartumWeek,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<User> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nickname')) {
      context.handle(_nicknameMeta,
          nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta));
    }
    if (data.containsKey('stage')) {
      context.handle(
          _stageMeta, stage.isAcceptableOrUnknown(data['stage']!, _stageMeta));
    }
    if (data.containsKey('last_menstruation_date')) {
      context.handle(
          _lastMenstruationDateMeta,
          lastMenstruationDate.isAcceptableOrUnknown(
              data['last_menstruation_date']!, _lastMenstruationDateMeta));
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    }
    if (data.containsKey('birth_date')) {
      context.handle(_birthDateMeta,
          birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta));
    }
    if (data.containsKey('pregnancy_week')) {
      context.handle(
          _pregnancyWeekMeta,
          pregnancyWeek.isAcceptableOrUnknown(
              data['pregnancy_week']!, _pregnancyWeekMeta));
    }
    if (data.containsKey('postpartum_week')) {
      context.handle(
          _postpartumWeekMeta,
          postpartumWeek.isAcceptableOrUnknown(
              data['postpartum_week']!, _postpartumWeekMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      nickname: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nickname'])!,
      stage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}stage'])!,
      lastMenstruationDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}last_menstruation_date']),
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date']),
      birthDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}birth_date']),
      pregnancyWeek: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}pregnancy_week']),
      postpartumWeek: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}postpartum_week']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final int id;
  final String nickname;

  /// PREP | PREGNANT | DELIVERY | POSTPARTUM
  final String stage;

  /// L3 sensitive health field.
  final DateTime? lastMenstruationDate;

  /// L3 sensitive health field.
  final DateTime? dueDate;

  /// L3 sensitive health field.
  final DateTime? birthDate;
  final int? pregnancyWeek;
  final int? postpartumWeek;
  final DateTime createdAt;
  final DateTime updatedAt;
  const User(
      {required this.id,
      required this.nickname,
      required this.stage,
      this.lastMenstruationDate,
      this.dueDate,
      this.birthDate,
      this.pregnancyWeek,
      this.postpartumWeek,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nickname'] = Variable<String>(nickname);
    map['stage'] = Variable<String>(stage);
    if (!nullToAbsent || lastMenstruationDate != null) {
      map['last_menstruation_date'] = Variable<DateTime>(lastMenstruationDate);
    }
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<DateTime>(birthDate);
    }
    if (!nullToAbsent || pregnancyWeek != null) {
      map['pregnancy_week'] = Variable<int>(pregnancyWeek);
    }
    if (!nullToAbsent || postpartumWeek != null) {
      map['postpartum_week'] = Variable<int>(postpartumWeek);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      nickname: Value(nickname),
      stage: Value(stage),
      lastMenstruationDate: lastMenstruationDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMenstruationDate),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      birthDate: birthDate == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDate),
      pregnancyWeek: pregnancyWeek == null && nullToAbsent
          ? const Value.absent()
          : Value(pregnancyWeek),
      postpartumWeek: postpartumWeek == null && nullToAbsent
          ? const Value.absent()
          : Value(postpartumWeek),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory User.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<int>(json['id']),
      nickname: serializer.fromJson<String>(json['nickname']),
      stage: serializer.fromJson<String>(json['stage']),
      lastMenstruationDate:
          serializer.fromJson<DateTime?>(json['lastMenstruationDate']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      birthDate: serializer.fromJson<DateTime?>(json['birthDate']),
      pregnancyWeek: serializer.fromJson<int?>(json['pregnancyWeek']),
      postpartumWeek: serializer.fromJson<int?>(json['postpartumWeek']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nickname': serializer.toJson<String>(nickname),
      'stage': serializer.toJson<String>(stage),
      'lastMenstruationDate':
          serializer.toJson<DateTime?>(lastMenstruationDate),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'birthDate': serializer.toJson<DateTime?>(birthDate),
      'pregnancyWeek': serializer.toJson<int?>(pregnancyWeek),
      'postpartumWeek': serializer.toJson<int?>(postpartumWeek),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  User copyWith(
          {int? id,
          String? nickname,
          String? stage,
          Value<DateTime?> lastMenstruationDate = const Value.absent(),
          Value<DateTime?> dueDate = const Value.absent(),
          Value<DateTime?> birthDate = const Value.absent(),
          Value<int?> pregnancyWeek = const Value.absent(),
          Value<int?> postpartumWeek = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      User(
        id: id ?? this.id,
        nickname: nickname ?? this.nickname,
        stage: stage ?? this.stage,
        lastMenstruationDate: lastMenstruationDate.present
            ? lastMenstruationDate.value
            : this.lastMenstruationDate,
        dueDate: dueDate.present ? dueDate.value : this.dueDate,
        birthDate: birthDate.present ? birthDate.value : this.birthDate,
        pregnancyWeek:
            pregnancyWeek.present ? pregnancyWeek.value : this.pregnancyWeek,
        postpartumWeek:
            postpartumWeek.present ? postpartumWeek.value : this.postpartumWeek,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      stage: data.stage.present ? data.stage.value : this.stage,
      lastMenstruationDate: data.lastMenstruationDate.present
          ? data.lastMenstruationDate.value
          : this.lastMenstruationDate,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      pregnancyWeek: data.pregnancyWeek.present
          ? data.pregnancyWeek.value
          : this.pregnancyWeek,
      postpartumWeek: data.postpartumWeek.present
          ? data.postpartumWeek.value
          : this.postpartumWeek,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('nickname: $nickname, ')
          ..write('stage: $stage, ')
          ..write('lastMenstruationDate: $lastMenstruationDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('birthDate: $birthDate, ')
          ..write('pregnancyWeek: $pregnancyWeek, ')
          ..write('postpartumWeek: $postpartumWeek, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nickname, stage, lastMenstruationDate,
      dueDate, birthDate, pregnancyWeek, postpartumWeek, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.nickname == this.nickname &&
          other.stage == this.stage &&
          other.lastMenstruationDate == this.lastMenstruationDate &&
          other.dueDate == this.dueDate &&
          other.birthDate == this.birthDate &&
          other.pregnancyWeek == this.pregnancyWeek &&
          other.postpartumWeek == this.postpartumWeek &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<int> id;
  final Value<String> nickname;
  final Value<String> stage;
  final Value<DateTime?> lastMenstruationDate;
  final Value<DateTime?> dueDate;
  final Value<DateTime?> birthDate;
  final Value<int?> pregnancyWeek;
  final Value<int?> postpartumWeek;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.nickname = const Value.absent(),
    this.stage = const Value.absent(),
    this.lastMenstruationDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.pregnancyWeek = const Value.absent(),
    this.postpartumWeek = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UsersCompanion.insert({
    this.id = const Value.absent(),
    this.nickname = const Value.absent(),
    this.stage = const Value.absent(),
    this.lastMenstruationDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.pregnancyWeek = const Value.absent(),
    this.postpartumWeek = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  })  : createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<User> custom({
    Expression<int>? id,
    Expression<String>? nickname,
    Expression<String>? stage,
    Expression<DateTime>? lastMenstruationDate,
    Expression<DateTime>? dueDate,
    Expression<DateTime>? birthDate,
    Expression<int>? pregnancyWeek,
    Expression<int>? postpartumWeek,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nickname != null) 'nickname': nickname,
      if (stage != null) 'stage': stage,
      if (lastMenstruationDate != null)
        'last_menstruation_date': lastMenstruationDate,
      if (dueDate != null) 'due_date': dueDate,
      if (birthDate != null) 'birth_date': birthDate,
      if (pregnancyWeek != null) 'pregnancy_week': pregnancyWeek,
      if (postpartumWeek != null) 'postpartum_week': postpartumWeek,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UsersCompanion copyWith(
      {Value<int>? id,
      Value<String>? nickname,
      Value<String>? stage,
      Value<DateTime?>? lastMenstruationDate,
      Value<DateTime?>? dueDate,
      Value<DateTime?>? birthDate,
      Value<int?>? pregnancyWeek,
      Value<int?>? postpartumWeek,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return UsersCompanion(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      stage: stage ?? this.stage,
      lastMenstruationDate: lastMenstruationDate ?? this.lastMenstruationDate,
      dueDate: dueDate ?? this.dueDate,
      birthDate: birthDate ?? this.birthDate,
      pregnancyWeek: pregnancyWeek ?? this.pregnancyWeek,
      postpartumWeek: postpartumWeek ?? this.postpartumWeek,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (stage.present) {
      map['stage'] = Variable<String>(stage.value);
    }
    if (lastMenstruationDate.present) {
      map['last_menstruation_date'] =
          Variable<DateTime>(lastMenstruationDate.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (pregnancyWeek.present) {
      map['pregnancy_week'] = Variable<int>(pregnancyWeek.value);
    }
    if (postpartumWeek.present) {
      map['postpartum_week'] = Variable<int>(postpartumWeek.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('nickname: $nickname, ')
          ..write('stage: $stage, ')
          ..write('lastMenstruationDate: $lastMenstruationDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('birthDate: $birthDate, ')
          ..write('pregnancyWeek: $pregnancyWeek, ')
          ..write('postpartumWeek: $postpartumWeek, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ConversationsTable extends Conversations
    with TableInfo<$ConversationsTable, Conversation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConversationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
      'user_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, userId, role, type, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conversations';
  @override
  VerificationContext validateIntegrity(Insertable<Conversation> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Conversation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Conversation(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}user_id'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ConversationsTable createAlias(String alias) {
    return $ConversationsTable(attachedDatabase, alias);
  }
}

class Conversation extends DataClass implements Insertable<Conversation> {
  final int id;
  final int userId;

  /// AgentRole: XIAONUAN | LIN | SUXIN | AMA
  final String role;

  /// ConversationType: SOLO | GROUP
  final String type;
  final DateTime createdAt;
  const Conversation(
      {required this.id,
      required this.userId,
      required this.role,
      required this.type,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['role'] = Variable<String>(role);
    map['type'] = Variable<String>(type);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ConversationsCompanion toCompanion(bool nullToAbsent) {
    return ConversationsCompanion(
      id: Value(id),
      userId: Value(userId),
      role: Value(role),
      type: Value(type),
      createdAt: Value(createdAt),
    );
  }

  factory Conversation.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Conversation(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      role: serializer.fromJson<String>(json['role']),
      type: serializer.fromJson<String>(json['type']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'role': serializer.toJson<String>(role),
      'type': serializer.toJson<String>(type),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Conversation copyWith(
          {int? id,
          int? userId,
          String? role,
          String? type,
          DateTime? createdAt}) =>
      Conversation(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        role: role ?? this.role,
        type: type ?? this.type,
        createdAt: createdAt ?? this.createdAt,
      );
  Conversation copyWithCompanion(ConversationsCompanion data) {
    return Conversation(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      role: data.role.present ? data.role.value : this.role,
      type: data.type.present ? data.type.value : this.type,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Conversation(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('type: $type, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, role, type, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Conversation &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.role == this.role &&
          other.type == this.type &&
          other.createdAt == this.createdAt);
}

class ConversationsCompanion extends UpdateCompanion<Conversation> {
  final Value<int> id;
  final Value<int> userId;
  final Value<String> role;
  final Value<String> type;
  final Value<DateTime> createdAt;
  const ConversationsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.role = const Value.absent(),
    this.type = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ConversationsCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required String role,
    required String type,
    required DateTime createdAt,
  })  : userId = Value(userId),
        role = Value(role),
        type = Value(type),
        createdAt = Value(createdAt);
  static Insertable<Conversation> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<String>? role,
    Expression<String>? type,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (role != null) 'role': role,
      if (type != null) 'type': type,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ConversationsCompanion copyWith(
      {Value<int>? id,
      Value<int>? userId,
      Value<String>? role,
      Value<String>? type,
      Value<DateTime>? createdAt}) {
    return ConversationsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConversationsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('type: $type, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _conversationIdMeta =
      const VerificationMeta('conversationId');
  @override
  late final GeneratedColumn<int> conversationId = GeneratedColumn<int>(
      'conversation_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _speakerRoleMeta =
      const VerificationMeta('speakerRole');
  @override
  late final GeneratedColumn<String> speakerRole = GeneratedColumn<String>(
      'speaker_role', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _imageRefMeta =
      const VerificationMeta('imageRef');
  @override
  late final GeneratedColumn<String> imageRef = GeneratedColumn<String>(
      'image_ref', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tokenCostMeta =
      const VerificationMeta('tokenCost');
  @override
  late final GeneratedColumn<int> tokenCost = GeneratedColumn<int>(
      'token_cost', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _agentReplyRefMeta =
      const VerificationMeta('agentReplyRef');
  @override
  late final GeneratedColumn<String> agentReplyRef = GeneratedColumn<String>(
      'agent_reply_ref', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        conversationId,
        role,
        speakerRole,
        content,
        imageRef,
        tokenCost,
        agentReplyRef,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(Insertable<Message> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
          _conversationIdMeta,
          conversationId.isAcceptableOrUnknown(
              data['conversation_id']!, _conversationIdMeta));
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('speaker_role')) {
      context.handle(
          _speakerRoleMeta,
          speakerRole.isAcceptableOrUnknown(
              data['speaker_role']!, _speakerRoleMeta));
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('image_ref')) {
      context.handle(_imageRefMeta,
          imageRef.isAcceptableOrUnknown(data['image_ref']!, _imageRefMeta));
    }
    if (data.containsKey('token_cost')) {
      context.handle(_tokenCostMeta,
          tokenCost.isAcceptableOrUnknown(data['token_cost']!, _tokenCostMeta));
    }
    if (data.containsKey('agent_reply_ref')) {
      context.handle(
          _agentReplyRefMeta,
          agentReplyRef.isAcceptableOrUnknown(
              data['agent_reply_ref']!, _agentReplyRefMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      conversationId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}conversation_id'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      speakerRole: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}speaker_role']),
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      imageRef: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_ref']),
      tokenCost: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}token_cost']),
      agentReplyRef: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}agent_reply_ref']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class Message extends DataClass implements Insertable<Message> {
  final int id;
  final int conversationId;

  /// MessageRole: user | assistant | system
  final String role;

  /// AgentRole when assistant speaks in GROUP; nullable for user/system.
  final String? speakerRole;

  /// L3 sensitive content.
  final String content;
  final String? imageRef;
  final int? tokenCost;
  final String? agentReplyRef;
  final DateTime createdAt;
  const Message(
      {required this.id,
      required this.conversationId,
      required this.role,
      this.speakerRole,
      required this.content,
      this.imageRef,
      this.tokenCost,
      this.agentReplyRef,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['conversation_id'] = Variable<int>(conversationId);
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || speakerRole != null) {
      map['speaker_role'] = Variable<String>(speakerRole);
    }
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || imageRef != null) {
      map['image_ref'] = Variable<String>(imageRef);
    }
    if (!nullToAbsent || tokenCost != null) {
      map['token_cost'] = Variable<int>(tokenCost);
    }
    if (!nullToAbsent || agentReplyRef != null) {
      map['agent_reply_ref'] = Variable<String>(agentReplyRef);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      conversationId: Value(conversationId),
      role: Value(role),
      speakerRole: speakerRole == null && nullToAbsent
          ? const Value.absent()
          : Value(speakerRole),
      content: Value(content),
      imageRef: imageRef == null && nullToAbsent
          ? const Value.absent()
          : Value(imageRef),
      tokenCost: tokenCost == null && nullToAbsent
          ? const Value.absent()
          : Value(tokenCost),
      agentReplyRef: agentReplyRef == null && nullToAbsent
          ? const Value.absent()
          : Value(agentReplyRef),
      createdAt: Value(createdAt),
    );
  }

  factory Message.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Message(
      id: serializer.fromJson<int>(json['id']),
      conversationId: serializer.fromJson<int>(json['conversationId']),
      role: serializer.fromJson<String>(json['role']),
      speakerRole: serializer.fromJson<String?>(json['speakerRole']),
      content: serializer.fromJson<String>(json['content']),
      imageRef: serializer.fromJson<String?>(json['imageRef']),
      tokenCost: serializer.fromJson<int?>(json['tokenCost']),
      agentReplyRef: serializer.fromJson<String?>(json['agentReplyRef']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'conversationId': serializer.toJson<int>(conversationId),
      'role': serializer.toJson<String>(role),
      'speakerRole': serializer.toJson<String?>(speakerRole),
      'content': serializer.toJson<String>(content),
      'imageRef': serializer.toJson<String?>(imageRef),
      'tokenCost': serializer.toJson<int?>(tokenCost),
      'agentReplyRef': serializer.toJson<String?>(agentReplyRef),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Message copyWith(
          {int? id,
          int? conversationId,
          String? role,
          Value<String?> speakerRole = const Value.absent(),
          String? content,
          Value<String?> imageRef = const Value.absent(),
          Value<int?> tokenCost = const Value.absent(),
          Value<String?> agentReplyRef = const Value.absent(),
          DateTime? createdAt}) =>
      Message(
        id: id ?? this.id,
        conversationId: conversationId ?? this.conversationId,
        role: role ?? this.role,
        speakerRole: speakerRole.present ? speakerRole.value : this.speakerRole,
        content: content ?? this.content,
        imageRef: imageRef.present ? imageRef.value : this.imageRef,
        tokenCost: tokenCost.present ? tokenCost.value : this.tokenCost,
        agentReplyRef:
            agentReplyRef.present ? agentReplyRef.value : this.agentReplyRef,
        createdAt: createdAt ?? this.createdAt,
      );
  Message copyWithCompanion(MessagesCompanion data) {
    return Message(
      id: data.id.present ? data.id.value : this.id,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      role: data.role.present ? data.role.value : this.role,
      speakerRole:
          data.speakerRole.present ? data.speakerRole.value : this.speakerRole,
      content: data.content.present ? data.content.value : this.content,
      imageRef: data.imageRef.present ? data.imageRef.value : this.imageRef,
      tokenCost: data.tokenCost.present ? data.tokenCost.value : this.tokenCost,
      agentReplyRef: data.agentReplyRef.present
          ? data.agentReplyRef.value
          : this.agentReplyRef,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('role: $role, ')
          ..write('speakerRole: $speakerRole, ')
          ..write('content: $content, ')
          ..write('imageRef: $imageRef, ')
          ..write('tokenCost: $tokenCost, ')
          ..write('agentReplyRef: $agentReplyRef, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, conversationId, role, speakerRole,
      content, imageRef, tokenCost, agentReplyRef, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.role == this.role &&
          other.speakerRole == this.speakerRole &&
          other.content == this.content &&
          other.imageRef == this.imageRef &&
          other.tokenCost == this.tokenCost &&
          other.agentReplyRef == this.agentReplyRef &&
          other.createdAt == this.createdAt);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<int> id;
  final Value<int> conversationId;
  final Value<String> role;
  final Value<String?> speakerRole;
  final Value<String> content;
  final Value<String?> imageRef;
  final Value<int?> tokenCost;
  final Value<String?> agentReplyRef;
  final Value<DateTime> createdAt;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.role = const Value.absent(),
    this.speakerRole = const Value.absent(),
    this.content = const Value.absent(),
    this.imageRef = const Value.absent(),
    this.tokenCost = const Value.absent(),
    this.agentReplyRef = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MessagesCompanion.insert({
    this.id = const Value.absent(),
    required int conversationId,
    required String role,
    this.speakerRole = const Value.absent(),
    required String content,
    this.imageRef = const Value.absent(),
    this.tokenCost = const Value.absent(),
    this.agentReplyRef = const Value.absent(),
    required DateTime createdAt,
  })  : conversationId = Value(conversationId),
        role = Value(role),
        content = Value(content),
        createdAt = Value(createdAt);
  static Insertable<Message> custom({
    Expression<int>? id,
    Expression<int>? conversationId,
    Expression<String>? role,
    Expression<String>? speakerRole,
    Expression<String>? content,
    Expression<String>? imageRef,
    Expression<int>? tokenCost,
    Expression<String>? agentReplyRef,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (role != null) 'role': role,
      if (speakerRole != null) 'speaker_role': speakerRole,
      if (content != null) 'content': content,
      if (imageRef != null) 'image_ref': imageRef,
      if (tokenCost != null) 'token_cost': tokenCost,
      if (agentReplyRef != null) 'agent_reply_ref': agentReplyRef,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MessagesCompanion copyWith(
      {Value<int>? id,
      Value<int>? conversationId,
      Value<String>? role,
      Value<String?>? speakerRole,
      Value<String>? content,
      Value<String?>? imageRef,
      Value<int?>? tokenCost,
      Value<String?>? agentReplyRef,
      Value<DateTime>? createdAt}) {
    return MessagesCompanion(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      speakerRole: speakerRole ?? this.speakerRole,
      content: content ?? this.content,
      imageRef: imageRef ?? this.imageRef,
      tokenCost: tokenCost ?? this.tokenCost,
      agentReplyRef: agentReplyRef ?? this.agentReplyRef,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<int>(conversationId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (speakerRole.present) {
      map['speaker_role'] = Variable<String>(speakerRole.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (imageRef.present) {
      map['image_ref'] = Variable<String>(imageRef.value);
    }
    if (tokenCost.present) {
      map['token_cost'] = Variable<int>(tokenCost.value);
    }
    if (agentReplyRef.present) {
      map['agent_reply_ref'] = Variable<String>(agentReplyRef.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('role: $role, ')
          ..write('speakerRole: $speakerRole, ')
          ..write('content: $content, ')
          ..write('imageRef: $imageRef, ')
          ..write('tokenCost: $tokenCost, ')
          ..write('agentReplyRef: $agentReplyRef, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ProfileEventsTable extends ProfileEvents
    with TableInfo<$ProfileEventsTable, ProfileEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfileEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
      'user_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _weekStartMeta =
      const VerificationMeta('weekStart');
  @override
  late final GeneratedColumn<DateTime> weekStart = GeneratedColumn<DateTime>(
      'week_start', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _weekValueMeta =
      const VerificationMeta('weekValue');
  @override
  late final GeneratedColumn<int> weekValue = GeneratedColumn<int>(
      'week_value', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _weekUnitMeta =
      const VerificationMeta('weekUnit');
  @override
  late final GeneratedColumn<String> weekUnit = GeneratedColumn<String>(
      'week_unit', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _summaryMeta =
      const VerificationMeta('summary');
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
      'summary', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rawRefMeta = const VerificationMeta('rawRef');
  @override
  late final GeneratedColumn<String> rawRef = GeneratedColumn<String>(
      'raw_ref', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _riskScoreMeta =
      const VerificationMeta('riskScore');
  @override
  late final GeneratedColumn<double> riskScore = GeneratedColumn<double>(
      'risk_score', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        weekStart,
        weekValue,
        weekUnit,
        category,
        summary,
        rawRef,
        riskScore
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile_events';
  @override
  VerificationContext validateIntegrity(Insertable<ProfileEvent> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('week_start')) {
      context.handle(_weekStartMeta,
          weekStart.isAcceptableOrUnknown(data['week_start']!, _weekStartMeta));
    } else if (isInserting) {
      context.missing(_weekStartMeta);
    }
    if (data.containsKey('week_value')) {
      context.handle(_weekValueMeta,
          weekValue.isAcceptableOrUnknown(data['week_value']!, _weekValueMeta));
    } else if (isInserting) {
      context.missing(_weekValueMeta);
    }
    if (data.containsKey('week_unit')) {
      context.handle(_weekUnitMeta,
          weekUnit.isAcceptableOrUnknown(data['week_unit']!, _weekUnitMeta));
    } else if (isInserting) {
      context.missing(_weekUnitMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(_summaryMeta,
          summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta));
    } else if (isInserting) {
      context.missing(_summaryMeta);
    }
    if (data.containsKey('raw_ref')) {
      context.handle(_rawRefMeta,
          rawRef.isAcceptableOrUnknown(data['raw_ref']!, _rawRefMeta));
    }
    if (data.containsKey('risk_score')) {
      context.handle(_riskScoreMeta,
          riskScore.isAcceptableOrUnknown(data['risk_score']!, _riskScoreMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileEvent(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}user_id'])!,
      weekStart: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}week_start'])!,
      weekValue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}week_value'])!,
      weekUnit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}week_unit'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      summary: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}summary'])!,
      rawRef: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_ref']),
      riskScore: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}risk_score']),
    );
  }

  @override
  $ProfileEventsTable createAlias(String alias) {
    return $ProfileEventsTable(attachedDatabase, alias);
  }
}

class ProfileEvent extends DataClass implements Insertable<ProfileEvent> {
  final int id;
  final int userId;
  final DateTime weekStart;
  final int weekValue;

  /// WeekUnit: PREGNANCY_WEEK | POSTPARTUM_WEEK
  final String weekUnit;

  /// ProfileCategory: MOOD | SYMPTOM | EXAM | FEEDING | HABIT | SUMMARY
  final String category;

  /// L3 sensitive summary.
  final String summary;
  final String? rawRef;

  /// L4 audit-sensitive score.
  final double? riskScore;
  const ProfileEvent(
      {required this.id,
      required this.userId,
      required this.weekStart,
      required this.weekValue,
      required this.weekUnit,
      required this.category,
      required this.summary,
      this.rawRef,
      this.riskScore});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['week_start'] = Variable<DateTime>(weekStart);
    map['week_value'] = Variable<int>(weekValue);
    map['week_unit'] = Variable<String>(weekUnit);
    map['category'] = Variable<String>(category);
    map['summary'] = Variable<String>(summary);
    if (!nullToAbsent || rawRef != null) {
      map['raw_ref'] = Variable<String>(rawRef);
    }
    if (!nullToAbsent || riskScore != null) {
      map['risk_score'] = Variable<double>(riskScore);
    }
    return map;
  }

  ProfileEventsCompanion toCompanion(bool nullToAbsent) {
    return ProfileEventsCompanion(
      id: Value(id),
      userId: Value(userId),
      weekStart: Value(weekStart),
      weekValue: Value(weekValue),
      weekUnit: Value(weekUnit),
      category: Value(category),
      summary: Value(summary),
      rawRef:
          rawRef == null && nullToAbsent ? const Value.absent() : Value(rawRef),
      riskScore: riskScore == null && nullToAbsent
          ? const Value.absent()
          : Value(riskScore),
    );
  }

  factory ProfileEvent.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileEvent(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      weekStart: serializer.fromJson<DateTime>(json['weekStart']),
      weekValue: serializer.fromJson<int>(json['weekValue']),
      weekUnit: serializer.fromJson<String>(json['weekUnit']),
      category: serializer.fromJson<String>(json['category']),
      summary: serializer.fromJson<String>(json['summary']),
      rawRef: serializer.fromJson<String?>(json['rawRef']),
      riskScore: serializer.fromJson<double?>(json['riskScore']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'weekStart': serializer.toJson<DateTime>(weekStart),
      'weekValue': serializer.toJson<int>(weekValue),
      'weekUnit': serializer.toJson<String>(weekUnit),
      'category': serializer.toJson<String>(category),
      'summary': serializer.toJson<String>(summary),
      'rawRef': serializer.toJson<String?>(rawRef),
      'riskScore': serializer.toJson<double?>(riskScore),
    };
  }

  ProfileEvent copyWith(
          {int? id,
          int? userId,
          DateTime? weekStart,
          int? weekValue,
          String? weekUnit,
          String? category,
          String? summary,
          Value<String?> rawRef = const Value.absent(),
          Value<double?> riskScore = const Value.absent()}) =>
      ProfileEvent(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        weekStart: weekStart ?? this.weekStart,
        weekValue: weekValue ?? this.weekValue,
        weekUnit: weekUnit ?? this.weekUnit,
        category: category ?? this.category,
        summary: summary ?? this.summary,
        rawRef: rawRef.present ? rawRef.value : this.rawRef,
        riskScore: riskScore.present ? riskScore.value : this.riskScore,
      );
  ProfileEvent copyWithCompanion(ProfileEventsCompanion data) {
    return ProfileEvent(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      weekStart: data.weekStart.present ? data.weekStart.value : this.weekStart,
      weekValue: data.weekValue.present ? data.weekValue.value : this.weekValue,
      weekUnit: data.weekUnit.present ? data.weekUnit.value : this.weekUnit,
      category: data.category.present ? data.category.value : this.category,
      summary: data.summary.present ? data.summary.value : this.summary,
      rawRef: data.rawRef.present ? data.rawRef.value : this.rawRef,
      riskScore: data.riskScore.present ? data.riskScore.value : this.riskScore,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileEvent(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('weekStart: $weekStart, ')
          ..write('weekValue: $weekValue, ')
          ..write('weekUnit: $weekUnit, ')
          ..write('category: $category, ')
          ..write('summary: $summary, ')
          ..write('rawRef: $rawRef, ')
          ..write('riskScore: $riskScore')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, weekStart, weekValue, weekUnit,
      category, summary, rawRef, riskScore);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileEvent &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.weekStart == this.weekStart &&
          other.weekValue == this.weekValue &&
          other.weekUnit == this.weekUnit &&
          other.category == this.category &&
          other.summary == this.summary &&
          other.rawRef == this.rawRef &&
          other.riskScore == this.riskScore);
}

class ProfileEventsCompanion extends UpdateCompanion<ProfileEvent> {
  final Value<int> id;
  final Value<int> userId;
  final Value<DateTime> weekStart;
  final Value<int> weekValue;
  final Value<String> weekUnit;
  final Value<String> category;
  final Value<String> summary;
  final Value<String?> rawRef;
  final Value<double?> riskScore;
  const ProfileEventsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.weekStart = const Value.absent(),
    this.weekValue = const Value.absent(),
    this.weekUnit = const Value.absent(),
    this.category = const Value.absent(),
    this.summary = const Value.absent(),
    this.rawRef = const Value.absent(),
    this.riskScore = const Value.absent(),
  });
  ProfileEventsCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required DateTime weekStart,
    required int weekValue,
    required String weekUnit,
    required String category,
    required String summary,
    this.rawRef = const Value.absent(),
    this.riskScore = const Value.absent(),
  })  : userId = Value(userId),
        weekStart = Value(weekStart),
        weekValue = Value(weekValue),
        weekUnit = Value(weekUnit),
        category = Value(category),
        summary = Value(summary);
  static Insertable<ProfileEvent> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<DateTime>? weekStart,
    Expression<int>? weekValue,
    Expression<String>? weekUnit,
    Expression<String>? category,
    Expression<String>? summary,
    Expression<String>? rawRef,
    Expression<double>? riskScore,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (weekStart != null) 'week_start': weekStart,
      if (weekValue != null) 'week_value': weekValue,
      if (weekUnit != null) 'week_unit': weekUnit,
      if (category != null) 'category': category,
      if (summary != null) 'summary': summary,
      if (rawRef != null) 'raw_ref': rawRef,
      if (riskScore != null) 'risk_score': riskScore,
    });
  }

  ProfileEventsCompanion copyWith(
      {Value<int>? id,
      Value<int>? userId,
      Value<DateTime>? weekStart,
      Value<int>? weekValue,
      Value<String>? weekUnit,
      Value<String>? category,
      Value<String>? summary,
      Value<String?>? rawRef,
      Value<double?>? riskScore}) {
    return ProfileEventsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      weekStart: weekStart ?? this.weekStart,
      weekValue: weekValue ?? this.weekValue,
      weekUnit: weekUnit ?? this.weekUnit,
      category: category ?? this.category,
      summary: summary ?? this.summary,
      rawRef: rawRef ?? this.rawRef,
      riskScore: riskScore ?? this.riskScore,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (weekStart.present) {
      map['week_start'] = Variable<DateTime>(weekStart.value);
    }
    if (weekValue.present) {
      map['week_value'] = Variable<int>(weekValue.value);
    }
    if (weekUnit.present) {
      map['week_unit'] = Variable<String>(weekUnit.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (rawRef.present) {
      map['raw_ref'] = Variable<String>(rawRef.value);
    }
    if (riskScore.present) {
      map['risk_score'] = Variable<double>(riskScore.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileEventsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('weekStart: $weekStart, ')
          ..write('weekValue: $weekValue, ')
          ..write('weekUnit: $weekUnit, ')
          ..write('category: $category, ')
          ..write('summary: $summary, ')
          ..write('rawRef: $rawRef, ')
          ..write('riskScore: $riskScore')
          ..write(')'))
        .toString();
  }
}

class $TaskCardsTable extends TaskCards
    with TableInfo<$TaskCardsTable, TaskCard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
      'user_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _localDateMeta =
      const VerificationMeta('localDate');
  @override
  late final GeneratedColumn<DateTime> localDate = GeneratedColumn<DateTime>(
      'local_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _stageMeta = const VerificationMeta('stage');
  @override
  late final GeneratedColumn<String> stage = GeneratedColumn<String>(
      'stage', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _weekValueMeta =
      const VerificationMeta('weekValue');
  @override
  late final GeneratedColumn<int> weekValue = GeneratedColumn<int>(
      'week_value', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, localDate, stage, weekValue, payloadJson, status];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_cards';
  @override
  VerificationContext validateIntegrity(Insertable<TaskCard> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('local_date')) {
      context.handle(_localDateMeta,
          localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta));
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    if (data.containsKey('stage')) {
      context.handle(
          _stageMeta, stage.isAcceptableOrUnknown(data['stage']!, _stageMeta));
    } else if (isInserting) {
      context.missing(_stageMeta);
    }
    if (data.containsKey('week_value')) {
      context.handle(_weekValueMeta,
          weekValue.isAcceptableOrUnknown(data['week_value']!, _weekValueMeta));
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskCard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskCard(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}user_id'])!,
      localDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}local_date'])!,
      stage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}stage'])!,
      weekValue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}week_value']),
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
    );
  }

  @override
  $TaskCardsTable createAlias(String alias) {
    return $TaskCardsTable(attachedDatabase, alias);
  }
}

class TaskCard extends DataClass implements Insertable<TaskCard> {
  final int id;
  final int userId;
  final DateTime localDate;
  final String stage;
  final int? weekValue;
  final String payloadJson;

  /// TaskStatus: PENDING | DONE | SKIPPED
  final String status;
  const TaskCard(
      {required this.id,
      required this.userId,
      required this.localDate,
      required this.stage,
      this.weekValue,
      required this.payloadJson,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['local_date'] = Variable<DateTime>(localDate);
    map['stage'] = Variable<String>(stage);
    if (!nullToAbsent || weekValue != null) {
      map['week_value'] = Variable<int>(weekValue);
    }
    map['payload_json'] = Variable<String>(payloadJson);
    map['status'] = Variable<String>(status);
    return map;
  }

  TaskCardsCompanion toCompanion(bool nullToAbsent) {
    return TaskCardsCompanion(
      id: Value(id),
      userId: Value(userId),
      localDate: Value(localDate),
      stage: Value(stage),
      weekValue: weekValue == null && nullToAbsent
          ? const Value.absent()
          : Value(weekValue),
      payloadJson: Value(payloadJson),
      status: Value(status),
    );
  }

  factory TaskCard.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskCard(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      localDate: serializer.fromJson<DateTime>(json['localDate']),
      stage: serializer.fromJson<String>(json['stage']),
      weekValue: serializer.fromJson<int?>(json['weekValue']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'localDate': serializer.toJson<DateTime>(localDate),
      'stage': serializer.toJson<String>(stage),
      'weekValue': serializer.toJson<int?>(weekValue),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'status': serializer.toJson<String>(status),
    };
  }

  TaskCard copyWith(
          {int? id,
          int? userId,
          DateTime? localDate,
          String? stage,
          Value<int?> weekValue = const Value.absent(),
          String? payloadJson,
          String? status}) =>
      TaskCard(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        localDate: localDate ?? this.localDate,
        stage: stage ?? this.stage,
        weekValue: weekValue.present ? weekValue.value : this.weekValue,
        payloadJson: payloadJson ?? this.payloadJson,
        status: status ?? this.status,
      );
  TaskCard copyWithCompanion(TaskCardsCompanion data) {
    return TaskCard(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
      stage: data.stage.present ? data.stage.value : this.stage,
      weekValue: data.weekValue.present ? data.weekValue.value : this.weekValue,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskCard(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('localDate: $localDate, ')
          ..write('stage: $stage, ')
          ..write('weekValue: $weekValue, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, localDate, stage, weekValue, payloadJson, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskCard &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.localDate == this.localDate &&
          other.stage == this.stage &&
          other.weekValue == this.weekValue &&
          other.payloadJson == this.payloadJson &&
          other.status == this.status);
}

class TaskCardsCompanion extends UpdateCompanion<TaskCard> {
  final Value<int> id;
  final Value<int> userId;
  final Value<DateTime> localDate;
  final Value<String> stage;
  final Value<int?> weekValue;
  final Value<String> payloadJson;
  final Value<String> status;
  const TaskCardsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.localDate = const Value.absent(),
    this.stage = const Value.absent(),
    this.weekValue = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.status = const Value.absent(),
  });
  TaskCardsCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required DateTime localDate,
    required String stage,
    this.weekValue = const Value.absent(),
    required String payloadJson,
    required String status,
  })  : userId = Value(userId),
        localDate = Value(localDate),
        stage = Value(stage),
        payloadJson = Value(payloadJson),
        status = Value(status);
  static Insertable<TaskCard> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<DateTime>? localDate,
    Expression<String>? stage,
    Expression<int>? weekValue,
    Expression<String>? payloadJson,
    Expression<String>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (localDate != null) 'local_date': localDate,
      if (stage != null) 'stage': stage,
      if (weekValue != null) 'week_value': weekValue,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (status != null) 'status': status,
    });
  }

  TaskCardsCompanion copyWith(
      {Value<int>? id,
      Value<int>? userId,
      Value<DateTime>? localDate,
      Value<String>? stage,
      Value<int?>? weekValue,
      Value<String>? payloadJson,
      Value<String>? status}) {
    return TaskCardsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      localDate: localDate ?? this.localDate,
      stage: stage ?? this.stage,
      weekValue: weekValue ?? this.weekValue,
      payloadJson: payloadJson ?? this.payloadJson,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<DateTime>(localDate.value);
    }
    if (stage.present) {
      map['stage'] = Variable<String>(stage.value);
    }
    if (weekValue.present) {
      map['week_value'] = Variable<int>(weekValue.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskCardsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('localDate: $localDate, ')
          ..write('stage: $stage, ')
          ..write('weekValue: $weekValue, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $SubscriptionsTable extends Subscriptions
    with TableInfo<$SubscriptionsTable, Subscription> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubscriptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
      'user_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _planMeta = const VerificationMeta('plan');
  @override
  late final GeneratedColumn<String> plan = GeneratedColumn<String>(
      'plan', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startAtMeta =
      const VerificationMeta('startAt');
  @override
  late final GeneratedColumn<DateTime> startAt = GeneratedColumn<DateTime>(
      'start_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _expireAtMeta =
      const VerificationMeta('expireAt');
  @override
  late final GeneratedColumn<DateTime> expireAt = GeneratedColumn<DateTime>(
      'expire_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _dailyChatQuotaMeta =
      const VerificationMeta('dailyChatQuota');
  @override
  late final GeneratedColumn<int> dailyChatQuota = GeneratedColumn<int>(
      'daily_chat_quota', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _monthlyReportQuotaMeta =
      const VerificationMeta('monthlyReportQuota');
  @override
  late final GeneratedColumn<int> monthlyReportQuota = GeneratedColumn<int>(
      'monthly_report_quota', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _groupConsultEnabledMeta =
      const VerificationMeta('groupConsultEnabled');
  @override
  late final GeneratedColumn<bool> groupConsultEnabled = GeneratedColumn<bool>(
      'group_consult_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("group_consult_enabled" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        plan,
        startAt,
        expireAt,
        dailyChatQuota,
        monthlyReportQuota,
        groupConsultEnabled
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subscriptions';
  @override
  VerificationContext validateIntegrity(Insertable<Subscription> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('plan')) {
      context.handle(
          _planMeta, plan.isAcceptableOrUnknown(data['plan']!, _planMeta));
    } else if (isInserting) {
      context.missing(_planMeta);
    }
    if (data.containsKey('start_at')) {
      context.handle(_startAtMeta,
          startAt.isAcceptableOrUnknown(data['start_at']!, _startAtMeta));
    } else if (isInserting) {
      context.missing(_startAtMeta);
    }
    if (data.containsKey('expire_at')) {
      context.handle(_expireAtMeta,
          expireAt.isAcceptableOrUnknown(data['expire_at']!, _expireAtMeta));
    }
    if (data.containsKey('daily_chat_quota')) {
      context.handle(
          _dailyChatQuotaMeta,
          dailyChatQuota.isAcceptableOrUnknown(
              data['daily_chat_quota']!, _dailyChatQuotaMeta));
    } else if (isInserting) {
      context.missing(_dailyChatQuotaMeta);
    }
    if (data.containsKey('monthly_report_quota')) {
      context.handle(
          _monthlyReportQuotaMeta,
          monthlyReportQuota.isAcceptableOrUnknown(
              data['monthly_report_quota']!, _monthlyReportQuotaMeta));
    } else if (isInserting) {
      context.missing(_monthlyReportQuotaMeta);
    }
    if (data.containsKey('group_consult_enabled')) {
      context.handle(
          _groupConsultEnabledMeta,
          groupConsultEnabled.isAcceptableOrUnknown(
              data['group_consult_enabled']!, _groupConsultEnabledMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Subscription map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Subscription(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}user_id'])!,
      plan: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}plan'])!,
      startAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_at'])!,
      expireAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}expire_at']),
      dailyChatQuota: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}daily_chat_quota'])!,
      monthlyReportQuota: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}monthly_report_quota'])!,
      groupConsultEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}group_consult_enabled'])!,
    );
  }

  @override
  $SubscriptionsTable createAlias(String alias) {
    return $SubscriptionsTable(attachedDatabase, alias);
  }
}

class Subscription extends DataClass implements Insertable<Subscription> {
  final int id;
  final int userId;

  /// Plan: FREE | COMPANION | FULLCARE | ANNUAL
  final String plan;
  final DateTime startAt;
  final DateTime? expireAt;
  final int dailyChatQuota;
  final int monthlyReportQuota;
  final bool groupConsultEnabled;
  const Subscription(
      {required this.id,
      required this.userId,
      required this.plan,
      required this.startAt,
      this.expireAt,
      required this.dailyChatQuota,
      required this.monthlyReportQuota,
      required this.groupConsultEnabled});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['plan'] = Variable<String>(plan);
    map['start_at'] = Variable<DateTime>(startAt);
    if (!nullToAbsent || expireAt != null) {
      map['expire_at'] = Variable<DateTime>(expireAt);
    }
    map['daily_chat_quota'] = Variable<int>(dailyChatQuota);
    map['monthly_report_quota'] = Variable<int>(monthlyReportQuota);
    map['group_consult_enabled'] = Variable<bool>(groupConsultEnabled);
    return map;
  }

  SubscriptionsCompanion toCompanion(bool nullToAbsent) {
    return SubscriptionsCompanion(
      id: Value(id),
      userId: Value(userId),
      plan: Value(plan),
      startAt: Value(startAt),
      expireAt: expireAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expireAt),
      dailyChatQuota: Value(dailyChatQuota),
      monthlyReportQuota: Value(monthlyReportQuota),
      groupConsultEnabled: Value(groupConsultEnabled),
    );
  }

  factory Subscription.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Subscription(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      plan: serializer.fromJson<String>(json['plan']),
      startAt: serializer.fromJson<DateTime>(json['startAt']),
      expireAt: serializer.fromJson<DateTime?>(json['expireAt']),
      dailyChatQuota: serializer.fromJson<int>(json['dailyChatQuota']),
      monthlyReportQuota: serializer.fromJson<int>(json['monthlyReportQuota']),
      groupConsultEnabled:
          serializer.fromJson<bool>(json['groupConsultEnabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'plan': serializer.toJson<String>(plan),
      'startAt': serializer.toJson<DateTime>(startAt),
      'expireAt': serializer.toJson<DateTime?>(expireAt),
      'dailyChatQuota': serializer.toJson<int>(dailyChatQuota),
      'monthlyReportQuota': serializer.toJson<int>(monthlyReportQuota),
      'groupConsultEnabled': serializer.toJson<bool>(groupConsultEnabled),
    };
  }

  Subscription copyWith(
          {int? id,
          int? userId,
          String? plan,
          DateTime? startAt,
          Value<DateTime?> expireAt = const Value.absent(),
          int? dailyChatQuota,
          int? monthlyReportQuota,
          bool? groupConsultEnabled}) =>
      Subscription(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        plan: plan ?? this.plan,
        startAt: startAt ?? this.startAt,
        expireAt: expireAt.present ? expireAt.value : this.expireAt,
        dailyChatQuota: dailyChatQuota ?? this.dailyChatQuota,
        monthlyReportQuota: monthlyReportQuota ?? this.monthlyReportQuota,
        groupConsultEnabled: groupConsultEnabled ?? this.groupConsultEnabled,
      );
  Subscription copyWithCompanion(SubscriptionsCompanion data) {
    return Subscription(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      plan: data.plan.present ? data.plan.value : this.plan,
      startAt: data.startAt.present ? data.startAt.value : this.startAt,
      expireAt: data.expireAt.present ? data.expireAt.value : this.expireAt,
      dailyChatQuota: data.dailyChatQuota.present
          ? data.dailyChatQuota.value
          : this.dailyChatQuota,
      monthlyReportQuota: data.monthlyReportQuota.present
          ? data.monthlyReportQuota.value
          : this.monthlyReportQuota,
      groupConsultEnabled: data.groupConsultEnabled.present
          ? data.groupConsultEnabled.value
          : this.groupConsultEnabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Subscription(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('plan: $plan, ')
          ..write('startAt: $startAt, ')
          ..write('expireAt: $expireAt, ')
          ..write('dailyChatQuota: $dailyChatQuota, ')
          ..write('monthlyReportQuota: $monthlyReportQuota, ')
          ..write('groupConsultEnabled: $groupConsultEnabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, plan, startAt, expireAt,
      dailyChatQuota, monthlyReportQuota, groupConsultEnabled);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Subscription &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.plan == this.plan &&
          other.startAt == this.startAt &&
          other.expireAt == this.expireAt &&
          other.dailyChatQuota == this.dailyChatQuota &&
          other.monthlyReportQuota == this.monthlyReportQuota &&
          other.groupConsultEnabled == this.groupConsultEnabled);
}

class SubscriptionsCompanion extends UpdateCompanion<Subscription> {
  final Value<int> id;
  final Value<int> userId;
  final Value<String> plan;
  final Value<DateTime> startAt;
  final Value<DateTime?> expireAt;
  final Value<int> dailyChatQuota;
  final Value<int> monthlyReportQuota;
  final Value<bool> groupConsultEnabled;
  const SubscriptionsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.plan = const Value.absent(),
    this.startAt = const Value.absent(),
    this.expireAt = const Value.absent(),
    this.dailyChatQuota = const Value.absent(),
    this.monthlyReportQuota = const Value.absent(),
    this.groupConsultEnabled = const Value.absent(),
  });
  SubscriptionsCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required String plan,
    required DateTime startAt,
    this.expireAt = const Value.absent(),
    required int dailyChatQuota,
    required int monthlyReportQuota,
    this.groupConsultEnabled = const Value.absent(),
  })  : userId = Value(userId),
        plan = Value(plan),
        startAt = Value(startAt),
        dailyChatQuota = Value(dailyChatQuota),
        monthlyReportQuota = Value(monthlyReportQuota);
  static Insertable<Subscription> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<String>? plan,
    Expression<DateTime>? startAt,
    Expression<DateTime>? expireAt,
    Expression<int>? dailyChatQuota,
    Expression<int>? monthlyReportQuota,
    Expression<bool>? groupConsultEnabled,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (plan != null) 'plan': plan,
      if (startAt != null) 'start_at': startAt,
      if (expireAt != null) 'expire_at': expireAt,
      if (dailyChatQuota != null) 'daily_chat_quota': dailyChatQuota,
      if (monthlyReportQuota != null)
        'monthly_report_quota': monthlyReportQuota,
      if (groupConsultEnabled != null)
        'group_consult_enabled': groupConsultEnabled,
    });
  }

  SubscriptionsCompanion copyWith(
      {Value<int>? id,
      Value<int>? userId,
      Value<String>? plan,
      Value<DateTime>? startAt,
      Value<DateTime?>? expireAt,
      Value<int>? dailyChatQuota,
      Value<int>? monthlyReportQuota,
      Value<bool>? groupConsultEnabled}) {
    return SubscriptionsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      plan: plan ?? this.plan,
      startAt: startAt ?? this.startAt,
      expireAt: expireAt ?? this.expireAt,
      dailyChatQuota: dailyChatQuota ?? this.dailyChatQuota,
      monthlyReportQuota: monthlyReportQuota ?? this.monthlyReportQuota,
      groupConsultEnabled: groupConsultEnabled ?? this.groupConsultEnabled,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (plan.present) {
      map['plan'] = Variable<String>(plan.value);
    }
    if (startAt.present) {
      map['start_at'] = Variable<DateTime>(startAt.value);
    }
    if (expireAt.present) {
      map['expire_at'] = Variable<DateTime>(expireAt.value);
    }
    if (dailyChatQuota.present) {
      map['daily_chat_quota'] = Variable<int>(dailyChatQuota.value);
    }
    if (monthlyReportQuota.present) {
      map['monthly_report_quota'] = Variable<int>(monthlyReportQuota.value);
    }
    if (groupConsultEnabled.present) {
      map['group_consult_enabled'] = Variable<bool>(groupConsultEnabled.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubscriptionsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('plan: $plan, ')
          ..write('startAt: $startAt, ')
          ..write('expireAt: $expireAt, ')
          ..write('dailyChatQuota: $dailyChatQuota, ')
          ..write('monthlyReportQuota: $monthlyReportQuota, ')
          ..write('groupConsultEnabled: $groupConsultEnabled')
          ..write(')'))
        .toString();
  }
}

class $SchemaMetaTable extends SchemaMeta
    with TableInfo<$SchemaMetaTable, SchemaMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SchemaMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, version];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schema_meta';
  @override
  VerificationContext validateIntegrity(Insertable<SchemaMetaData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SchemaMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SchemaMetaData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
    );
  }

  @override
  $SchemaMetaTable createAlias(String alias) {
    return $SchemaMetaTable(attachedDatabase, alias);
  }
}

class SchemaMetaData extends DataClass implements Insertable<SchemaMetaData> {
  final int id;
  final int version;
  const SchemaMetaData({required this.id, required this.version});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['version'] = Variable<int>(version);
    return map;
  }

  SchemaMetaCompanion toCompanion(bool nullToAbsent) {
    return SchemaMetaCompanion(
      id: Value(id),
      version: Value(version),
    );
  }

  factory SchemaMetaData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SchemaMetaData(
      id: serializer.fromJson<int>(json['id']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'version': serializer.toJson<int>(version),
    };
  }

  SchemaMetaData copyWith({int? id, int? version}) => SchemaMetaData(
        id: id ?? this.id,
        version: version ?? this.version,
      );
  SchemaMetaData copyWithCompanion(SchemaMetaCompanion data) {
    return SchemaMetaData(
      id: data.id.present ? data.id.value : this.id,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SchemaMetaData(')
          ..write('id: $id, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, version);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SchemaMetaData &&
          other.id == this.id &&
          other.version == this.version);
}

class SchemaMetaCompanion extends UpdateCompanion<SchemaMetaData> {
  final Value<int> id;
  final Value<int> version;
  const SchemaMetaCompanion({
    this.id = const Value.absent(),
    this.version = const Value.absent(),
  });
  SchemaMetaCompanion.insert({
    this.id = const Value.absent(),
    required int version,
  }) : version = Value(version);
  static Insertable<SchemaMetaData> custom({
    Expression<int>? id,
    Expression<int>? version,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (version != null) 'version': version,
    });
  }

  SchemaMetaCompanion copyWith({Value<int>? id, Value<int>? version}) {
    return SchemaMetaCompanion(
      id: id ?? this.id,
      version: version ?? this.version,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SchemaMetaCompanion(')
          ..write('id: $id, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $ConversationsTable conversations = $ConversationsTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $ProfileEventsTable profileEvents = $ProfileEventsTable(this);
  late final $TaskCardsTable taskCards = $TaskCardsTable(this);
  late final $SubscriptionsTable subscriptions = $SubscriptionsTable(this);
  late final $SchemaMetaTable schemaMeta = $SchemaMetaTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        users,
        conversations,
        messages,
        profileEvents,
        taskCards,
        subscriptions,
        schemaMeta
      ];
}

typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  Value<int> id,
  Value<String> nickname,
  Value<String> stage,
  Value<DateTime?> lastMenstruationDate,
  Value<DateTime?> dueDate,
  Value<DateTime?> birthDate,
  Value<int?> pregnancyWeek,
  Value<int?> postpartumWeek,
  required DateTime createdAt,
  required DateTime updatedAt,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<int> id,
  Value<String> nickname,
  Value<String> stage,
  Value<DateTime?> lastMenstruationDate,
  Value<DateTime?> dueDate,
  Value<DateTime?> birthDate,
  Value<int?> pregnancyWeek,
  Value<int?> postpartumWeek,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nickname => $composableBuilder(
      column: $table.nickname, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get stage => $composableBuilder(
      column: $table.stage, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastMenstruationDate => $composableBuilder(
      column: $table.lastMenstruationDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
      column: $table.birthDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pregnancyWeek => $composableBuilder(
      column: $table.pregnancyWeek, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get postpartumWeek => $composableBuilder(
      column: $table.postpartumWeek,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nickname => $composableBuilder(
      column: $table.nickname, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get stage => $composableBuilder(
      column: $table.stage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastMenstruationDate => $composableBuilder(
      column: $table.lastMenstruationDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
      column: $table.birthDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pregnancyWeek => $composableBuilder(
      column: $table.pregnancyWeek,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get postpartumWeek => $composableBuilder(
      column: $table.postpartumWeek,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<String> get stage =>
      $composableBuilder(column: $table.stage, builder: (column) => column);

  GeneratedColumn<DateTime> get lastMenstruationDate => $composableBuilder(
      column: $table.lastMenstruationDate, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<int> get pregnancyWeek => $composableBuilder(
      column: $table.pregnancyWeek, builder: (column) => column);

  GeneratedColumn<int> get postpartumWeek => $composableBuilder(
      column: $table.postpartumWeek, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
    User,
    PrefetchHooks Function()> {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> nickname = const Value.absent(),
            Value<String> stage = const Value.absent(),
            Value<DateTime?> lastMenstruationDate = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<DateTime?> birthDate = const Value.absent(),
            Value<int?> pregnancyWeek = const Value.absent(),
            Value<int?> postpartumWeek = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              UsersCompanion(
            id: id,
            nickname: nickname,
            stage: stage,
            lastMenstruationDate: lastMenstruationDate,
            dueDate: dueDate,
            birthDate: birthDate,
            pregnancyWeek: pregnancyWeek,
            postpartumWeek: postpartumWeek,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> nickname = const Value.absent(),
            Value<String> stage = const Value.absent(),
            Value<DateTime?> lastMenstruationDate = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<DateTime?> birthDate = const Value.absent(),
            Value<int?> pregnancyWeek = const Value.absent(),
            Value<int?> postpartumWeek = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
          }) =>
              UsersCompanion.insert(
            id: id,
            nickname: nickname,
            stage: stage,
            lastMenstruationDate: lastMenstruationDate,
            dueDate: dueDate,
            birthDate: birthDate,
            pregnancyWeek: pregnancyWeek,
            postpartumWeek: postpartumWeek,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
    User,
    PrefetchHooks Function()>;
typedef $$ConversationsTableCreateCompanionBuilder = ConversationsCompanion
    Function({
  Value<int> id,
  required int userId,
  required String role,
  required String type,
  required DateTime createdAt,
});
typedef $$ConversationsTableUpdateCompanionBuilder = ConversationsCompanion
    Function({
  Value<int> id,
  Value<int> userId,
  Value<String> role,
  Value<String> type,
  Value<DateTime> createdAt,
});

class $$ConversationsTableFilterComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ConversationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ConversationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ConversationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ConversationsTable,
    Conversation,
    $$ConversationsTableFilterComposer,
    $$ConversationsTableOrderingComposer,
    $$ConversationsTableAnnotationComposer,
    $$ConversationsTableCreateCompanionBuilder,
    $$ConversationsTableUpdateCompanionBuilder,
    (
      Conversation,
      BaseReferences<_$AppDatabase, $ConversationsTable, Conversation>
    ),
    Conversation,
    PrefetchHooks Function()> {
  $$ConversationsTableTableManager(_$AppDatabase db, $ConversationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConversationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConversationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConversationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> userId = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ConversationsCompanion(
            id: id,
            userId: userId,
            role: role,
            type: type,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int userId,
            required String role,
            required String type,
            required DateTime createdAt,
          }) =>
              ConversationsCompanion.insert(
            id: id,
            userId: userId,
            role: role,
            type: type,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ConversationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ConversationsTable,
    Conversation,
    $$ConversationsTableFilterComposer,
    $$ConversationsTableOrderingComposer,
    $$ConversationsTableAnnotationComposer,
    $$ConversationsTableCreateCompanionBuilder,
    $$ConversationsTableUpdateCompanionBuilder,
    (
      Conversation,
      BaseReferences<_$AppDatabase, $ConversationsTable, Conversation>
    ),
    Conversation,
    PrefetchHooks Function()>;
typedef $$MessagesTableCreateCompanionBuilder = MessagesCompanion Function({
  Value<int> id,
  required int conversationId,
  required String role,
  Value<String?> speakerRole,
  required String content,
  Value<String?> imageRef,
  Value<int?> tokenCost,
  Value<String?> agentReplyRef,
  required DateTime createdAt,
});
typedef $$MessagesTableUpdateCompanionBuilder = MessagesCompanion Function({
  Value<int> id,
  Value<int> conversationId,
  Value<String> role,
  Value<String?> speakerRole,
  Value<String> content,
  Value<String?> imageRef,
  Value<int?> tokenCost,
  Value<String?> agentReplyRef,
  Value<DateTime> createdAt,
});

class $$MessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get conversationId => $composableBuilder(
      column: $table.conversationId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get speakerRole => $composableBuilder(
      column: $table.speakerRole, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageRef => $composableBuilder(
      column: $table.imageRef, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tokenCost => $composableBuilder(
      column: $table.tokenCost, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get agentReplyRef => $composableBuilder(
      column: $table.agentReplyRef, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$MessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get conversationId => $composableBuilder(
      column: $table.conversationId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get speakerRole => $composableBuilder(
      column: $table.speakerRole, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageRef => $composableBuilder(
      column: $table.imageRef, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tokenCost => $composableBuilder(
      column: $table.tokenCost, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get agentReplyRef => $composableBuilder(
      column: $table.agentReplyRef,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get conversationId => $composableBuilder(
      column: $table.conversationId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get speakerRole => $composableBuilder(
      column: $table.speakerRole, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get imageRef =>
      $composableBuilder(column: $table.imageRef, builder: (column) => column);

  GeneratedColumn<int> get tokenCost =>
      $composableBuilder(column: $table.tokenCost, builder: (column) => column);

  GeneratedColumn<String> get agentReplyRef => $composableBuilder(
      column: $table.agentReplyRef, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MessagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MessagesTable,
    Message,
    $$MessagesTableFilterComposer,
    $$MessagesTableOrderingComposer,
    $$MessagesTableAnnotationComposer,
    $$MessagesTableCreateCompanionBuilder,
    $$MessagesTableUpdateCompanionBuilder,
    (Message, BaseReferences<_$AppDatabase, $MessagesTable, Message>),
    Message,
    PrefetchHooks Function()> {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> conversationId = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String?> speakerRole = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<String?> imageRef = const Value.absent(),
            Value<int?> tokenCost = const Value.absent(),
            Value<String?> agentReplyRef = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              MessagesCompanion(
            id: id,
            conversationId: conversationId,
            role: role,
            speakerRole: speakerRole,
            content: content,
            imageRef: imageRef,
            tokenCost: tokenCost,
            agentReplyRef: agentReplyRef,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int conversationId,
            required String role,
            Value<String?> speakerRole = const Value.absent(),
            required String content,
            Value<String?> imageRef = const Value.absent(),
            Value<int?> tokenCost = const Value.absent(),
            Value<String?> agentReplyRef = const Value.absent(),
            required DateTime createdAt,
          }) =>
              MessagesCompanion.insert(
            id: id,
            conversationId: conversationId,
            role: role,
            speakerRole: speakerRole,
            content: content,
            imageRef: imageRef,
            tokenCost: tokenCost,
            agentReplyRef: agentReplyRef,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MessagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MessagesTable,
    Message,
    $$MessagesTableFilterComposer,
    $$MessagesTableOrderingComposer,
    $$MessagesTableAnnotationComposer,
    $$MessagesTableCreateCompanionBuilder,
    $$MessagesTableUpdateCompanionBuilder,
    (Message, BaseReferences<_$AppDatabase, $MessagesTable, Message>),
    Message,
    PrefetchHooks Function()>;
typedef $$ProfileEventsTableCreateCompanionBuilder = ProfileEventsCompanion
    Function({
  Value<int> id,
  required int userId,
  required DateTime weekStart,
  required int weekValue,
  required String weekUnit,
  required String category,
  required String summary,
  Value<String?> rawRef,
  Value<double?> riskScore,
});
typedef $$ProfileEventsTableUpdateCompanionBuilder = ProfileEventsCompanion
    Function({
  Value<int> id,
  Value<int> userId,
  Value<DateTime> weekStart,
  Value<int> weekValue,
  Value<String> weekUnit,
  Value<String> category,
  Value<String> summary,
  Value<String?> rawRef,
  Value<double?> riskScore,
});

class $$ProfileEventsTableFilterComposer
    extends Composer<_$AppDatabase, $ProfileEventsTable> {
  $$ProfileEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get weekStart => $composableBuilder(
      column: $table.weekStart, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get weekValue => $composableBuilder(
      column: $table.weekValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get weekUnit => $composableBuilder(
      column: $table.weekUnit, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get summary => $composableBuilder(
      column: $table.summary, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rawRef => $composableBuilder(
      column: $table.rawRef, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get riskScore => $composableBuilder(
      column: $table.riskScore, builder: (column) => ColumnFilters(column));
}

class $$ProfileEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfileEventsTable> {
  $$ProfileEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get weekStart => $composableBuilder(
      column: $table.weekStart, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get weekValue => $composableBuilder(
      column: $table.weekValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get weekUnit => $composableBuilder(
      column: $table.weekUnit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get summary => $composableBuilder(
      column: $table.summary, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rawRef => $composableBuilder(
      column: $table.rawRef, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get riskScore => $composableBuilder(
      column: $table.riskScore, builder: (column) => ColumnOrderings(column));
}

class $$ProfileEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfileEventsTable> {
  $$ProfileEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get weekStart =>
      $composableBuilder(column: $table.weekStart, builder: (column) => column);

  GeneratedColumn<int> get weekValue =>
      $composableBuilder(column: $table.weekValue, builder: (column) => column);

  GeneratedColumn<String> get weekUnit =>
      $composableBuilder(column: $table.weekUnit, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get rawRef =>
      $composableBuilder(column: $table.rawRef, builder: (column) => column);

  GeneratedColumn<double> get riskScore =>
      $composableBuilder(column: $table.riskScore, builder: (column) => column);
}

class $$ProfileEventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProfileEventsTable,
    ProfileEvent,
    $$ProfileEventsTableFilterComposer,
    $$ProfileEventsTableOrderingComposer,
    $$ProfileEventsTableAnnotationComposer,
    $$ProfileEventsTableCreateCompanionBuilder,
    $$ProfileEventsTableUpdateCompanionBuilder,
    (
      ProfileEvent,
      BaseReferences<_$AppDatabase, $ProfileEventsTable, ProfileEvent>
    ),
    ProfileEvent,
    PrefetchHooks Function()> {
  $$ProfileEventsTableTableManager(_$AppDatabase db, $ProfileEventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfileEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfileEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfileEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> userId = const Value.absent(),
            Value<DateTime> weekStart = const Value.absent(),
            Value<int> weekValue = const Value.absent(),
            Value<String> weekUnit = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> summary = const Value.absent(),
            Value<String?> rawRef = const Value.absent(),
            Value<double?> riskScore = const Value.absent(),
          }) =>
              ProfileEventsCompanion(
            id: id,
            userId: userId,
            weekStart: weekStart,
            weekValue: weekValue,
            weekUnit: weekUnit,
            category: category,
            summary: summary,
            rawRef: rawRef,
            riskScore: riskScore,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int userId,
            required DateTime weekStart,
            required int weekValue,
            required String weekUnit,
            required String category,
            required String summary,
            Value<String?> rawRef = const Value.absent(),
            Value<double?> riskScore = const Value.absent(),
          }) =>
              ProfileEventsCompanion.insert(
            id: id,
            userId: userId,
            weekStart: weekStart,
            weekValue: weekValue,
            weekUnit: weekUnit,
            category: category,
            summary: summary,
            rawRef: rawRef,
            riskScore: riskScore,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProfileEventsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProfileEventsTable,
    ProfileEvent,
    $$ProfileEventsTableFilterComposer,
    $$ProfileEventsTableOrderingComposer,
    $$ProfileEventsTableAnnotationComposer,
    $$ProfileEventsTableCreateCompanionBuilder,
    $$ProfileEventsTableUpdateCompanionBuilder,
    (
      ProfileEvent,
      BaseReferences<_$AppDatabase, $ProfileEventsTable, ProfileEvent>
    ),
    ProfileEvent,
    PrefetchHooks Function()>;
typedef $$TaskCardsTableCreateCompanionBuilder = TaskCardsCompanion Function({
  Value<int> id,
  required int userId,
  required DateTime localDate,
  required String stage,
  Value<int?> weekValue,
  required String payloadJson,
  required String status,
});
typedef $$TaskCardsTableUpdateCompanionBuilder = TaskCardsCompanion Function({
  Value<int> id,
  Value<int> userId,
  Value<DateTime> localDate,
  Value<String> stage,
  Value<int?> weekValue,
  Value<String> payloadJson,
  Value<String> status,
});

class $$TaskCardsTableFilterComposer
    extends Composer<_$AppDatabase, $TaskCardsTable> {
  $$TaskCardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get localDate => $composableBuilder(
      column: $table.localDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get stage => $composableBuilder(
      column: $table.stage, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get weekValue => $composableBuilder(
      column: $table.weekValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));
}

class $$TaskCardsTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskCardsTable> {
  $$TaskCardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get localDate => $composableBuilder(
      column: $table.localDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get stage => $composableBuilder(
      column: $table.stage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get weekValue => $composableBuilder(
      column: $table.weekValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));
}

class $$TaskCardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskCardsTable> {
  $$TaskCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);

  GeneratedColumn<String> get stage =>
      $composableBuilder(column: $table.stage, builder: (column) => column);

  GeneratedColumn<int> get weekValue =>
      $composableBuilder(column: $table.weekValue, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$TaskCardsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TaskCardsTable,
    TaskCard,
    $$TaskCardsTableFilterComposer,
    $$TaskCardsTableOrderingComposer,
    $$TaskCardsTableAnnotationComposer,
    $$TaskCardsTableCreateCompanionBuilder,
    $$TaskCardsTableUpdateCompanionBuilder,
    (TaskCard, BaseReferences<_$AppDatabase, $TaskCardsTable, TaskCard>),
    TaskCard,
    PrefetchHooks Function()> {
  $$TaskCardsTableTableManager(_$AppDatabase db, $TaskCardsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> userId = const Value.absent(),
            Value<DateTime> localDate = const Value.absent(),
            Value<String> stage = const Value.absent(),
            Value<int?> weekValue = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<String> status = const Value.absent(),
          }) =>
              TaskCardsCompanion(
            id: id,
            userId: userId,
            localDate: localDate,
            stage: stage,
            weekValue: weekValue,
            payloadJson: payloadJson,
            status: status,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int userId,
            required DateTime localDate,
            required String stage,
            Value<int?> weekValue = const Value.absent(),
            required String payloadJson,
            required String status,
          }) =>
              TaskCardsCompanion.insert(
            id: id,
            userId: userId,
            localDate: localDate,
            stage: stage,
            weekValue: weekValue,
            payloadJson: payloadJson,
            status: status,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TaskCardsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TaskCardsTable,
    TaskCard,
    $$TaskCardsTableFilterComposer,
    $$TaskCardsTableOrderingComposer,
    $$TaskCardsTableAnnotationComposer,
    $$TaskCardsTableCreateCompanionBuilder,
    $$TaskCardsTableUpdateCompanionBuilder,
    (TaskCard, BaseReferences<_$AppDatabase, $TaskCardsTable, TaskCard>),
    TaskCard,
    PrefetchHooks Function()>;
typedef $$SubscriptionsTableCreateCompanionBuilder = SubscriptionsCompanion
    Function({
  Value<int> id,
  required int userId,
  required String plan,
  required DateTime startAt,
  Value<DateTime?> expireAt,
  required int dailyChatQuota,
  required int monthlyReportQuota,
  Value<bool> groupConsultEnabled,
});
typedef $$SubscriptionsTableUpdateCompanionBuilder = SubscriptionsCompanion
    Function({
  Value<int> id,
  Value<int> userId,
  Value<String> plan,
  Value<DateTime> startAt,
  Value<DateTime?> expireAt,
  Value<int> dailyChatQuota,
  Value<int> monthlyReportQuota,
  Value<bool> groupConsultEnabled,
});

class $$SubscriptionsTableFilterComposer
    extends Composer<_$AppDatabase, $SubscriptionsTable> {
  $$SubscriptionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get plan => $composableBuilder(
      column: $table.plan, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startAt => $composableBuilder(
      column: $table.startAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get expireAt => $composableBuilder(
      column: $table.expireAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dailyChatQuota => $composableBuilder(
      column: $table.dailyChatQuota,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get monthlyReportQuota => $composableBuilder(
      column: $table.monthlyReportQuota,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get groupConsultEnabled => $composableBuilder(
      column: $table.groupConsultEnabled,
      builder: (column) => ColumnFilters(column));
}

class $$SubscriptionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubscriptionsTable> {
  $$SubscriptionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get plan => $composableBuilder(
      column: $table.plan, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startAt => $composableBuilder(
      column: $table.startAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get expireAt => $composableBuilder(
      column: $table.expireAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dailyChatQuota => $composableBuilder(
      column: $table.dailyChatQuota,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get monthlyReportQuota => $composableBuilder(
      column: $table.monthlyReportQuota,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get groupConsultEnabled => $composableBuilder(
      column: $table.groupConsultEnabled,
      builder: (column) => ColumnOrderings(column));
}

class $$SubscriptionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubscriptionsTable> {
  $$SubscriptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get plan =>
      $composableBuilder(column: $table.plan, builder: (column) => column);

  GeneratedColumn<DateTime> get startAt =>
      $composableBuilder(column: $table.startAt, builder: (column) => column);

  GeneratedColumn<DateTime> get expireAt =>
      $composableBuilder(column: $table.expireAt, builder: (column) => column);

  GeneratedColumn<int> get dailyChatQuota => $composableBuilder(
      column: $table.dailyChatQuota, builder: (column) => column);

  GeneratedColumn<int> get monthlyReportQuota => $composableBuilder(
      column: $table.monthlyReportQuota, builder: (column) => column);

  GeneratedColumn<bool> get groupConsultEnabled => $composableBuilder(
      column: $table.groupConsultEnabled, builder: (column) => column);
}

class $$SubscriptionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SubscriptionsTable,
    Subscription,
    $$SubscriptionsTableFilterComposer,
    $$SubscriptionsTableOrderingComposer,
    $$SubscriptionsTableAnnotationComposer,
    $$SubscriptionsTableCreateCompanionBuilder,
    $$SubscriptionsTableUpdateCompanionBuilder,
    (
      Subscription,
      BaseReferences<_$AppDatabase, $SubscriptionsTable, Subscription>
    ),
    Subscription,
    PrefetchHooks Function()> {
  $$SubscriptionsTableTableManager(_$AppDatabase db, $SubscriptionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubscriptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubscriptionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubscriptionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> userId = const Value.absent(),
            Value<String> plan = const Value.absent(),
            Value<DateTime> startAt = const Value.absent(),
            Value<DateTime?> expireAt = const Value.absent(),
            Value<int> dailyChatQuota = const Value.absent(),
            Value<int> monthlyReportQuota = const Value.absent(),
            Value<bool> groupConsultEnabled = const Value.absent(),
          }) =>
              SubscriptionsCompanion(
            id: id,
            userId: userId,
            plan: plan,
            startAt: startAt,
            expireAt: expireAt,
            dailyChatQuota: dailyChatQuota,
            monthlyReportQuota: monthlyReportQuota,
            groupConsultEnabled: groupConsultEnabled,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int userId,
            required String plan,
            required DateTime startAt,
            Value<DateTime?> expireAt = const Value.absent(),
            required int dailyChatQuota,
            required int monthlyReportQuota,
            Value<bool> groupConsultEnabled = const Value.absent(),
          }) =>
              SubscriptionsCompanion.insert(
            id: id,
            userId: userId,
            plan: plan,
            startAt: startAt,
            expireAt: expireAt,
            dailyChatQuota: dailyChatQuota,
            monthlyReportQuota: monthlyReportQuota,
            groupConsultEnabled: groupConsultEnabled,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SubscriptionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SubscriptionsTable,
    Subscription,
    $$SubscriptionsTableFilterComposer,
    $$SubscriptionsTableOrderingComposer,
    $$SubscriptionsTableAnnotationComposer,
    $$SubscriptionsTableCreateCompanionBuilder,
    $$SubscriptionsTableUpdateCompanionBuilder,
    (
      Subscription,
      BaseReferences<_$AppDatabase, $SubscriptionsTable, Subscription>
    ),
    Subscription,
    PrefetchHooks Function()>;
typedef $$SchemaMetaTableCreateCompanionBuilder = SchemaMetaCompanion Function({
  Value<int> id,
  required int version,
});
typedef $$SchemaMetaTableUpdateCompanionBuilder = SchemaMetaCompanion Function({
  Value<int> id,
  Value<int> version,
});

class $$SchemaMetaTableFilterComposer
    extends Composer<_$AppDatabase, $SchemaMetaTable> {
  $$SchemaMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));
}

class $$SchemaMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $SchemaMetaTable> {
  $$SchemaMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));
}

class $$SchemaMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $SchemaMetaTable> {
  $$SchemaMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);
}

class $$SchemaMetaTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SchemaMetaTable,
    SchemaMetaData,
    $$SchemaMetaTableFilterComposer,
    $$SchemaMetaTableOrderingComposer,
    $$SchemaMetaTableAnnotationComposer,
    $$SchemaMetaTableCreateCompanionBuilder,
    $$SchemaMetaTableUpdateCompanionBuilder,
    (
      SchemaMetaData,
      BaseReferences<_$AppDatabase, $SchemaMetaTable, SchemaMetaData>
    ),
    SchemaMetaData,
    PrefetchHooks Function()> {
  $$SchemaMetaTableTableManager(_$AppDatabase db, $SchemaMetaTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SchemaMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SchemaMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SchemaMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> version = const Value.absent(),
          }) =>
              SchemaMetaCompanion(
            id: id,
            version: version,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int version,
          }) =>
              SchemaMetaCompanion.insert(
            id: id,
            version: version,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SchemaMetaTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SchemaMetaTable,
    SchemaMetaData,
    $$SchemaMetaTableFilterComposer,
    $$SchemaMetaTableOrderingComposer,
    $$SchemaMetaTableAnnotationComposer,
    $$SchemaMetaTableCreateCompanionBuilder,
    $$SchemaMetaTableUpdateCompanionBuilder,
    (
      SchemaMetaData,
      BaseReferences<_$AppDatabase, $SchemaMetaTable, SchemaMetaData>
    ),
    SchemaMetaData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$ConversationsTableTableManager get conversations =>
      $$ConversationsTableTableManager(_db, _db.conversations);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$ProfileEventsTableTableManager get profileEvents =>
      $$ProfileEventsTableTableManager(_db, _db.profileEvents);
  $$TaskCardsTableTableManager get taskCards =>
      $$TaskCardsTableTableManager(_db, _db.taskCards);
  $$SubscriptionsTableTableManager get subscriptions =>
      $$SubscriptionsTableTableManager(_db, _db.subscriptions);
  $$SchemaMetaTableTableManager get schemaMeta =>
      $$SchemaMetaTableTableManager(_db, _db.schemaMeta);
}
