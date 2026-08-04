// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CustomersTable extends Customers
    with TableInfo<$CustomersTable, CustomerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyMeta = const VerificationMeta(
    'company',
  );
  @override
  late final GeneratedColumn<String> company = GeneratedColumn<String>(
    'company',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wechatMeta = const VerificationMeta('wechat');
  @override
  late final GeneratedColumn<String> wechat = GeneratedColumn<String>(
    'wechat',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stageMeta = const VerificationMeta('stage');
  @override
  late final GeneratedColumn<String> stage = GeneratedColumn<String>(
    'stage',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('potential'),
  );
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<String> grade = GeneratedColumn<String>(
    'grade',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('c'),
  );
  static const VerificationMeta _lastFollowAtMeta = const VerificationMeta(
    'lastFollowAt',
  );
  @override
  late final GeneratedColumn<int> lastFollowAt = GeneratedColumn<int>(
    'last_follow_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    company,
    phone,
    wechat,
    address,
    source,
    note,
    stage,
    grade,
    lastFollowAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomerRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('company')) {
      context.handle(
        _companyMeta,
        company.isAcceptableOrUnknown(data['company']!, _companyMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('wechat')) {
      context.handle(
        _wechatMeta,
        wechat.isAcceptableOrUnknown(data['wechat']!, _wechatMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('stage')) {
      context.handle(
        _stageMeta,
        stage.isAcceptableOrUnknown(data['stage']!, _stageMeta),
      );
    }
    if (data.containsKey('grade')) {
      context.handle(
        _gradeMeta,
        grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta),
      );
    }
    if (data.containsKey('last_follow_at')) {
      context.handle(
        _lastFollowAtMeta,
        lastFollowAt.isAcceptableOrUnknown(
          data['last_follow_at']!,
          _lastFollowAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomerRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      company: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      wechat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wechat'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      stage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stage'],
      )!,
      grade: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grade'],
      )!,
      lastFollowAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_follow_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }
}

class CustomerRow extends DataClass implements Insertable<CustomerRow> {
  final int id;

  /// 客户名称。唯一必填项。
  final String name;
  final String? company;

  /// 电话。建索引以支持模糊搜索。
  final String? phone;
  final String? wechat;
  final String? address;

  /// 来源渠道。自由文本，不做枚举，实际来源太杂。
  final String? source;
  final String? note;

  /// 客户阶段，存 CustomerStage.dbValue。
  final String stage;

  /// 客户分级，存 CustomerGrade.dbValue。
  final String grade;

  /// 最后一次跟进时间，UTC 毫秒。
  ///
  /// 冗余字段，由 FollowupDao 在写入跟进记录时同步维护。
  /// 「久未联系」查询需要按它过滤，每次对 followups 做聚合在 500 客户下太慢。
  final int? lastFollowAt;
  final int createdAt;
  final int updatedAt;
  const CustomerRow({
    required this.id,
    required this.name,
    this.company,
    this.phone,
    this.wechat,
    this.address,
    this.source,
    this.note,
    required this.stage,
    required this.grade,
    this.lastFollowAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || company != null) {
      map['company'] = Variable<String>(company);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || wechat != null) {
      map['wechat'] = Variable<String>(wechat);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['stage'] = Variable<String>(stage);
    map['grade'] = Variable<String>(grade);
    if (!nullToAbsent || lastFollowAt != null) {
      map['last_follow_at'] = Variable<int>(lastFollowAt);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
      id: Value(id),
      name: Value(name),
      company: company == null && nullToAbsent
          ? const Value.absent()
          : Value(company),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      wechat: wechat == null && nullToAbsent
          ? const Value.absent()
          : Value(wechat),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      source: source == null && nullToAbsent
          ? const Value.absent()
          : Value(source),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      stage: Value(stage),
      grade: Value(grade),
      lastFollowAt: lastFollowAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastFollowAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CustomerRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomerRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      company: serializer.fromJson<String?>(json['company']),
      phone: serializer.fromJson<String?>(json['phone']),
      wechat: serializer.fromJson<String?>(json['wechat']),
      address: serializer.fromJson<String?>(json['address']),
      source: serializer.fromJson<String?>(json['source']),
      note: serializer.fromJson<String?>(json['note']),
      stage: serializer.fromJson<String>(json['stage']),
      grade: serializer.fromJson<String>(json['grade']),
      lastFollowAt: serializer.fromJson<int?>(json['lastFollowAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'company': serializer.toJson<String?>(company),
      'phone': serializer.toJson<String?>(phone),
      'wechat': serializer.toJson<String?>(wechat),
      'address': serializer.toJson<String?>(address),
      'source': serializer.toJson<String?>(source),
      'note': serializer.toJson<String?>(note),
      'stage': serializer.toJson<String>(stage),
      'grade': serializer.toJson<String>(grade),
      'lastFollowAt': serializer.toJson<int?>(lastFollowAt),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  CustomerRow copyWith({
    int? id,
    String? name,
    Value<String?> company = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> wechat = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> source = const Value.absent(),
    Value<String?> note = const Value.absent(),
    String? stage,
    String? grade,
    Value<int?> lastFollowAt = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => CustomerRow(
    id: id ?? this.id,
    name: name ?? this.name,
    company: company.present ? company.value : this.company,
    phone: phone.present ? phone.value : this.phone,
    wechat: wechat.present ? wechat.value : this.wechat,
    address: address.present ? address.value : this.address,
    source: source.present ? source.value : this.source,
    note: note.present ? note.value : this.note,
    stage: stage ?? this.stage,
    grade: grade ?? this.grade,
    lastFollowAt: lastFollowAt.present ? lastFollowAt.value : this.lastFollowAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CustomerRow copyWithCompanion(CustomersCompanion data) {
    return CustomerRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      company: data.company.present ? data.company.value : this.company,
      phone: data.phone.present ? data.phone.value : this.phone,
      wechat: data.wechat.present ? data.wechat.value : this.wechat,
      address: data.address.present ? data.address.value : this.address,
      source: data.source.present ? data.source.value : this.source,
      note: data.note.present ? data.note.value : this.note,
      stage: data.stage.present ? data.stage.value : this.stage,
      grade: data.grade.present ? data.grade.value : this.grade,
      lastFollowAt: data.lastFollowAt.present
          ? data.lastFollowAt.value
          : this.lastFollowAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomerRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('company: $company, ')
          ..write('phone: $phone, ')
          ..write('wechat: $wechat, ')
          ..write('address: $address, ')
          ..write('source: $source, ')
          ..write('note: $note, ')
          ..write('stage: $stage, ')
          ..write('grade: $grade, ')
          ..write('lastFollowAt: $lastFollowAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    company,
    phone,
    wechat,
    address,
    source,
    note,
    stage,
    grade,
    lastFollowAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomerRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.company == this.company &&
          other.phone == this.phone &&
          other.wechat == this.wechat &&
          other.address == this.address &&
          other.source == this.source &&
          other.note == this.note &&
          other.stage == this.stage &&
          other.grade == this.grade &&
          other.lastFollowAt == this.lastFollowAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CustomersCompanion extends UpdateCompanion<CustomerRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> company;
  final Value<String?> phone;
  final Value<String?> wechat;
  final Value<String?> address;
  final Value<String?> source;
  final Value<String?> note;
  final Value<String> stage;
  final Value<String> grade;
  final Value<int?> lastFollowAt;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  const CustomersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.company = const Value.absent(),
    this.phone = const Value.absent(),
    this.wechat = const Value.absent(),
    this.address = const Value.absent(),
    this.source = const Value.absent(),
    this.note = const Value.absent(),
    this.stage = const Value.absent(),
    this.grade = const Value.absent(),
    this.lastFollowAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CustomersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.company = const Value.absent(),
    this.phone = const Value.absent(),
    this.wechat = const Value.absent(),
    this.address = const Value.absent(),
    this.source = const Value.absent(),
    this.note = const Value.absent(),
    this.stage = const Value.absent(),
    this.grade = const Value.absent(),
    this.lastFollowAt = const Value.absent(),
    required int createdAt,
    required int updatedAt,
  }) : name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CustomerRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? company,
    Expression<String>? phone,
    Expression<String>? wechat,
    Expression<String>? address,
    Expression<String>? source,
    Expression<String>? note,
    Expression<String>? stage,
    Expression<String>? grade,
    Expression<int>? lastFollowAt,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (company != null) 'company': company,
      if (phone != null) 'phone': phone,
      if (wechat != null) 'wechat': wechat,
      if (address != null) 'address': address,
      if (source != null) 'source': source,
      if (note != null) 'note': note,
      if (stage != null) 'stage': stage,
      if (grade != null) 'grade': grade,
      if (lastFollowAt != null) 'last_follow_at': lastFollowAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CustomersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? company,
    Value<String?>? phone,
    Value<String?>? wechat,
    Value<String?>? address,
    Value<String?>? source,
    Value<String?>? note,
    Value<String>? stage,
    Value<String>? grade,
    Value<int?>? lastFollowAt,
    Value<int>? createdAt,
    Value<int>? updatedAt,
  }) {
    return CustomersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      company: company ?? this.company,
      phone: phone ?? this.phone,
      wechat: wechat ?? this.wechat,
      address: address ?? this.address,
      source: source ?? this.source,
      note: note ?? this.note,
      stage: stage ?? this.stage,
      grade: grade ?? this.grade,
      lastFollowAt: lastFollowAt ?? this.lastFollowAt,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (company.present) {
      map['company'] = Variable<String>(company.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (wechat.present) {
      map['wechat'] = Variable<String>(wechat.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (stage.present) {
      map['stage'] = Variable<String>(stage.value);
    }
    if (grade.present) {
      map['grade'] = Variable<String>(grade.value);
    }
    if (lastFollowAt.present) {
      map['last_follow_at'] = Variable<int>(lastFollowAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('company: $company, ')
          ..write('phone: $phone, ')
          ..write('wechat: $wechat, ')
          ..write('address: $address, ')
          ..write('source: $source, ')
          ..write('note: $note, ')
          ..write('stage: $stage, ')
          ..write('grade: $grade, ')
          ..write('lastFollowAt: $lastFollowAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ContactsTable extends Contacts
    with TableInfo<$ContactsTable, ContactRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<int> customerId = GeneratedColumn<int>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES customers (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<String> position = GeneratedColumn<String>(
    'position',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDecisionMakerMeta = const VerificationMeta(
    'isDecisionMaker',
  );
  @override
  late final GeneratedColumn<bool> isDecisionMaker = GeneratedColumn<bool>(
    'is_decision_maker',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_decision_maker" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    customerId,
    name,
    position,
    phone,
    isDecisionMaker,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contacts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContactRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('is_decision_maker')) {
      context.handle(
        _isDecisionMakerMeta,
        isDecisionMaker.isAcceptableOrUnknown(
          data['is_decision_maker']!,
          _isDecisionMakerMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContactRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContactRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}customer_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}position'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      isDecisionMaker: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_decision_maker'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ContactsTable createAlias(String alias) {
    return $ContactsTable(attachedDatabase, alias);
  }
}

class ContactRow extends DataClass implements Insertable<ContactRow> {
  final int id;
  final int customerId;
  final String name;
  final String? position;
  final String? phone;

  /// 是否决策人。能拍板的那个人要能一眼看出来。
  final bool isDecisionMaker;
  final int createdAt;
  final int updatedAt;
  const ContactRow({
    required this.id,
    required this.customerId,
    required this.name,
    this.position,
    this.phone,
    required this.isDecisionMaker,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['customer_id'] = Variable<int>(customerId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || position != null) {
      map['position'] = Variable<String>(position);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['is_decision_maker'] = Variable<bool>(isDecisionMaker);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  ContactsCompanion toCompanion(bool nullToAbsent) {
    return ContactsCompanion(
      id: Value(id),
      customerId: Value(customerId),
      name: Value(name),
      position: position == null && nullToAbsent
          ? const Value.absent()
          : Value(position),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      isDecisionMaker: Value(isDecisionMaker),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ContactRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContactRow(
      id: serializer.fromJson<int>(json['id']),
      customerId: serializer.fromJson<int>(json['customerId']),
      name: serializer.fromJson<String>(json['name']),
      position: serializer.fromJson<String?>(json['position']),
      phone: serializer.fromJson<String?>(json['phone']),
      isDecisionMaker: serializer.fromJson<bool>(json['isDecisionMaker']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'customerId': serializer.toJson<int>(customerId),
      'name': serializer.toJson<String>(name),
      'position': serializer.toJson<String?>(position),
      'phone': serializer.toJson<String?>(phone),
      'isDecisionMaker': serializer.toJson<bool>(isDecisionMaker),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  ContactRow copyWith({
    int? id,
    int? customerId,
    String? name,
    Value<String?> position = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    bool? isDecisionMaker,
    int? createdAt,
    int? updatedAt,
  }) => ContactRow(
    id: id ?? this.id,
    customerId: customerId ?? this.customerId,
    name: name ?? this.name,
    position: position.present ? position.value : this.position,
    phone: phone.present ? phone.value : this.phone,
    isDecisionMaker: isDecisionMaker ?? this.isDecisionMaker,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ContactRow copyWithCompanion(ContactsCompanion data) {
    return ContactRow(
      id: data.id.present ? data.id.value : this.id,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      name: data.name.present ? data.name.value : this.name,
      position: data.position.present ? data.position.value : this.position,
      phone: data.phone.present ? data.phone.value : this.phone,
      isDecisionMaker: data.isDecisionMaker.present
          ? data.isDecisionMaker.value
          : this.isDecisionMaker,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContactRow(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('name: $name, ')
          ..write('position: $position, ')
          ..write('phone: $phone, ')
          ..write('isDecisionMaker: $isDecisionMaker, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    customerId,
    name,
    position,
    phone,
    isDecisionMaker,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContactRow &&
          other.id == this.id &&
          other.customerId == this.customerId &&
          other.name == this.name &&
          other.position == this.position &&
          other.phone == this.phone &&
          other.isDecisionMaker == this.isDecisionMaker &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ContactsCompanion extends UpdateCompanion<ContactRow> {
  final Value<int> id;
  final Value<int> customerId;
  final Value<String> name;
  final Value<String?> position;
  final Value<String?> phone;
  final Value<bool> isDecisionMaker;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  const ContactsCompanion({
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.name = const Value.absent(),
    this.position = const Value.absent(),
    this.phone = const Value.absent(),
    this.isDecisionMaker = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ContactsCompanion.insert({
    this.id = const Value.absent(),
    required int customerId,
    required String name,
    this.position = const Value.absent(),
    this.phone = const Value.absent(),
    this.isDecisionMaker = const Value.absent(),
    required int createdAt,
    required int updatedAt,
  }) : customerId = Value(customerId),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ContactRow> custom({
    Expression<int>? id,
    Expression<int>? customerId,
    Expression<String>? name,
    Expression<String>? position,
    Expression<String>? phone,
    Expression<bool>? isDecisionMaker,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      if (name != null) 'name': name,
      if (position != null) 'position': position,
      if (phone != null) 'phone': phone,
      if (isDecisionMaker != null) 'is_decision_maker': isDecisionMaker,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ContactsCompanion copyWith({
    Value<int>? id,
    Value<int>? customerId,
    Value<String>? name,
    Value<String?>? position,
    Value<String?>? phone,
    Value<bool>? isDecisionMaker,
    Value<int>? createdAt,
    Value<int>? updatedAt,
  }) {
    return ContactsCompanion(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      name: name ?? this.name,
      position: position ?? this.position,
      phone: phone ?? this.phone,
      isDecisionMaker: isDecisionMaker ?? this.isDecisionMaker,
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
    if (customerId.present) {
      map['customer_id'] = Variable<int>(customerId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (position.present) {
      map['position'] = Variable<String>(position.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (isDecisionMaker.present) {
      map['is_decision_maker'] = Variable<bool>(isDecisionMaker.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactsCompanion(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('name: $name, ')
          ..write('position: $position, ')
          ..write('phone: $phone, ')
          ..write('isDecisionMaker: $isDecisionMaker, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $FollowupsTable extends Followups
    with TableInfo<$FollowupsTable, FollowupRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FollowupsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<int> customerId = GeneratedColumn<int>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES customers (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<int> occurredAt = GeneratedColumn<int>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conclusionMeta = const VerificationMeta(
    'conclusion',
  );
  @override
  late final GeneratedColumn<String> conclusion = GeneratedColumn<String>(
    'conclusion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    customerId,
    occurredAt,
    method,
    content,
    conclusion,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'followups';
  @override
  VerificationContext validateIntegrity(
    Insertable<FollowupRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('conclusion')) {
      context.handle(
        _conclusionMeta,
        conclusion.isAcceptableOrUnknown(data['conclusion']!, _conclusionMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FollowupRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FollowupRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}customer_id'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occurred_at'],
      )!,
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      conclusion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conclusion'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FollowupsTable createAlias(String alias) {
    return $FollowupsTable(attachedDatabase, alias);
  }
}

class FollowupRow extends DataClass implements Insertable<FollowupRow> {
  final int id;
  final int customerId;

  /// 发生时间，UTC 毫秒。可以补录过去的跟进，所以不用 createdAt 代替。
  final int occurredAt;

  /// 跟进方式，存 FollowMethod.dbValue。
  final String method;

  /// 沟通内容。
  final String content;

  /// 本次结论。可空，不是每次跟进都有明确结论。
  final String? conclusion;
  final int createdAt;
  final int updatedAt;
  const FollowupRow({
    required this.id,
    required this.customerId,
    required this.occurredAt,
    required this.method,
    required this.content,
    this.conclusion,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['customer_id'] = Variable<int>(customerId);
    map['occurred_at'] = Variable<int>(occurredAt);
    map['method'] = Variable<String>(method);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || conclusion != null) {
      map['conclusion'] = Variable<String>(conclusion);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  FollowupsCompanion toCompanion(bool nullToAbsent) {
    return FollowupsCompanion(
      id: Value(id),
      customerId: Value(customerId),
      occurredAt: Value(occurredAt),
      method: Value(method),
      content: Value(content),
      conclusion: conclusion == null && nullToAbsent
          ? const Value.absent()
          : Value(conclusion),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory FollowupRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FollowupRow(
      id: serializer.fromJson<int>(json['id']),
      customerId: serializer.fromJson<int>(json['customerId']),
      occurredAt: serializer.fromJson<int>(json['occurredAt']),
      method: serializer.fromJson<String>(json['method']),
      content: serializer.fromJson<String>(json['content']),
      conclusion: serializer.fromJson<String?>(json['conclusion']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'customerId': serializer.toJson<int>(customerId),
      'occurredAt': serializer.toJson<int>(occurredAt),
      'method': serializer.toJson<String>(method),
      'content': serializer.toJson<String>(content),
      'conclusion': serializer.toJson<String?>(conclusion),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  FollowupRow copyWith({
    int? id,
    int? customerId,
    int? occurredAt,
    String? method,
    String? content,
    Value<String?> conclusion = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => FollowupRow(
    id: id ?? this.id,
    customerId: customerId ?? this.customerId,
    occurredAt: occurredAt ?? this.occurredAt,
    method: method ?? this.method,
    content: content ?? this.content,
    conclusion: conclusion.present ? conclusion.value : this.conclusion,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  FollowupRow copyWithCompanion(FollowupsCompanion data) {
    return FollowupRow(
      id: data.id.present ? data.id.value : this.id,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      method: data.method.present ? data.method.value : this.method,
      content: data.content.present ? data.content.value : this.content,
      conclusion: data.conclusion.present
          ? data.conclusion.value
          : this.conclusion,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FollowupRow(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('method: $method, ')
          ..write('content: $content, ')
          ..write('conclusion: $conclusion, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    customerId,
    occurredAt,
    method,
    content,
    conclusion,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FollowupRow &&
          other.id == this.id &&
          other.customerId == this.customerId &&
          other.occurredAt == this.occurredAt &&
          other.method == this.method &&
          other.content == this.content &&
          other.conclusion == this.conclusion &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FollowupsCompanion extends UpdateCompanion<FollowupRow> {
  final Value<int> id;
  final Value<int> customerId;
  final Value<int> occurredAt;
  final Value<String> method;
  final Value<String> content;
  final Value<String?> conclusion;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  const FollowupsCompanion({
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.method = const Value.absent(),
    this.content = const Value.absent(),
    this.conclusion = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  FollowupsCompanion.insert({
    this.id = const Value.absent(),
    required int customerId,
    required int occurredAt,
    required String method,
    required String content,
    this.conclusion = const Value.absent(),
    required int createdAt,
    required int updatedAt,
  }) : customerId = Value(customerId),
       occurredAt = Value(occurredAt),
       method = Value(method),
       content = Value(content),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<FollowupRow> custom({
    Expression<int>? id,
    Expression<int>? customerId,
    Expression<int>? occurredAt,
    Expression<String>? method,
    Expression<String>? content,
    Expression<String>? conclusion,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (method != null) 'method': method,
      if (content != null) 'content': content,
      if (conclusion != null) 'conclusion': conclusion,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  FollowupsCompanion copyWith({
    Value<int>? id,
    Value<int>? customerId,
    Value<int>? occurredAt,
    Value<String>? method,
    Value<String>? content,
    Value<String?>? conclusion,
    Value<int>? createdAt,
    Value<int>? updatedAt,
  }) {
    return FollowupsCompanion(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      occurredAt: occurredAt ?? this.occurredAt,
      method: method ?? this.method,
      content: content ?? this.content,
      conclusion: conclusion ?? this.conclusion,
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
    if (customerId.present) {
      map['customer_id'] = Variable<int>(customerId.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<int>(occurredAt.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (conclusion.present) {
      map['conclusion'] = Variable<String>(conclusion.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FollowupsCompanion(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('method: $method, ')
          ..write('content: $content, ')
          ..write('conclusion: $conclusion, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $FollowPlansTable extends FollowPlans
    with TableInfo<$FollowPlansTable, FollowPlanRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FollowPlansTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<int> customerId = GeneratedColumn<int>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES customers (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _planAtMeta = const VerificationMeta('planAt');
  @override
  late final GeneratedColumn<int> planAt = GeneratedColumn<int>(
    'plan_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _notifiedAtMeta = const VerificationMeta(
    'notifiedAt',
  );
  @override
  late final GeneratedColumn<int> notifiedAt = GeneratedColumn<int>(
    'notified_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    customerId,
    title,
    planAt,
    status,
    notifiedAt,
    completedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'follow_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<FollowPlanRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('plan_at')) {
      context.handle(
        _planAtMeta,
        planAt.isAcceptableOrUnknown(data['plan_at']!, _planAtMeta),
      );
    } else if (isInserting) {
      context.missing(_planAtMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('notified_at')) {
      context.handle(
        _notifiedAtMeta,
        notifiedAt.isAcceptableOrUnknown(data['notified_at']!, _notifiedAtMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FollowPlanRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FollowPlanRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}customer_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      planAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plan_at'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      notifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notified_at'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FollowPlansTable createAlias(String alias) {
    return $FollowPlansTable(attachedDatabase, alias);
  }
}

class FollowPlanRow extends DataClass implements Insertable<FollowPlanRow> {
  final int id;
  final int customerId;

  /// 事项标题，如「催合同」。
  final String title;

  /// 计划时间，UTC 毫秒。建索引，待办查询与闹钟排期都按它过滤。
  final int planAt;

  /// 状态，存 PlanStatus.dbValue。
  final String status;

  /// 提醒实际触发时间，UTC 毫秒。
  ///
  /// 对应 PRD 5.3 的可靠性自查要求：阶段 2 在一加 13 上连续验证时，
  /// 靠它与 planAt 的偏差判断 ColorOS 有没有掐掉闹钟。
  final int? notifiedAt;
  final int? completedAt;
  final int createdAt;
  final int updatedAt;
  const FollowPlanRow({
    required this.id,
    required this.customerId,
    required this.title,
    required this.planAt,
    required this.status,
    this.notifiedAt,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['customer_id'] = Variable<int>(customerId);
    map['title'] = Variable<String>(title);
    map['plan_at'] = Variable<int>(planAt);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notifiedAt != null) {
      map['notified_at'] = Variable<int>(notifiedAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  FollowPlansCompanion toCompanion(bool nullToAbsent) {
    return FollowPlansCompanion(
      id: Value(id),
      customerId: Value(customerId),
      title: Value(title),
      planAt: Value(planAt),
      status: Value(status),
      notifiedAt: notifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(notifiedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory FollowPlanRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FollowPlanRow(
      id: serializer.fromJson<int>(json['id']),
      customerId: serializer.fromJson<int>(json['customerId']),
      title: serializer.fromJson<String>(json['title']),
      planAt: serializer.fromJson<int>(json['planAt']),
      status: serializer.fromJson<String>(json['status']),
      notifiedAt: serializer.fromJson<int?>(json['notifiedAt']),
      completedAt: serializer.fromJson<int?>(json['completedAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'customerId': serializer.toJson<int>(customerId),
      'title': serializer.toJson<String>(title),
      'planAt': serializer.toJson<int>(planAt),
      'status': serializer.toJson<String>(status),
      'notifiedAt': serializer.toJson<int?>(notifiedAt),
      'completedAt': serializer.toJson<int?>(completedAt),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  FollowPlanRow copyWith({
    int? id,
    int? customerId,
    String? title,
    int? planAt,
    String? status,
    Value<int?> notifiedAt = const Value.absent(),
    Value<int?> completedAt = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => FollowPlanRow(
    id: id ?? this.id,
    customerId: customerId ?? this.customerId,
    title: title ?? this.title,
    planAt: planAt ?? this.planAt,
    status: status ?? this.status,
    notifiedAt: notifiedAt.present ? notifiedAt.value : this.notifiedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  FollowPlanRow copyWithCompanion(FollowPlansCompanion data) {
    return FollowPlanRow(
      id: data.id.present ? data.id.value : this.id,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      title: data.title.present ? data.title.value : this.title,
      planAt: data.planAt.present ? data.planAt.value : this.planAt,
      status: data.status.present ? data.status.value : this.status,
      notifiedAt: data.notifiedAt.present
          ? data.notifiedAt.value
          : this.notifiedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FollowPlanRow(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('title: $title, ')
          ..write('planAt: $planAt, ')
          ..write('status: $status, ')
          ..write('notifiedAt: $notifiedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    customerId,
    title,
    planAt,
    status,
    notifiedAt,
    completedAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FollowPlanRow &&
          other.id == this.id &&
          other.customerId == this.customerId &&
          other.title == this.title &&
          other.planAt == this.planAt &&
          other.status == this.status &&
          other.notifiedAt == this.notifiedAt &&
          other.completedAt == this.completedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FollowPlansCompanion extends UpdateCompanion<FollowPlanRow> {
  final Value<int> id;
  final Value<int> customerId;
  final Value<String> title;
  final Value<int> planAt;
  final Value<String> status;
  final Value<int?> notifiedAt;
  final Value<int?> completedAt;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  const FollowPlansCompanion({
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.title = const Value.absent(),
    this.planAt = const Value.absent(),
    this.status = const Value.absent(),
    this.notifiedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  FollowPlansCompanion.insert({
    this.id = const Value.absent(),
    required int customerId,
    required String title,
    required int planAt,
    this.status = const Value.absent(),
    this.notifiedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    required int createdAt,
    required int updatedAt,
  }) : customerId = Value(customerId),
       title = Value(title),
       planAt = Value(planAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<FollowPlanRow> custom({
    Expression<int>? id,
    Expression<int>? customerId,
    Expression<String>? title,
    Expression<int>? planAt,
    Expression<String>? status,
    Expression<int>? notifiedAt,
    Expression<int>? completedAt,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      if (title != null) 'title': title,
      if (planAt != null) 'plan_at': planAt,
      if (status != null) 'status': status,
      if (notifiedAt != null) 'notified_at': notifiedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  FollowPlansCompanion copyWith({
    Value<int>? id,
    Value<int>? customerId,
    Value<String>? title,
    Value<int>? planAt,
    Value<String>? status,
    Value<int?>? notifiedAt,
    Value<int?>? completedAt,
    Value<int>? createdAt,
    Value<int>? updatedAt,
  }) {
    return FollowPlansCompanion(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      title: title ?? this.title,
      planAt: planAt ?? this.planAt,
      status: status ?? this.status,
      notifiedAt: notifiedAt ?? this.notifiedAt,
      completedAt: completedAt ?? this.completedAt,
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
    if (customerId.present) {
      map['customer_id'] = Variable<int>(customerId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (planAt.present) {
      map['plan_at'] = Variable<int>(planAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notifiedAt.present) {
      map['notified_at'] = Variable<int>(notifiedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FollowPlansCompanion(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('title: $title, ')
          ..write('planAt: $planAt, ')
          ..write('status: $status, ')
          ..write('notifiedAt: $notifiedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $OrdersTable extends Orders with TableInfo<$OrdersTable, OrderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrdersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<int> customerId = GeneratedColumn<int>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES customers (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _orderNoMeta = const VerificationMeta(
    'orderNo',
  );
  @override
  late final GeneratedColumn<String> orderNo = GeneratedColumn<String>(
    'order_no',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _orderedAtMeta = const VerificationMeta(
    'orderedAt',
  );
  @override
  late final GeneratedColumn<int> orderedAt = GeneratedColumn<int>(
    'ordered_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    customerId,
    orderNo,
    orderedAt,
    amountCents,
    description,
    status,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'orders';
  @override
  VerificationContext validateIntegrity(
    Insertable<OrderRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('order_no')) {
      context.handle(
        _orderNoMeta,
        orderNo.isAcceptableOrUnknown(data['order_no']!, _orderNoMeta),
      );
    } else if (isInserting) {
      context.missing(_orderNoMeta);
    }
    if (data.containsKey('ordered_at')) {
      context.handle(
        _orderedAtMeta,
        orderedAt.isAcceptableOrUnknown(data['ordered_at']!, _orderedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_orderedAtMeta);
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrderRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}customer_id'],
      )!,
      orderNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_no'],
      )!,
      orderedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordered_at'],
      )!,
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $OrdersTable createAlias(String alias) {
    return $OrdersTable(attachedDatabase, alias);
  }
}

class OrderRow extends DataClass implements Insertable<OrderRow> {
  final int id;
  final int customerId;

  /// 订单编号。唯一，可由系统按日期序号自动生成。
  final String orderNo;

  /// 下单日期，UTC 毫秒。
  final int orderedAt;

  /// 金额，单位分。
  ///
  /// 字段名带单位是刻意的：写 amount 迟早有人塞进去一个元为单位的 double，
  /// 浮点误差在金额上不可接受。
  final int amountCents;

  /// 商品或服务描述。
  final String? description;

  /// 状态，存 OrderStatus.dbValue。
  final String status;
  final int createdAt;
  final int updatedAt;
  const OrderRow({
    required this.id,
    required this.customerId,
    required this.orderNo,
    required this.orderedAt,
    required this.amountCents,
    this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['customer_id'] = Variable<int>(customerId);
    map['order_no'] = Variable<String>(orderNo);
    map['ordered_at'] = Variable<int>(orderedAt);
    map['amount_cents'] = Variable<int>(amountCents);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  OrdersCompanion toCompanion(bool nullToAbsent) {
    return OrdersCompanion(
      id: Value(id),
      customerId: Value(customerId),
      orderNo: Value(orderNo),
      orderedAt: Value(orderedAt),
      amountCents: Value(amountCents),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory OrderRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrderRow(
      id: serializer.fromJson<int>(json['id']),
      customerId: serializer.fromJson<int>(json['customerId']),
      orderNo: serializer.fromJson<String>(json['orderNo']),
      orderedAt: serializer.fromJson<int>(json['orderedAt']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      description: serializer.fromJson<String?>(json['description']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'customerId': serializer.toJson<int>(customerId),
      'orderNo': serializer.toJson<String>(orderNo),
      'orderedAt': serializer.toJson<int>(orderedAt),
      'amountCents': serializer.toJson<int>(amountCents),
      'description': serializer.toJson<String?>(description),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  OrderRow copyWith({
    int? id,
    int? customerId,
    String? orderNo,
    int? orderedAt,
    int? amountCents,
    Value<String?> description = const Value.absent(),
    String? status,
    int? createdAt,
    int? updatedAt,
  }) => OrderRow(
    id: id ?? this.id,
    customerId: customerId ?? this.customerId,
    orderNo: orderNo ?? this.orderNo,
    orderedAt: orderedAt ?? this.orderedAt,
    amountCents: amountCents ?? this.amountCents,
    description: description.present ? description.value : this.description,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  OrderRow copyWithCompanion(OrdersCompanion data) {
    return OrderRow(
      id: data.id.present ? data.id.value : this.id,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      orderNo: data.orderNo.present ? data.orderNo.value : this.orderNo,
      orderedAt: data.orderedAt.present ? data.orderedAt.value : this.orderedAt,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      description: data.description.present
          ? data.description.value
          : this.description,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrderRow(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('orderNo: $orderNo, ')
          ..write('orderedAt: $orderedAt, ')
          ..write('amountCents: $amountCents, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    customerId,
    orderNo,
    orderedAt,
    amountCents,
    description,
    status,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderRow &&
          other.id == this.id &&
          other.customerId == this.customerId &&
          other.orderNo == this.orderNo &&
          other.orderedAt == this.orderedAt &&
          other.amountCents == this.amountCents &&
          other.description == this.description &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class OrdersCompanion extends UpdateCompanion<OrderRow> {
  final Value<int> id;
  final Value<int> customerId;
  final Value<String> orderNo;
  final Value<int> orderedAt;
  final Value<int> amountCents;
  final Value<String?> description;
  final Value<String> status;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  const OrdersCompanion({
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.orderNo = const Value.absent(),
    this.orderedAt = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  OrdersCompanion.insert({
    this.id = const Value.absent(),
    required int customerId,
    required String orderNo,
    required int orderedAt,
    required int amountCents,
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    required int createdAt,
    required int updatedAt,
  }) : customerId = Value(customerId),
       orderNo = Value(orderNo),
       orderedAt = Value(orderedAt),
       amountCents = Value(amountCents),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<OrderRow> custom({
    Expression<int>? id,
    Expression<int>? customerId,
    Expression<String>? orderNo,
    Expression<int>? orderedAt,
    Expression<int>? amountCents,
    Expression<String>? description,
    Expression<String>? status,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      if (orderNo != null) 'order_no': orderNo,
      if (orderedAt != null) 'ordered_at': orderedAt,
      if (amountCents != null) 'amount_cents': amountCents,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  OrdersCompanion copyWith({
    Value<int>? id,
    Value<int>? customerId,
    Value<String>? orderNo,
    Value<int>? orderedAt,
    Value<int>? amountCents,
    Value<String?>? description,
    Value<String>? status,
    Value<int>? createdAt,
    Value<int>? updatedAt,
  }) {
    return OrdersCompanion(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      orderNo: orderNo ?? this.orderNo,
      orderedAt: orderedAt ?? this.orderedAt,
      amountCents: amountCents ?? this.amountCents,
      description: description ?? this.description,
      status: status ?? this.status,
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
    if (customerId.present) {
      map['customer_id'] = Variable<int>(customerId.value);
    }
    if (orderNo.present) {
      map['order_no'] = Variable<String>(orderNo.value);
    }
    if (orderedAt.present) {
      map['ordered_at'] = Variable<int>(orderedAt.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrdersCompanion(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('orderNo: $orderNo, ')
          ..write('orderedAt: $orderedAt, ')
          ..write('amountCents: $amountCents, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, TagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<TagRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TagRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class TagRow extends DataClass implements Insertable<TagRow> {
  final int id;

  /// 标签名。唯一，避免同名标签堆积。
  final String name;
  final int createdAt;
  final int updatedAt;
  const TagRow({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TagRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TagRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  TagRow copyWith({int? id, String? name, int? createdAt, int? updatedAt}) =>
      TagRow(
        id: id ?? this.id,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  TagRow copyWithCompanion(TagsCompanion data) {
    return TagRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TagRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TagRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TagsCompanion extends UpdateCompanion<TagRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TagsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int createdAt,
    required int updatedAt,
  }) : name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TagRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TagsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? createdAt,
    Value<int>? updatedAt,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CustomerTagsTable extends CustomerTags
    with TableInfo<$CustomerTagsTable, CustomerTagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomerTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<int> customerId = GeneratedColumn<int>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES customers (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<int> tagId = GeneratedColumn<int>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [customerId, tagId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customer_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomerTagRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {customerId, tagId};
  @override
  CustomerTagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomerTagRow(
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}customer_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tag_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CustomerTagsTable createAlias(String alias) {
    return $CustomerTagsTable(attachedDatabase, alias);
  }
}

class CustomerTagRow extends DataClass implements Insertable<CustomerTagRow> {
  final int customerId;
  final int tagId;
  final int createdAt;
  const CustomerTagRow({
    required this.customerId,
    required this.tagId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['customer_id'] = Variable<int>(customerId);
    map['tag_id'] = Variable<int>(tagId);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  CustomerTagsCompanion toCompanion(bool nullToAbsent) {
    return CustomerTagsCompanion(
      customerId: Value(customerId),
      tagId: Value(tagId),
      createdAt: Value(createdAt),
    );
  }

  factory CustomerTagRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomerTagRow(
      customerId: serializer.fromJson<int>(json['customerId']),
      tagId: serializer.fromJson<int>(json['tagId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'customerId': serializer.toJson<int>(customerId),
      'tagId': serializer.toJson<int>(tagId),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  CustomerTagRow copyWith({int? customerId, int? tagId, int? createdAt}) =>
      CustomerTagRow(
        customerId: customerId ?? this.customerId,
        tagId: tagId ?? this.tagId,
        createdAt: createdAt ?? this.createdAt,
      );
  CustomerTagRow copyWithCompanion(CustomerTagsCompanion data) {
    return CustomerTagRow(
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomerTagRow(')
          ..write('customerId: $customerId, ')
          ..write('tagId: $tagId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(customerId, tagId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomerTagRow &&
          other.customerId == this.customerId &&
          other.tagId == this.tagId &&
          other.createdAt == this.createdAt);
}

class CustomerTagsCompanion extends UpdateCompanion<CustomerTagRow> {
  final Value<int> customerId;
  final Value<int> tagId;
  final Value<int> createdAt;
  final Value<int> rowid;
  const CustomerTagsCompanion({
    this.customerId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomerTagsCompanion.insert({
    required int customerId,
    required int tagId,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : customerId = Value(customerId),
       tagId = Value(tagId),
       createdAt = Value(createdAt);
  static Insertable<CustomerTagRow> custom({
    Expression<int>? customerId,
    Expression<int>? tagId,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (customerId != null) 'customer_id': customerId,
      if (tagId != null) 'tag_id': tagId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomerTagsCompanion copyWith({
    Value<int>? customerId,
    Value<int>? tagId,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return CustomerTagsCompanion(
      customerId: customerId ?? this.customerId,
      tagId: tagId ?? this.tagId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (customerId.present) {
      map['customer_id'] = Variable<int>(customerId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<int>(tagId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomerTagsCompanion(')
          ..write('customerId: $customerId, ')
          ..write('tagId: $tagId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttachmentsTable extends Attachments
    with TableInfo<$AttachmentsTable, AttachmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttachmentsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _followupIdMeta = const VerificationMeta(
    'followupId',
  );
  @override
  late final GeneratedColumn<int> followupId = GeneratedColumn<int>(
    'followup_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES followups (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _orderIdMeta = const VerificationMeta(
    'orderId',
  );
  @override
  late final GeneratedColumn<int> orderId = GeneratedColumn<int>(
    'order_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES orders (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _relativePathMeta = const VerificationMeta(
    'relativePath',
  );
  @override
  late final GeneratedColumn<String> relativePath = GeneratedColumn<String>(
    'relative_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalNameMeta = const VerificationMeta(
    'originalName',
  );
  @override
  late final GeneratedColumn<String> originalName = GeneratedColumn<String>(
    'original_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    followupId,
    orderId,
    relativePath,
    originalName,
    mimeType,
    sizeBytes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttachmentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('followup_id')) {
      context.handle(
        _followupIdMeta,
        followupId.isAcceptableOrUnknown(data['followup_id']!, _followupIdMeta),
      );
    }
    if (data.containsKey('order_id')) {
      context.handle(
        _orderIdMeta,
        orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta),
      );
    }
    if (data.containsKey('relative_path')) {
      context.handle(
        _relativePathMeta,
        relativePath.isAcceptableOrUnknown(
          data['relative_path']!,
          _relativePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relativePathMeta);
    }
    if (data.containsKey('original_name')) {
      context.handle(
        _originalNameMeta,
        originalName.isAcceptableOrUnknown(
          data['original_name']!,
          _originalNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalNameMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AttachmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttachmentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      followupId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}followup_id'],
      ),
      orderId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_id'],
      ),
      relativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relative_path'],
      )!,
      originalName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_name'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AttachmentsTable createAlias(String alias) {
    return $AttachmentsTable(attachedDatabase, alias);
  }
}

class AttachmentRow extends DataClass implements Insertable<AttachmentRow> {
  final int id;
  final int? followupId;
  final int? orderId;

  /// 相对应用文档目录的路径，形如 `attachments/2026/08/uuid.jpg`。
  final String relativePath;

  /// 原始文件名，用于展示与导出时还原。
  final String originalName;
  final String mimeType;
  final int sizeBytes;
  final int createdAt;
  final int updatedAt;
  const AttachmentRow({
    required this.id,
    this.followupId,
    this.orderId,
    required this.relativePath,
    required this.originalName,
    required this.mimeType,
    required this.sizeBytes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || followupId != null) {
      map['followup_id'] = Variable<int>(followupId);
    }
    if (!nullToAbsent || orderId != null) {
      map['order_id'] = Variable<int>(orderId);
    }
    map['relative_path'] = Variable<String>(relativePath);
    map['original_name'] = Variable<String>(originalName);
    map['mime_type'] = Variable<String>(mimeType);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  AttachmentsCompanion toCompanion(bool nullToAbsent) {
    return AttachmentsCompanion(
      id: Value(id),
      followupId: followupId == null && nullToAbsent
          ? const Value.absent()
          : Value(followupId),
      orderId: orderId == null && nullToAbsent
          ? const Value.absent()
          : Value(orderId),
      relativePath: Value(relativePath),
      originalName: Value(originalName),
      mimeType: Value(mimeType),
      sizeBytes: Value(sizeBytes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AttachmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttachmentRow(
      id: serializer.fromJson<int>(json['id']),
      followupId: serializer.fromJson<int?>(json['followupId']),
      orderId: serializer.fromJson<int?>(json['orderId']),
      relativePath: serializer.fromJson<String>(json['relativePath']),
      originalName: serializer.fromJson<String>(json['originalName']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'followupId': serializer.toJson<int?>(followupId),
      'orderId': serializer.toJson<int?>(orderId),
      'relativePath': serializer.toJson<String>(relativePath),
      'originalName': serializer.toJson<String>(originalName),
      'mimeType': serializer.toJson<String>(mimeType),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  AttachmentRow copyWith({
    int? id,
    Value<int?> followupId = const Value.absent(),
    Value<int?> orderId = const Value.absent(),
    String? relativePath,
    String? originalName,
    String? mimeType,
    int? sizeBytes,
    int? createdAt,
    int? updatedAt,
  }) => AttachmentRow(
    id: id ?? this.id,
    followupId: followupId.present ? followupId.value : this.followupId,
    orderId: orderId.present ? orderId.value : this.orderId,
    relativePath: relativePath ?? this.relativePath,
    originalName: originalName ?? this.originalName,
    mimeType: mimeType ?? this.mimeType,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AttachmentRow copyWithCompanion(AttachmentsCompanion data) {
    return AttachmentRow(
      id: data.id.present ? data.id.value : this.id,
      followupId: data.followupId.present
          ? data.followupId.value
          : this.followupId,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      relativePath: data.relativePath.present
          ? data.relativePath.value
          : this.relativePath,
      originalName: data.originalName.present
          ? data.originalName.value
          : this.originalName,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentRow(')
          ..write('id: $id, ')
          ..write('followupId: $followupId, ')
          ..write('orderId: $orderId, ')
          ..write('relativePath: $relativePath, ')
          ..write('originalName: $originalName, ')
          ..write('mimeType: $mimeType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    followupId,
    orderId,
    relativePath,
    originalName,
    mimeType,
    sizeBytes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttachmentRow &&
          other.id == this.id &&
          other.followupId == this.followupId &&
          other.orderId == this.orderId &&
          other.relativePath == this.relativePath &&
          other.originalName == this.originalName &&
          other.mimeType == this.mimeType &&
          other.sizeBytes == this.sizeBytes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AttachmentsCompanion extends UpdateCompanion<AttachmentRow> {
  final Value<int> id;
  final Value<int?> followupId;
  final Value<int?> orderId;
  final Value<String> relativePath;
  final Value<String> originalName;
  final Value<String> mimeType;
  final Value<int> sizeBytes;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  const AttachmentsCompanion({
    this.id = const Value.absent(),
    this.followupId = const Value.absent(),
    this.orderId = const Value.absent(),
    this.relativePath = const Value.absent(),
    this.originalName = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  AttachmentsCompanion.insert({
    this.id = const Value.absent(),
    this.followupId = const Value.absent(),
    this.orderId = const Value.absent(),
    required String relativePath,
    required String originalName,
    required String mimeType,
    required int sizeBytes,
    required int createdAt,
    required int updatedAt,
  }) : relativePath = Value(relativePath),
       originalName = Value(originalName),
       mimeType = Value(mimeType),
       sizeBytes = Value(sizeBytes),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<AttachmentRow> custom({
    Expression<int>? id,
    Expression<int>? followupId,
    Expression<int>? orderId,
    Expression<String>? relativePath,
    Expression<String>? originalName,
    Expression<String>? mimeType,
    Expression<int>? sizeBytes,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (followupId != null) 'followup_id': followupId,
      if (orderId != null) 'order_id': orderId,
      if (relativePath != null) 'relative_path': relativePath,
      if (originalName != null) 'original_name': originalName,
      if (mimeType != null) 'mime_type': mimeType,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  AttachmentsCompanion copyWith({
    Value<int>? id,
    Value<int?>? followupId,
    Value<int?>? orderId,
    Value<String>? relativePath,
    Value<String>? originalName,
    Value<String>? mimeType,
    Value<int>? sizeBytes,
    Value<int>? createdAt,
    Value<int>? updatedAt,
  }) {
    return AttachmentsCompanion(
      id: id ?? this.id,
      followupId: followupId ?? this.followupId,
      orderId: orderId ?? this.orderId,
      relativePath: relativePath ?? this.relativePath,
      originalName: originalName ?? this.originalName,
      mimeType: mimeType ?? this.mimeType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
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
    if (followupId.present) {
      map['followup_id'] = Variable<int>(followupId.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<int>(orderId.value);
    }
    if (relativePath.present) {
      map['relative_path'] = Variable<String>(relativePath.value);
    }
    if (originalName.present) {
      map['original_name'] = Variable<String>(originalName.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('followupId: $followupId, ')
          ..write('orderId: $orderId, ')
          ..write('relativePath: $relativePath, ')
          ..write('originalName: $originalName, ')
          ..write('mimeType: $mimeType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CustomersTable customers = $CustomersTable(this);
  late final $ContactsTable contacts = $ContactsTable(this);
  late final $FollowupsTable followups = $FollowupsTable(this);
  late final $FollowPlansTable followPlans = $FollowPlansTable(this);
  late final $OrdersTable orders = $OrdersTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $CustomerTagsTable customerTags = $CustomerTagsTable(this);
  late final $AttachmentsTable attachments = $AttachmentsTable(this);
  late final CustomerDao customerDao = CustomerDao(this as AppDatabase);
  late final ContactDao contactDao = ContactDao(this as AppDatabase);
  late final FollowupDao followupDao = FollowupDao(this as AppDatabase);
  late final PlanDao planDao = PlanDao(this as AppDatabase);
  late final OrderDao orderDao = OrderDao(this as AppDatabase);
  late final AttachmentDao attachmentDao = AttachmentDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    customers,
    contacts,
    followups,
    followPlans,
    orders,
    tags,
    customerTags,
    attachments,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'customers',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('contacts', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'customers',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('followups', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'customers',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('follow_plans', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'customers',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('orders', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'customers',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('customer_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tags',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('customer_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'followups',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('attachments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'orders',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('attachments', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CustomersTableCreateCompanionBuilder =
    CustomersCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> company,
      Value<String?> phone,
      Value<String?> wechat,
      Value<String?> address,
      Value<String?> source,
      Value<String?> note,
      Value<String> stage,
      Value<String> grade,
      Value<int?> lastFollowAt,
      required int createdAt,
      required int updatedAt,
    });
typedef $$CustomersTableUpdateCompanionBuilder =
    CustomersCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> company,
      Value<String?> phone,
      Value<String?> wechat,
      Value<String?> address,
      Value<String?> source,
      Value<String?> note,
      Value<String> stage,
      Value<String> grade,
      Value<int?> lastFollowAt,
      Value<int> createdAt,
      Value<int> updatedAt,
    });

final class $$CustomersTableReferences
    extends BaseReferences<_$AppDatabase, $CustomersTable, CustomerRow> {
  $$CustomersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ContactsTable, List<ContactRow>>
  _contactsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.contacts,
    aliasName: 'customers__id__contacts__customer_id',
  );

  $$ContactsTableProcessedTableManager get contactsRefs {
    final manager = $$ContactsTableTableManager(
      $_db,
      $_db.contacts,
    ).filter((f) => f.customerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_contactsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FollowupsTable, List<FollowupRow>>
  _followupsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.followups,
    aliasName: 'customers__id__followups__customer_id',
  );

  $$FollowupsTableProcessedTableManager get followupsRefs {
    final manager = $$FollowupsTableTableManager(
      $_db,
      $_db.followups,
    ).filter((f) => f.customerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_followupsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FollowPlansTable, List<FollowPlanRow>>
  _followPlansRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.followPlans,
    aliasName: 'customers__id__follow_plans__customer_id',
  );

  $$FollowPlansTableProcessedTableManager get followPlansRefs {
    final manager = $$FollowPlansTableTableManager(
      $_db,
      $_db.followPlans,
    ).filter((f) => f.customerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_followPlansRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$OrdersTable, List<OrderRow>> _ordersRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.orders,
    aliasName: 'customers__id__orders__customer_id',
  );

  $$OrdersTableProcessedTableManager get ordersRefs {
    final manager = $$OrdersTableTableManager(
      $_db,
      $_db.orders,
    ).filter((f) => f.customerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_ordersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CustomerTagsTable, List<CustomerTagRow>>
  _customerTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.customerTags,
    aliasName: 'customers__id__customer_tags__customer_id',
  );

  $$CustomerTagsTableProcessedTableManager get customerTagsRefs {
    final manager = $$CustomerTagsTableTableManager(
      $_db,
      $_db.customerTags,
    ).filter((f) => f.customerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_customerTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CustomersTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wechat => $composableBuilder(
    column: $table.wechat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastFollowAt => $composableBuilder(
    column: $table.lastFollowAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> contactsRefs(
    Expression<bool> Function($$ContactsTableFilterComposer f) f,
  ) {
    final $$ContactsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.contacts,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsTableFilterComposer(
            $db: $db,
            $table: $db.contacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> followupsRefs(
    Expression<bool> Function($$FollowupsTableFilterComposer f) f,
  ) {
    final $$FollowupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.followups,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FollowupsTableFilterComposer(
            $db: $db,
            $table: $db.followups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> followPlansRefs(
    Expression<bool> Function($$FollowPlansTableFilterComposer f) f,
  ) {
    final $$FollowPlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.followPlans,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FollowPlansTableFilterComposer(
            $db: $db,
            $table: $db.followPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> ordersRefs(
    Expression<bool> Function($$OrdersTableFilterComposer f) f,
  ) {
    final $$OrdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableFilterComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> customerTagsRefs(
    Expression<bool> Function($$CustomerTagsTableFilterComposer f) f,
  ) {
    final $$CustomerTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.customerTags,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomerTagsTableFilterComposer(
            $db: $db,
            $table: $db.customerTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomersTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wechat => $composableBuilder(
    column: $table.wechat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastFollowAt => $composableBuilder(
    column: $table.lastFollowAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get company =>
      $composableBuilder(column: $table.company, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get wechat =>
      $composableBuilder(column: $table.wechat, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get stage =>
      $composableBuilder(column: $table.stage, builder: (column) => column);

  GeneratedColumn<String> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumn<int> get lastFollowAt => $composableBuilder(
    column: $table.lastFollowAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> contactsRefs<T extends Object>(
    Expression<T> Function($$ContactsTableAnnotationComposer a) f,
  ) {
    final $$ContactsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.contacts,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsTableAnnotationComposer(
            $db: $db,
            $table: $db.contacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> followupsRefs<T extends Object>(
    Expression<T> Function($$FollowupsTableAnnotationComposer a) f,
  ) {
    final $$FollowupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.followups,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FollowupsTableAnnotationComposer(
            $db: $db,
            $table: $db.followups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> followPlansRefs<T extends Object>(
    Expression<T> Function($$FollowPlansTableAnnotationComposer a) f,
  ) {
    final $$FollowPlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.followPlans,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FollowPlansTableAnnotationComposer(
            $db: $db,
            $table: $db.followPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> ordersRefs<T extends Object>(
    Expression<T> Function($$OrdersTableAnnotationComposer a) f,
  ) {
    final $$OrdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableAnnotationComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> customerTagsRefs<T extends Object>(
    Expression<T> Function($$CustomerTagsTableAnnotationComposer a) f,
  ) {
    final $$CustomerTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.customerTags,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomerTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.customerTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomersTable,
          CustomerRow,
          $$CustomersTableFilterComposer,
          $$CustomersTableOrderingComposer,
          $$CustomersTableAnnotationComposer,
          $$CustomersTableCreateCompanionBuilder,
          $$CustomersTableUpdateCompanionBuilder,
          (CustomerRow, $$CustomersTableReferences),
          CustomerRow,
          PrefetchHooks Function({
            bool contactsRefs,
            bool followupsRefs,
            bool followPlansRefs,
            bool ordersRefs,
            bool customerTagsRefs,
          })
        > {
  $$CustomersTableTableManager(_$AppDatabase db, $CustomersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> company = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> wechat = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> stage = const Value.absent(),
                Value<String> grade = const Value.absent(),
                Value<int?> lastFollowAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => CustomersCompanion(
                id: id,
                name: name,
                company: company,
                phone: phone,
                wechat: wechat,
                address: address,
                source: source,
                note: note,
                stage: stage,
                grade: grade,
                lastFollowAt: lastFollowAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> company = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> wechat = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> stage = const Value.absent(),
                Value<String> grade = const Value.absent(),
                Value<int?> lastFollowAt = const Value.absent(),
                required int createdAt,
                required int updatedAt,
              }) => CustomersCompanion.insert(
                id: id,
                name: name,
                company: company,
                phone: phone,
                wechat: wechat,
                address: address,
                source: source,
                note: note,
                stage: stage,
                grade: grade,
                lastFollowAt: lastFollowAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CustomersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                contactsRefs = false,
                followupsRefs = false,
                followPlansRefs = false,
                ordersRefs = false,
                customerTagsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (contactsRefs) db.contacts,
                    if (followupsRefs) db.followups,
                    if (followPlansRefs) db.followPlans,
                    if (ordersRefs) db.orders,
                    if (customerTagsRefs) db.customerTags,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (contactsRefs)
                        await $_getPrefetchedData<
                          CustomerRow,
                          $CustomersTable,
                          ContactRow
                        >(
                          currentTable: table,
                          referencedTable: $$CustomersTableReferences
                              ._contactsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CustomersTableReferences(
                                db,
                                table,
                                p0,
                              ).contactsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.customerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (followupsRefs)
                        await $_getPrefetchedData<
                          CustomerRow,
                          $CustomersTable,
                          FollowupRow
                        >(
                          currentTable: table,
                          referencedTable: $$CustomersTableReferences
                              ._followupsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CustomersTableReferences(
                                db,
                                table,
                                p0,
                              ).followupsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.customerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (followPlansRefs)
                        await $_getPrefetchedData<
                          CustomerRow,
                          $CustomersTable,
                          FollowPlanRow
                        >(
                          currentTable: table,
                          referencedTable: $$CustomersTableReferences
                              ._followPlansRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CustomersTableReferences(
                                db,
                                table,
                                p0,
                              ).followPlansRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.customerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (ordersRefs)
                        await $_getPrefetchedData<
                          CustomerRow,
                          $CustomersTable,
                          OrderRow
                        >(
                          currentTable: table,
                          referencedTable: $$CustomersTableReferences
                              ._ordersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CustomersTableReferences(
                                db,
                                table,
                                p0,
                              ).ordersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.customerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (customerTagsRefs)
                        await $_getPrefetchedData<
                          CustomerRow,
                          $CustomersTable,
                          CustomerTagRow
                        >(
                          currentTable: table,
                          referencedTable: $$CustomersTableReferences
                              ._customerTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CustomersTableReferences(
                                db,
                                table,
                                p0,
                              ).customerTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.customerId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CustomersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomersTable,
      CustomerRow,
      $$CustomersTableFilterComposer,
      $$CustomersTableOrderingComposer,
      $$CustomersTableAnnotationComposer,
      $$CustomersTableCreateCompanionBuilder,
      $$CustomersTableUpdateCompanionBuilder,
      (CustomerRow, $$CustomersTableReferences),
      CustomerRow,
      PrefetchHooks Function({
        bool contactsRefs,
        bool followupsRefs,
        bool followPlansRefs,
        bool ordersRefs,
        bool customerTagsRefs,
      })
    >;
typedef $$ContactsTableCreateCompanionBuilder =
    ContactsCompanion Function({
      Value<int> id,
      required int customerId,
      required String name,
      Value<String?> position,
      Value<String?> phone,
      Value<bool> isDecisionMaker,
      required int createdAt,
      required int updatedAt,
    });
typedef $$ContactsTableUpdateCompanionBuilder =
    ContactsCompanion Function({
      Value<int> id,
      Value<int> customerId,
      Value<String> name,
      Value<String?> position,
      Value<String?> phone,
      Value<bool> isDecisionMaker,
      Value<int> createdAt,
      Value<int> updatedAt,
    });

final class $$ContactsTableReferences
    extends BaseReferences<_$AppDatabase, $ContactsTable, ContactRow> {
  $$ContactsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CustomersTable _customerIdTable(_$AppDatabase db) =>
      db.customers.createAlias('contacts__customer_id__customers__id');

  $$CustomersTableProcessedTableManager get customerId {
    final $_column = $_itemColumn<int>('customer_id')!;

    final manager = $$CustomersTableTableManager(
      $_db,
      $_db.customers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ContactsTableFilterComposer
    extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDecisionMaker => $composableBuilder(
    column: $table.isDecisionMaker,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CustomersTableFilterComposer get customerId {
    final $$CustomersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableFilterComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ContactsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDecisionMaker => $composableBuilder(
    column: $table.isDecisionMaker,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CustomersTableOrderingComposer get customerId {
    final $$CustomersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableOrderingComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ContactsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<bool> get isDecisionMaker => $composableBuilder(
    column: $table.isDecisionMaker,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CustomersTableAnnotationComposer get customerId {
    final $$CustomersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableAnnotationComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ContactsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContactsTable,
          ContactRow,
          $$ContactsTableFilterComposer,
          $$ContactsTableOrderingComposer,
          $$ContactsTableAnnotationComposer,
          $$ContactsTableCreateCompanionBuilder,
          $$ContactsTableUpdateCompanionBuilder,
          (ContactRow, $$ContactsTableReferences),
          ContactRow,
          PrefetchHooks Function({bool customerId})
        > {
  $$ContactsTableTableManager(_$AppDatabase db, $ContactsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContactsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContactsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContactsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> customerId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> position = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<bool> isDecisionMaker = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => ContactsCompanion(
                id: id,
                customerId: customerId,
                name: name,
                position: position,
                phone: phone,
                isDecisionMaker: isDecisionMaker,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int customerId,
                required String name,
                Value<String?> position = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<bool> isDecisionMaker = const Value.absent(),
                required int createdAt,
                required int updatedAt,
              }) => ContactsCompanion.insert(
                id: id,
                customerId: customerId,
                name: name,
                position: position,
                phone: phone,
                isDecisionMaker: isDecisionMaker,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ContactsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({customerId = false}) {
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
                    if (customerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.customerId,
                                referencedTable: $$ContactsTableReferences
                                    ._customerIdTable(db),
                                referencedColumn: $$ContactsTableReferences
                                    ._customerIdTable(db)
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

typedef $$ContactsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContactsTable,
      ContactRow,
      $$ContactsTableFilterComposer,
      $$ContactsTableOrderingComposer,
      $$ContactsTableAnnotationComposer,
      $$ContactsTableCreateCompanionBuilder,
      $$ContactsTableUpdateCompanionBuilder,
      (ContactRow, $$ContactsTableReferences),
      ContactRow,
      PrefetchHooks Function({bool customerId})
    >;
typedef $$FollowupsTableCreateCompanionBuilder =
    FollowupsCompanion Function({
      Value<int> id,
      required int customerId,
      required int occurredAt,
      required String method,
      required String content,
      Value<String?> conclusion,
      required int createdAt,
      required int updatedAt,
    });
typedef $$FollowupsTableUpdateCompanionBuilder =
    FollowupsCompanion Function({
      Value<int> id,
      Value<int> customerId,
      Value<int> occurredAt,
      Value<String> method,
      Value<String> content,
      Value<String?> conclusion,
      Value<int> createdAt,
      Value<int> updatedAt,
    });

final class $$FollowupsTableReferences
    extends BaseReferences<_$AppDatabase, $FollowupsTable, FollowupRow> {
  $$FollowupsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CustomersTable _customerIdTable(_$AppDatabase db) =>
      db.customers.createAlias('followups__customer_id__customers__id');

  $$CustomersTableProcessedTableManager get customerId {
    final $_column = $_itemColumn<int>('customer_id')!;

    final manager = $$CustomersTableTableManager(
      $_db,
      $_db.customers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$AttachmentsTable, List<AttachmentRow>>
  _attachmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.attachments,
    aliasName: 'followups__id__attachments__followup_id',
  );

  $$AttachmentsTableProcessedTableManager get attachmentsRefs {
    final manager = $$AttachmentsTableTableManager(
      $_db,
      $_db.attachments,
    ).filter((f) => f.followupId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_attachmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FollowupsTableFilterComposer
    extends Composer<_$AppDatabase, $FollowupsTable> {
  $$FollowupsTableFilterComposer({
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

  ColumnFilters<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conclusion => $composableBuilder(
    column: $table.conclusion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CustomersTableFilterComposer get customerId {
    final $$CustomersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableFilterComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> attachmentsRefs(
    Expression<bool> Function($$AttachmentsTableFilterComposer f) f,
  ) {
    final $$AttachmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.followupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentsTableFilterComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FollowupsTableOrderingComposer
    extends Composer<_$AppDatabase, $FollowupsTable> {
  $$FollowupsTableOrderingComposer({
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

  ColumnOrderings<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conclusion => $composableBuilder(
    column: $table.conclusion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CustomersTableOrderingComposer get customerId {
    final $$CustomersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableOrderingComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FollowupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FollowupsTable> {
  $$FollowupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get conclusion => $composableBuilder(
    column: $table.conclusion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CustomersTableAnnotationComposer get customerId {
    final $$CustomersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableAnnotationComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> attachmentsRefs<T extends Object>(
    Expression<T> Function($$AttachmentsTableAnnotationComposer a) f,
  ) {
    final $$AttachmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.followupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FollowupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FollowupsTable,
          FollowupRow,
          $$FollowupsTableFilterComposer,
          $$FollowupsTableOrderingComposer,
          $$FollowupsTableAnnotationComposer,
          $$FollowupsTableCreateCompanionBuilder,
          $$FollowupsTableUpdateCompanionBuilder,
          (FollowupRow, $$FollowupsTableReferences),
          FollowupRow,
          PrefetchHooks Function({bool customerId, bool attachmentsRefs})
        > {
  $$FollowupsTableTableManager(_$AppDatabase db, $FollowupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FollowupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FollowupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FollowupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> customerId = const Value.absent(),
                Value<int> occurredAt = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String?> conclusion = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => FollowupsCompanion(
                id: id,
                customerId: customerId,
                occurredAt: occurredAt,
                method: method,
                content: content,
                conclusion: conclusion,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int customerId,
                required int occurredAt,
                required String method,
                required String content,
                Value<String?> conclusion = const Value.absent(),
                required int createdAt,
                required int updatedAt,
              }) => FollowupsCompanion.insert(
                id: id,
                customerId: customerId,
                occurredAt: occurredAt,
                method: method,
                content: content,
                conclusion: conclusion,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FollowupsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({customerId = false, attachmentsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (attachmentsRefs) db.attachments,
                  ],
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
                        if (customerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.customerId,
                                    referencedTable: $$FollowupsTableReferences
                                        ._customerIdTable(db),
                                    referencedColumn: $$FollowupsTableReferences
                                        ._customerIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (attachmentsRefs)
                        await $_getPrefetchedData<
                          FollowupRow,
                          $FollowupsTable,
                          AttachmentRow
                        >(
                          currentTable: table,
                          referencedTable: $$FollowupsTableReferences
                              ._attachmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FollowupsTableReferences(
                                db,
                                table,
                                p0,
                              ).attachmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.followupId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$FollowupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FollowupsTable,
      FollowupRow,
      $$FollowupsTableFilterComposer,
      $$FollowupsTableOrderingComposer,
      $$FollowupsTableAnnotationComposer,
      $$FollowupsTableCreateCompanionBuilder,
      $$FollowupsTableUpdateCompanionBuilder,
      (FollowupRow, $$FollowupsTableReferences),
      FollowupRow,
      PrefetchHooks Function({bool customerId, bool attachmentsRefs})
    >;
typedef $$FollowPlansTableCreateCompanionBuilder =
    FollowPlansCompanion Function({
      Value<int> id,
      required int customerId,
      required String title,
      required int planAt,
      Value<String> status,
      Value<int?> notifiedAt,
      Value<int?> completedAt,
      required int createdAt,
      required int updatedAt,
    });
typedef $$FollowPlansTableUpdateCompanionBuilder =
    FollowPlansCompanion Function({
      Value<int> id,
      Value<int> customerId,
      Value<String> title,
      Value<int> planAt,
      Value<String> status,
      Value<int?> notifiedAt,
      Value<int?> completedAt,
      Value<int> createdAt,
      Value<int> updatedAt,
    });

final class $$FollowPlansTableReferences
    extends BaseReferences<_$AppDatabase, $FollowPlansTable, FollowPlanRow> {
  $$FollowPlansTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CustomersTable _customerIdTable(_$AppDatabase db) =>
      db.customers.createAlias('follow_plans__customer_id__customers__id');

  $$CustomersTableProcessedTableManager get customerId {
    final $_column = $_itemColumn<int>('customer_id')!;

    final manager = $$CustomersTableTableManager(
      $_db,
      $_db.customers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FollowPlansTableFilterComposer
    extends Composer<_$AppDatabase, $FollowPlansTable> {
  $$FollowPlansTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get planAt => $composableBuilder(
    column: $table.planAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get notifiedAt => $composableBuilder(
    column: $table.notifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CustomersTableFilterComposer get customerId {
    final $$CustomersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableFilterComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FollowPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $FollowPlansTable> {
  $$FollowPlansTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get planAt => $composableBuilder(
    column: $table.planAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get notifiedAt => $composableBuilder(
    column: $table.notifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CustomersTableOrderingComposer get customerId {
    final $$CustomersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableOrderingComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FollowPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $FollowPlansTable> {
  $$FollowPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get planAt =>
      $composableBuilder(column: $table.planAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get notifiedAt => $composableBuilder(
    column: $table.notifiedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CustomersTableAnnotationComposer get customerId {
    final $$CustomersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableAnnotationComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FollowPlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FollowPlansTable,
          FollowPlanRow,
          $$FollowPlansTableFilterComposer,
          $$FollowPlansTableOrderingComposer,
          $$FollowPlansTableAnnotationComposer,
          $$FollowPlansTableCreateCompanionBuilder,
          $$FollowPlansTableUpdateCompanionBuilder,
          (FollowPlanRow, $$FollowPlansTableReferences),
          FollowPlanRow,
          PrefetchHooks Function({bool customerId})
        > {
  $$FollowPlansTableTableManager(_$AppDatabase db, $FollowPlansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FollowPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FollowPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FollowPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> customerId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> planAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> notifiedAt = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => FollowPlansCompanion(
                id: id,
                customerId: customerId,
                title: title,
                planAt: planAt,
                status: status,
                notifiedAt: notifiedAt,
                completedAt: completedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int customerId,
                required String title,
                required int planAt,
                Value<String> status = const Value.absent(),
                Value<int?> notifiedAt = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                required int createdAt,
                required int updatedAt,
              }) => FollowPlansCompanion.insert(
                id: id,
                customerId: customerId,
                title: title,
                planAt: planAt,
                status: status,
                notifiedAt: notifiedAt,
                completedAt: completedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FollowPlansTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({customerId = false}) {
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
                    if (customerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.customerId,
                                referencedTable: $$FollowPlansTableReferences
                                    ._customerIdTable(db),
                                referencedColumn: $$FollowPlansTableReferences
                                    ._customerIdTable(db)
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

typedef $$FollowPlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FollowPlansTable,
      FollowPlanRow,
      $$FollowPlansTableFilterComposer,
      $$FollowPlansTableOrderingComposer,
      $$FollowPlansTableAnnotationComposer,
      $$FollowPlansTableCreateCompanionBuilder,
      $$FollowPlansTableUpdateCompanionBuilder,
      (FollowPlanRow, $$FollowPlansTableReferences),
      FollowPlanRow,
      PrefetchHooks Function({bool customerId})
    >;
typedef $$OrdersTableCreateCompanionBuilder =
    OrdersCompanion Function({
      Value<int> id,
      required int customerId,
      required String orderNo,
      required int orderedAt,
      required int amountCents,
      Value<String?> description,
      Value<String> status,
      required int createdAt,
      required int updatedAt,
    });
typedef $$OrdersTableUpdateCompanionBuilder =
    OrdersCompanion Function({
      Value<int> id,
      Value<int> customerId,
      Value<String> orderNo,
      Value<int> orderedAt,
      Value<int> amountCents,
      Value<String?> description,
      Value<String> status,
      Value<int> createdAt,
      Value<int> updatedAt,
    });

final class $$OrdersTableReferences
    extends BaseReferences<_$AppDatabase, $OrdersTable, OrderRow> {
  $$OrdersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CustomersTable _customerIdTable(_$AppDatabase db) =>
      db.customers.createAlias('orders__customer_id__customers__id');

  $$CustomersTableProcessedTableManager get customerId {
    final $_column = $_itemColumn<int>('customer_id')!;

    final manager = $$CustomersTableTableManager(
      $_db,
      $_db.customers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$AttachmentsTable, List<AttachmentRow>>
  _attachmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.attachments,
    aliasName: 'orders__id__attachments__order_id',
  );

  $$AttachmentsTableProcessedTableManager get attachmentsRefs {
    final manager = $$AttachmentsTableTableManager(
      $_db,
      $_db.attachments,
    ).filter((f) => f.orderId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_attachmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$OrdersTableFilterComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableFilterComposer({
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

  ColumnFilters<String> get orderNo => $composableBuilder(
    column: $table.orderNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderedAt => $composableBuilder(
    column: $table.orderedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CustomersTableFilterComposer get customerId {
    final $$CustomersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableFilterComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> attachmentsRefs(
    Expression<bool> Function($$AttachmentsTableFilterComposer f) f,
  ) {
    final $$AttachmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.orderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentsTableFilterComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OrdersTableOrderingComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableOrderingComposer({
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

  ColumnOrderings<String> get orderNo => $composableBuilder(
    column: $table.orderNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderedAt => $composableBuilder(
    column: $table.orderedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CustomersTableOrderingComposer get customerId {
    final $$CustomersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableOrderingComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OrdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get orderNo =>
      $composableBuilder(column: $table.orderNo, builder: (column) => column);

  GeneratedColumn<int> get orderedAt =>
      $composableBuilder(column: $table.orderedAt, builder: (column) => column);

  GeneratedColumn<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CustomersTableAnnotationComposer get customerId {
    final $$CustomersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableAnnotationComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> attachmentsRefs<T extends Object>(
    Expression<T> Function($$AttachmentsTableAnnotationComposer a) f,
  ) {
    final $$AttachmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.orderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OrdersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OrdersTable,
          OrderRow,
          $$OrdersTableFilterComposer,
          $$OrdersTableOrderingComposer,
          $$OrdersTableAnnotationComposer,
          $$OrdersTableCreateCompanionBuilder,
          $$OrdersTableUpdateCompanionBuilder,
          (OrderRow, $$OrdersTableReferences),
          OrderRow,
          PrefetchHooks Function({bool customerId, bool attachmentsRefs})
        > {
  $$OrdersTableTableManager(_$AppDatabase db, $OrdersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrdersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> customerId = const Value.absent(),
                Value<String> orderNo = const Value.absent(),
                Value<int> orderedAt = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => OrdersCompanion(
                id: id,
                customerId: customerId,
                orderNo: orderNo,
                orderedAt: orderedAt,
                amountCents: amountCents,
                description: description,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int customerId,
                required String orderNo,
                required int orderedAt,
                required int amountCents,
                Value<String?> description = const Value.absent(),
                Value<String> status = const Value.absent(),
                required int createdAt,
                required int updatedAt,
              }) => OrdersCompanion.insert(
                id: id,
                customerId: customerId,
                orderNo: orderNo,
                orderedAt: orderedAt,
                amountCents: amountCents,
                description: description,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$OrdersTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({customerId = false, attachmentsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (attachmentsRefs) db.attachments,
                  ],
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
                        if (customerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.customerId,
                                    referencedTable: $$OrdersTableReferences
                                        ._customerIdTable(db),
                                    referencedColumn: $$OrdersTableReferences
                                        ._customerIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (attachmentsRefs)
                        await $_getPrefetchedData<
                          OrderRow,
                          $OrdersTable,
                          AttachmentRow
                        >(
                          currentTable: table,
                          referencedTable: $$OrdersTableReferences
                              ._attachmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OrdersTableReferences(
                                db,
                                table,
                                p0,
                              ).attachmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.orderId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$OrdersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OrdersTable,
      OrderRow,
      $$OrdersTableFilterComposer,
      $$OrdersTableOrderingComposer,
      $$OrdersTableAnnotationComposer,
      $$OrdersTableCreateCompanionBuilder,
      $$OrdersTableUpdateCompanionBuilder,
      (OrderRow, $$OrdersTableReferences),
      OrderRow,
      PrefetchHooks Function({bool customerId, bool attachmentsRefs})
    >;
typedef $$TagsTableCreateCompanionBuilder =
    TagsCompanion Function({
      Value<int> id,
      required String name,
      required int createdAt,
      required int updatedAt,
    });
typedef $$TagsTableUpdateCompanionBuilder =
    TagsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> createdAt,
      Value<int> updatedAt,
    });

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, TagRow> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CustomerTagsTable, List<CustomerTagRow>>
  _customerTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.customerTags,
    aliasName: 'tags__id__customer_tags__tag_id',
  );

  $$CustomerTagsTableProcessedTableManager get customerTagsRefs {
    final manager = $$CustomerTagsTableTableManager(
      $_db,
      $_db.customerTags,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_customerTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> customerTagsRefs(
    Expression<bool> Function($$CustomerTagsTableFilterComposer f) f,
  ) {
    final $$CustomerTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.customerTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomerTagsTableFilterComposer(
            $db: $db,
            $table: $db.customerTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> customerTagsRefs<T extends Object>(
    Expression<T> Function($$CustomerTagsTableAnnotationComposer a) f,
  ) {
    final $$CustomerTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.customerTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomerTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.customerTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsTable,
          TagRow,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (TagRow, $$TagsTableReferences),
          TagRow,
          PrefetchHooks Function({bool customerTagsRefs})
        > {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => TagsCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int createdAt,
                required int updatedAt,
              }) => TagsCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TagsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({customerTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (customerTagsRefs) db.customerTags],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (customerTagsRefs)
                    await $_getPrefetchedData<
                      TagRow,
                      $TagsTable,
                      CustomerTagRow
                    >(
                      currentTable: table,
                      referencedTable: $$TagsTableReferences
                          ._customerTagsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TagsTableReferences(db, table, p0).customerTagsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.tagId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsTable,
      TagRow,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (TagRow, $$TagsTableReferences),
      TagRow,
      PrefetchHooks Function({bool customerTagsRefs})
    >;
typedef $$CustomerTagsTableCreateCompanionBuilder =
    CustomerTagsCompanion Function({
      required int customerId,
      required int tagId,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$CustomerTagsTableUpdateCompanionBuilder =
    CustomerTagsCompanion Function({
      Value<int> customerId,
      Value<int> tagId,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$CustomerTagsTableReferences
    extends BaseReferences<_$AppDatabase, $CustomerTagsTable, CustomerTagRow> {
  $$CustomerTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CustomersTable _customerIdTable(_$AppDatabase db) =>
      db.customers.createAlias('customer_tags__customer_id__customers__id');

  $$CustomersTableProcessedTableManager get customerId {
    final $_column = $_itemColumn<int>('customer_id')!;

    final manager = $$CustomersTableTableManager(
      $_db,
      $_db.customers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) =>
      db.tags.createAlias('customer_tags__tag_id__tags__id');

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<int>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CustomerTagsTableFilterComposer
    extends Composer<_$AppDatabase, $CustomerTagsTable> {
  $$CustomerTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CustomersTableFilterComposer get customerId {
    final $$CustomersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableFilterComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomerTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomerTagsTable> {
  $$CustomerTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CustomersTableOrderingComposer get customerId {
    final $$CustomersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableOrderingComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomerTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomerTagsTable> {
  $$CustomerTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CustomersTableAnnotationComposer get customerId {
    final $$CustomersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableAnnotationComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomerTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomerTagsTable,
          CustomerTagRow,
          $$CustomerTagsTableFilterComposer,
          $$CustomerTagsTableOrderingComposer,
          $$CustomerTagsTableAnnotationComposer,
          $$CustomerTagsTableCreateCompanionBuilder,
          $$CustomerTagsTableUpdateCompanionBuilder,
          (CustomerTagRow, $$CustomerTagsTableReferences),
          CustomerTagRow,
          PrefetchHooks Function({bool customerId, bool tagId})
        > {
  $$CustomerTagsTableTableManager(_$AppDatabase db, $CustomerTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomerTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomerTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomerTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> customerId = const Value.absent(),
                Value<int> tagId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomerTagsCompanion(
                customerId: customerId,
                tagId: tagId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int customerId,
                required int tagId,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CustomerTagsCompanion.insert(
                customerId: customerId,
                tagId: tagId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CustomerTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({customerId = false, tagId = false}) {
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
                    if (customerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.customerId,
                                referencedTable: $$CustomerTagsTableReferences
                                    ._customerIdTable(db),
                                referencedColumn: $$CustomerTagsTableReferences
                                    ._customerIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (tagId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tagId,
                                referencedTable: $$CustomerTagsTableReferences
                                    ._tagIdTable(db),
                                referencedColumn: $$CustomerTagsTableReferences
                                    ._tagIdTable(db)
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

typedef $$CustomerTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomerTagsTable,
      CustomerTagRow,
      $$CustomerTagsTableFilterComposer,
      $$CustomerTagsTableOrderingComposer,
      $$CustomerTagsTableAnnotationComposer,
      $$CustomerTagsTableCreateCompanionBuilder,
      $$CustomerTagsTableUpdateCompanionBuilder,
      (CustomerTagRow, $$CustomerTagsTableReferences),
      CustomerTagRow,
      PrefetchHooks Function({bool customerId, bool tagId})
    >;
typedef $$AttachmentsTableCreateCompanionBuilder =
    AttachmentsCompanion Function({
      Value<int> id,
      Value<int?> followupId,
      Value<int?> orderId,
      required String relativePath,
      required String originalName,
      required String mimeType,
      required int sizeBytes,
      required int createdAt,
      required int updatedAt,
    });
typedef $$AttachmentsTableUpdateCompanionBuilder =
    AttachmentsCompanion Function({
      Value<int> id,
      Value<int?> followupId,
      Value<int?> orderId,
      Value<String> relativePath,
      Value<String> originalName,
      Value<String> mimeType,
      Value<int> sizeBytes,
      Value<int> createdAt,
      Value<int> updatedAt,
    });

final class $$AttachmentsTableReferences
    extends BaseReferences<_$AppDatabase, $AttachmentsTable, AttachmentRow> {
  $$AttachmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FollowupsTable _followupIdTable(_$AppDatabase db) =>
      db.followups.createAlias('attachments__followup_id__followups__id');

  $$FollowupsTableProcessedTableManager? get followupId {
    final $_column = $_itemColumn<int>('followup_id');
    if ($_column == null) return null;
    final manager = $$FollowupsTableTableManager(
      $_db,
      $_db.followups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_followupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $OrdersTable _orderIdTable(_$AppDatabase db) =>
      db.orders.createAlias('attachments__order_id__orders__id');

  $$OrdersTableProcessedTableManager? get orderId {
    final $_column = $_itemColumn<int>('order_id');
    if ($_column == null) return null;
    final manager = $$OrdersTableTableManager(
      $_db,
      $_db.orders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_orderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableFilterComposer({
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

  ColumnFilters<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalName => $composableBuilder(
    column: $table.originalName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$FollowupsTableFilterComposer get followupId {
    final $$FollowupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.followupId,
      referencedTable: $db.followups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FollowupsTableFilterComposer(
            $db: $db,
            $table: $db.followups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OrdersTableFilterComposer get orderId {
    final $$OrdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableFilterComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableOrderingComposer({
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

  ColumnOrderings<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalName => $composableBuilder(
    column: $table.originalName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$FollowupsTableOrderingComposer get followupId {
    final $$FollowupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.followupId,
      referencedTable: $db.followups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FollowupsTableOrderingComposer(
            $db: $db,
            $table: $db.followups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OrdersTableOrderingComposer get orderId {
    final $$OrdersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableOrderingComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalName => $composableBuilder(
    column: $table.originalName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$FollowupsTableAnnotationComposer get followupId {
    final $$FollowupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.followupId,
      referencedTable: $db.followups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FollowupsTableAnnotationComposer(
            $db: $db,
            $table: $db.followups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OrdersTableAnnotationComposer get orderId {
    final $$OrdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableAnnotationComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttachmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttachmentsTable,
          AttachmentRow,
          $$AttachmentsTableFilterComposer,
          $$AttachmentsTableOrderingComposer,
          $$AttachmentsTableAnnotationComposer,
          $$AttachmentsTableCreateCompanionBuilder,
          $$AttachmentsTableUpdateCompanionBuilder,
          (AttachmentRow, $$AttachmentsTableReferences),
          AttachmentRow,
          PrefetchHooks Function({bool followupId, bool orderId})
        > {
  $$AttachmentsTableTableManager(_$AppDatabase db, $AttachmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttachmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> followupId = const Value.absent(),
                Value<int?> orderId = const Value.absent(),
                Value<String> relativePath = const Value.absent(),
                Value<String> originalName = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => AttachmentsCompanion(
                id: id,
                followupId: followupId,
                orderId: orderId,
                relativePath: relativePath,
                originalName: originalName,
                mimeType: mimeType,
                sizeBytes: sizeBytes,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> followupId = const Value.absent(),
                Value<int?> orderId = const Value.absent(),
                required String relativePath,
                required String originalName,
                required String mimeType,
                required int sizeBytes,
                required int createdAt,
                required int updatedAt,
              }) => AttachmentsCompanion.insert(
                id: id,
                followupId: followupId,
                orderId: orderId,
                relativePath: relativePath,
                originalName: originalName,
                mimeType: mimeType,
                sizeBytes: sizeBytes,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AttachmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({followupId = false, orderId = false}) {
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
                    if (followupId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.followupId,
                                referencedTable: $$AttachmentsTableReferences
                                    ._followupIdTable(db),
                                referencedColumn: $$AttachmentsTableReferences
                                    ._followupIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (orderId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.orderId,
                                referencedTable: $$AttachmentsTableReferences
                                    ._orderIdTable(db),
                                referencedColumn: $$AttachmentsTableReferences
                                    ._orderIdTable(db)
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

typedef $$AttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttachmentsTable,
      AttachmentRow,
      $$AttachmentsTableFilterComposer,
      $$AttachmentsTableOrderingComposer,
      $$AttachmentsTableAnnotationComposer,
      $$AttachmentsTableCreateCompanionBuilder,
      $$AttachmentsTableUpdateCompanionBuilder,
      (AttachmentRow, $$AttachmentsTableReferences),
      AttachmentRow,
      PrefetchHooks Function({bool followupId, bool orderId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
  $$ContactsTableTableManager get contacts =>
      $$ContactsTableTableManager(_db, _db.contacts);
  $$FollowupsTableTableManager get followups =>
      $$FollowupsTableTableManager(_db, _db.followups);
  $$FollowPlansTableTableManager get followPlans =>
      $$FollowPlansTableTableManager(_db, _db.followPlans);
  $$OrdersTableTableManager get orders =>
      $$OrdersTableTableManager(_db, _db.orders);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$CustomerTagsTableTableManager get customerTags =>
      $$CustomerTagsTableTableManager(_db, _db.customerTags);
  $$AttachmentsTableTableManager get attachments =>
      $$AttachmentsTableTableManager(_db, _db.attachments);
}
