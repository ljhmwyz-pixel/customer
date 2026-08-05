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
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
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
    country,
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
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
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
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
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

  /// 国家/地区。v4 增量字段，旧客户无法可靠推断所以保持可空。
  final String? country;

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
    this.country,
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
    if (!nullToAbsent || country != null) {
      map['country'] = Variable<String>(country);
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
      country: country == null && nullToAbsent
          ? const Value.absent()
          : Value(country),
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
      country: serializer.fromJson<String?>(json['country']),
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
      'country': serializer.toJson<String?>(country),
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
    Value<String?> country = const Value.absent(),
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
    country: country.present ? country.value : this.country,
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
      country: data.country.present ? data.country.value : this.country,
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
          ..write('country: $country, ')
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
    country,
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
          other.country == this.country &&
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
  final Value<String?> country;
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
    this.country = const Value.absent(),
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
    this.country = const Value.absent(),
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
    Expression<String>? country,
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
      if (country != null) 'country': country,
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
    Value<String?>? country,
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
      country: country ?? this.country,
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
    if (country.present) {
      map['country'] = Variable<String>(country.value);
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
          ..write('country: $country, ')
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

class $OpportunitiesTable extends Opportunities
    with TableInfo<$OpportunitiesTable, OpportunityRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OpportunitiesTable(this.attachedDatabase, [this._alias]);
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
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerMeta = const VerificationMeta('owner');
  @override
  late final GeneratedColumn<String> owner = GeneratedColumn<String>(
    'owner',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('本人'),
  );
  static const VerificationMeta _importanceMeta = const VerificationMeta(
    'importance',
  );
  @override
  late final GeneratedColumn<String> importance = GeneratedColumn<String>(
    'importance',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('normal'),
  );
  static const VerificationMeta _productCategoryMeta = const VerificationMeta(
    'productCategory',
  );
  @override
  late final GeneratedColumn<String> productCategory = GeneratedColumn<String>(
    'product_category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productModelMeta = const VerificationMeta(
    'productModel',
  );
  @override
  late final GeneratedColumn<String> productModel = GeneratedColumn<String>(
    'product_model',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _equipmentBrandMeta = const VerificationMeta(
    'equipmentBrand',
  );
  @override
  late final GeneratedColumn<String> equipmentBrand = GeneratedColumn<String>(
    'equipment_brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _equipmentModelMeta = const VerificationMeta(
    'equipmentModel',
  );
  @override
  late final GeneratedColumn<String> equipmentModel = GeneratedColumn<String>(
    'equipment_model',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estimatedAnnualVolumeMeta =
      const VerificationMeta('estimatedAnnualVolume');
  @override
  late final GeneratedColumn<int> estimatedAnnualVolume = GeneratedColumn<int>(
    'estimated_annual_volume',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _forecastAmountMinorMeta =
      const VerificationMeta('forecastAmountMinor');
  @override
  late final GeneratedColumn<int> forecastAmountMinor = GeneratedColumn<int>(
    'forecast_amount_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('USD'),
  );
  static const VerificationMeta _probabilityPercentMeta =
      const VerificationMeta('probabilityPercent');
  @override
  late final GeneratedColumn<int> probabilityPercent = GeneratedColumn<int>(
    'probability_percent',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expectedCloseAtMeta = const VerificationMeta(
    'expectedCloseAt',
  );
  @override
  late final GeneratedColumn<int> expectedCloseAt = GeneratedColumn<int>(
    'expected_close_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currentSupplierMeta = const VerificationMeta(
    'currentSupplier',
  );
  @override
  late final GeneratedColumn<String> currentSupplier = GeneratedColumn<String>(
    'current_supplier',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currentPurchaseBrandMeta =
      const VerificationMeta('currentPurchaseBrand');
  @override
  late final GeneratedColumn<String> currentPurchaseBrand =
      GeneratedColumn<String>(
        'current_purchase_brand',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _currentPurchasePriceMinorMeta =
      const VerificationMeta('currentPurchasePriceMinor');
  @override
  late final GeneratedColumn<int> currentPurchasePriceMinor =
      GeneratedColumn<int>(
        'current_purchase_price_minor',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _supplierStabilityMeta = const VerificationMeta(
    'supplierStability',
  );
  @override
  late final GeneratedColumn<String> supplierStability =
      GeneratedColumn<String>(
        'supplier_stability',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _supplierProblemMeta = const VerificationMeta(
    'supplierProblem',
  );
  @override
  late final GeneratedColumn<String> supplierProblem = GeneratedColumn<String>(
    'supplier_problem',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _changeWillingnessMeta = const VerificationMeta(
    'changeWillingness',
  );
  @override
  late final GeneratedColumn<String> changeWillingness =
      GeneratedColumn<String>(
        'change_willingness',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _substitutionDifficultyMeta =
      const VerificationMeta('substitutionDifficulty');
  @override
  late final GeneratedColumn<String> substitutionDifficulty =
      GeneratedColumn<String>(
        'substitution_difficulty',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _latestQuoteMinorMeta = const VerificationMeta(
    'latestQuoteMinor',
  );
  @override
  late final GeneratedColumn<int> latestQuoteMinor = GeneratedColumn<int>(
    'latest_quote_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetPriceMinorMeta = const VerificationMeta(
    'targetPriceMinor',
  );
  @override
  late final GeneratedColumn<int> targetPriceMinor = GeneratedColumn<int>(
    'target_price_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entryPointMeta = const VerificationMeta(
    'entryPoint',
  );
  @override
  late final GeneratedColumn<String> entryPoint = GeneratedColumn<String>(
    'entry_point',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _investmentAdviceMeta = const VerificationMeta(
    'investmentAdvice',
  );
  @override
  late final GeneratedColumn<String> investmentAdvice = GeneratedColumn<String>(
    'investment_advice',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _needsSampleMeta = const VerificationMeta(
    'needsSample',
  );
  @override
  late final GeneratedColumn<bool> needsSample = GeneratedColumn<bool>(
    'needs_sample',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("needs_sample" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _needsRegistrationMeta = const VerificationMeta(
    'needsRegistration',
  );
  @override
  late final GeneratedColumn<bool> needsRegistration = GeneratedColumn<bool>(
    'needs_registration',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("needs_registration" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _needsAuthorizationMeta =
      const VerificationMeta('needsAuthorization');
  @override
  late final GeneratedColumn<bool> needsAuthorization = GeneratedColumn<bool>(
    'needs_authorization',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("needs_authorization" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _stageMeta = const VerificationMeta('stage');
  @override
  late final GeneratedColumn<String> stage = GeneratedColumn<String>(
    'stage',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('new_lead'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _latestFeedbackMeta = const VerificationMeta(
    'latestFeedback',
  );
  @override
  late final GeneratedColumn<String> latestFeedback = GeneratedColumn<String>(
    'latest_feedback',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currentObstacleMeta = const VerificationMeta(
    'currentObstacle',
  );
  @override
  late final GeneratedColumn<String> currentObstacle = GeneratedColumn<String>(
    'current_obstacle',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextActionMeta = const VerificationMeta(
    'nextAction',
  );
  @override
  late final GeneratedColumn<String> nextAction = GeneratedColumn<String>(
    'next_action',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextFollowAtMeta = const VerificationMeta(
    'nextFollowAt',
  );
  @override
  late final GeneratedColumn<int> nextFollowAt = GeneratedColumn<int>(
    'next_follow_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  static const VerificationMeta _isLegacyDefaultMeta = const VerificationMeta(
    'isLegacyDefault',
  );
  @override
  late final GeneratedColumn<bool> isLegacyDefault = GeneratedColumn<bool>(
    'is_legacy_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_legacy_default" IN (0, 1))',
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
    owner,
    importance,
    productCategory,
    productModel,
    equipmentBrand,
    equipmentModel,
    estimatedAnnualVolume,
    forecastAmountMinor,
    currency,
    probabilityPercent,
    expectedCloseAt,
    currentSupplier,
    currentPurchaseBrand,
    currentPurchasePriceMinor,
    supplierStability,
    supplierProblem,
    changeWillingness,
    substitutionDifficulty,
    latestQuoteMinor,
    targetPriceMinor,
    entryPoint,
    investmentAdvice,
    needsSample,
    needsRegistration,
    needsAuthorization,
    stage,
    status,
    latestFeedback,
    currentObstacle,
    nextAction,
    nextFollowAt,
    lastFollowAt,
    isLegacyDefault,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'opportunities';
  @override
  VerificationContext validateIntegrity(
    Insertable<OpportunityRow> instance, {
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
    if (data.containsKey('owner')) {
      context.handle(
        _ownerMeta,
        owner.isAcceptableOrUnknown(data['owner']!, _ownerMeta),
      );
    }
    if (data.containsKey('importance')) {
      context.handle(
        _importanceMeta,
        importance.isAcceptableOrUnknown(data['importance']!, _importanceMeta),
      );
    }
    if (data.containsKey('product_category')) {
      context.handle(
        _productCategoryMeta,
        productCategory.isAcceptableOrUnknown(
          data['product_category']!,
          _productCategoryMeta,
        ),
      );
    }
    if (data.containsKey('product_model')) {
      context.handle(
        _productModelMeta,
        productModel.isAcceptableOrUnknown(
          data['product_model']!,
          _productModelMeta,
        ),
      );
    }
    if (data.containsKey('equipment_brand')) {
      context.handle(
        _equipmentBrandMeta,
        equipmentBrand.isAcceptableOrUnknown(
          data['equipment_brand']!,
          _equipmentBrandMeta,
        ),
      );
    }
    if (data.containsKey('equipment_model')) {
      context.handle(
        _equipmentModelMeta,
        equipmentModel.isAcceptableOrUnknown(
          data['equipment_model']!,
          _equipmentModelMeta,
        ),
      );
    }
    if (data.containsKey('estimated_annual_volume')) {
      context.handle(
        _estimatedAnnualVolumeMeta,
        estimatedAnnualVolume.isAcceptableOrUnknown(
          data['estimated_annual_volume']!,
          _estimatedAnnualVolumeMeta,
        ),
      );
    }
    if (data.containsKey('forecast_amount_minor')) {
      context.handle(
        _forecastAmountMinorMeta,
        forecastAmountMinor.isAcceptableOrUnknown(
          data['forecast_amount_minor']!,
          _forecastAmountMinorMeta,
        ),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('probability_percent')) {
      context.handle(
        _probabilityPercentMeta,
        probabilityPercent.isAcceptableOrUnknown(
          data['probability_percent']!,
          _probabilityPercentMeta,
        ),
      );
    }
    if (data.containsKey('expected_close_at')) {
      context.handle(
        _expectedCloseAtMeta,
        expectedCloseAt.isAcceptableOrUnknown(
          data['expected_close_at']!,
          _expectedCloseAtMeta,
        ),
      );
    }
    if (data.containsKey('current_supplier')) {
      context.handle(
        _currentSupplierMeta,
        currentSupplier.isAcceptableOrUnknown(
          data['current_supplier']!,
          _currentSupplierMeta,
        ),
      );
    }
    if (data.containsKey('current_purchase_brand')) {
      context.handle(
        _currentPurchaseBrandMeta,
        currentPurchaseBrand.isAcceptableOrUnknown(
          data['current_purchase_brand']!,
          _currentPurchaseBrandMeta,
        ),
      );
    }
    if (data.containsKey('current_purchase_price_minor')) {
      context.handle(
        _currentPurchasePriceMinorMeta,
        currentPurchasePriceMinor.isAcceptableOrUnknown(
          data['current_purchase_price_minor']!,
          _currentPurchasePriceMinorMeta,
        ),
      );
    }
    if (data.containsKey('supplier_stability')) {
      context.handle(
        _supplierStabilityMeta,
        supplierStability.isAcceptableOrUnknown(
          data['supplier_stability']!,
          _supplierStabilityMeta,
        ),
      );
    }
    if (data.containsKey('supplier_problem')) {
      context.handle(
        _supplierProblemMeta,
        supplierProblem.isAcceptableOrUnknown(
          data['supplier_problem']!,
          _supplierProblemMeta,
        ),
      );
    }
    if (data.containsKey('change_willingness')) {
      context.handle(
        _changeWillingnessMeta,
        changeWillingness.isAcceptableOrUnknown(
          data['change_willingness']!,
          _changeWillingnessMeta,
        ),
      );
    }
    if (data.containsKey('substitution_difficulty')) {
      context.handle(
        _substitutionDifficultyMeta,
        substitutionDifficulty.isAcceptableOrUnknown(
          data['substitution_difficulty']!,
          _substitutionDifficultyMeta,
        ),
      );
    }
    if (data.containsKey('latest_quote_minor')) {
      context.handle(
        _latestQuoteMinorMeta,
        latestQuoteMinor.isAcceptableOrUnknown(
          data['latest_quote_minor']!,
          _latestQuoteMinorMeta,
        ),
      );
    }
    if (data.containsKey('target_price_minor')) {
      context.handle(
        _targetPriceMinorMeta,
        targetPriceMinor.isAcceptableOrUnknown(
          data['target_price_minor']!,
          _targetPriceMinorMeta,
        ),
      );
    }
    if (data.containsKey('entry_point')) {
      context.handle(
        _entryPointMeta,
        entryPoint.isAcceptableOrUnknown(data['entry_point']!, _entryPointMeta),
      );
    }
    if (data.containsKey('investment_advice')) {
      context.handle(
        _investmentAdviceMeta,
        investmentAdvice.isAcceptableOrUnknown(
          data['investment_advice']!,
          _investmentAdviceMeta,
        ),
      );
    }
    if (data.containsKey('needs_sample')) {
      context.handle(
        _needsSampleMeta,
        needsSample.isAcceptableOrUnknown(
          data['needs_sample']!,
          _needsSampleMeta,
        ),
      );
    }
    if (data.containsKey('needs_registration')) {
      context.handle(
        _needsRegistrationMeta,
        needsRegistration.isAcceptableOrUnknown(
          data['needs_registration']!,
          _needsRegistrationMeta,
        ),
      );
    }
    if (data.containsKey('needs_authorization')) {
      context.handle(
        _needsAuthorizationMeta,
        needsAuthorization.isAcceptableOrUnknown(
          data['needs_authorization']!,
          _needsAuthorizationMeta,
        ),
      );
    }
    if (data.containsKey('stage')) {
      context.handle(
        _stageMeta,
        stage.isAcceptableOrUnknown(data['stage']!, _stageMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('latest_feedback')) {
      context.handle(
        _latestFeedbackMeta,
        latestFeedback.isAcceptableOrUnknown(
          data['latest_feedback']!,
          _latestFeedbackMeta,
        ),
      );
    }
    if (data.containsKey('current_obstacle')) {
      context.handle(
        _currentObstacleMeta,
        currentObstacle.isAcceptableOrUnknown(
          data['current_obstacle']!,
          _currentObstacleMeta,
        ),
      );
    }
    if (data.containsKey('next_action')) {
      context.handle(
        _nextActionMeta,
        nextAction.isAcceptableOrUnknown(data['next_action']!, _nextActionMeta),
      );
    }
    if (data.containsKey('next_follow_at')) {
      context.handle(
        _nextFollowAtMeta,
        nextFollowAt.isAcceptableOrUnknown(
          data['next_follow_at']!,
          _nextFollowAtMeta,
        ),
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
    if (data.containsKey('is_legacy_default')) {
      context.handle(
        _isLegacyDefaultMeta,
        isLegacyDefault.isAcceptableOrUnknown(
          data['is_legacy_default']!,
          _isLegacyDefaultMeta,
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
  OpportunityRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OpportunityRow(
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
      owner: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner'],
      )!,
      importance: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}importance'],
      )!,
      productCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_category'],
      ),
      productModel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_model'],
      ),
      equipmentBrand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipment_brand'],
      ),
      equipmentModel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipment_model'],
      ),
      estimatedAnnualVolume: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_annual_volume'],
      ),
      forecastAmountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}forecast_amount_minor'],
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      probabilityPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}probability_percent'],
      ),
      expectedCloseAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expected_close_at'],
      ),
      currentSupplier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_supplier'],
      ),
      currentPurchaseBrand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_purchase_brand'],
      ),
      currentPurchasePriceMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_purchase_price_minor'],
      ),
      supplierStability: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier_stability'],
      ),
      supplierProblem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier_problem'],
      ),
      changeWillingness: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}change_willingness'],
      ),
      substitutionDifficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}substitution_difficulty'],
      ),
      latestQuoteMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}latest_quote_minor'],
      ),
      targetPriceMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_price_minor'],
      ),
      entryPoint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_point'],
      ),
      investmentAdvice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}investment_advice'],
      ),
      needsSample: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}needs_sample'],
      )!,
      needsRegistration: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}needs_registration'],
      )!,
      needsAuthorization: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}needs_authorization'],
      )!,
      stage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stage'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      latestFeedback: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}latest_feedback'],
      ),
      currentObstacle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_obstacle'],
      ),
      nextAction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}next_action'],
      ),
      nextFollowAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_follow_at'],
      ),
      lastFollowAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_follow_at'],
      ),
      isLegacyDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_legacy_default'],
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
  $OpportunitiesTable createAlias(String alias) {
    return $OpportunitiesTable(attachedDatabase, alias);
  }
}

class OpportunityRow extends DataClass implements Insertable<OpportunityRow> {
  final int id;
  final int customerId;
  final String name;

  /// 单人版默认由本人负责，保留文本字段供后续表单覆盖。
  final String owner;

  /// 项目重要程度，存 OpportunityImportance.dbValue。
  final String importance;
  final String? productCategory;
  final String? productModel;
  final String? equipmentBrand;
  final String? equipmentModel;
  final int? estimatedAnnualVolume;

  /// 预计项目金额，单位为 [currency] 的最小货币单位。
  final int? forecastAmountMinor;
  final String currency;
  final int? probabilityPercent;
  final int? expectedCloseAt;
  final String? currentSupplier;
  final String? currentPurchaseBrand;
  final int? currentPurchasePriceMinor;
  final String? supplierStability;
  final String? supplierProblem;
  final String? changeWillingness;
  final String? substitutionDifficulty;
  final int? latestQuoteMinor;
  final int? targetPriceMinor;
  final String? entryPoint;
  final String? investmentAdvice;
  final bool needsSample;
  final bool needsRegistration;
  final bool needsAuthorization;

  /// 存 OpportunityStage.dbValue。
  final String stage;

  /// 存 OpportunityStatus.dbValue。
  final String status;
  final String? latestFeedback;
  final String? currentObstacle;
  final String? nextAction;
  final int? nextFollowAt;

  /// 最近一次同步到项目状态的跟进发生时间。
  final int? lastFollowAt;

  /// v1 升级时为每个客户创建的历史承接项目。
  final bool isLegacyDefault;
  final int createdAt;
  final int updatedAt;
  const OpportunityRow({
    required this.id,
    required this.customerId,
    required this.name,
    required this.owner,
    required this.importance,
    this.productCategory,
    this.productModel,
    this.equipmentBrand,
    this.equipmentModel,
    this.estimatedAnnualVolume,
    this.forecastAmountMinor,
    required this.currency,
    this.probabilityPercent,
    this.expectedCloseAt,
    this.currentSupplier,
    this.currentPurchaseBrand,
    this.currentPurchasePriceMinor,
    this.supplierStability,
    this.supplierProblem,
    this.changeWillingness,
    this.substitutionDifficulty,
    this.latestQuoteMinor,
    this.targetPriceMinor,
    this.entryPoint,
    this.investmentAdvice,
    required this.needsSample,
    required this.needsRegistration,
    required this.needsAuthorization,
    required this.stage,
    required this.status,
    this.latestFeedback,
    this.currentObstacle,
    this.nextAction,
    this.nextFollowAt,
    this.lastFollowAt,
    required this.isLegacyDefault,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['customer_id'] = Variable<int>(customerId);
    map['name'] = Variable<String>(name);
    map['owner'] = Variable<String>(owner);
    map['importance'] = Variable<String>(importance);
    if (!nullToAbsent || productCategory != null) {
      map['product_category'] = Variable<String>(productCategory);
    }
    if (!nullToAbsent || productModel != null) {
      map['product_model'] = Variable<String>(productModel);
    }
    if (!nullToAbsent || equipmentBrand != null) {
      map['equipment_brand'] = Variable<String>(equipmentBrand);
    }
    if (!nullToAbsent || equipmentModel != null) {
      map['equipment_model'] = Variable<String>(equipmentModel);
    }
    if (!nullToAbsent || estimatedAnnualVolume != null) {
      map['estimated_annual_volume'] = Variable<int>(estimatedAnnualVolume);
    }
    if (!nullToAbsent || forecastAmountMinor != null) {
      map['forecast_amount_minor'] = Variable<int>(forecastAmountMinor);
    }
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || probabilityPercent != null) {
      map['probability_percent'] = Variable<int>(probabilityPercent);
    }
    if (!nullToAbsent || expectedCloseAt != null) {
      map['expected_close_at'] = Variable<int>(expectedCloseAt);
    }
    if (!nullToAbsent || currentSupplier != null) {
      map['current_supplier'] = Variable<String>(currentSupplier);
    }
    if (!nullToAbsent || currentPurchaseBrand != null) {
      map['current_purchase_brand'] = Variable<String>(currentPurchaseBrand);
    }
    if (!nullToAbsent || currentPurchasePriceMinor != null) {
      map['current_purchase_price_minor'] = Variable<int>(
        currentPurchasePriceMinor,
      );
    }
    if (!nullToAbsent || supplierStability != null) {
      map['supplier_stability'] = Variable<String>(supplierStability);
    }
    if (!nullToAbsent || supplierProblem != null) {
      map['supplier_problem'] = Variable<String>(supplierProblem);
    }
    if (!nullToAbsent || changeWillingness != null) {
      map['change_willingness'] = Variable<String>(changeWillingness);
    }
    if (!nullToAbsent || substitutionDifficulty != null) {
      map['substitution_difficulty'] = Variable<String>(substitutionDifficulty);
    }
    if (!nullToAbsent || latestQuoteMinor != null) {
      map['latest_quote_minor'] = Variable<int>(latestQuoteMinor);
    }
    if (!nullToAbsent || targetPriceMinor != null) {
      map['target_price_minor'] = Variable<int>(targetPriceMinor);
    }
    if (!nullToAbsent || entryPoint != null) {
      map['entry_point'] = Variable<String>(entryPoint);
    }
    if (!nullToAbsent || investmentAdvice != null) {
      map['investment_advice'] = Variable<String>(investmentAdvice);
    }
    map['needs_sample'] = Variable<bool>(needsSample);
    map['needs_registration'] = Variable<bool>(needsRegistration);
    map['needs_authorization'] = Variable<bool>(needsAuthorization);
    map['stage'] = Variable<String>(stage);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || latestFeedback != null) {
      map['latest_feedback'] = Variable<String>(latestFeedback);
    }
    if (!nullToAbsent || currentObstacle != null) {
      map['current_obstacle'] = Variable<String>(currentObstacle);
    }
    if (!nullToAbsent || nextAction != null) {
      map['next_action'] = Variable<String>(nextAction);
    }
    if (!nullToAbsent || nextFollowAt != null) {
      map['next_follow_at'] = Variable<int>(nextFollowAt);
    }
    if (!nullToAbsent || lastFollowAt != null) {
      map['last_follow_at'] = Variable<int>(lastFollowAt);
    }
    map['is_legacy_default'] = Variable<bool>(isLegacyDefault);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  OpportunitiesCompanion toCompanion(bool nullToAbsent) {
    return OpportunitiesCompanion(
      id: Value(id),
      customerId: Value(customerId),
      name: Value(name),
      owner: Value(owner),
      importance: Value(importance),
      productCategory: productCategory == null && nullToAbsent
          ? const Value.absent()
          : Value(productCategory),
      productModel: productModel == null && nullToAbsent
          ? const Value.absent()
          : Value(productModel),
      equipmentBrand: equipmentBrand == null && nullToAbsent
          ? const Value.absent()
          : Value(equipmentBrand),
      equipmentModel: equipmentModel == null && nullToAbsent
          ? const Value.absent()
          : Value(equipmentModel),
      estimatedAnnualVolume: estimatedAnnualVolume == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedAnnualVolume),
      forecastAmountMinor: forecastAmountMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(forecastAmountMinor),
      currency: Value(currency),
      probabilityPercent: probabilityPercent == null && nullToAbsent
          ? const Value.absent()
          : Value(probabilityPercent),
      expectedCloseAt: expectedCloseAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expectedCloseAt),
      currentSupplier: currentSupplier == null && nullToAbsent
          ? const Value.absent()
          : Value(currentSupplier),
      currentPurchaseBrand: currentPurchaseBrand == null && nullToAbsent
          ? const Value.absent()
          : Value(currentPurchaseBrand),
      currentPurchasePriceMinor:
          currentPurchasePriceMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(currentPurchasePriceMinor),
      supplierStability: supplierStability == null && nullToAbsent
          ? const Value.absent()
          : Value(supplierStability),
      supplierProblem: supplierProblem == null && nullToAbsent
          ? const Value.absent()
          : Value(supplierProblem),
      changeWillingness: changeWillingness == null && nullToAbsent
          ? const Value.absent()
          : Value(changeWillingness),
      substitutionDifficulty: substitutionDifficulty == null && nullToAbsent
          ? const Value.absent()
          : Value(substitutionDifficulty),
      latestQuoteMinor: latestQuoteMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(latestQuoteMinor),
      targetPriceMinor: targetPriceMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(targetPriceMinor),
      entryPoint: entryPoint == null && nullToAbsent
          ? const Value.absent()
          : Value(entryPoint),
      investmentAdvice: investmentAdvice == null && nullToAbsent
          ? const Value.absent()
          : Value(investmentAdvice),
      needsSample: Value(needsSample),
      needsRegistration: Value(needsRegistration),
      needsAuthorization: Value(needsAuthorization),
      stage: Value(stage),
      status: Value(status),
      latestFeedback: latestFeedback == null && nullToAbsent
          ? const Value.absent()
          : Value(latestFeedback),
      currentObstacle: currentObstacle == null && nullToAbsent
          ? const Value.absent()
          : Value(currentObstacle),
      nextAction: nextAction == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAction),
      nextFollowAt: nextFollowAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextFollowAt),
      lastFollowAt: lastFollowAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastFollowAt),
      isLegacyDefault: Value(isLegacyDefault),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory OpportunityRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OpportunityRow(
      id: serializer.fromJson<int>(json['id']),
      customerId: serializer.fromJson<int>(json['customerId']),
      name: serializer.fromJson<String>(json['name']),
      owner: serializer.fromJson<String>(json['owner']),
      importance: serializer.fromJson<String>(json['importance']),
      productCategory: serializer.fromJson<String?>(json['productCategory']),
      productModel: serializer.fromJson<String?>(json['productModel']),
      equipmentBrand: serializer.fromJson<String?>(json['equipmentBrand']),
      equipmentModel: serializer.fromJson<String?>(json['equipmentModel']),
      estimatedAnnualVolume: serializer.fromJson<int?>(
        json['estimatedAnnualVolume'],
      ),
      forecastAmountMinor: serializer.fromJson<int?>(
        json['forecastAmountMinor'],
      ),
      currency: serializer.fromJson<String>(json['currency']),
      probabilityPercent: serializer.fromJson<int?>(json['probabilityPercent']),
      expectedCloseAt: serializer.fromJson<int?>(json['expectedCloseAt']),
      currentSupplier: serializer.fromJson<String?>(json['currentSupplier']),
      currentPurchaseBrand: serializer.fromJson<String?>(
        json['currentPurchaseBrand'],
      ),
      currentPurchasePriceMinor: serializer.fromJson<int?>(
        json['currentPurchasePriceMinor'],
      ),
      supplierStability: serializer.fromJson<String?>(
        json['supplierStability'],
      ),
      supplierProblem: serializer.fromJson<String?>(json['supplierProblem']),
      changeWillingness: serializer.fromJson<String?>(
        json['changeWillingness'],
      ),
      substitutionDifficulty: serializer.fromJson<String?>(
        json['substitutionDifficulty'],
      ),
      latestQuoteMinor: serializer.fromJson<int?>(json['latestQuoteMinor']),
      targetPriceMinor: serializer.fromJson<int?>(json['targetPriceMinor']),
      entryPoint: serializer.fromJson<String?>(json['entryPoint']),
      investmentAdvice: serializer.fromJson<String?>(json['investmentAdvice']),
      needsSample: serializer.fromJson<bool>(json['needsSample']),
      needsRegistration: serializer.fromJson<bool>(json['needsRegistration']),
      needsAuthorization: serializer.fromJson<bool>(json['needsAuthorization']),
      stage: serializer.fromJson<String>(json['stage']),
      status: serializer.fromJson<String>(json['status']),
      latestFeedback: serializer.fromJson<String?>(json['latestFeedback']),
      currentObstacle: serializer.fromJson<String?>(json['currentObstacle']),
      nextAction: serializer.fromJson<String?>(json['nextAction']),
      nextFollowAt: serializer.fromJson<int?>(json['nextFollowAt']),
      lastFollowAt: serializer.fromJson<int?>(json['lastFollowAt']),
      isLegacyDefault: serializer.fromJson<bool>(json['isLegacyDefault']),
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
      'owner': serializer.toJson<String>(owner),
      'importance': serializer.toJson<String>(importance),
      'productCategory': serializer.toJson<String?>(productCategory),
      'productModel': serializer.toJson<String?>(productModel),
      'equipmentBrand': serializer.toJson<String?>(equipmentBrand),
      'equipmentModel': serializer.toJson<String?>(equipmentModel),
      'estimatedAnnualVolume': serializer.toJson<int?>(estimatedAnnualVolume),
      'forecastAmountMinor': serializer.toJson<int?>(forecastAmountMinor),
      'currency': serializer.toJson<String>(currency),
      'probabilityPercent': serializer.toJson<int?>(probabilityPercent),
      'expectedCloseAt': serializer.toJson<int?>(expectedCloseAt),
      'currentSupplier': serializer.toJson<String?>(currentSupplier),
      'currentPurchaseBrand': serializer.toJson<String?>(currentPurchaseBrand),
      'currentPurchasePriceMinor': serializer.toJson<int?>(
        currentPurchasePriceMinor,
      ),
      'supplierStability': serializer.toJson<String?>(supplierStability),
      'supplierProblem': serializer.toJson<String?>(supplierProblem),
      'changeWillingness': serializer.toJson<String?>(changeWillingness),
      'substitutionDifficulty': serializer.toJson<String?>(
        substitutionDifficulty,
      ),
      'latestQuoteMinor': serializer.toJson<int?>(latestQuoteMinor),
      'targetPriceMinor': serializer.toJson<int?>(targetPriceMinor),
      'entryPoint': serializer.toJson<String?>(entryPoint),
      'investmentAdvice': serializer.toJson<String?>(investmentAdvice),
      'needsSample': serializer.toJson<bool>(needsSample),
      'needsRegistration': serializer.toJson<bool>(needsRegistration),
      'needsAuthorization': serializer.toJson<bool>(needsAuthorization),
      'stage': serializer.toJson<String>(stage),
      'status': serializer.toJson<String>(status),
      'latestFeedback': serializer.toJson<String?>(latestFeedback),
      'currentObstacle': serializer.toJson<String?>(currentObstacle),
      'nextAction': serializer.toJson<String?>(nextAction),
      'nextFollowAt': serializer.toJson<int?>(nextFollowAt),
      'lastFollowAt': serializer.toJson<int?>(lastFollowAt),
      'isLegacyDefault': serializer.toJson<bool>(isLegacyDefault),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  OpportunityRow copyWith({
    int? id,
    int? customerId,
    String? name,
    String? owner,
    String? importance,
    Value<String?> productCategory = const Value.absent(),
    Value<String?> productModel = const Value.absent(),
    Value<String?> equipmentBrand = const Value.absent(),
    Value<String?> equipmentModel = const Value.absent(),
    Value<int?> estimatedAnnualVolume = const Value.absent(),
    Value<int?> forecastAmountMinor = const Value.absent(),
    String? currency,
    Value<int?> probabilityPercent = const Value.absent(),
    Value<int?> expectedCloseAt = const Value.absent(),
    Value<String?> currentSupplier = const Value.absent(),
    Value<String?> currentPurchaseBrand = const Value.absent(),
    Value<int?> currentPurchasePriceMinor = const Value.absent(),
    Value<String?> supplierStability = const Value.absent(),
    Value<String?> supplierProblem = const Value.absent(),
    Value<String?> changeWillingness = const Value.absent(),
    Value<String?> substitutionDifficulty = const Value.absent(),
    Value<int?> latestQuoteMinor = const Value.absent(),
    Value<int?> targetPriceMinor = const Value.absent(),
    Value<String?> entryPoint = const Value.absent(),
    Value<String?> investmentAdvice = const Value.absent(),
    bool? needsSample,
    bool? needsRegistration,
    bool? needsAuthorization,
    String? stage,
    String? status,
    Value<String?> latestFeedback = const Value.absent(),
    Value<String?> currentObstacle = const Value.absent(),
    Value<String?> nextAction = const Value.absent(),
    Value<int?> nextFollowAt = const Value.absent(),
    Value<int?> lastFollowAt = const Value.absent(),
    bool? isLegacyDefault,
    int? createdAt,
    int? updatedAt,
  }) => OpportunityRow(
    id: id ?? this.id,
    customerId: customerId ?? this.customerId,
    name: name ?? this.name,
    owner: owner ?? this.owner,
    importance: importance ?? this.importance,
    productCategory: productCategory.present
        ? productCategory.value
        : this.productCategory,
    productModel: productModel.present ? productModel.value : this.productModel,
    equipmentBrand: equipmentBrand.present
        ? equipmentBrand.value
        : this.equipmentBrand,
    equipmentModel: equipmentModel.present
        ? equipmentModel.value
        : this.equipmentModel,
    estimatedAnnualVolume: estimatedAnnualVolume.present
        ? estimatedAnnualVolume.value
        : this.estimatedAnnualVolume,
    forecastAmountMinor: forecastAmountMinor.present
        ? forecastAmountMinor.value
        : this.forecastAmountMinor,
    currency: currency ?? this.currency,
    probabilityPercent: probabilityPercent.present
        ? probabilityPercent.value
        : this.probabilityPercent,
    expectedCloseAt: expectedCloseAt.present
        ? expectedCloseAt.value
        : this.expectedCloseAt,
    currentSupplier: currentSupplier.present
        ? currentSupplier.value
        : this.currentSupplier,
    currentPurchaseBrand: currentPurchaseBrand.present
        ? currentPurchaseBrand.value
        : this.currentPurchaseBrand,
    currentPurchasePriceMinor: currentPurchasePriceMinor.present
        ? currentPurchasePriceMinor.value
        : this.currentPurchasePriceMinor,
    supplierStability: supplierStability.present
        ? supplierStability.value
        : this.supplierStability,
    supplierProblem: supplierProblem.present
        ? supplierProblem.value
        : this.supplierProblem,
    changeWillingness: changeWillingness.present
        ? changeWillingness.value
        : this.changeWillingness,
    substitutionDifficulty: substitutionDifficulty.present
        ? substitutionDifficulty.value
        : this.substitutionDifficulty,
    latestQuoteMinor: latestQuoteMinor.present
        ? latestQuoteMinor.value
        : this.latestQuoteMinor,
    targetPriceMinor: targetPriceMinor.present
        ? targetPriceMinor.value
        : this.targetPriceMinor,
    entryPoint: entryPoint.present ? entryPoint.value : this.entryPoint,
    investmentAdvice: investmentAdvice.present
        ? investmentAdvice.value
        : this.investmentAdvice,
    needsSample: needsSample ?? this.needsSample,
    needsRegistration: needsRegistration ?? this.needsRegistration,
    needsAuthorization: needsAuthorization ?? this.needsAuthorization,
    stage: stage ?? this.stage,
    status: status ?? this.status,
    latestFeedback: latestFeedback.present
        ? latestFeedback.value
        : this.latestFeedback,
    currentObstacle: currentObstacle.present
        ? currentObstacle.value
        : this.currentObstacle,
    nextAction: nextAction.present ? nextAction.value : this.nextAction,
    nextFollowAt: nextFollowAt.present ? nextFollowAt.value : this.nextFollowAt,
    lastFollowAt: lastFollowAt.present ? lastFollowAt.value : this.lastFollowAt,
    isLegacyDefault: isLegacyDefault ?? this.isLegacyDefault,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  OpportunityRow copyWithCompanion(OpportunitiesCompanion data) {
    return OpportunityRow(
      id: data.id.present ? data.id.value : this.id,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      name: data.name.present ? data.name.value : this.name,
      owner: data.owner.present ? data.owner.value : this.owner,
      importance: data.importance.present
          ? data.importance.value
          : this.importance,
      productCategory: data.productCategory.present
          ? data.productCategory.value
          : this.productCategory,
      productModel: data.productModel.present
          ? data.productModel.value
          : this.productModel,
      equipmentBrand: data.equipmentBrand.present
          ? data.equipmentBrand.value
          : this.equipmentBrand,
      equipmentModel: data.equipmentModel.present
          ? data.equipmentModel.value
          : this.equipmentModel,
      estimatedAnnualVolume: data.estimatedAnnualVolume.present
          ? data.estimatedAnnualVolume.value
          : this.estimatedAnnualVolume,
      forecastAmountMinor: data.forecastAmountMinor.present
          ? data.forecastAmountMinor.value
          : this.forecastAmountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      probabilityPercent: data.probabilityPercent.present
          ? data.probabilityPercent.value
          : this.probabilityPercent,
      expectedCloseAt: data.expectedCloseAt.present
          ? data.expectedCloseAt.value
          : this.expectedCloseAt,
      currentSupplier: data.currentSupplier.present
          ? data.currentSupplier.value
          : this.currentSupplier,
      currentPurchaseBrand: data.currentPurchaseBrand.present
          ? data.currentPurchaseBrand.value
          : this.currentPurchaseBrand,
      currentPurchasePriceMinor: data.currentPurchasePriceMinor.present
          ? data.currentPurchasePriceMinor.value
          : this.currentPurchasePriceMinor,
      supplierStability: data.supplierStability.present
          ? data.supplierStability.value
          : this.supplierStability,
      supplierProblem: data.supplierProblem.present
          ? data.supplierProblem.value
          : this.supplierProblem,
      changeWillingness: data.changeWillingness.present
          ? data.changeWillingness.value
          : this.changeWillingness,
      substitutionDifficulty: data.substitutionDifficulty.present
          ? data.substitutionDifficulty.value
          : this.substitutionDifficulty,
      latestQuoteMinor: data.latestQuoteMinor.present
          ? data.latestQuoteMinor.value
          : this.latestQuoteMinor,
      targetPriceMinor: data.targetPriceMinor.present
          ? data.targetPriceMinor.value
          : this.targetPriceMinor,
      entryPoint: data.entryPoint.present
          ? data.entryPoint.value
          : this.entryPoint,
      investmentAdvice: data.investmentAdvice.present
          ? data.investmentAdvice.value
          : this.investmentAdvice,
      needsSample: data.needsSample.present
          ? data.needsSample.value
          : this.needsSample,
      needsRegistration: data.needsRegistration.present
          ? data.needsRegistration.value
          : this.needsRegistration,
      needsAuthorization: data.needsAuthorization.present
          ? data.needsAuthorization.value
          : this.needsAuthorization,
      stage: data.stage.present ? data.stage.value : this.stage,
      status: data.status.present ? data.status.value : this.status,
      latestFeedback: data.latestFeedback.present
          ? data.latestFeedback.value
          : this.latestFeedback,
      currentObstacle: data.currentObstacle.present
          ? data.currentObstacle.value
          : this.currentObstacle,
      nextAction: data.nextAction.present
          ? data.nextAction.value
          : this.nextAction,
      nextFollowAt: data.nextFollowAt.present
          ? data.nextFollowAt.value
          : this.nextFollowAt,
      lastFollowAt: data.lastFollowAt.present
          ? data.lastFollowAt.value
          : this.lastFollowAt,
      isLegacyDefault: data.isLegacyDefault.present
          ? data.isLegacyDefault.value
          : this.isLegacyDefault,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OpportunityRow(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('name: $name, ')
          ..write('owner: $owner, ')
          ..write('importance: $importance, ')
          ..write('productCategory: $productCategory, ')
          ..write('productModel: $productModel, ')
          ..write('equipmentBrand: $equipmentBrand, ')
          ..write('equipmentModel: $equipmentModel, ')
          ..write('estimatedAnnualVolume: $estimatedAnnualVolume, ')
          ..write('forecastAmountMinor: $forecastAmountMinor, ')
          ..write('currency: $currency, ')
          ..write('probabilityPercent: $probabilityPercent, ')
          ..write('expectedCloseAt: $expectedCloseAt, ')
          ..write('currentSupplier: $currentSupplier, ')
          ..write('currentPurchaseBrand: $currentPurchaseBrand, ')
          ..write('currentPurchasePriceMinor: $currentPurchasePriceMinor, ')
          ..write('supplierStability: $supplierStability, ')
          ..write('supplierProblem: $supplierProblem, ')
          ..write('changeWillingness: $changeWillingness, ')
          ..write('substitutionDifficulty: $substitutionDifficulty, ')
          ..write('latestQuoteMinor: $latestQuoteMinor, ')
          ..write('targetPriceMinor: $targetPriceMinor, ')
          ..write('entryPoint: $entryPoint, ')
          ..write('investmentAdvice: $investmentAdvice, ')
          ..write('needsSample: $needsSample, ')
          ..write('needsRegistration: $needsRegistration, ')
          ..write('needsAuthorization: $needsAuthorization, ')
          ..write('stage: $stage, ')
          ..write('status: $status, ')
          ..write('latestFeedback: $latestFeedback, ')
          ..write('currentObstacle: $currentObstacle, ')
          ..write('nextAction: $nextAction, ')
          ..write('nextFollowAt: $nextFollowAt, ')
          ..write('lastFollowAt: $lastFollowAt, ')
          ..write('isLegacyDefault: $isLegacyDefault, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    customerId,
    name,
    owner,
    importance,
    productCategory,
    productModel,
    equipmentBrand,
    equipmentModel,
    estimatedAnnualVolume,
    forecastAmountMinor,
    currency,
    probabilityPercent,
    expectedCloseAt,
    currentSupplier,
    currentPurchaseBrand,
    currentPurchasePriceMinor,
    supplierStability,
    supplierProblem,
    changeWillingness,
    substitutionDifficulty,
    latestQuoteMinor,
    targetPriceMinor,
    entryPoint,
    investmentAdvice,
    needsSample,
    needsRegistration,
    needsAuthorization,
    stage,
    status,
    latestFeedback,
    currentObstacle,
    nextAction,
    nextFollowAt,
    lastFollowAt,
    isLegacyDefault,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OpportunityRow &&
          other.id == this.id &&
          other.customerId == this.customerId &&
          other.name == this.name &&
          other.owner == this.owner &&
          other.importance == this.importance &&
          other.productCategory == this.productCategory &&
          other.productModel == this.productModel &&
          other.equipmentBrand == this.equipmentBrand &&
          other.equipmentModel == this.equipmentModel &&
          other.estimatedAnnualVolume == this.estimatedAnnualVolume &&
          other.forecastAmountMinor == this.forecastAmountMinor &&
          other.currency == this.currency &&
          other.probabilityPercent == this.probabilityPercent &&
          other.expectedCloseAt == this.expectedCloseAt &&
          other.currentSupplier == this.currentSupplier &&
          other.currentPurchaseBrand == this.currentPurchaseBrand &&
          other.currentPurchasePriceMinor == this.currentPurchasePriceMinor &&
          other.supplierStability == this.supplierStability &&
          other.supplierProblem == this.supplierProblem &&
          other.changeWillingness == this.changeWillingness &&
          other.substitutionDifficulty == this.substitutionDifficulty &&
          other.latestQuoteMinor == this.latestQuoteMinor &&
          other.targetPriceMinor == this.targetPriceMinor &&
          other.entryPoint == this.entryPoint &&
          other.investmentAdvice == this.investmentAdvice &&
          other.needsSample == this.needsSample &&
          other.needsRegistration == this.needsRegistration &&
          other.needsAuthorization == this.needsAuthorization &&
          other.stage == this.stage &&
          other.status == this.status &&
          other.latestFeedback == this.latestFeedback &&
          other.currentObstacle == this.currentObstacle &&
          other.nextAction == this.nextAction &&
          other.nextFollowAt == this.nextFollowAt &&
          other.lastFollowAt == this.lastFollowAt &&
          other.isLegacyDefault == this.isLegacyDefault &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class OpportunitiesCompanion extends UpdateCompanion<OpportunityRow> {
  final Value<int> id;
  final Value<int> customerId;
  final Value<String> name;
  final Value<String> owner;
  final Value<String> importance;
  final Value<String?> productCategory;
  final Value<String?> productModel;
  final Value<String?> equipmentBrand;
  final Value<String?> equipmentModel;
  final Value<int?> estimatedAnnualVolume;
  final Value<int?> forecastAmountMinor;
  final Value<String> currency;
  final Value<int?> probabilityPercent;
  final Value<int?> expectedCloseAt;
  final Value<String?> currentSupplier;
  final Value<String?> currentPurchaseBrand;
  final Value<int?> currentPurchasePriceMinor;
  final Value<String?> supplierStability;
  final Value<String?> supplierProblem;
  final Value<String?> changeWillingness;
  final Value<String?> substitutionDifficulty;
  final Value<int?> latestQuoteMinor;
  final Value<int?> targetPriceMinor;
  final Value<String?> entryPoint;
  final Value<String?> investmentAdvice;
  final Value<bool> needsSample;
  final Value<bool> needsRegistration;
  final Value<bool> needsAuthorization;
  final Value<String> stage;
  final Value<String> status;
  final Value<String?> latestFeedback;
  final Value<String?> currentObstacle;
  final Value<String?> nextAction;
  final Value<int?> nextFollowAt;
  final Value<int?> lastFollowAt;
  final Value<bool> isLegacyDefault;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  const OpportunitiesCompanion({
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.name = const Value.absent(),
    this.owner = const Value.absent(),
    this.importance = const Value.absent(),
    this.productCategory = const Value.absent(),
    this.productModel = const Value.absent(),
    this.equipmentBrand = const Value.absent(),
    this.equipmentModel = const Value.absent(),
    this.estimatedAnnualVolume = const Value.absent(),
    this.forecastAmountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.probabilityPercent = const Value.absent(),
    this.expectedCloseAt = const Value.absent(),
    this.currentSupplier = const Value.absent(),
    this.currentPurchaseBrand = const Value.absent(),
    this.currentPurchasePriceMinor = const Value.absent(),
    this.supplierStability = const Value.absent(),
    this.supplierProblem = const Value.absent(),
    this.changeWillingness = const Value.absent(),
    this.substitutionDifficulty = const Value.absent(),
    this.latestQuoteMinor = const Value.absent(),
    this.targetPriceMinor = const Value.absent(),
    this.entryPoint = const Value.absent(),
    this.investmentAdvice = const Value.absent(),
    this.needsSample = const Value.absent(),
    this.needsRegistration = const Value.absent(),
    this.needsAuthorization = const Value.absent(),
    this.stage = const Value.absent(),
    this.status = const Value.absent(),
    this.latestFeedback = const Value.absent(),
    this.currentObstacle = const Value.absent(),
    this.nextAction = const Value.absent(),
    this.nextFollowAt = const Value.absent(),
    this.lastFollowAt = const Value.absent(),
    this.isLegacyDefault = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  OpportunitiesCompanion.insert({
    this.id = const Value.absent(),
    required int customerId,
    required String name,
    this.owner = const Value.absent(),
    this.importance = const Value.absent(),
    this.productCategory = const Value.absent(),
    this.productModel = const Value.absent(),
    this.equipmentBrand = const Value.absent(),
    this.equipmentModel = const Value.absent(),
    this.estimatedAnnualVolume = const Value.absent(),
    this.forecastAmountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.probabilityPercent = const Value.absent(),
    this.expectedCloseAt = const Value.absent(),
    this.currentSupplier = const Value.absent(),
    this.currentPurchaseBrand = const Value.absent(),
    this.currentPurchasePriceMinor = const Value.absent(),
    this.supplierStability = const Value.absent(),
    this.supplierProblem = const Value.absent(),
    this.changeWillingness = const Value.absent(),
    this.substitutionDifficulty = const Value.absent(),
    this.latestQuoteMinor = const Value.absent(),
    this.targetPriceMinor = const Value.absent(),
    this.entryPoint = const Value.absent(),
    this.investmentAdvice = const Value.absent(),
    this.needsSample = const Value.absent(),
    this.needsRegistration = const Value.absent(),
    this.needsAuthorization = const Value.absent(),
    this.stage = const Value.absent(),
    this.status = const Value.absent(),
    this.latestFeedback = const Value.absent(),
    this.currentObstacle = const Value.absent(),
    this.nextAction = const Value.absent(),
    this.nextFollowAt = const Value.absent(),
    this.lastFollowAt = const Value.absent(),
    this.isLegacyDefault = const Value.absent(),
    required int createdAt,
    required int updatedAt,
  }) : customerId = Value(customerId),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<OpportunityRow> custom({
    Expression<int>? id,
    Expression<int>? customerId,
    Expression<String>? name,
    Expression<String>? owner,
    Expression<String>? importance,
    Expression<String>? productCategory,
    Expression<String>? productModel,
    Expression<String>? equipmentBrand,
    Expression<String>? equipmentModel,
    Expression<int>? estimatedAnnualVolume,
    Expression<int>? forecastAmountMinor,
    Expression<String>? currency,
    Expression<int>? probabilityPercent,
    Expression<int>? expectedCloseAt,
    Expression<String>? currentSupplier,
    Expression<String>? currentPurchaseBrand,
    Expression<int>? currentPurchasePriceMinor,
    Expression<String>? supplierStability,
    Expression<String>? supplierProblem,
    Expression<String>? changeWillingness,
    Expression<String>? substitutionDifficulty,
    Expression<int>? latestQuoteMinor,
    Expression<int>? targetPriceMinor,
    Expression<String>? entryPoint,
    Expression<String>? investmentAdvice,
    Expression<bool>? needsSample,
    Expression<bool>? needsRegistration,
    Expression<bool>? needsAuthorization,
    Expression<String>? stage,
    Expression<String>? status,
    Expression<String>? latestFeedback,
    Expression<String>? currentObstacle,
    Expression<String>? nextAction,
    Expression<int>? nextFollowAt,
    Expression<int>? lastFollowAt,
    Expression<bool>? isLegacyDefault,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      if (name != null) 'name': name,
      if (owner != null) 'owner': owner,
      if (importance != null) 'importance': importance,
      if (productCategory != null) 'product_category': productCategory,
      if (productModel != null) 'product_model': productModel,
      if (equipmentBrand != null) 'equipment_brand': equipmentBrand,
      if (equipmentModel != null) 'equipment_model': equipmentModel,
      if (estimatedAnnualVolume != null)
        'estimated_annual_volume': estimatedAnnualVolume,
      if (forecastAmountMinor != null)
        'forecast_amount_minor': forecastAmountMinor,
      if (currency != null) 'currency': currency,
      if (probabilityPercent != null) 'probability_percent': probabilityPercent,
      if (expectedCloseAt != null) 'expected_close_at': expectedCloseAt,
      if (currentSupplier != null) 'current_supplier': currentSupplier,
      if (currentPurchaseBrand != null)
        'current_purchase_brand': currentPurchaseBrand,
      if (currentPurchasePriceMinor != null)
        'current_purchase_price_minor': currentPurchasePriceMinor,
      if (supplierStability != null) 'supplier_stability': supplierStability,
      if (supplierProblem != null) 'supplier_problem': supplierProblem,
      if (changeWillingness != null) 'change_willingness': changeWillingness,
      if (substitutionDifficulty != null)
        'substitution_difficulty': substitutionDifficulty,
      if (latestQuoteMinor != null) 'latest_quote_minor': latestQuoteMinor,
      if (targetPriceMinor != null) 'target_price_minor': targetPriceMinor,
      if (entryPoint != null) 'entry_point': entryPoint,
      if (investmentAdvice != null) 'investment_advice': investmentAdvice,
      if (needsSample != null) 'needs_sample': needsSample,
      if (needsRegistration != null) 'needs_registration': needsRegistration,
      if (needsAuthorization != null) 'needs_authorization': needsAuthorization,
      if (stage != null) 'stage': stage,
      if (status != null) 'status': status,
      if (latestFeedback != null) 'latest_feedback': latestFeedback,
      if (currentObstacle != null) 'current_obstacle': currentObstacle,
      if (nextAction != null) 'next_action': nextAction,
      if (nextFollowAt != null) 'next_follow_at': nextFollowAt,
      if (lastFollowAt != null) 'last_follow_at': lastFollowAt,
      if (isLegacyDefault != null) 'is_legacy_default': isLegacyDefault,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  OpportunitiesCompanion copyWith({
    Value<int>? id,
    Value<int>? customerId,
    Value<String>? name,
    Value<String>? owner,
    Value<String>? importance,
    Value<String?>? productCategory,
    Value<String?>? productModel,
    Value<String?>? equipmentBrand,
    Value<String?>? equipmentModel,
    Value<int?>? estimatedAnnualVolume,
    Value<int?>? forecastAmountMinor,
    Value<String>? currency,
    Value<int?>? probabilityPercent,
    Value<int?>? expectedCloseAt,
    Value<String?>? currentSupplier,
    Value<String?>? currentPurchaseBrand,
    Value<int?>? currentPurchasePriceMinor,
    Value<String?>? supplierStability,
    Value<String?>? supplierProblem,
    Value<String?>? changeWillingness,
    Value<String?>? substitutionDifficulty,
    Value<int?>? latestQuoteMinor,
    Value<int?>? targetPriceMinor,
    Value<String?>? entryPoint,
    Value<String?>? investmentAdvice,
    Value<bool>? needsSample,
    Value<bool>? needsRegistration,
    Value<bool>? needsAuthorization,
    Value<String>? stage,
    Value<String>? status,
    Value<String?>? latestFeedback,
    Value<String?>? currentObstacle,
    Value<String?>? nextAction,
    Value<int?>? nextFollowAt,
    Value<int?>? lastFollowAt,
    Value<bool>? isLegacyDefault,
    Value<int>? createdAt,
    Value<int>? updatedAt,
  }) {
    return OpportunitiesCompanion(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      name: name ?? this.name,
      owner: owner ?? this.owner,
      importance: importance ?? this.importance,
      productCategory: productCategory ?? this.productCategory,
      productModel: productModel ?? this.productModel,
      equipmentBrand: equipmentBrand ?? this.equipmentBrand,
      equipmentModel: equipmentModel ?? this.equipmentModel,
      estimatedAnnualVolume:
          estimatedAnnualVolume ?? this.estimatedAnnualVolume,
      forecastAmountMinor: forecastAmountMinor ?? this.forecastAmountMinor,
      currency: currency ?? this.currency,
      probabilityPercent: probabilityPercent ?? this.probabilityPercent,
      expectedCloseAt: expectedCloseAt ?? this.expectedCloseAt,
      currentSupplier: currentSupplier ?? this.currentSupplier,
      currentPurchaseBrand: currentPurchaseBrand ?? this.currentPurchaseBrand,
      currentPurchasePriceMinor:
          currentPurchasePriceMinor ?? this.currentPurchasePriceMinor,
      supplierStability: supplierStability ?? this.supplierStability,
      supplierProblem: supplierProblem ?? this.supplierProblem,
      changeWillingness: changeWillingness ?? this.changeWillingness,
      substitutionDifficulty:
          substitutionDifficulty ?? this.substitutionDifficulty,
      latestQuoteMinor: latestQuoteMinor ?? this.latestQuoteMinor,
      targetPriceMinor: targetPriceMinor ?? this.targetPriceMinor,
      entryPoint: entryPoint ?? this.entryPoint,
      investmentAdvice: investmentAdvice ?? this.investmentAdvice,
      needsSample: needsSample ?? this.needsSample,
      needsRegistration: needsRegistration ?? this.needsRegistration,
      needsAuthorization: needsAuthorization ?? this.needsAuthorization,
      stage: stage ?? this.stage,
      status: status ?? this.status,
      latestFeedback: latestFeedback ?? this.latestFeedback,
      currentObstacle: currentObstacle ?? this.currentObstacle,
      nextAction: nextAction ?? this.nextAction,
      nextFollowAt: nextFollowAt ?? this.nextFollowAt,
      lastFollowAt: lastFollowAt ?? this.lastFollowAt,
      isLegacyDefault: isLegacyDefault ?? this.isLegacyDefault,
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
    if (owner.present) {
      map['owner'] = Variable<String>(owner.value);
    }
    if (importance.present) {
      map['importance'] = Variable<String>(importance.value);
    }
    if (productCategory.present) {
      map['product_category'] = Variable<String>(productCategory.value);
    }
    if (productModel.present) {
      map['product_model'] = Variable<String>(productModel.value);
    }
    if (equipmentBrand.present) {
      map['equipment_brand'] = Variable<String>(equipmentBrand.value);
    }
    if (equipmentModel.present) {
      map['equipment_model'] = Variable<String>(equipmentModel.value);
    }
    if (estimatedAnnualVolume.present) {
      map['estimated_annual_volume'] = Variable<int>(
        estimatedAnnualVolume.value,
      );
    }
    if (forecastAmountMinor.present) {
      map['forecast_amount_minor'] = Variable<int>(forecastAmountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (probabilityPercent.present) {
      map['probability_percent'] = Variable<int>(probabilityPercent.value);
    }
    if (expectedCloseAt.present) {
      map['expected_close_at'] = Variable<int>(expectedCloseAt.value);
    }
    if (currentSupplier.present) {
      map['current_supplier'] = Variable<String>(currentSupplier.value);
    }
    if (currentPurchaseBrand.present) {
      map['current_purchase_brand'] = Variable<String>(
        currentPurchaseBrand.value,
      );
    }
    if (currentPurchasePriceMinor.present) {
      map['current_purchase_price_minor'] = Variable<int>(
        currentPurchasePriceMinor.value,
      );
    }
    if (supplierStability.present) {
      map['supplier_stability'] = Variable<String>(supplierStability.value);
    }
    if (supplierProblem.present) {
      map['supplier_problem'] = Variable<String>(supplierProblem.value);
    }
    if (changeWillingness.present) {
      map['change_willingness'] = Variable<String>(changeWillingness.value);
    }
    if (substitutionDifficulty.present) {
      map['substitution_difficulty'] = Variable<String>(
        substitutionDifficulty.value,
      );
    }
    if (latestQuoteMinor.present) {
      map['latest_quote_minor'] = Variable<int>(latestQuoteMinor.value);
    }
    if (targetPriceMinor.present) {
      map['target_price_minor'] = Variable<int>(targetPriceMinor.value);
    }
    if (entryPoint.present) {
      map['entry_point'] = Variable<String>(entryPoint.value);
    }
    if (investmentAdvice.present) {
      map['investment_advice'] = Variable<String>(investmentAdvice.value);
    }
    if (needsSample.present) {
      map['needs_sample'] = Variable<bool>(needsSample.value);
    }
    if (needsRegistration.present) {
      map['needs_registration'] = Variable<bool>(needsRegistration.value);
    }
    if (needsAuthorization.present) {
      map['needs_authorization'] = Variable<bool>(needsAuthorization.value);
    }
    if (stage.present) {
      map['stage'] = Variable<String>(stage.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (latestFeedback.present) {
      map['latest_feedback'] = Variable<String>(latestFeedback.value);
    }
    if (currentObstacle.present) {
      map['current_obstacle'] = Variable<String>(currentObstacle.value);
    }
    if (nextAction.present) {
      map['next_action'] = Variable<String>(nextAction.value);
    }
    if (nextFollowAt.present) {
      map['next_follow_at'] = Variable<int>(nextFollowAt.value);
    }
    if (lastFollowAt.present) {
      map['last_follow_at'] = Variable<int>(lastFollowAt.value);
    }
    if (isLegacyDefault.present) {
      map['is_legacy_default'] = Variable<bool>(isLegacyDefault.value);
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
    return (StringBuffer('OpportunitiesCompanion(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('name: $name, ')
          ..write('owner: $owner, ')
          ..write('importance: $importance, ')
          ..write('productCategory: $productCategory, ')
          ..write('productModel: $productModel, ')
          ..write('equipmentBrand: $equipmentBrand, ')
          ..write('equipmentModel: $equipmentModel, ')
          ..write('estimatedAnnualVolume: $estimatedAnnualVolume, ')
          ..write('forecastAmountMinor: $forecastAmountMinor, ')
          ..write('currency: $currency, ')
          ..write('probabilityPercent: $probabilityPercent, ')
          ..write('expectedCloseAt: $expectedCloseAt, ')
          ..write('currentSupplier: $currentSupplier, ')
          ..write('currentPurchaseBrand: $currentPurchaseBrand, ')
          ..write('currentPurchasePriceMinor: $currentPurchasePriceMinor, ')
          ..write('supplierStability: $supplierStability, ')
          ..write('supplierProblem: $supplierProblem, ')
          ..write('changeWillingness: $changeWillingness, ')
          ..write('substitutionDifficulty: $substitutionDifficulty, ')
          ..write('latestQuoteMinor: $latestQuoteMinor, ')
          ..write('targetPriceMinor: $targetPriceMinor, ')
          ..write('entryPoint: $entryPoint, ')
          ..write('investmentAdvice: $investmentAdvice, ')
          ..write('needsSample: $needsSample, ')
          ..write('needsRegistration: $needsRegistration, ')
          ..write('needsAuthorization: $needsAuthorization, ')
          ..write('stage: $stage, ')
          ..write('status: $status, ')
          ..write('latestFeedback: $latestFeedback, ')
          ..write('currentObstacle: $currentObstacle, ')
          ..write('nextAction: $nextAction, ')
          ..write('nextFollowAt: $nextFollowAt, ')
          ..write('lastFollowAt: $lastFollowAt, ')
          ..write('isLegacyDefault: $isLegacyDefault, ')
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
  static const VerificationMeta _opportunityIdMeta = const VerificationMeta(
    'opportunityId',
  );
  @override
  late final GeneratedColumn<int> opportunityId = GeneratedColumn<int>(
    'opportunity_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES opportunities (id) ON DELETE SET NULL',
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
  static const VerificationMeta _feedbackMeta = const VerificationMeta(
    'feedback',
  );
  @override
  late final GeneratedColumn<String> feedback = GeneratedColumn<String>(
    'feedback',
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextActionMeta = const VerificationMeta(
    'nextAction',
  );
  @override
  late final GeneratedColumn<String> nextAction = GeneratedColumn<String>(
    'next_action',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextFollowAtMeta = const VerificationMeta(
    'nextFollowAt',
  );
  @override
  late final GeneratedColumn<int> nextFollowAt = GeneratedColumn<int>(
    'next_follow_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pauseReasonMeta = const VerificationMeta(
    'pauseReason',
  );
  @override
  late final GeneratedColumn<String> pauseReason = GeneratedColumn<String>(
    'pause_reason',
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
    opportunityId,
    occurredAt,
    method,
    content,
    conclusion,
    feedback,
    stage,
    nextAction,
    nextFollowAt,
    pauseReason,
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
    if (data.containsKey('opportunity_id')) {
      context.handle(
        _opportunityIdMeta,
        opportunityId.isAcceptableOrUnknown(
          data['opportunity_id']!,
          _opportunityIdMeta,
        ),
      );
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
    if (data.containsKey('feedback')) {
      context.handle(
        _feedbackMeta,
        feedback.isAcceptableOrUnknown(data['feedback']!, _feedbackMeta),
      );
    }
    if (data.containsKey('stage')) {
      context.handle(
        _stageMeta,
        stage.isAcceptableOrUnknown(data['stage']!, _stageMeta),
      );
    }
    if (data.containsKey('next_action')) {
      context.handle(
        _nextActionMeta,
        nextAction.isAcceptableOrUnknown(data['next_action']!, _nextActionMeta),
      );
    }
    if (data.containsKey('next_follow_at')) {
      context.handle(
        _nextFollowAtMeta,
        nextFollowAt.isAcceptableOrUnknown(
          data['next_follow_at']!,
          _nextFollowAtMeta,
        ),
      );
    }
    if (data.containsKey('pause_reason')) {
      context.handle(
        _pauseReasonMeta,
        pauseReason.isAcceptableOrUnknown(
          data['pause_reason']!,
          _pauseReasonMeta,
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
      opportunityId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}opportunity_id'],
      ),
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
      feedback: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feedback'],
      ),
      stage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stage'],
      ),
      nextAction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}next_action'],
      ),
      nextFollowAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_follow_at'],
      ),
      pauseReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pause_reason'],
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

  /// v2 项目归属。为兼容原表结构保持可空，迁移会为全部旧记录回填。
  final int? opportunityId;

  /// 发生时间，UTC 毫秒。可以补录过去的跟进，所以不用 createdAt 代替。
  final int occurredAt;

  /// 跟进方式，存 FollowMethod.dbValue。
  final String method;

  /// 沟通内容。
  final String content;

  /// 本次结论。可空，不是每次跟进都有明确结论。
  final String? conclusion;

  /// v3 五字段跟进快照。保持可空以兼容历史记录与无损增量迁移。
  final String? feedback;

  /// 保存跟进发生时的项目阶段，不随后续项目更新而变化。
  final String? stage;
  final String? nextAction;
  final int? nextFollowAt;

  /// 选择暂不跟进时的原因，与 [nextFollowAt] 互斥。
  final String? pauseReason;
  final int createdAt;
  final int updatedAt;
  const FollowupRow({
    required this.id,
    required this.customerId,
    this.opportunityId,
    required this.occurredAt,
    required this.method,
    required this.content,
    this.conclusion,
    this.feedback,
    this.stage,
    this.nextAction,
    this.nextFollowAt,
    this.pauseReason,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['customer_id'] = Variable<int>(customerId);
    if (!nullToAbsent || opportunityId != null) {
      map['opportunity_id'] = Variable<int>(opportunityId);
    }
    map['occurred_at'] = Variable<int>(occurredAt);
    map['method'] = Variable<String>(method);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || conclusion != null) {
      map['conclusion'] = Variable<String>(conclusion);
    }
    if (!nullToAbsent || feedback != null) {
      map['feedback'] = Variable<String>(feedback);
    }
    if (!nullToAbsent || stage != null) {
      map['stage'] = Variable<String>(stage);
    }
    if (!nullToAbsent || nextAction != null) {
      map['next_action'] = Variable<String>(nextAction);
    }
    if (!nullToAbsent || nextFollowAt != null) {
      map['next_follow_at'] = Variable<int>(nextFollowAt);
    }
    if (!nullToAbsent || pauseReason != null) {
      map['pause_reason'] = Variable<String>(pauseReason);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  FollowupsCompanion toCompanion(bool nullToAbsent) {
    return FollowupsCompanion(
      id: Value(id),
      customerId: Value(customerId),
      opportunityId: opportunityId == null && nullToAbsent
          ? const Value.absent()
          : Value(opportunityId),
      occurredAt: Value(occurredAt),
      method: Value(method),
      content: Value(content),
      conclusion: conclusion == null && nullToAbsent
          ? const Value.absent()
          : Value(conclusion),
      feedback: feedback == null && nullToAbsent
          ? const Value.absent()
          : Value(feedback),
      stage: stage == null && nullToAbsent
          ? const Value.absent()
          : Value(stage),
      nextAction: nextAction == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAction),
      nextFollowAt: nextFollowAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextFollowAt),
      pauseReason: pauseReason == null && nullToAbsent
          ? const Value.absent()
          : Value(pauseReason),
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
      opportunityId: serializer.fromJson<int?>(json['opportunityId']),
      occurredAt: serializer.fromJson<int>(json['occurredAt']),
      method: serializer.fromJson<String>(json['method']),
      content: serializer.fromJson<String>(json['content']),
      conclusion: serializer.fromJson<String?>(json['conclusion']),
      feedback: serializer.fromJson<String?>(json['feedback']),
      stage: serializer.fromJson<String?>(json['stage']),
      nextAction: serializer.fromJson<String?>(json['nextAction']),
      nextFollowAt: serializer.fromJson<int?>(json['nextFollowAt']),
      pauseReason: serializer.fromJson<String?>(json['pauseReason']),
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
      'opportunityId': serializer.toJson<int?>(opportunityId),
      'occurredAt': serializer.toJson<int>(occurredAt),
      'method': serializer.toJson<String>(method),
      'content': serializer.toJson<String>(content),
      'conclusion': serializer.toJson<String?>(conclusion),
      'feedback': serializer.toJson<String?>(feedback),
      'stage': serializer.toJson<String?>(stage),
      'nextAction': serializer.toJson<String?>(nextAction),
      'nextFollowAt': serializer.toJson<int?>(nextFollowAt),
      'pauseReason': serializer.toJson<String?>(pauseReason),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  FollowupRow copyWith({
    int? id,
    int? customerId,
    Value<int?> opportunityId = const Value.absent(),
    int? occurredAt,
    String? method,
    String? content,
    Value<String?> conclusion = const Value.absent(),
    Value<String?> feedback = const Value.absent(),
    Value<String?> stage = const Value.absent(),
    Value<String?> nextAction = const Value.absent(),
    Value<int?> nextFollowAt = const Value.absent(),
    Value<String?> pauseReason = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => FollowupRow(
    id: id ?? this.id,
    customerId: customerId ?? this.customerId,
    opportunityId: opportunityId.present
        ? opportunityId.value
        : this.opportunityId,
    occurredAt: occurredAt ?? this.occurredAt,
    method: method ?? this.method,
    content: content ?? this.content,
    conclusion: conclusion.present ? conclusion.value : this.conclusion,
    feedback: feedback.present ? feedback.value : this.feedback,
    stage: stage.present ? stage.value : this.stage,
    nextAction: nextAction.present ? nextAction.value : this.nextAction,
    nextFollowAt: nextFollowAt.present ? nextFollowAt.value : this.nextFollowAt,
    pauseReason: pauseReason.present ? pauseReason.value : this.pauseReason,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  FollowupRow copyWithCompanion(FollowupsCompanion data) {
    return FollowupRow(
      id: data.id.present ? data.id.value : this.id,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      opportunityId: data.opportunityId.present
          ? data.opportunityId.value
          : this.opportunityId,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      method: data.method.present ? data.method.value : this.method,
      content: data.content.present ? data.content.value : this.content,
      conclusion: data.conclusion.present
          ? data.conclusion.value
          : this.conclusion,
      feedback: data.feedback.present ? data.feedback.value : this.feedback,
      stage: data.stage.present ? data.stage.value : this.stage,
      nextAction: data.nextAction.present
          ? data.nextAction.value
          : this.nextAction,
      nextFollowAt: data.nextFollowAt.present
          ? data.nextFollowAt.value
          : this.nextFollowAt,
      pauseReason: data.pauseReason.present
          ? data.pauseReason.value
          : this.pauseReason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FollowupRow(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('opportunityId: $opportunityId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('method: $method, ')
          ..write('content: $content, ')
          ..write('conclusion: $conclusion, ')
          ..write('feedback: $feedback, ')
          ..write('stage: $stage, ')
          ..write('nextAction: $nextAction, ')
          ..write('nextFollowAt: $nextFollowAt, ')
          ..write('pauseReason: $pauseReason, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    customerId,
    opportunityId,
    occurredAt,
    method,
    content,
    conclusion,
    feedback,
    stage,
    nextAction,
    nextFollowAt,
    pauseReason,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FollowupRow &&
          other.id == this.id &&
          other.customerId == this.customerId &&
          other.opportunityId == this.opportunityId &&
          other.occurredAt == this.occurredAt &&
          other.method == this.method &&
          other.content == this.content &&
          other.conclusion == this.conclusion &&
          other.feedback == this.feedback &&
          other.stage == this.stage &&
          other.nextAction == this.nextAction &&
          other.nextFollowAt == this.nextFollowAt &&
          other.pauseReason == this.pauseReason &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FollowupsCompanion extends UpdateCompanion<FollowupRow> {
  final Value<int> id;
  final Value<int> customerId;
  final Value<int?> opportunityId;
  final Value<int> occurredAt;
  final Value<String> method;
  final Value<String> content;
  final Value<String?> conclusion;
  final Value<String?> feedback;
  final Value<String?> stage;
  final Value<String?> nextAction;
  final Value<int?> nextFollowAt;
  final Value<String?> pauseReason;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  const FollowupsCompanion({
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.opportunityId = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.method = const Value.absent(),
    this.content = const Value.absent(),
    this.conclusion = const Value.absent(),
    this.feedback = const Value.absent(),
    this.stage = const Value.absent(),
    this.nextAction = const Value.absent(),
    this.nextFollowAt = const Value.absent(),
    this.pauseReason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  FollowupsCompanion.insert({
    this.id = const Value.absent(),
    required int customerId,
    this.opportunityId = const Value.absent(),
    required int occurredAt,
    required String method,
    required String content,
    this.conclusion = const Value.absent(),
    this.feedback = const Value.absent(),
    this.stage = const Value.absent(),
    this.nextAction = const Value.absent(),
    this.nextFollowAt = const Value.absent(),
    this.pauseReason = const Value.absent(),
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
    Expression<int>? opportunityId,
    Expression<int>? occurredAt,
    Expression<String>? method,
    Expression<String>? content,
    Expression<String>? conclusion,
    Expression<String>? feedback,
    Expression<String>? stage,
    Expression<String>? nextAction,
    Expression<int>? nextFollowAt,
    Expression<String>? pauseReason,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      if (opportunityId != null) 'opportunity_id': opportunityId,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (method != null) 'method': method,
      if (content != null) 'content': content,
      if (conclusion != null) 'conclusion': conclusion,
      if (feedback != null) 'feedback': feedback,
      if (stage != null) 'stage': stage,
      if (nextAction != null) 'next_action': nextAction,
      if (nextFollowAt != null) 'next_follow_at': nextFollowAt,
      if (pauseReason != null) 'pause_reason': pauseReason,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  FollowupsCompanion copyWith({
    Value<int>? id,
    Value<int>? customerId,
    Value<int?>? opportunityId,
    Value<int>? occurredAt,
    Value<String>? method,
    Value<String>? content,
    Value<String?>? conclusion,
    Value<String?>? feedback,
    Value<String?>? stage,
    Value<String?>? nextAction,
    Value<int?>? nextFollowAt,
    Value<String?>? pauseReason,
    Value<int>? createdAt,
    Value<int>? updatedAt,
  }) {
    return FollowupsCompanion(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      opportunityId: opportunityId ?? this.opportunityId,
      occurredAt: occurredAt ?? this.occurredAt,
      method: method ?? this.method,
      content: content ?? this.content,
      conclusion: conclusion ?? this.conclusion,
      feedback: feedback ?? this.feedback,
      stage: stage ?? this.stage,
      nextAction: nextAction ?? this.nextAction,
      nextFollowAt: nextFollowAt ?? this.nextFollowAt,
      pauseReason: pauseReason ?? this.pauseReason,
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
    if (opportunityId.present) {
      map['opportunity_id'] = Variable<int>(opportunityId.value);
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
    if (feedback.present) {
      map['feedback'] = Variable<String>(feedback.value);
    }
    if (stage.present) {
      map['stage'] = Variable<String>(stage.value);
    }
    if (nextAction.present) {
      map['next_action'] = Variable<String>(nextAction.value);
    }
    if (nextFollowAt.present) {
      map['next_follow_at'] = Variable<int>(nextFollowAt.value);
    }
    if (pauseReason.present) {
      map['pause_reason'] = Variable<String>(pauseReason.value);
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
          ..write('opportunityId: $opportunityId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('method: $method, ')
          ..write('content: $content, ')
          ..write('conclusion: $conclusion, ')
          ..write('feedback: $feedback, ')
          ..write('stage: $stage, ')
          ..write('nextAction: $nextAction, ')
          ..write('nextFollowAt: $nextFollowAt, ')
          ..write('pauseReason: $pauseReason, ')
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
  static const VerificationMeta _opportunityIdMeta = const VerificationMeta(
    'opportunityId',
  );
  @override
  late final GeneratedColumn<int> opportunityId = GeneratedColumn<int>(
    'opportunity_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES opportunities (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _sourceTypeMeta = const VerificationMeta(
    'sourceType',
  );
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
    'source_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('legacy'),
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<int> sourceId = GeneratedColumn<int>(
    'source_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ruleKeyMeta = const VerificationMeta(
    'ruleKey',
  );
  @override
  late final GeneratedColumn<String> ruleKey = GeneratedColumn<String>(
    'rule_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _talkingDirectionMeta = const VerificationMeta(
    'talkingDirection',
  );
  @override
  late final GeneratedColumn<String> talkingDirection = GeneratedColumn<String>(
    'talking_direction',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextActionMeta = const VerificationMeta(
    'nextAction',
  );
  @override
  late final GeneratedColumn<String> nextAction = GeneratedColumn<String>(
    'next_action',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ownerMeta = const VerificationMeta('owner');
  @override
  late final GeneratedColumn<String> owner = GeneratedColumn<String>(
    'owner',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('本人'),
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
  static const VerificationMeta _cancelledAtMeta = const VerificationMeta(
    'cancelledAt',
  );
  @override
  late final GeneratedColumn<int> cancelledAt = GeneratedColumn<int>(
    'cancelled_at',
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
    opportunityId,
    sourceType,
    sourceId,
    ruleKey,
    title,
    reason,
    talkingDirection,
    nextAction,
    owner,
    planAt,
    status,
    notifiedAt,
    completedAt,
    cancelledAt,
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
    if (data.containsKey('opportunity_id')) {
      context.handle(
        _opportunityIdMeta,
        opportunityId.isAcceptableOrUnknown(
          data['opportunity_id']!,
          _opportunityIdMeta,
        ),
      );
    }
    if (data.containsKey('source_type')) {
      context.handle(
        _sourceTypeMeta,
        sourceType.isAcceptableOrUnknown(data['source_type']!, _sourceTypeMeta),
      );
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    }
    if (data.containsKey('rule_key')) {
      context.handle(
        _ruleKeyMeta,
        ruleKey.isAcceptableOrUnknown(data['rule_key']!, _ruleKeyMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('talking_direction')) {
      context.handle(
        _talkingDirectionMeta,
        talkingDirection.isAcceptableOrUnknown(
          data['talking_direction']!,
          _talkingDirectionMeta,
        ),
      );
    }
    if (data.containsKey('next_action')) {
      context.handle(
        _nextActionMeta,
        nextAction.isAcceptableOrUnknown(data['next_action']!, _nextActionMeta),
      );
    }
    if (data.containsKey('owner')) {
      context.handle(
        _ownerMeta,
        owner.isAcceptableOrUnknown(data['owner']!, _ownerMeta),
      );
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
    if (data.containsKey('cancelled_at')) {
      context.handle(
        _cancelledAtMeta,
        cancelledAt.isAcceptableOrUnknown(
          data['cancelled_at']!,
          _cancelledAtMeta,
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
      opportunityId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}opportunity_id'],
      ),
      sourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_type'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_id'],
      ),
      ruleKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule_key'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      talkingDirection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}talking_direction'],
      ),
      nextAction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}next_action'],
      ),
      owner: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner'],
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
      cancelledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cancelled_at'],
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

  /// v2 项目归属。为兼容原表结构保持可空，迁移会为全部旧记录回填。
  final int? opportunityId;

  /// 业务来源，存 TaskSourceType.dbValue。
  final String sourceType;

  /// 来源业务记录主键。手工和历史任务为空。
  final int? sourceId;

  /// 自动任务规则稳定键，与 sourceType/sourceId 共同用于去重。
  final String? ruleKey;

  /// 事项标题，如「催合同」。
  final String title;

  /// 任务生成或手工安排的原因。历史任务保持为空。
  final String? reason;

  /// 建议沟通重点，只提供方向，不生成对外消息。
  final String? talkingDirection;

  /// 任务创建时的下一步行动快照。
  final String? nextAction;

  /// 任务负责人快照。单人版默认本人。
  final String owner;

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
  final int? cancelledAt;
  final int createdAt;
  final int updatedAt;
  const FollowPlanRow({
    required this.id,
    required this.customerId,
    this.opportunityId,
    required this.sourceType,
    this.sourceId,
    this.ruleKey,
    required this.title,
    this.reason,
    this.talkingDirection,
    this.nextAction,
    required this.owner,
    required this.planAt,
    required this.status,
    this.notifiedAt,
    this.completedAt,
    this.cancelledAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['customer_id'] = Variable<int>(customerId);
    if (!nullToAbsent || opportunityId != null) {
      map['opportunity_id'] = Variable<int>(opportunityId);
    }
    map['source_type'] = Variable<String>(sourceType);
    if (!nullToAbsent || sourceId != null) {
      map['source_id'] = Variable<int>(sourceId);
    }
    if (!nullToAbsent || ruleKey != null) {
      map['rule_key'] = Variable<String>(ruleKey);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    if (!nullToAbsent || talkingDirection != null) {
      map['talking_direction'] = Variable<String>(talkingDirection);
    }
    if (!nullToAbsent || nextAction != null) {
      map['next_action'] = Variable<String>(nextAction);
    }
    map['owner'] = Variable<String>(owner);
    map['plan_at'] = Variable<int>(planAt);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notifiedAt != null) {
      map['notified_at'] = Variable<int>(notifiedAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    if (!nullToAbsent || cancelledAt != null) {
      map['cancelled_at'] = Variable<int>(cancelledAt);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  FollowPlansCompanion toCompanion(bool nullToAbsent) {
    return FollowPlansCompanion(
      id: Value(id),
      customerId: Value(customerId),
      opportunityId: opportunityId == null && nullToAbsent
          ? const Value.absent()
          : Value(opportunityId),
      sourceType: Value(sourceType),
      sourceId: sourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceId),
      ruleKey: ruleKey == null && nullToAbsent
          ? const Value.absent()
          : Value(ruleKey),
      title: Value(title),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      talkingDirection: talkingDirection == null && nullToAbsent
          ? const Value.absent()
          : Value(talkingDirection),
      nextAction: nextAction == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAction),
      owner: Value(owner),
      planAt: Value(planAt),
      status: Value(status),
      notifiedAt: notifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(notifiedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      cancelledAt: cancelledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(cancelledAt),
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
      opportunityId: serializer.fromJson<int?>(json['opportunityId']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      sourceId: serializer.fromJson<int?>(json['sourceId']),
      ruleKey: serializer.fromJson<String?>(json['ruleKey']),
      title: serializer.fromJson<String>(json['title']),
      reason: serializer.fromJson<String?>(json['reason']),
      talkingDirection: serializer.fromJson<String?>(json['talkingDirection']),
      nextAction: serializer.fromJson<String?>(json['nextAction']),
      owner: serializer.fromJson<String>(json['owner']),
      planAt: serializer.fromJson<int>(json['planAt']),
      status: serializer.fromJson<String>(json['status']),
      notifiedAt: serializer.fromJson<int?>(json['notifiedAt']),
      completedAt: serializer.fromJson<int?>(json['completedAt']),
      cancelledAt: serializer.fromJson<int?>(json['cancelledAt']),
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
      'opportunityId': serializer.toJson<int?>(opportunityId),
      'sourceType': serializer.toJson<String>(sourceType),
      'sourceId': serializer.toJson<int?>(sourceId),
      'ruleKey': serializer.toJson<String?>(ruleKey),
      'title': serializer.toJson<String>(title),
      'reason': serializer.toJson<String?>(reason),
      'talkingDirection': serializer.toJson<String?>(talkingDirection),
      'nextAction': serializer.toJson<String?>(nextAction),
      'owner': serializer.toJson<String>(owner),
      'planAt': serializer.toJson<int>(planAt),
      'status': serializer.toJson<String>(status),
      'notifiedAt': serializer.toJson<int?>(notifiedAt),
      'completedAt': serializer.toJson<int?>(completedAt),
      'cancelledAt': serializer.toJson<int?>(cancelledAt),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  FollowPlanRow copyWith({
    int? id,
    int? customerId,
    Value<int?> opportunityId = const Value.absent(),
    String? sourceType,
    Value<int?> sourceId = const Value.absent(),
    Value<String?> ruleKey = const Value.absent(),
    String? title,
    Value<String?> reason = const Value.absent(),
    Value<String?> talkingDirection = const Value.absent(),
    Value<String?> nextAction = const Value.absent(),
    String? owner,
    int? planAt,
    String? status,
    Value<int?> notifiedAt = const Value.absent(),
    Value<int?> completedAt = const Value.absent(),
    Value<int?> cancelledAt = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => FollowPlanRow(
    id: id ?? this.id,
    customerId: customerId ?? this.customerId,
    opportunityId: opportunityId.present
        ? opportunityId.value
        : this.opportunityId,
    sourceType: sourceType ?? this.sourceType,
    sourceId: sourceId.present ? sourceId.value : this.sourceId,
    ruleKey: ruleKey.present ? ruleKey.value : this.ruleKey,
    title: title ?? this.title,
    reason: reason.present ? reason.value : this.reason,
    talkingDirection: talkingDirection.present
        ? talkingDirection.value
        : this.talkingDirection,
    nextAction: nextAction.present ? nextAction.value : this.nextAction,
    owner: owner ?? this.owner,
    planAt: planAt ?? this.planAt,
    status: status ?? this.status,
    notifiedAt: notifiedAt.present ? notifiedAt.value : this.notifiedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    cancelledAt: cancelledAt.present ? cancelledAt.value : this.cancelledAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  FollowPlanRow copyWithCompanion(FollowPlansCompanion data) {
    return FollowPlanRow(
      id: data.id.present ? data.id.value : this.id,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      opportunityId: data.opportunityId.present
          ? data.opportunityId.value
          : this.opportunityId,
      sourceType: data.sourceType.present
          ? data.sourceType.value
          : this.sourceType,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      ruleKey: data.ruleKey.present ? data.ruleKey.value : this.ruleKey,
      title: data.title.present ? data.title.value : this.title,
      reason: data.reason.present ? data.reason.value : this.reason,
      talkingDirection: data.talkingDirection.present
          ? data.talkingDirection.value
          : this.talkingDirection,
      nextAction: data.nextAction.present
          ? data.nextAction.value
          : this.nextAction,
      owner: data.owner.present ? data.owner.value : this.owner,
      planAt: data.planAt.present ? data.planAt.value : this.planAt,
      status: data.status.present ? data.status.value : this.status,
      notifiedAt: data.notifiedAt.present
          ? data.notifiedAt.value
          : this.notifiedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      cancelledAt: data.cancelledAt.present
          ? data.cancelledAt.value
          : this.cancelledAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FollowPlanRow(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('opportunityId: $opportunityId, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceId: $sourceId, ')
          ..write('ruleKey: $ruleKey, ')
          ..write('title: $title, ')
          ..write('reason: $reason, ')
          ..write('talkingDirection: $talkingDirection, ')
          ..write('nextAction: $nextAction, ')
          ..write('owner: $owner, ')
          ..write('planAt: $planAt, ')
          ..write('status: $status, ')
          ..write('notifiedAt: $notifiedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('cancelledAt: $cancelledAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    customerId,
    opportunityId,
    sourceType,
    sourceId,
    ruleKey,
    title,
    reason,
    talkingDirection,
    nextAction,
    owner,
    planAt,
    status,
    notifiedAt,
    completedAt,
    cancelledAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FollowPlanRow &&
          other.id == this.id &&
          other.customerId == this.customerId &&
          other.opportunityId == this.opportunityId &&
          other.sourceType == this.sourceType &&
          other.sourceId == this.sourceId &&
          other.ruleKey == this.ruleKey &&
          other.title == this.title &&
          other.reason == this.reason &&
          other.talkingDirection == this.talkingDirection &&
          other.nextAction == this.nextAction &&
          other.owner == this.owner &&
          other.planAt == this.planAt &&
          other.status == this.status &&
          other.notifiedAt == this.notifiedAt &&
          other.completedAt == this.completedAt &&
          other.cancelledAt == this.cancelledAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FollowPlansCompanion extends UpdateCompanion<FollowPlanRow> {
  final Value<int> id;
  final Value<int> customerId;
  final Value<int?> opportunityId;
  final Value<String> sourceType;
  final Value<int?> sourceId;
  final Value<String?> ruleKey;
  final Value<String> title;
  final Value<String?> reason;
  final Value<String?> talkingDirection;
  final Value<String?> nextAction;
  final Value<String> owner;
  final Value<int> planAt;
  final Value<String> status;
  final Value<int?> notifiedAt;
  final Value<int?> completedAt;
  final Value<int?> cancelledAt;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  const FollowPlansCompanion({
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.opportunityId = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.ruleKey = const Value.absent(),
    this.title = const Value.absent(),
    this.reason = const Value.absent(),
    this.talkingDirection = const Value.absent(),
    this.nextAction = const Value.absent(),
    this.owner = const Value.absent(),
    this.planAt = const Value.absent(),
    this.status = const Value.absent(),
    this.notifiedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.cancelledAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  FollowPlansCompanion.insert({
    this.id = const Value.absent(),
    required int customerId,
    this.opportunityId = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.ruleKey = const Value.absent(),
    required String title,
    this.reason = const Value.absent(),
    this.talkingDirection = const Value.absent(),
    this.nextAction = const Value.absent(),
    this.owner = const Value.absent(),
    required int planAt,
    this.status = const Value.absent(),
    this.notifiedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.cancelledAt = const Value.absent(),
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
    Expression<int>? opportunityId,
    Expression<String>? sourceType,
    Expression<int>? sourceId,
    Expression<String>? ruleKey,
    Expression<String>? title,
    Expression<String>? reason,
    Expression<String>? talkingDirection,
    Expression<String>? nextAction,
    Expression<String>? owner,
    Expression<int>? planAt,
    Expression<String>? status,
    Expression<int>? notifiedAt,
    Expression<int>? completedAt,
    Expression<int>? cancelledAt,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      if (opportunityId != null) 'opportunity_id': opportunityId,
      if (sourceType != null) 'source_type': sourceType,
      if (sourceId != null) 'source_id': sourceId,
      if (ruleKey != null) 'rule_key': ruleKey,
      if (title != null) 'title': title,
      if (reason != null) 'reason': reason,
      if (talkingDirection != null) 'talking_direction': talkingDirection,
      if (nextAction != null) 'next_action': nextAction,
      if (owner != null) 'owner': owner,
      if (planAt != null) 'plan_at': planAt,
      if (status != null) 'status': status,
      if (notifiedAt != null) 'notified_at': notifiedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (cancelledAt != null) 'cancelled_at': cancelledAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  FollowPlansCompanion copyWith({
    Value<int>? id,
    Value<int>? customerId,
    Value<int?>? opportunityId,
    Value<String>? sourceType,
    Value<int?>? sourceId,
    Value<String?>? ruleKey,
    Value<String>? title,
    Value<String?>? reason,
    Value<String?>? talkingDirection,
    Value<String?>? nextAction,
    Value<String>? owner,
    Value<int>? planAt,
    Value<String>? status,
    Value<int?>? notifiedAt,
    Value<int?>? completedAt,
    Value<int?>? cancelledAt,
    Value<int>? createdAt,
    Value<int>? updatedAt,
  }) {
    return FollowPlansCompanion(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      opportunityId: opportunityId ?? this.opportunityId,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      ruleKey: ruleKey ?? this.ruleKey,
      title: title ?? this.title,
      reason: reason ?? this.reason,
      talkingDirection: talkingDirection ?? this.talkingDirection,
      nextAction: nextAction ?? this.nextAction,
      owner: owner ?? this.owner,
      planAt: planAt ?? this.planAt,
      status: status ?? this.status,
      notifiedAt: notifiedAt ?? this.notifiedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
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
    if (opportunityId.present) {
      map['opportunity_id'] = Variable<int>(opportunityId.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<int>(sourceId.value);
    }
    if (ruleKey.present) {
      map['rule_key'] = Variable<String>(ruleKey.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (talkingDirection.present) {
      map['talking_direction'] = Variable<String>(talkingDirection.value);
    }
    if (nextAction.present) {
      map['next_action'] = Variable<String>(nextAction.value);
    }
    if (owner.present) {
      map['owner'] = Variable<String>(owner.value);
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
    if (cancelledAt.present) {
      map['cancelled_at'] = Variable<int>(cancelledAt.value);
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
          ..write('opportunityId: $opportunityId, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceId: $sourceId, ')
          ..write('ruleKey: $ruleKey, ')
          ..write('title: $title, ')
          ..write('reason: $reason, ')
          ..write('talkingDirection: $talkingDirection, ')
          ..write('nextAction: $nextAction, ')
          ..write('owner: $owner, ')
          ..write('planAt: $planAt, ')
          ..write('status: $status, ')
          ..write('notifiedAt: $notifiedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('cancelledAt: $cancelledAt, ')
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
  static const VerificationMeta _opportunityIdMeta = const VerificationMeta(
    'opportunityId',
  );
  @override
  late final GeneratedColumn<int> opportunityId = GeneratedColumn<int>(
    'opportunity_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES opportunities (id) ON DELETE SET NULL',
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
    opportunityId,
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
    if (data.containsKey('opportunity_id')) {
      context.handle(
        _opportunityIdMeta,
        opportunityId.isAcceptableOrUnknown(
          data['opportunity_id']!,
          _opportunityIdMeta,
        ),
      );
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
      opportunityId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}opportunity_id'],
      ),
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

  /// v2 项目归属。为兼容原表结构保持可空，迁移会为全部旧记录回填。
  final int? opportunityId;

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
    this.opportunityId,
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
    if (!nullToAbsent || opportunityId != null) {
      map['opportunity_id'] = Variable<int>(opportunityId);
    }
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
      opportunityId: opportunityId == null && nullToAbsent
          ? const Value.absent()
          : Value(opportunityId),
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
      opportunityId: serializer.fromJson<int?>(json['opportunityId']),
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
      'opportunityId': serializer.toJson<int?>(opportunityId),
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
    Value<int?> opportunityId = const Value.absent(),
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
    opportunityId: opportunityId.present
        ? opportunityId.value
        : this.opportunityId,
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
      opportunityId: data.opportunityId.present
          ? data.opportunityId.value
          : this.opportunityId,
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
          ..write('opportunityId: $opportunityId, ')
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
    opportunityId,
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
          other.opportunityId == this.opportunityId &&
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
  final Value<int?> opportunityId;
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
    this.opportunityId = const Value.absent(),
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
    this.opportunityId = const Value.absent(),
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
    Expression<int>? opportunityId,
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
      if (opportunityId != null) 'opportunity_id': opportunityId,
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
    Value<int?>? opportunityId,
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
      opportunityId: opportunityId ?? this.opportunityId,
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
    if (opportunityId.present) {
      map['opportunity_id'] = Variable<int>(opportunityId.value);
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
          ..write('opportunityId: $opportunityId, ')
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

class $QuotesTable extends Quotes with TableInfo<$QuotesTable, QuoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuotesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _opportunityIdMeta = const VerificationMeta(
    'opportunityId',
  );
  @override
  late final GeneratedColumn<int> opportunityId = GeneratedColumn<int>(
    'opportunity_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES opportunities (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _quoteNoMeta = const VerificationMeta(
    'quoteNo',
  );
  @override
  late final GeneratedColumn<String> quoteNo = GeneratedColumn<String>(
    'quote_no',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productModelMeta = const VerificationMeta(
    'productModel',
  );
  @override
  late final GeneratedColumn<String> productModel = GeneratedColumn<String>(
    'product_model',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('USD'),
  );
  static const VerificationMeta _unitPriceMinorMeta = const VerificationMeta(
    'unitPriceMinor',
  );
  @override
  late final GeneratedColumn<int> unitPriceMinor = GeneratedColumn<int>(
    'unit_price_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalAmountMinorMeta = const VerificationMeta(
    'totalAmountMinor',
  );
  @override
  late final GeneratedColumn<int> totalAmountMinor = GeneratedColumn<int>(
    'total_amount_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quotedAtMeta = const VerificationMeta(
    'quotedAt',
  );
  @override
  late final GeneratedColumn<int> quotedAt = GeneratedColumn<int>(
    'quoted_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _validUntilMeta = const VerificationMeta(
    'validUntil',
  );
  @override
  late final GeneratedColumn<int> validUntil = GeneratedColumn<int>(
    'valid_until',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customerReceivedMeta = const VerificationMeta(
    'customerReceived',
  );
  @override
  late final GeneratedColumn<bool> customerReceived = GeneratedColumn<bool>(
    'customer_received',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("customer_received" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _customerFeedbackMeta = const VerificationMeta(
    'customerFeedback',
  );
  @override
  late final GeneratedColumn<String> customerFeedback = GeneratedColumn<String>(
    'customer_feedback',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextFollowAtMeta = const VerificationMeta(
    'nextFollowAt',
  );
  @override
  late final GeneratedColumn<int> nextFollowAt = GeneratedColumn<int>(
    'next_follow_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resultMeta = const VerificationMeta('result');
  @override
  late final GeneratedColumn<String> result = GeneratedColumn<String>(
    'result',
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
    opportunityId,
    quoteNo,
    version,
    productModel,
    quantity,
    currency,
    unitPriceMinor,
    totalAmountMinor,
    quotedAt,
    validUntil,
    customerReceived,
    customerFeedback,
    nextFollowAt,
    result,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quotes';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuoteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('opportunity_id')) {
      context.handle(
        _opportunityIdMeta,
        opportunityId.isAcceptableOrUnknown(
          data['opportunity_id']!,
          _opportunityIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_opportunityIdMeta);
    }
    if (data.containsKey('quote_no')) {
      context.handle(
        _quoteNoMeta,
        quoteNo.isAcceptableOrUnknown(data['quote_no']!, _quoteNoMeta),
      );
    } else if (isInserting) {
      context.missing(_quoteNoMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('product_model')) {
      context.handle(
        _productModelMeta,
        productModel.isAcceptableOrUnknown(
          data['product_model']!,
          _productModelMeta,
        ),
      );
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('unit_price_minor')) {
      context.handle(
        _unitPriceMinorMeta,
        unitPriceMinor.isAcceptableOrUnknown(
          data['unit_price_minor']!,
          _unitPriceMinorMeta,
        ),
      );
    }
    if (data.containsKey('total_amount_minor')) {
      context.handle(
        _totalAmountMinorMeta,
        totalAmountMinor.isAcceptableOrUnknown(
          data['total_amount_minor']!,
          _totalAmountMinorMeta,
        ),
      );
    }
    if (data.containsKey('quoted_at')) {
      context.handle(
        _quotedAtMeta,
        quotedAt.isAcceptableOrUnknown(data['quoted_at']!, _quotedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_quotedAtMeta);
    }
    if (data.containsKey('valid_until')) {
      context.handle(
        _validUntilMeta,
        validUntil.isAcceptableOrUnknown(data['valid_until']!, _validUntilMeta),
      );
    }
    if (data.containsKey('customer_received')) {
      context.handle(
        _customerReceivedMeta,
        customerReceived.isAcceptableOrUnknown(
          data['customer_received']!,
          _customerReceivedMeta,
        ),
      );
    }
    if (data.containsKey('customer_feedback')) {
      context.handle(
        _customerFeedbackMeta,
        customerFeedback.isAcceptableOrUnknown(
          data['customer_feedback']!,
          _customerFeedbackMeta,
        ),
      );
    }
    if (data.containsKey('next_follow_at')) {
      context.handle(
        _nextFollowAtMeta,
        nextFollowAt.isAcceptableOrUnknown(
          data['next_follow_at']!,
          _nextFollowAtMeta,
        ),
      );
    }
    if (data.containsKey('result')) {
      context.handle(
        _resultMeta,
        result.isAcceptableOrUnknown(data['result']!, _resultMeta),
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
  QuoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuoteRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      opportunityId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}opportunity_id'],
      )!,
      quoteNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quote_no'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      productModel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_model'],
      ),
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      unitPriceMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_price_minor'],
      ),
      totalAmountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_amount_minor'],
      ),
      quotedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quoted_at'],
      )!,
      validUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}valid_until'],
      ),
      customerReceived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}customer_received'],
      )!,
      customerFeedback: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_feedback'],
      ),
      nextFollowAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_follow_at'],
      ),
      result: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result'],
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
  $QuotesTable createAlias(String alias) {
    return $QuotesTable(attachedDatabase, alias);
  }
}

class QuoteRow extends DataClass implements Insertable<QuoteRow> {
  final int id;
  final int opportunityId;
  final String quoteNo;
  final int version;
  final String? productModel;
  final int quantity;
  final String currency;
  final int? unitPriceMinor;
  final int? totalAmountMinor;
  final int quotedAt;
  final int? validUntil;
  final bool customerReceived;
  final String? customerFeedback;
  final int? nextFollowAt;
  final String? result;
  final int createdAt;
  final int updatedAt;
  const QuoteRow({
    required this.id,
    required this.opportunityId,
    required this.quoteNo,
    required this.version,
    this.productModel,
    required this.quantity,
    required this.currency,
    this.unitPriceMinor,
    this.totalAmountMinor,
    required this.quotedAt,
    this.validUntil,
    required this.customerReceived,
    this.customerFeedback,
    this.nextFollowAt,
    this.result,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['opportunity_id'] = Variable<int>(opportunityId);
    map['quote_no'] = Variable<String>(quoteNo);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || productModel != null) {
      map['product_model'] = Variable<String>(productModel);
    }
    map['quantity'] = Variable<int>(quantity);
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || unitPriceMinor != null) {
      map['unit_price_minor'] = Variable<int>(unitPriceMinor);
    }
    if (!nullToAbsent || totalAmountMinor != null) {
      map['total_amount_minor'] = Variable<int>(totalAmountMinor);
    }
    map['quoted_at'] = Variable<int>(quotedAt);
    if (!nullToAbsent || validUntil != null) {
      map['valid_until'] = Variable<int>(validUntil);
    }
    map['customer_received'] = Variable<bool>(customerReceived);
    if (!nullToAbsent || customerFeedback != null) {
      map['customer_feedback'] = Variable<String>(customerFeedback);
    }
    if (!nullToAbsent || nextFollowAt != null) {
      map['next_follow_at'] = Variable<int>(nextFollowAt);
    }
    if (!nullToAbsent || result != null) {
      map['result'] = Variable<String>(result);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  QuotesCompanion toCompanion(bool nullToAbsent) {
    return QuotesCompanion(
      id: Value(id),
      opportunityId: Value(opportunityId),
      quoteNo: Value(quoteNo),
      version: Value(version),
      productModel: productModel == null && nullToAbsent
          ? const Value.absent()
          : Value(productModel),
      quantity: Value(quantity),
      currency: Value(currency),
      unitPriceMinor: unitPriceMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(unitPriceMinor),
      totalAmountMinor: totalAmountMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(totalAmountMinor),
      quotedAt: Value(quotedAt),
      validUntil: validUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(validUntil),
      customerReceived: Value(customerReceived),
      customerFeedback: customerFeedback == null && nullToAbsent
          ? const Value.absent()
          : Value(customerFeedback),
      nextFollowAt: nextFollowAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextFollowAt),
      result: result == null && nullToAbsent
          ? const Value.absent()
          : Value(result),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory QuoteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuoteRow(
      id: serializer.fromJson<int>(json['id']),
      opportunityId: serializer.fromJson<int>(json['opportunityId']),
      quoteNo: serializer.fromJson<String>(json['quoteNo']),
      version: serializer.fromJson<int>(json['version']),
      productModel: serializer.fromJson<String?>(json['productModel']),
      quantity: serializer.fromJson<int>(json['quantity']),
      currency: serializer.fromJson<String>(json['currency']),
      unitPriceMinor: serializer.fromJson<int?>(json['unitPriceMinor']),
      totalAmountMinor: serializer.fromJson<int?>(json['totalAmountMinor']),
      quotedAt: serializer.fromJson<int>(json['quotedAt']),
      validUntil: serializer.fromJson<int?>(json['validUntil']),
      customerReceived: serializer.fromJson<bool>(json['customerReceived']),
      customerFeedback: serializer.fromJson<String?>(json['customerFeedback']),
      nextFollowAt: serializer.fromJson<int?>(json['nextFollowAt']),
      result: serializer.fromJson<String?>(json['result']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'opportunityId': serializer.toJson<int>(opportunityId),
      'quoteNo': serializer.toJson<String>(quoteNo),
      'version': serializer.toJson<int>(version),
      'productModel': serializer.toJson<String?>(productModel),
      'quantity': serializer.toJson<int>(quantity),
      'currency': serializer.toJson<String>(currency),
      'unitPriceMinor': serializer.toJson<int?>(unitPriceMinor),
      'totalAmountMinor': serializer.toJson<int?>(totalAmountMinor),
      'quotedAt': serializer.toJson<int>(quotedAt),
      'validUntil': serializer.toJson<int?>(validUntil),
      'customerReceived': serializer.toJson<bool>(customerReceived),
      'customerFeedback': serializer.toJson<String?>(customerFeedback),
      'nextFollowAt': serializer.toJson<int?>(nextFollowAt),
      'result': serializer.toJson<String?>(result),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  QuoteRow copyWith({
    int? id,
    int? opportunityId,
    String? quoteNo,
    int? version,
    Value<String?> productModel = const Value.absent(),
    int? quantity,
    String? currency,
    Value<int?> unitPriceMinor = const Value.absent(),
    Value<int?> totalAmountMinor = const Value.absent(),
    int? quotedAt,
    Value<int?> validUntil = const Value.absent(),
    bool? customerReceived,
    Value<String?> customerFeedback = const Value.absent(),
    Value<int?> nextFollowAt = const Value.absent(),
    Value<String?> result = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => QuoteRow(
    id: id ?? this.id,
    opportunityId: opportunityId ?? this.opportunityId,
    quoteNo: quoteNo ?? this.quoteNo,
    version: version ?? this.version,
    productModel: productModel.present ? productModel.value : this.productModel,
    quantity: quantity ?? this.quantity,
    currency: currency ?? this.currency,
    unitPriceMinor: unitPriceMinor.present
        ? unitPriceMinor.value
        : this.unitPriceMinor,
    totalAmountMinor: totalAmountMinor.present
        ? totalAmountMinor.value
        : this.totalAmountMinor,
    quotedAt: quotedAt ?? this.quotedAt,
    validUntil: validUntil.present ? validUntil.value : this.validUntil,
    customerReceived: customerReceived ?? this.customerReceived,
    customerFeedback: customerFeedback.present
        ? customerFeedback.value
        : this.customerFeedback,
    nextFollowAt: nextFollowAt.present ? nextFollowAt.value : this.nextFollowAt,
    result: result.present ? result.value : this.result,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  QuoteRow copyWithCompanion(QuotesCompanion data) {
    return QuoteRow(
      id: data.id.present ? data.id.value : this.id,
      opportunityId: data.opportunityId.present
          ? data.opportunityId.value
          : this.opportunityId,
      quoteNo: data.quoteNo.present ? data.quoteNo.value : this.quoteNo,
      version: data.version.present ? data.version.value : this.version,
      productModel: data.productModel.present
          ? data.productModel.value
          : this.productModel,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      currency: data.currency.present ? data.currency.value : this.currency,
      unitPriceMinor: data.unitPriceMinor.present
          ? data.unitPriceMinor.value
          : this.unitPriceMinor,
      totalAmountMinor: data.totalAmountMinor.present
          ? data.totalAmountMinor.value
          : this.totalAmountMinor,
      quotedAt: data.quotedAt.present ? data.quotedAt.value : this.quotedAt,
      validUntil: data.validUntil.present
          ? data.validUntil.value
          : this.validUntil,
      customerReceived: data.customerReceived.present
          ? data.customerReceived.value
          : this.customerReceived,
      customerFeedback: data.customerFeedback.present
          ? data.customerFeedback.value
          : this.customerFeedback,
      nextFollowAt: data.nextFollowAt.present
          ? data.nextFollowAt.value
          : this.nextFollowAt,
      result: data.result.present ? data.result.value : this.result,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuoteRow(')
          ..write('id: $id, ')
          ..write('opportunityId: $opportunityId, ')
          ..write('quoteNo: $quoteNo, ')
          ..write('version: $version, ')
          ..write('productModel: $productModel, ')
          ..write('quantity: $quantity, ')
          ..write('currency: $currency, ')
          ..write('unitPriceMinor: $unitPriceMinor, ')
          ..write('totalAmountMinor: $totalAmountMinor, ')
          ..write('quotedAt: $quotedAt, ')
          ..write('validUntil: $validUntil, ')
          ..write('customerReceived: $customerReceived, ')
          ..write('customerFeedback: $customerFeedback, ')
          ..write('nextFollowAt: $nextFollowAt, ')
          ..write('result: $result, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    opportunityId,
    quoteNo,
    version,
    productModel,
    quantity,
    currency,
    unitPriceMinor,
    totalAmountMinor,
    quotedAt,
    validUntil,
    customerReceived,
    customerFeedback,
    nextFollowAt,
    result,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuoteRow &&
          other.id == this.id &&
          other.opportunityId == this.opportunityId &&
          other.quoteNo == this.quoteNo &&
          other.version == this.version &&
          other.productModel == this.productModel &&
          other.quantity == this.quantity &&
          other.currency == this.currency &&
          other.unitPriceMinor == this.unitPriceMinor &&
          other.totalAmountMinor == this.totalAmountMinor &&
          other.quotedAt == this.quotedAt &&
          other.validUntil == this.validUntil &&
          other.customerReceived == this.customerReceived &&
          other.customerFeedback == this.customerFeedback &&
          other.nextFollowAt == this.nextFollowAt &&
          other.result == this.result &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class QuotesCompanion extends UpdateCompanion<QuoteRow> {
  final Value<int> id;
  final Value<int> opportunityId;
  final Value<String> quoteNo;
  final Value<int> version;
  final Value<String?> productModel;
  final Value<int> quantity;
  final Value<String> currency;
  final Value<int?> unitPriceMinor;
  final Value<int?> totalAmountMinor;
  final Value<int> quotedAt;
  final Value<int?> validUntil;
  final Value<bool> customerReceived;
  final Value<String?> customerFeedback;
  final Value<int?> nextFollowAt;
  final Value<String?> result;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  const QuotesCompanion({
    this.id = const Value.absent(),
    this.opportunityId = const Value.absent(),
    this.quoteNo = const Value.absent(),
    this.version = const Value.absent(),
    this.productModel = const Value.absent(),
    this.quantity = const Value.absent(),
    this.currency = const Value.absent(),
    this.unitPriceMinor = const Value.absent(),
    this.totalAmountMinor = const Value.absent(),
    this.quotedAt = const Value.absent(),
    this.validUntil = const Value.absent(),
    this.customerReceived = const Value.absent(),
    this.customerFeedback = const Value.absent(),
    this.nextFollowAt = const Value.absent(),
    this.result = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  QuotesCompanion.insert({
    this.id = const Value.absent(),
    required int opportunityId,
    required String quoteNo,
    required int version,
    this.productModel = const Value.absent(),
    required int quantity,
    this.currency = const Value.absent(),
    this.unitPriceMinor = const Value.absent(),
    this.totalAmountMinor = const Value.absent(),
    required int quotedAt,
    this.validUntil = const Value.absent(),
    this.customerReceived = const Value.absent(),
    this.customerFeedback = const Value.absent(),
    this.nextFollowAt = const Value.absent(),
    this.result = const Value.absent(),
    required int createdAt,
    required int updatedAt,
  }) : opportunityId = Value(opportunityId),
       quoteNo = Value(quoteNo),
       version = Value(version),
       quantity = Value(quantity),
       quotedAt = Value(quotedAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<QuoteRow> custom({
    Expression<int>? id,
    Expression<int>? opportunityId,
    Expression<String>? quoteNo,
    Expression<int>? version,
    Expression<String>? productModel,
    Expression<int>? quantity,
    Expression<String>? currency,
    Expression<int>? unitPriceMinor,
    Expression<int>? totalAmountMinor,
    Expression<int>? quotedAt,
    Expression<int>? validUntil,
    Expression<bool>? customerReceived,
    Expression<String>? customerFeedback,
    Expression<int>? nextFollowAt,
    Expression<String>? result,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (opportunityId != null) 'opportunity_id': opportunityId,
      if (quoteNo != null) 'quote_no': quoteNo,
      if (version != null) 'version': version,
      if (productModel != null) 'product_model': productModel,
      if (quantity != null) 'quantity': quantity,
      if (currency != null) 'currency': currency,
      if (unitPriceMinor != null) 'unit_price_minor': unitPriceMinor,
      if (totalAmountMinor != null) 'total_amount_minor': totalAmountMinor,
      if (quotedAt != null) 'quoted_at': quotedAt,
      if (validUntil != null) 'valid_until': validUntil,
      if (customerReceived != null) 'customer_received': customerReceived,
      if (customerFeedback != null) 'customer_feedback': customerFeedback,
      if (nextFollowAt != null) 'next_follow_at': nextFollowAt,
      if (result != null) 'result': result,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  QuotesCompanion copyWith({
    Value<int>? id,
    Value<int>? opportunityId,
    Value<String>? quoteNo,
    Value<int>? version,
    Value<String?>? productModel,
    Value<int>? quantity,
    Value<String>? currency,
    Value<int?>? unitPriceMinor,
    Value<int?>? totalAmountMinor,
    Value<int>? quotedAt,
    Value<int?>? validUntil,
    Value<bool>? customerReceived,
    Value<String?>? customerFeedback,
    Value<int?>? nextFollowAt,
    Value<String?>? result,
    Value<int>? createdAt,
    Value<int>? updatedAt,
  }) {
    return QuotesCompanion(
      id: id ?? this.id,
      opportunityId: opportunityId ?? this.opportunityId,
      quoteNo: quoteNo ?? this.quoteNo,
      version: version ?? this.version,
      productModel: productModel ?? this.productModel,
      quantity: quantity ?? this.quantity,
      currency: currency ?? this.currency,
      unitPriceMinor: unitPriceMinor ?? this.unitPriceMinor,
      totalAmountMinor: totalAmountMinor ?? this.totalAmountMinor,
      quotedAt: quotedAt ?? this.quotedAt,
      validUntil: validUntil ?? this.validUntil,
      customerReceived: customerReceived ?? this.customerReceived,
      customerFeedback: customerFeedback ?? this.customerFeedback,
      nextFollowAt: nextFollowAt ?? this.nextFollowAt,
      result: result ?? this.result,
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
    if (opportunityId.present) {
      map['opportunity_id'] = Variable<int>(opportunityId.value);
    }
    if (quoteNo.present) {
      map['quote_no'] = Variable<String>(quoteNo.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (productModel.present) {
      map['product_model'] = Variable<String>(productModel.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (unitPriceMinor.present) {
      map['unit_price_minor'] = Variable<int>(unitPriceMinor.value);
    }
    if (totalAmountMinor.present) {
      map['total_amount_minor'] = Variable<int>(totalAmountMinor.value);
    }
    if (quotedAt.present) {
      map['quoted_at'] = Variable<int>(quotedAt.value);
    }
    if (validUntil.present) {
      map['valid_until'] = Variable<int>(validUntil.value);
    }
    if (customerReceived.present) {
      map['customer_received'] = Variable<bool>(customerReceived.value);
    }
    if (customerFeedback.present) {
      map['customer_feedback'] = Variable<String>(customerFeedback.value);
    }
    if (nextFollowAt.present) {
      map['next_follow_at'] = Variable<int>(nextFollowAt.value);
    }
    if (result.present) {
      map['result'] = Variable<String>(result.value);
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
    return (StringBuffer('QuotesCompanion(')
          ..write('id: $id, ')
          ..write('opportunityId: $opportunityId, ')
          ..write('quoteNo: $quoteNo, ')
          ..write('version: $version, ')
          ..write('productModel: $productModel, ')
          ..write('quantity: $quantity, ')
          ..write('currency: $currency, ')
          ..write('unitPriceMinor: $unitPriceMinor, ')
          ..write('totalAmountMinor: $totalAmountMinor, ')
          ..write('quotedAt: $quotedAt, ')
          ..write('validUntil: $validUntil, ')
          ..write('customerReceived: $customerReceived, ')
          ..write('customerFeedback: $customerFeedback, ')
          ..write('nextFollowAt: $nextFollowAt, ')
          ..write('result: $result, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SamplesTable extends Samples with TableInfo<$SamplesTable, SampleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SamplesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _opportunityIdMeta = const VerificationMeta(
    'opportunityId',
  );
  @override
  late final GeneratedColumn<int> opportunityId = GeneratedColumn<int>(
    'opportunity_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES opportunities (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sampleModelMeta = const VerificationMeta(
    'sampleModel',
  );
  @override
  late final GeneratedColumn<String> sampleModel = GeneratedColumn<String>(
    'sample_model',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feeMinorMeta = const VerificationMeta(
    'feeMinor',
  );
  @override
  late final GeneratedColumn<int> feeMinor = GeneratedColumn<int>(
    'fee_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sentAtMeta = const VerificationMeta('sentAt');
  @override
  late final GeneratedColumn<int> sentAt = GeneratedColumn<int>(
    'sent_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _carrierMeta = const VerificationMeta(
    'carrier',
  );
  @override
  late final GeneratedColumn<String> carrier = GeneratedColumn<String>(
    'carrier',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trackingNoMeta = const VerificationMeta(
    'trackingNo',
  );
  @override
  late final GeneratedColumn<String> trackingNo = GeneratedColumn<String>(
    'tracking_no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deliveredAtMeta = const VerificationMeta(
    'deliveredAt',
  );
  @override
  late final GeneratedColumn<int> deliveredAt = GeneratedColumn<int>(
    'delivered_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recipientMeta = const VerificationMeta(
    'recipient',
  );
  @override
  late final GeneratedColumn<String> recipient = GeneratedColumn<String>(
    'recipient',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _testerMeta = const VerificationMeta('tester');
  @override
  late final GeneratedColumn<String> tester = GeneratedColumn<String>(
    'tester',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plannedTestAtMeta = const VerificationMeta(
    'plannedTestAt',
  );
  @override
  late final GeneratedColumn<int> plannedTestAt = GeneratedColumn<int>(
    'planned_test_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
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
    defaultValue: const Constant('preparing'),
  );
  static const VerificationMeta _testResultMeta = const VerificationMeta(
    'testResult',
  );
  @override
  late final GeneratedColumn<String> testResult = GeneratedColumn<String>(
    'test_result',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextActionMeta = const VerificationMeta(
    'nextAction',
  );
  @override
  late final GeneratedColumn<String> nextAction = GeneratedColumn<String>(
    'next_action',
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
    opportunityId,
    sampleModel,
    quantity,
    feeMinor,
    sentAt,
    carrier,
    trackingNo,
    deliveredAt,
    recipient,
    tester,
    plannedTestAt,
    status,
    testResult,
    nextAction,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'samples';
  @override
  VerificationContext validateIntegrity(
    Insertable<SampleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('opportunity_id')) {
      context.handle(
        _opportunityIdMeta,
        opportunityId.isAcceptableOrUnknown(
          data['opportunity_id']!,
          _opportunityIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_opportunityIdMeta);
    }
    if (data.containsKey('sample_model')) {
      context.handle(
        _sampleModelMeta,
        sampleModel.isAcceptableOrUnknown(
          data['sample_model']!,
          _sampleModelMeta,
        ),
      );
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('fee_minor')) {
      context.handle(
        _feeMinorMeta,
        feeMinor.isAcceptableOrUnknown(data['fee_minor']!, _feeMinorMeta),
      );
    }
    if (data.containsKey('sent_at')) {
      context.handle(
        _sentAtMeta,
        sentAt.isAcceptableOrUnknown(data['sent_at']!, _sentAtMeta),
      );
    }
    if (data.containsKey('carrier')) {
      context.handle(
        _carrierMeta,
        carrier.isAcceptableOrUnknown(data['carrier']!, _carrierMeta),
      );
    }
    if (data.containsKey('tracking_no')) {
      context.handle(
        _trackingNoMeta,
        trackingNo.isAcceptableOrUnknown(data['tracking_no']!, _trackingNoMeta),
      );
    }
    if (data.containsKey('delivered_at')) {
      context.handle(
        _deliveredAtMeta,
        deliveredAt.isAcceptableOrUnknown(
          data['delivered_at']!,
          _deliveredAtMeta,
        ),
      );
    }
    if (data.containsKey('recipient')) {
      context.handle(
        _recipientMeta,
        recipient.isAcceptableOrUnknown(data['recipient']!, _recipientMeta),
      );
    }
    if (data.containsKey('tester')) {
      context.handle(
        _testerMeta,
        tester.isAcceptableOrUnknown(data['tester']!, _testerMeta),
      );
    }
    if (data.containsKey('planned_test_at')) {
      context.handle(
        _plannedTestAtMeta,
        plannedTestAt.isAcceptableOrUnknown(
          data['planned_test_at']!,
          _plannedTestAtMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('test_result')) {
      context.handle(
        _testResultMeta,
        testResult.isAcceptableOrUnknown(data['test_result']!, _testResultMeta),
      );
    }
    if (data.containsKey('next_action')) {
      context.handle(
        _nextActionMeta,
        nextAction.isAcceptableOrUnknown(data['next_action']!, _nextActionMeta),
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
  SampleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SampleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      opportunityId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}opportunity_id'],
      )!,
      sampleModel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sample_model'],
      ),
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      feeMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fee_minor'],
      ),
      sentAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sent_at'],
      ),
      carrier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}carrier'],
      ),
      trackingNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tracking_no'],
      ),
      deliveredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}delivered_at'],
      ),
      recipient: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipient'],
      ),
      tester: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tester'],
      ),
      plannedTestAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_test_at'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      testResult: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}test_result'],
      ),
      nextAction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}next_action'],
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
  $SamplesTable createAlias(String alias) {
    return $SamplesTable(attachedDatabase, alias);
  }
}

class SampleRow extends DataClass implements Insertable<SampleRow> {
  final int id;
  final int opportunityId;
  final String? sampleModel;
  final int quantity;
  final int? feeMinor;
  final int? sentAt;
  final String? carrier;
  final String? trackingNo;
  final int? deliveredAt;
  final String? recipient;
  final String? tester;
  final int? plannedTestAt;
  final String status;
  final String? testResult;
  final String? nextAction;
  final int createdAt;
  final int updatedAt;
  const SampleRow({
    required this.id,
    required this.opportunityId,
    this.sampleModel,
    required this.quantity,
    this.feeMinor,
    this.sentAt,
    this.carrier,
    this.trackingNo,
    this.deliveredAt,
    this.recipient,
    this.tester,
    this.plannedTestAt,
    required this.status,
    this.testResult,
    this.nextAction,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['opportunity_id'] = Variable<int>(opportunityId);
    if (!nullToAbsent || sampleModel != null) {
      map['sample_model'] = Variable<String>(sampleModel);
    }
    map['quantity'] = Variable<int>(quantity);
    if (!nullToAbsent || feeMinor != null) {
      map['fee_minor'] = Variable<int>(feeMinor);
    }
    if (!nullToAbsent || sentAt != null) {
      map['sent_at'] = Variable<int>(sentAt);
    }
    if (!nullToAbsent || carrier != null) {
      map['carrier'] = Variable<String>(carrier);
    }
    if (!nullToAbsent || trackingNo != null) {
      map['tracking_no'] = Variable<String>(trackingNo);
    }
    if (!nullToAbsent || deliveredAt != null) {
      map['delivered_at'] = Variable<int>(deliveredAt);
    }
    if (!nullToAbsent || recipient != null) {
      map['recipient'] = Variable<String>(recipient);
    }
    if (!nullToAbsent || tester != null) {
      map['tester'] = Variable<String>(tester);
    }
    if (!nullToAbsent || plannedTestAt != null) {
      map['planned_test_at'] = Variable<int>(plannedTestAt);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || testResult != null) {
      map['test_result'] = Variable<String>(testResult);
    }
    if (!nullToAbsent || nextAction != null) {
      map['next_action'] = Variable<String>(nextAction);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  SamplesCompanion toCompanion(bool nullToAbsent) {
    return SamplesCompanion(
      id: Value(id),
      opportunityId: Value(opportunityId),
      sampleModel: sampleModel == null && nullToAbsent
          ? const Value.absent()
          : Value(sampleModel),
      quantity: Value(quantity),
      feeMinor: feeMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(feeMinor),
      sentAt: sentAt == null && nullToAbsent
          ? const Value.absent()
          : Value(sentAt),
      carrier: carrier == null && nullToAbsent
          ? const Value.absent()
          : Value(carrier),
      trackingNo: trackingNo == null && nullToAbsent
          ? const Value.absent()
          : Value(trackingNo),
      deliveredAt: deliveredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveredAt),
      recipient: recipient == null && nullToAbsent
          ? const Value.absent()
          : Value(recipient),
      tester: tester == null && nullToAbsent
          ? const Value.absent()
          : Value(tester),
      plannedTestAt: plannedTestAt == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedTestAt),
      status: Value(status),
      testResult: testResult == null && nullToAbsent
          ? const Value.absent()
          : Value(testResult),
      nextAction: nextAction == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAction),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SampleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SampleRow(
      id: serializer.fromJson<int>(json['id']),
      opportunityId: serializer.fromJson<int>(json['opportunityId']),
      sampleModel: serializer.fromJson<String?>(json['sampleModel']),
      quantity: serializer.fromJson<int>(json['quantity']),
      feeMinor: serializer.fromJson<int?>(json['feeMinor']),
      sentAt: serializer.fromJson<int?>(json['sentAt']),
      carrier: serializer.fromJson<String?>(json['carrier']),
      trackingNo: serializer.fromJson<String?>(json['trackingNo']),
      deliveredAt: serializer.fromJson<int?>(json['deliveredAt']),
      recipient: serializer.fromJson<String?>(json['recipient']),
      tester: serializer.fromJson<String?>(json['tester']),
      plannedTestAt: serializer.fromJson<int?>(json['plannedTestAt']),
      status: serializer.fromJson<String>(json['status']),
      testResult: serializer.fromJson<String?>(json['testResult']),
      nextAction: serializer.fromJson<String?>(json['nextAction']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'opportunityId': serializer.toJson<int>(opportunityId),
      'sampleModel': serializer.toJson<String?>(sampleModel),
      'quantity': serializer.toJson<int>(quantity),
      'feeMinor': serializer.toJson<int?>(feeMinor),
      'sentAt': serializer.toJson<int?>(sentAt),
      'carrier': serializer.toJson<String?>(carrier),
      'trackingNo': serializer.toJson<String?>(trackingNo),
      'deliveredAt': serializer.toJson<int?>(deliveredAt),
      'recipient': serializer.toJson<String?>(recipient),
      'tester': serializer.toJson<String?>(tester),
      'plannedTestAt': serializer.toJson<int?>(plannedTestAt),
      'status': serializer.toJson<String>(status),
      'testResult': serializer.toJson<String?>(testResult),
      'nextAction': serializer.toJson<String?>(nextAction),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  SampleRow copyWith({
    int? id,
    int? opportunityId,
    Value<String?> sampleModel = const Value.absent(),
    int? quantity,
    Value<int?> feeMinor = const Value.absent(),
    Value<int?> sentAt = const Value.absent(),
    Value<String?> carrier = const Value.absent(),
    Value<String?> trackingNo = const Value.absent(),
    Value<int?> deliveredAt = const Value.absent(),
    Value<String?> recipient = const Value.absent(),
    Value<String?> tester = const Value.absent(),
    Value<int?> plannedTestAt = const Value.absent(),
    String? status,
    Value<String?> testResult = const Value.absent(),
    Value<String?> nextAction = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => SampleRow(
    id: id ?? this.id,
    opportunityId: opportunityId ?? this.opportunityId,
    sampleModel: sampleModel.present ? sampleModel.value : this.sampleModel,
    quantity: quantity ?? this.quantity,
    feeMinor: feeMinor.present ? feeMinor.value : this.feeMinor,
    sentAt: sentAt.present ? sentAt.value : this.sentAt,
    carrier: carrier.present ? carrier.value : this.carrier,
    trackingNo: trackingNo.present ? trackingNo.value : this.trackingNo,
    deliveredAt: deliveredAt.present ? deliveredAt.value : this.deliveredAt,
    recipient: recipient.present ? recipient.value : this.recipient,
    tester: tester.present ? tester.value : this.tester,
    plannedTestAt: plannedTestAt.present
        ? plannedTestAt.value
        : this.plannedTestAt,
    status: status ?? this.status,
    testResult: testResult.present ? testResult.value : this.testResult,
    nextAction: nextAction.present ? nextAction.value : this.nextAction,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SampleRow copyWithCompanion(SamplesCompanion data) {
    return SampleRow(
      id: data.id.present ? data.id.value : this.id,
      opportunityId: data.opportunityId.present
          ? data.opportunityId.value
          : this.opportunityId,
      sampleModel: data.sampleModel.present
          ? data.sampleModel.value
          : this.sampleModel,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      feeMinor: data.feeMinor.present ? data.feeMinor.value : this.feeMinor,
      sentAt: data.sentAt.present ? data.sentAt.value : this.sentAt,
      carrier: data.carrier.present ? data.carrier.value : this.carrier,
      trackingNo: data.trackingNo.present
          ? data.trackingNo.value
          : this.trackingNo,
      deliveredAt: data.deliveredAt.present
          ? data.deliveredAt.value
          : this.deliveredAt,
      recipient: data.recipient.present ? data.recipient.value : this.recipient,
      tester: data.tester.present ? data.tester.value : this.tester,
      plannedTestAt: data.plannedTestAt.present
          ? data.plannedTestAt.value
          : this.plannedTestAt,
      status: data.status.present ? data.status.value : this.status,
      testResult: data.testResult.present
          ? data.testResult.value
          : this.testResult,
      nextAction: data.nextAction.present
          ? data.nextAction.value
          : this.nextAction,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SampleRow(')
          ..write('id: $id, ')
          ..write('opportunityId: $opportunityId, ')
          ..write('sampleModel: $sampleModel, ')
          ..write('quantity: $quantity, ')
          ..write('feeMinor: $feeMinor, ')
          ..write('sentAt: $sentAt, ')
          ..write('carrier: $carrier, ')
          ..write('trackingNo: $trackingNo, ')
          ..write('deliveredAt: $deliveredAt, ')
          ..write('recipient: $recipient, ')
          ..write('tester: $tester, ')
          ..write('plannedTestAt: $plannedTestAt, ')
          ..write('status: $status, ')
          ..write('testResult: $testResult, ')
          ..write('nextAction: $nextAction, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    opportunityId,
    sampleModel,
    quantity,
    feeMinor,
    sentAt,
    carrier,
    trackingNo,
    deliveredAt,
    recipient,
    tester,
    plannedTestAt,
    status,
    testResult,
    nextAction,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SampleRow &&
          other.id == this.id &&
          other.opportunityId == this.opportunityId &&
          other.sampleModel == this.sampleModel &&
          other.quantity == this.quantity &&
          other.feeMinor == this.feeMinor &&
          other.sentAt == this.sentAt &&
          other.carrier == this.carrier &&
          other.trackingNo == this.trackingNo &&
          other.deliveredAt == this.deliveredAt &&
          other.recipient == this.recipient &&
          other.tester == this.tester &&
          other.plannedTestAt == this.plannedTestAt &&
          other.status == this.status &&
          other.testResult == this.testResult &&
          other.nextAction == this.nextAction &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SamplesCompanion extends UpdateCompanion<SampleRow> {
  final Value<int> id;
  final Value<int> opportunityId;
  final Value<String?> sampleModel;
  final Value<int> quantity;
  final Value<int?> feeMinor;
  final Value<int?> sentAt;
  final Value<String?> carrier;
  final Value<String?> trackingNo;
  final Value<int?> deliveredAt;
  final Value<String?> recipient;
  final Value<String?> tester;
  final Value<int?> plannedTestAt;
  final Value<String> status;
  final Value<String?> testResult;
  final Value<String?> nextAction;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  const SamplesCompanion({
    this.id = const Value.absent(),
    this.opportunityId = const Value.absent(),
    this.sampleModel = const Value.absent(),
    this.quantity = const Value.absent(),
    this.feeMinor = const Value.absent(),
    this.sentAt = const Value.absent(),
    this.carrier = const Value.absent(),
    this.trackingNo = const Value.absent(),
    this.deliveredAt = const Value.absent(),
    this.recipient = const Value.absent(),
    this.tester = const Value.absent(),
    this.plannedTestAt = const Value.absent(),
    this.status = const Value.absent(),
    this.testResult = const Value.absent(),
    this.nextAction = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SamplesCompanion.insert({
    this.id = const Value.absent(),
    required int opportunityId,
    this.sampleModel = const Value.absent(),
    required int quantity,
    this.feeMinor = const Value.absent(),
    this.sentAt = const Value.absent(),
    this.carrier = const Value.absent(),
    this.trackingNo = const Value.absent(),
    this.deliveredAt = const Value.absent(),
    this.recipient = const Value.absent(),
    this.tester = const Value.absent(),
    this.plannedTestAt = const Value.absent(),
    this.status = const Value.absent(),
    this.testResult = const Value.absent(),
    this.nextAction = const Value.absent(),
    required int createdAt,
    required int updatedAt,
  }) : opportunityId = Value(opportunityId),
       quantity = Value(quantity),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SampleRow> custom({
    Expression<int>? id,
    Expression<int>? opportunityId,
    Expression<String>? sampleModel,
    Expression<int>? quantity,
    Expression<int>? feeMinor,
    Expression<int>? sentAt,
    Expression<String>? carrier,
    Expression<String>? trackingNo,
    Expression<int>? deliveredAt,
    Expression<String>? recipient,
    Expression<String>? tester,
    Expression<int>? plannedTestAt,
    Expression<String>? status,
    Expression<String>? testResult,
    Expression<String>? nextAction,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (opportunityId != null) 'opportunity_id': opportunityId,
      if (sampleModel != null) 'sample_model': sampleModel,
      if (quantity != null) 'quantity': quantity,
      if (feeMinor != null) 'fee_minor': feeMinor,
      if (sentAt != null) 'sent_at': sentAt,
      if (carrier != null) 'carrier': carrier,
      if (trackingNo != null) 'tracking_no': trackingNo,
      if (deliveredAt != null) 'delivered_at': deliveredAt,
      if (recipient != null) 'recipient': recipient,
      if (tester != null) 'tester': tester,
      if (plannedTestAt != null) 'planned_test_at': plannedTestAt,
      if (status != null) 'status': status,
      if (testResult != null) 'test_result': testResult,
      if (nextAction != null) 'next_action': nextAction,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SamplesCompanion copyWith({
    Value<int>? id,
    Value<int>? opportunityId,
    Value<String?>? sampleModel,
    Value<int>? quantity,
    Value<int?>? feeMinor,
    Value<int?>? sentAt,
    Value<String?>? carrier,
    Value<String?>? trackingNo,
    Value<int?>? deliveredAt,
    Value<String?>? recipient,
    Value<String?>? tester,
    Value<int?>? plannedTestAt,
    Value<String>? status,
    Value<String?>? testResult,
    Value<String?>? nextAction,
    Value<int>? createdAt,
    Value<int>? updatedAt,
  }) {
    return SamplesCompanion(
      id: id ?? this.id,
      opportunityId: opportunityId ?? this.opportunityId,
      sampleModel: sampleModel ?? this.sampleModel,
      quantity: quantity ?? this.quantity,
      feeMinor: feeMinor ?? this.feeMinor,
      sentAt: sentAt ?? this.sentAt,
      carrier: carrier ?? this.carrier,
      trackingNo: trackingNo ?? this.trackingNo,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      recipient: recipient ?? this.recipient,
      tester: tester ?? this.tester,
      plannedTestAt: plannedTestAt ?? this.plannedTestAt,
      status: status ?? this.status,
      testResult: testResult ?? this.testResult,
      nextAction: nextAction ?? this.nextAction,
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
    if (opportunityId.present) {
      map['opportunity_id'] = Variable<int>(opportunityId.value);
    }
    if (sampleModel.present) {
      map['sample_model'] = Variable<String>(sampleModel.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (feeMinor.present) {
      map['fee_minor'] = Variable<int>(feeMinor.value);
    }
    if (sentAt.present) {
      map['sent_at'] = Variable<int>(sentAt.value);
    }
    if (carrier.present) {
      map['carrier'] = Variable<String>(carrier.value);
    }
    if (trackingNo.present) {
      map['tracking_no'] = Variable<String>(trackingNo.value);
    }
    if (deliveredAt.present) {
      map['delivered_at'] = Variable<int>(deliveredAt.value);
    }
    if (recipient.present) {
      map['recipient'] = Variable<String>(recipient.value);
    }
    if (tester.present) {
      map['tester'] = Variable<String>(tester.value);
    }
    if (plannedTestAt.present) {
      map['planned_test_at'] = Variable<int>(plannedTestAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (testResult.present) {
      map['test_result'] = Variable<String>(testResult.value);
    }
    if (nextAction.present) {
      map['next_action'] = Variable<String>(nextAction.value);
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
    return (StringBuffer('SamplesCompanion(')
          ..write('id: $id, ')
          ..write('opportunityId: $opportunityId, ')
          ..write('sampleModel: $sampleModel, ')
          ..write('quantity: $quantity, ')
          ..write('feeMinor: $feeMinor, ')
          ..write('sentAt: $sentAt, ')
          ..write('carrier: $carrier, ')
          ..write('trackingNo: $trackingNo, ')
          ..write('deliveredAt: $deliveredAt, ')
          ..write('recipient: $recipient, ')
          ..write('tester: $tester, ')
          ..write('plannedTestAt: $plannedTestAt, ')
          ..write('status: $status, ')
          ..write('testResult: $testResult, ')
          ..write('nextAction: $nextAction, ')
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
  late final $OpportunitiesTable opportunities = $OpportunitiesTable(this);
  late final $ContactsTable contacts = $ContactsTable(this);
  late final $FollowupsTable followups = $FollowupsTable(this);
  late final $FollowPlansTable followPlans = $FollowPlansTable(this);
  late final $OrdersTable orders = $OrdersTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $CustomerTagsTable customerTags = $CustomerTagsTable(this);
  late final $AttachmentsTable attachments = $AttachmentsTable(this);
  late final $QuotesTable quotes = $QuotesTable(this);
  late final $SamplesTable samples = $SamplesTable(this);
  late final CustomerDao customerDao = CustomerDao(this as AppDatabase);
  late final ContactDao contactDao = ContactDao(this as AppDatabase);
  late final FollowupDao followupDao = FollowupDao(this as AppDatabase);
  late final PlanDao planDao = PlanDao(this as AppDatabase);
  late final OrderDao orderDao = OrderDao(this as AppDatabase);
  late final OpportunityDao opportunityDao = OpportunityDao(
    this as AppDatabase,
  );
  late final AttachmentDao attachmentDao = AttachmentDao(this as AppDatabase);
  late final QuoteDao quoteDao = QuoteDao(this as AppDatabase);
  late final SampleDao sampleDao = SampleDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    customers,
    opportunities,
    contacts,
    followups,
    followPlans,
    orders,
    tags,
    customerTags,
    attachments,
    quotes,
    samples,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'customers',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('opportunities', kind: UpdateKind.delete)],
    ),
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
        'opportunities',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('followups', kind: UpdateKind.update)],
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
        'opportunities',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('follow_plans', kind: UpdateKind.update)],
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
        'opportunities',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('orders', kind: UpdateKind.update)],
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
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'opportunities',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('quotes', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'opportunities',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('samples', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CustomersTableCreateCompanionBuilder =
    CustomersCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> company,
      Value<String?> country,
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
      Value<String?> country,
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

  static MultiTypedResultKey<$OpportunitiesTable, List<OpportunityRow>>
  _opportunitiesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.opportunities,
    aliasName: 'customers__id__opportunities__customer_id',
  );

  $$OpportunitiesTableProcessedTableManager get opportunitiesRefs {
    final manager = $$OpportunitiesTableTableManager(
      $_db,
      $_db.opportunities,
    ).filter((f) => f.customerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_opportunitiesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

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

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
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

  Expression<bool> opportunitiesRefs(
    Expression<bool> Function($$OpportunitiesTableFilterComposer f) f,
  ) {
    final $$OpportunitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.opportunities,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OpportunitiesTableFilterComposer(
            $db: $db,
            $table: $db.opportunities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

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

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
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

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

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

  Expression<T> opportunitiesRefs<T extends Object>(
    Expression<T> Function($$OpportunitiesTableAnnotationComposer a) f,
  ) {
    final $$OpportunitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.opportunities,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OpportunitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.opportunities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

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
            bool opportunitiesRefs,
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
                Value<String?> country = const Value.absent(),
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
                country: country,
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
                Value<String?> country = const Value.absent(),
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
                country: country,
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
                opportunitiesRefs = false,
                contactsRefs = false,
                followupsRefs = false,
                followPlansRefs = false,
                ordersRefs = false,
                customerTagsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (opportunitiesRefs) db.opportunities,
                    if (contactsRefs) db.contacts,
                    if (followupsRefs) db.followups,
                    if (followPlansRefs) db.followPlans,
                    if (ordersRefs) db.orders,
                    if (customerTagsRefs) db.customerTags,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (opportunitiesRefs)
                        await $_getPrefetchedData<
                          CustomerRow,
                          $CustomersTable,
                          OpportunityRow
                        >(
                          currentTable: table,
                          referencedTable: $$CustomersTableReferences
                              ._opportunitiesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CustomersTableReferences(
                                db,
                                table,
                                p0,
                              ).opportunitiesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.customerId == item.id,
                              ),
                          typedResults: items,
                        ),
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
        bool opportunitiesRefs,
        bool contactsRefs,
        bool followupsRefs,
        bool followPlansRefs,
        bool ordersRefs,
        bool customerTagsRefs,
      })
    >;
typedef $$OpportunitiesTableCreateCompanionBuilder =
    OpportunitiesCompanion Function({
      Value<int> id,
      required int customerId,
      required String name,
      Value<String> owner,
      Value<String> importance,
      Value<String?> productCategory,
      Value<String?> productModel,
      Value<String?> equipmentBrand,
      Value<String?> equipmentModel,
      Value<int?> estimatedAnnualVolume,
      Value<int?> forecastAmountMinor,
      Value<String> currency,
      Value<int?> probabilityPercent,
      Value<int?> expectedCloseAt,
      Value<String?> currentSupplier,
      Value<String?> currentPurchaseBrand,
      Value<int?> currentPurchasePriceMinor,
      Value<String?> supplierStability,
      Value<String?> supplierProblem,
      Value<String?> changeWillingness,
      Value<String?> substitutionDifficulty,
      Value<int?> latestQuoteMinor,
      Value<int?> targetPriceMinor,
      Value<String?> entryPoint,
      Value<String?> investmentAdvice,
      Value<bool> needsSample,
      Value<bool> needsRegistration,
      Value<bool> needsAuthorization,
      Value<String> stage,
      Value<String> status,
      Value<String?> latestFeedback,
      Value<String?> currentObstacle,
      Value<String?> nextAction,
      Value<int?> nextFollowAt,
      Value<int?> lastFollowAt,
      Value<bool> isLegacyDefault,
      required int createdAt,
      required int updatedAt,
    });
typedef $$OpportunitiesTableUpdateCompanionBuilder =
    OpportunitiesCompanion Function({
      Value<int> id,
      Value<int> customerId,
      Value<String> name,
      Value<String> owner,
      Value<String> importance,
      Value<String?> productCategory,
      Value<String?> productModel,
      Value<String?> equipmentBrand,
      Value<String?> equipmentModel,
      Value<int?> estimatedAnnualVolume,
      Value<int?> forecastAmountMinor,
      Value<String> currency,
      Value<int?> probabilityPercent,
      Value<int?> expectedCloseAt,
      Value<String?> currentSupplier,
      Value<String?> currentPurchaseBrand,
      Value<int?> currentPurchasePriceMinor,
      Value<String?> supplierStability,
      Value<String?> supplierProblem,
      Value<String?> changeWillingness,
      Value<String?> substitutionDifficulty,
      Value<int?> latestQuoteMinor,
      Value<int?> targetPriceMinor,
      Value<String?> entryPoint,
      Value<String?> investmentAdvice,
      Value<bool> needsSample,
      Value<bool> needsRegistration,
      Value<bool> needsAuthorization,
      Value<String> stage,
      Value<String> status,
      Value<String?> latestFeedback,
      Value<String?> currentObstacle,
      Value<String?> nextAction,
      Value<int?> nextFollowAt,
      Value<int?> lastFollowAt,
      Value<bool> isLegacyDefault,
      Value<int> createdAt,
      Value<int> updatedAt,
    });

final class $$OpportunitiesTableReferences
    extends BaseReferences<_$AppDatabase, $OpportunitiesTable, OpportunityRow> {
  $$OpportunitiesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CustomersTable _customerIdTable(_$AppDatabase db) =>
      db.customers.createAlias('opportunities__customer_id__customers__id');

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

  static MultiTypedResultKey<$FollowupsTable, List<FollowupRow>>
  _followupsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.followups,
    aliasName: 'opportunities__id__followups__opportunity_id',
  );

  $$FollowupsTableProcessedTableManager get followupsRefs {
    final manager = $$FollowupsTableTableManager(
      $_db,
      $_db.followups,
    ).filter((f) => f.opportunityId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_followupsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FollowPlansTable, List<FollowPlanRow>>
  _followPlansRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.followPlans,
    aliasName: 'opportunities__id__follow_plans__opportunity_id',
  );

  $$FollowPlansTableProcessedTableManager get followPlansRefs {
    final manager = $$FollowPlansTableTableManager(
      $_db,
      $_db.followPlans,
    ).filter((f) => f.opportunityId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_followPlansRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$OrdersTable, List<OrderRow>> _ordersRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.orders,
    aliasName: 'opportunities__id__orders__opportunity_id',
  );

  $$OrdersTableProcessedTableManager get ordersRefs {
    final manager = $$OrdersTableTableManager(
      $_db,
      $_db.orders,
    ).filter((f) => f.opportunityId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_ordersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$QuotesTable, List<QuoteRow>> _quotesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.quotes,
    aliasName: 'opportunities__id__quotes__opportunity_id',
  );

  $$QuotesTableProcessedTableManager get quotesRefs {
    final manager = $$QuotesTableTableManager(
      $_db,
      $_db.quotes,
    ).filter((f) => f.opportunityId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_quotesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SamplesTable, List<SampleRow>> _samplesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.samples,
    aliasName: 'opportunities__id__samples__opportunity_id',
  );

  $$SamplesTableProcessedTableManager get samplesRefs {
    final manager = $$SamplesTableTableManager(
      $_db,
      $_db.samples,
    ).filter((f) => f.opportunityId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_samplesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$OpportunitiesTableFilterComposer
    extends Composer<_$AppDatabase, $OpportunitiesTable> {
  $$OpportunitiesTableFilterComposer({
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

  ColumnFilters<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get importance => $composableBuilder(
    column: $table.importance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productCategory => $composableBuilder(
    column: $table.productCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productModel => $composableBuilder(
    column: $table.productModel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipmentBrand => $composableBuilder(
    column: $table.equipmentBrand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipmentModel => $composableBuilder(
    column: $table.equipmentModel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedAnnualVolume => $composableBuilder(
    column: $table.estimatedAnnualVolume,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get forecastAmountMinor => $composableBuilder(
    column: $table.forecastAmountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get probabilityPercent => $composableBuilder(
    column: $table.probabilityPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expectedCloseAt => $composableBuilder(
    column: $table.expectedCloseAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentSupplier => $composableBuilder(
    column: $table.currentSupplier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentPurchaseBrand => $composableBuilder(
    column: $table.currentPurchaseBrand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentPurchasePriceMinor => $composableBuilder(
    column: $table.currentPurchasePriceMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supplierStability => $composableBuilder(
    column: $table.supplierStability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supplierProblem => $composableBuilder(
    column: $table.supplierProblem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get changeWillingness => $composableBuilder(
    column: $table.changeWillingness,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get substitutionDifficulty => $composableBuilder(
    column: $table.substitutionDifficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get latestQuoteMinor => $composableBuilder(
    column: $table.latestQuoteMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetPriceMinor => $composableBuilder(
    column: $table.targetPriceMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryPoint => $composableBuilder(
    column: $table.entryPoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get investmentAdvice => $composableBuilder(
    column: $table.investmentAdvice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get needsSample => $composableBuilder(
    column: $table.needsSample,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get needsRegistration => $composableBuilder(
    column: $table.needsRegistration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get needsAuthorization => $composableBuilder(
    column: $table.needsAuthorization,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get latestFeedback => $composableBuilder(
    column: $table.latestFeedback,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentObstacle => $composableBuilder(
    column: $table.currentObstacle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nextAction => $composableBuilder(
    column: $table.nextAction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextFollowAt => $composableBuilder(
    column: $table.nextFollowAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastFollowAt => $composableBuilder(
    column: $table.lastFollowAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLegacyDefault => $composableBuilder(
    column: $table.isLegacyDefault,
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

  Expression<bool> followupsRefs(
    Expression<bool> Function($$FollowupsTableFilterComposer f) f,
  ) {
    final $$FollowupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.followups,
      getReferencedColumn: (t) => t.opportunityId,
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
      getReferencedColumn: (t) => t.opportunityId,
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
      getReferencedColumn: (t) => t.opportunityId,
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

  Expression<bool> quotesRefs(
    Expression<bool> Function($$QuotesTableFilterComposer f) f,
  ) {
    final $$QuotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quotes,
      getReferencedColumn: (t) => t.opportunityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuotesTableFilterComposer(
            $db: $db,
            $table: $db.quotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> samplesRefs(
    Expression<bool> Function($$SamplesTableFilterComposer f) f,
  ) {
    final $$SamplesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.samples,
      getReferencedColumn: (t) => t.opportunityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SamplesTableFilterComposer(
            $db: $db,
            $table: $db.samples,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OpportunitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $OpportunitiesTable> {
  $$OpportunitiesTableOrderingComposer({
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

  ColumnOrderings<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get importance => $composableBuilder(
    column: $table.importance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productCategory => $composableBuilder(
    column: $table.productCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productModel => $composableBuilder(
    column: $table.productModel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipmentBrand => $composableBuilder(
    column: $table.equipmentBrand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipmentModel => $composableBuilder(
    column: $table.equipmentModel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedAnnualVolume => $composableBuilder(
    column: $table.estimatedAnnualVolume,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get forecastAmountMinor => $composableBuilder(
    column: $table.forecastAmountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get probabilityPercent => $composableBuilder(
    column: $table.probabilityPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expectedCloseAt => $composableBuilder(
    column: $table.expectedCloseAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentSupplier => $composableBuilder(
    column: $table.currentSupplier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentPurchaseBrand => $composableBuilder(
    column: $table.currentPurchaseBrand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentPurchasePriceMinor => $composableBuilder(
    column: $table.currentPurchasePriceMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supplierStability => $composableBuilder(
    column: $table.supplierStability,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supplierProblem => $composableBuilder(
    column: $table.supplierProblem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get changeWillingness => $composableBuilder(
    column: $table.changeWillingness,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get substitutionDifficulty => $composableBuilder(
    column: $table.substitutionDifficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get latestQuoteMinor => $composableBuilder(
    column: $table.latestQuoteMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetPriceMinor => $composableBuilder(
    column: $table.targetPriceMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryPoint => $composableBuilder(
    column: $table.entryPoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get investmentAdvice => $composableBuilder(
    column: $table.investmentAdvice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get needsSample => $composableBuilder(
    column: $table.needsSample,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get needsRegistration => $composableBuilder(
    column: $table.needsRegistration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get needsAuthorization => $composableBuilder(
    column: $table.needsAuthorization,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get latestFeedback => $composableBuilder(
    column: $table.latestFeedback,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentObstacle => $composableBuilder(
    column: $table.currentObstacle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nextAction => $composableBuilder(
    column: $table.nextAction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextFollowAt => $composableBuilder(
    column: $table.nextFollowAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastFollowAt => $composableBuilder(
    column: $table.lastFollowAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLegacyDefault => $composableBuilder(
    column: $table.isLegacyDefault,
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

class $$OpportunitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OpportunitiesTable> {
  $$OpportunitiesTableAnnotationComposer({
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

  GeneratedColumn<String> get owner =>
      $composableBuilder(column: $table.owner, builder: (column) => column);

  GeneratedColumn<String> get importance => $composableBuilder(
    column: $table.importance,
    builder: (column) => column,
  );

  GeneratedColumn<String> get productCategory => $composableBuilder(
    column: $table.productCategory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get productModel => $composableBuilder(
    column: $table.productModel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get equipmentBrand => $composableBuilder(
    column: $table.equipmentBrand,
    builder: (column) => column,
  );

  GeneratedColumn<String> get equipmentModel => $composableBuilder(
    column: $table.equipmentModel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get estimatedAnnualVolume => $composableBuilder(
    column: $table.estimatedAnnualVolume,
    builder: (column) => column,
  );

  GeneratedColumn<int> get forecastAmountMinor => $composableBuilder(
    column: $table.forecastAmountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<int> get probabilityPercent => $composableBuilder(
    column: $table.probabilityPercent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get expectedCloseAt => $composableBuilder(
    column: $table.expectedCloseAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currentSupplier => $composableBuilder(
    column: $table.currentSupplier,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currentPurchaseBrand => $composableBuilder(
    column: $table.currentPurchaseBrand,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentPurchasePriceMinor => $composableBuilder(
    column: $table.currentPurchasePriceMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get supplierStability => $composableBuilder(
    column: $table.supplierStability,
    builder: (column) => column,
  );

  GeneratedColumn<String> get supplierProblem => $composableBuilder(
    column: $table.supplierProblem,
    builder: (column) => column,
  );

  GeneratedColumn<String> get changeWillingness => $composableBuilder(
    column: $table.changeWillingness,
    builder: (column) => column,
  );

  GeneratedColumn<String> get substitutionDifficulty => $composableBuilder(
    column: $table.substitutionDifficulty,
    builder: (column) => column,
  );

  GeneratedColumn<int> get latestQuoteMinor => $composableBuilder(
    column: $table.latestQuoteMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetPriceMinor => $composableBuilder(
    column: $table.targetPriceMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entryPoint => $composableBuilder(
    column: $table.entryPoint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get investmentAdvice => $composableBuilder(
    column: $table.investmentAdvice,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get needsSample => $composableBuilder(
    column: $table.needsSample,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get needsRegistration => $composableBuilder(
    column: $table.needsRegistration,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get needsAuthorization => $composableBuilder(
    column: $table.needsAuthorization,
    builder: (column) => column,
  );

  GeneratedColumn<String> get stage =>
      $composableBuilder(column: $table.stage, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get latestFeedback => $composableBuilder(
    column: $table.latestFeedback,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currentObstacle => $composableBuilder(
    column: $table.currentObstacle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nextAction => $composableBuilder(
    column: $table.nextAction,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nextFollowAt => $composableBuilder(
    column: $table.nextFollowAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastFollowAt => $composableBuilder(
    column: $table.lastFollowAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isLegacyDefault => $composableBuilder(
    column: $table.isLegacyDefault,
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

  Expression<T> followupsRefs<T extends Object>(
    Expression<T> Function($$FollowupsTableAnnotationComposer a) f,
  ) {
    final $$FollowupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.followups,
      getReferencedColumn: (t) => t.opportunityId,
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
      getReferencedColumn: (t) => t.opportunityId,
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
      getReferencedColumn: (t) => t.opportunityId,
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

  Expression<T> quotesRefs<T extends Object>(
    Expression<T> Function($$QuotesTableAnnotationComposer a) f,
  ) {
    final $$QuotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quotes,
      getReferencedColumn: (t) => t.opportunityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuotesTableAnnotationComposer(
            $db: $db,
            $table: $db.quotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> samplesRefs<T extends Object>(
    Expression<T> Function($$SamplesTableAnnotationComposer a) f,
  ) {
    final $$SamplesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.samples,
      getReferencedColumn: (t) => t.opportunityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SamplesTableAnnotationComposer(
            $db: $db,
            $table: $db.samples,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OpportunitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OpportunitiesTable,
          OpportunityRow,
          $$OpportunitiesTableFilterComposer,
          $$OpportunitiesTableOrderingComposer,
          $$OpportunitiesTableAnnotationComposer,
          $$OpportunitiesTableCreateCompanionBuilder,
          $$OpportunitiesTableUpdateCompanionBuilder,
          (OpportunityRow, $$OpportunitiesTableReferences),
          OpportunityRow,
          PrefetchHooks Function({
            bool customerId,
            bool followupsRefs,
            bool followPlansRefs,
            bool ordersRefs,
            bool quotesRefs,
            bool samplesRefs,
          })
        > {
  $$OpportunitiesTableTableManager(_$AppDatabase db, $OpportunitiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OpportunitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OpportunitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OpportunitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> customerId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> owner = const Value.absent(),
                Value<String> importance = const Value.absent(),
                Value<String?> productCategory = const Value.absent(),
                Value<String?> productModel = const Value.absent(),
                Value<String?> equipmentBrand = const Value.absent(),
                Value<String?> equipmentModel = const Value.absent(),
                Value<int?> estimatedAnnualVolume = const Value.absent(),
                Value<int?> forecastAmountMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int?> probabilityPercent = const Value.absent(),
                Value<int?> expectedCloseAt = const Value.absent(),
                Value<String?> currentSupplier = const Value.absent(),
                Value<String?> currentPurchaseBrand = const Value.absent(),
                Value<int?> currentPurchasePriceMinor = const Value.absent(),
                Value<String?> supplierStability = const Value.absent(),
                Value<String?> supplierProblem = const Value.absent(),
                Value<String?> changeWillingness = const Value.absent(),
                Value<String?> substitutionDifficulty = const Value.absent(),
                Value<int?> latestQuoteMinor = const Value.absent(),
                Value<int?> targetPriceMinor = const Value.absent(),
                Value<String?> entryPoint = const Value.absent(),
                Value<String?> investmentAdvice = const Value.absent(),
                Value<bool> needsSample = const Value.absent(),
                Value<bool> needsRegistration = const Value.absent(),
                Value<bool> needsAuthorization = const Value.absent(),
                Value<String> stage = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> latestFeedback = const Value.absent(),
                Value<String?> currentObstacle = const Value.absent(),
                Value<String?> nextAction = const Value.absent(),
                Value<int?> nextFollowAt = const Value.absent(),
                Value<int?> lastFollowAt = const Value.absent(),
                Value<bool> isLegacyDefault = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => OpportunitiesCompanion(
                id: id,
                customerId: customerId,
                name: name,
                owner: owner,
                importance: importance,
                productCategory: productCategory,
                productModel: productModel,
                equipmentBrand: equipmentBrand,
                equipmentModel: equipmentModel,
                estimatedAnnualVolume: estimatedAnnualVolume,
                forecastAmountMinor: forecastAmountMinor,
                currency: currency,
                probabilityPercent: probabilityPercent,
                expectedCloseAt: expectedCloseAt,
                currentSupplier: currentSupplier,
                currentPurchaseBrand: currentPurchaseBrand,
                currentPurchasePriceMinor: currentPurchasePriceMinor,
                supplierStability: supplierStability,
                supplierProblem: supplierProblem,
                changeWillingness: changeWillingness,
                substitutionDifficulty: substitutionDifficulty,
                latestQuoteMinor: latestQuoteMinor,
                targetPriceMinor: targetPriceMinor,
                entryPoint: entryPoint,
                investmentAdvice: investmentAdvice,
                needsSample: needsSample,
                needsRegistration: needsRegistration,
                needsAuthorization: needsAuthorization,
                stage: stage,
                status: status,
                latestFeedback: latestFeedback,
                currentObstacle: currentObstacle,
                nextAction: nextAction,
                nextFollowAt: nextFollowAt,
                lastFollowAt: lastFollowAt,
                isLegacyDefault: isLegacyDefault,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int customerId,
                required String name,
                Value<String> owner = const Value.absent(),
                Value<String> importance = const Value.absent(),
                Value<String?> productCategory = const Value.absent(),
                Value<String?> productModel = const Value.absent(),
                Value<String?> equipmentBrand = const Value.absent(),
                Value<String?> equipmentModel = const Value.absent(),
                Value<int?> estimatedAnnualVolume = const Value.absent(),
                Value<int?> forecastAmountMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int?> probabilityPercent = const Value.absent(),
                Value<int?> expectedCloseAt = const Value.absent(),
                Value<String?> currentSupplier = const Value.absent(),
                Value<String?> currentPurchaseBrand = const Value.absent(),
                Value<int?> currentPurchasePriceMinor = const Value.absent(),
                Value<String?> supplierStability = const Value.absent(),
                Value<String?> supplierProblem = const Value.absent(),
                Value<String?> changeWillingness = const Value.absent(),
                Value<String?> substitutionDifficulty = const Value.absent(),
                Value<int?> latestQuoteMinor = const Value.absent(),
                Value<int?> targetPriceMinor = const Value.absent(),
                Value<String?> entryPoint = const Value.absent(),
                Value<String?> investmentAdvice = const Value.absent(),
                Value<bool> needsSample = const Value.absent(),
                Value<bool> needsRegistration = const Value.absent(),
                Value<bool> needsAuthorization = const Value.absent(),
                Value<String> stage = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> latestFeedback = const Value.absent(),
                Value<String?> currentObstacle = const Value.absent(),
                Value<String?> nextAction = const Value.absent(),
                Value<int?> nextFollowAt = const Value.absent(),
                Value<int?> lastFollowAt = const Value.absent(),
                Value<bool> isLegacyDefault = const Value.absent(),
                required int createdAt,
                required int updatedAt,
              }) => OpportunitiesCompanion.insert(
                id: id,
                customerId: customerId,
                name: name,
                owner: owner,
                importance: importance,
                productCategory: productCategory,
                productModel: productModel,
                equipmentBrand: equipmentBrand,
                equipmentModel: equipmentModel,
                estimatedAnnualVolume: estimatedAnnualVolume,
                forecastAmountMinor: forecastAmountMinor,
                currency: currency,
                probabilityPercent: probabilityPercent,
                expectedCloseAt: expectedCloseAt,
                currentSupplier: currentSupplier,
                currentPurchaseBrand: currentPurchaseBrand,
                currentPurchasePriceMinor: currentPurchasePriceMinor,
                supplierStability: supplierStability,
                supplierProblem: supplierProblem,
                changeWillingness: changeWillingness,
                substitutionDifficulty: substitutionDifficulty,
                latestQuoteMinor: latestQuoteMinor,
                targetPriceMinor: targetPriceMinor,
                entryPoint: entryPoint,
                investmentAdvice: investmentAdvice,
                needsSample: needsSample,
                needsRegistration: needsRegistration,
                needsAuthorization: needsAuthorization,
                stage: stage,
                status: status,
                latestFeedback: latestFeedback,
                currentObstacle: currentObstacle,
                nextAction: nextAction,
                nextFollowAt: nextFollowAt,
                lastFollowAt: lastFollowAt,
                isLegacyDefault: isLegacyDefault,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$OpportunitiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                customerId = false,
                followupsRefs = false,
                followPlansRefs = false,
                ordersRefs = false,
                quotesRefs = false,
                samplesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (followupsRefs) db.followups,
                    if (followPlansRefs) db.followPlans,
                    if (ordersRefs) db.orders,
                    if (quotesRefs) db.quotes,
                    if (samplesRefs) db.samples,
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
                                    referencedTable:
                                        $$OpportunitiesTableReferences
                                            ._customerIdTable(db),
                                    referencedColumn:
                                        $$OpportunitiesTableReferences
                                            ._customerIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (followupsRefs)
                        await $_getPrefetchedData<
                          OpportunityRow,
                          $OpportunitiesTable,
                          FollowupRow
                        >(
                          currentTable: table,
                          referencedTable: $$OpportunitiesTableReferences
                              ._followupsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OpportunitiesTableReferences(
                                db,
                                table,
                                p0,
                              ).followupsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.opportunityId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (followPlansRefs)
                        await $_getPrefetchedData<
                          OpportunityRow,
                          $OpportunitiesTable,
                          FollowPlanRow
                        >(
                          currentTable: table,
                          referencedTable: $$OpportunitiesTableReferences
                              ._followPlansRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OpportunitiesTableReferences(
                                db,
                                table,
                                p0,
                              ).followPlansRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.opportunityId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (ordersRefs)
                        await $_getPrefetchedData<
                          OpportunityRow,
                          $OpportunitiesTable,
                          OrderRow
                        >(
                          currentTable: table,
                          referencedTable: $$OpportunitiesTableReferences
                              ._ordersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OpportunitiesTableReferences(
                                db,
                                table,
                                p0,
                              ).ordersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.opportunityId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (quotesRefs)
                        await $_getPrefetchedData<
                          OpportunityRow,
                          $OpportunitiesTable,
                          QuoteRow
                        >(
                          currentTable: table,
                          referencedTable: $$OpportunitiesTableReferences
                              ._quotesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OpportunitiesTableReferences(
                                db,
                                table,
                                p0,
                              ).quotesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.opportunityId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (samplesRefs)
                        await $_getPrefetchedData<
                          OpportunityRow,
                          $OpportunitiesTable,
                          SampleRow
                        >(
                          currentTable: table,
                          referencedTable: $$OpportunitiesTableReferences
                              ._samplesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OpportunitiesTableReferences(
                                db,
                                table,
                                p0,
                              ).samplesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.opportunityId == item.id,
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

typedef $$OpportunitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OpportunitiesTable,
      OpportunityRow,
      $$OpportunitiesTableFilterComposer,
      $$OpportunitiesTableOrderingComposer,
      $$OpportunitiesTableAnnotationComposer,
      $$OpportunitiesTableCreateCompanionBuilder,
      $$OpportunitiesTableUpdateCompanionBuilder,
      (OpportunityRow, $$OpportunitiesTableReferences),
      OpportunityRow,
      PrefetchHooks Function({
        bool customerId,
        bool followupsRefs,
        bool followPlansRefs,
        bool ordersRefs,
        bool quotesRefs,
        bool samplesRefs,
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
      Value<int?> opportunityId,
      required int occurredAt,
      required String method,
      required String content,
      Value<String?> conclusion,
      Value<String?> feedback,
      Value<String?> stage,
      Value<String?> nextAction,
      Value<int?> nextFollowAt,
      Value<String?> pauseReason,
      required int createdAt,
      required int updatedAt,
    });
typedef $$FollowupsTableUpdateCompanionBuilder =
    FollowupsCompanion Function({
      Value<int> id,
      Value<int> customerId,
      Value<int?> opportunityId,
      Value<int> occurredAt,
      Value<String> method,
      Value<String> content,
      Value<String?> conclusion,
      Value<String?> feedback,
      Value<String?> stage,
      Value<String?> nextAction,
      Value<int?> nextFollowAt,
      Value<String?> pauseReason,
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

  static $OpportunitiesTable _opportunityIdTable(_$AppDatabase db) => db
      .opportunities
      .createAlias('followups__opportunity_id__opportunities__id');

  $$OpportunitiesTableProcessedTableManager? get opportunityId {
    final $_column = $_itemColumn<int>('opportunity_id');
    if ($_column == null) return null;
    final manager = $$OpportunitiesTableTableManager(
      $_db,
      $_db.opportunities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_opportunityIdTable($_db));
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

  ColumnFilters<String> get feedback => $composableBuilder(
    column: $table.feedback,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nextAction => $composableBuilder(
    column: $table.nextAction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextFollowAt => $composableBuilder(
    column: $table.nextFollowAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pauseReason => $composableBuilder(
    column: $table.pauseReason,
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

  $$OpportunitiesTableFilterComposer get opportunityId {
    final $$OpportunitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.opportunityId,
      referencedTable: $db.opportunities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OpportunitiesTableFilterComposer(
            $db: $db,
            $table: $db.opportunities,
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

  ColumnOrderings<String> get feedback => $composableBuilder(
    column: $table.feedback,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nextAction => $composableBuilder(
    column: $table.nextAction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextFollowAt => $composableBuilder(
    column: $table.nextFollowAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pauseReason => $composableBuilder(
    column: $table.pauseReason,
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

  $$OpportunitiesTableOrderingComposer get opportunityId {
    final $$OpportunitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.opportunityId,
      referencedTable: $db.opportunities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OpportunitiesTableOrderingComposer(
            $db: $db,
            $table: $db.opportunities,
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

  GeneratedColumn<String> get feedback =>
      $composableBuilder(column: $table.feedback, builder: (column) => column);

  GeneratedColumn<String> get stage =>
      $composableBuilder(column: $table.stage, builder: (column) => column);

  GeneratedColumn<String> get nextAction => $composableBuilder(
    column: $table.nextAction,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nextFollowAt => $composableBuilder(
    column: $table.nextFollowAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pauseReason => $composableBuilder(
    column: $table.pauseReason,
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

  $$OpportunitiesTableAnnotationComposer get opportunityId {
    final $$OpportunitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.opportunityId,
      referencedTable: $db.opportunities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OpportunitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.opportunities,
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
          PrefetchHooks Function({
            bool customerId,
            bool opportunityId,
            bool attachmentsRefs,
          })
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
                Value<int?> opportunityId = const Value.absent(),
                Value<int> occurredAt = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String?> conclusion = const Value.absent(),
                Value<String?> feedback = const Value.absent(),
                Value<String?> stage = const Value.absent(),
                Value<String?> nextAction = const Value.absent(),
                Value<int?> nextFollowAt = const Value.absent(),
                Value<String?> pauseReason = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => FollowupsCompanion(
                id: id,
                customerId: customerId,
                opportunityId: opportunityId,
                occurredAt: occurredAt,
                method: method,
                content: content,
                conclusion: conclusion,
                feedback: feedback,
                stage: stage,
                nextAction: nextAction,
                nextFollowAt: nextFollowAt,
                pauseReason: pauseReason,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int customerId,
                Value<int?> opportunityId = const Value.absent(),
                required int occurredAt,
                required String method,
                required String content,
                Value<String?> conclusion = const Value.absent(),
                Value<String?> feedback = const Value.absent(),
                Value<String?> stage = const Value.absent(),
                Value<String?> nextAction = const Value.absent(),
                Value<int?> nextFollowAt = const Value.absent(),
                Value<String?> pauseReason = const Value.absent(),
                required int createdAt,
                required int updatedAt,
              }) => FollowupsCompanion.insert(
                id: id,
                customerId: customerId,
                opportunityId: opportunityId,
                occurredAt: occurredAt,
                method: method,
                content: content,
                conclusion: conclusion,
                feedback: feedback,
                stage: stage,
                nextAction: nextAction,
                nextFollowAt: nextFollowAt,
                pauseReason: pauseReason,
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
              ({
                customerId = false,
                opportunityId = false,
                attachmentsRefs = false,
              }) {
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
                        if (opportunityId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.opportunityId,
                                    referencedTable: $$FollowupsTableReferences
                                        ._opportunityIdTable(db),
                                    referencedColumn: $$FollowupsTableReferences
                                        ._opportunityIdTable(db)
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
      PrefetchHooks Function({
        bool customerId,
        bool opportunityId,
        bool attachmentsRefs,
      })
    >;
typedef $$FollowPlansTableCreateCompanionBuilder =
    FollowPlansCompanion Function({
      Value<int> id,
      required int customerId,
      Value<int?> opportunityId,
      Value<String> sourceType,
      Value<int?> sourceId,
      Value<String?> ruleKey,
      required String title,
      Value<String?> reason,
      Value<String?> talkingDirection,
      Value<String?> nextAction,
      Value<String> owner,
      required int planAt,
      Value<String> status,
      Value<int?> notifiedAt,
      Value<int?> completedAt,
      Value<int?> cancelledAt,
      required int createdAt,
      required int updatedAt,
    });
typedef $$FollowPlansTableUpdateCompanionBuilder =
    FollowPlansCompanion Function({
      Value<int> id,
      Value<int> customerId,
      Value<int?> opportunityId,
      Value<String> sourceType,
      Value<int?> sourceId,
      Value<String?> ruleKey,
      Value<String> title,
      Value<String?> reason,
      Value<String?> talkingDirection,
      Value<String?> nextAction,
      Value<String> owner,
      Value<int> planAt,
      Value<String> status,
      Value<int?> notifiedAt,
      Value<int?> completedAt,
      Value<int?> cancelledAt,
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

  static $OpportunitiesTable _opportunityIdTable(_$AppDatabase db) => db
      .opportunities
      .createAlias('follow_plans__opportunity_id__opportunities__id');

  $$OpportunitiesTableProcessedTableManager? get opportunityId {
    final $_column = $_itemColumn<int>('opportunity_id');
    if ($_column == null) return null;
    final manager = $$OpportunitiesTableTableManager(
      $_db,
      $_db.opportunities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_opportunityIdTable($_db));
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

  ColumnFilters<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ruleKey => $composableBuilder(
    column: $table.ruleKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get talkingDirection => $composableBuilder(
    column: $table.talkingDirection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nextAction => $composableBuilder(
    column: $table.nextAction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get owner => $composableBuilder(
    column: $table.owner,
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

  ColumnFilters<int> get cancelledAt => $composableBuilder(
    column: $table.cancelledAt,
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

  $$OpportunitiesTableFilterComposer get opportunityId {
    final $$OpportunitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.opportunityId,
      referencedTable: $db.opportunities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OpportunitiesTableFilterComposer(
            $db: $db,
            $table: $db.opportunities,
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

  ColumnOrderings<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ruleKey => $composableBuilder(
    column: $table.ruleKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get talkingDirection => $composableBuilder(
    column: $table.talkingDirection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nextAction => $composableBuilder(
    column: $table.nextAction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get owner => $composableBuilder(
    column: $table.owner,
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

  ColumnOrderings<int> get cancelledAt => $composableBuilder(
    column: $table.cancelledAt,
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

  $$OpportunitiesTableOrderingComposer get opportunityId {
    final $$OpportunitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.opportunityId,
      referencedTable: $db.opportunities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OpportunitiesTableOrderingComposer(
            $db: $db,
            $table: $db.opportunities,
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

  GeneratedColumn<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get ruleKey =>
      $composableBuilder(column: $table.ruleKey, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get talkingDirection => $composableBuilder(
    column: $table.talkingDirection,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nextAction => $composableBuilder(
    column: $table.nextAction,
    builder: (column) => column,
  );

  GeneratedColumn<String> get owner =>
      $composableBuilder(column: $table.owner, builder: (column) => column);

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

  GeneratedColumn<int> get cancelledAt => $composableBuilder(
    column: $table.cancelledAt,
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

  $$OpportunitiesTableAnnotationComposer get opportunityId {
    final $$OpportunitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.opportunityId,
      referencedTable: $db.opportunities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OpportunitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.opportunities,
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
          PrefetchHooks Function({bool customerId, bool opportunityId})
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
                Value<int?> opportunityId = const Value.absent(),
                Value<String> sourceType = const Value.absent(),
                Value<int?> sourceId = const Value.absent(),
                Value<String?> ruleKey = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<String?> talkingDirection = const Value.absent(),
                Value<String?> nextAction = const Value.absent(),
                Value<String> owner = const Value.absent(),
                Value<int> planAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> notifiedAt = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<int?> cancelledAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => FollowPlansCompanion(
                id: id,
                customerId: customerId,
                opportunityId: opportunityId,
                sourceType: sourceType,
                sourceId: sourceId,
                ruleKey: ruleKey,
                title: title,
                reason: reason,
                talkingDirection: talkingDirection,
                nextAction: nextAction,
                owner: owner,
                planAt: planAt,
                status: status,
                notifiedAt: notifiedAt,
                completedAt: completedAt,
                cancelledAt: cancelledAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int customerId,
                Value<int?> opportunityId = const Value.absent(),
                Value<String> sourceType = const Value.absent(),
                Value<int?> sourceId = const Value.absent(),
                Value<String?> ruleKey = const Value.absent(),
                required String title,
                Value<String?> reason = const Value.absent(),
                Value<String?> talkingDirection = const Value.absent(),
                Value<String?> nextAction = const Value.absent(),
                Value<String> owner = const Value.absent(),
                required int planAt,
                Value<String> status = const Value.absent(),
                Value<int?> notifiedAt = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<int?> cancelledAt = const Value.absent(),
                required int createdAt,
                required int updatedAt,
              }) => FollowPlansCompanion.insert(
                id: id,
                customerId: customerId,
                opportunityId: opportunityId,
                sourceType: sourceType,
                sourceId: sourceId,
                ruleKey: ruleKey,
                title: title,
                reason: reason,
                talkingDirection: talkingDirection,
                nextAction: nextAction,
                owner: owner,
                planAt: planAt,
                status: status,
                notifiedAt: notifiedAt,
                completedAt: completedAt,
                cancelledAt: cancelledAt,
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
          prefetchHooksCallback: ({customerId = false, opportunityId = false}) {
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
                    if (opportunityId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.opportunityId,
                                referencedTable: $$FollowPlansTableReferences
                                    ._opportunityIdTable(db),
                                referencedColumn: $$FollowPlansTableReferences
                                    ._opportunityIdTable(db)
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
      PrefetchHooks Function({bool customerId, bool opportunityId})
    >;
typedef $$OrdersTableCreateCompanionBuilder =
    OrdersCompanion Function({
      Value<int> id,
      required int customerId,
      Value<int?> opportunityId,
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
      Value<int?> opportunityId,
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

  static $OpportunitiesTable _opportunityIdTable(_$AppDatabase db) =>
      db.opportunities.createAlias('orders__opportunity_id__opportunities__id');

  $$OpportunitiesTableProcessedTableManager? get opportunityId {
    final $_column = $_itemColumn<int>('opportunity_id');
    if ($_column == null) return null;
    final manager = $$OpportunitiesTableTableManager(
      $_db,
      $_db.opportunities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_opportunityIdTable($_db));
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

  $$OpportunitiesTableFilterComposer get opportunityId {
    final $$OpportunitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.opportunityId,
      referencedTable: $db.opportunities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OpportunitiesTableFilterComposer(
            $db: $db,
            $table: $db.opportunities,
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

  $$OpportunitiesTableOrderingComposer get opportunityId {
    final $$OpportunitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.opportunityId,
      referencedTable: $db.opportunities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OpportunitiesTableOrderingComposer(
            $db: $db,
            $table: $db.opportunities,
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

  $$OpportunitiesTableAnnotationComposer get opportunityId {
    final $$OpportunitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.opportunityId,
      referencedTable: $db.opportunities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OpportunitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.opportunities,
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
          PrefetchHooks Function({
            bool customerId,
            bool opportunityId,
            bool attachmentsRefs,
          })
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
                Value<int?> opportunityId = const Value.absent(),
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
                opportunityId: opportunityId,
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
                Value<int?> opportunityId = const Value.absent(),
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
                opportunityId: opportunityId,
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
              ({
                customerId = false,
                opportunityId = false,
                attachmentsRefs = false,
              }) {
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
                        if (opportunityId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.opportunityId,
                                    referencedTable: $$OrdersTableReferences
                                        ._opportunityIdTable(db),
                                    referencedColumn: $$OrdersTableReferences
                                        ._opportunityIdTable(db)
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
      PrefetchHooks Function({
        bool customerId,
        bool opportunityId,
        bool attachmentsRefs,
      })
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
typedef $$QuotesTableCreateCompanionBuilder =
    QuotesCompanion Function({
      Value<int> id,
      required int opportunityId,
      required String quoteNo,
      required int version,
      Value<String?> productModel,
      required int quantity,
      Value<String> currency,
      Value<int?> unitPriceMinor,
      Value<int?> totalAmountMinor,
      required int quotedAt,
      Value<int?> validUntil,
      Value<bool> customerReceived,
      Value<String?> customerFeedback,
      Value<int?> nextFollowAt,
      Value<String?> result,
      required int createdAt,
      required int updatedAt,
    });
typedef $$QuotesTableUpdateCompanionBuilder =
    QuotesCompanion Function({
      Value<int> id,
      Value<int> opportunityId,
      Value<String> quoteNo,
      Value<int> version,
      Value<String?> productModel,
      Value<int> quantity,
      Value<String> currency,
      Value<int?> unitPriceMinor,
      Value<int?> totalAmountMinor,
      Value<int> quotedAt,
      Value<int?> validUntil,
      Value<bool> customerReceived,
      Value<String?> customerFeedback,
      Value<int?> nextFollowAt,
      Value<String?> result,
      Value<int> createdAt,
      Value<int> updatedAt,
    });

final class $$QuotesTableReferences
    extends BaseReferences<_$AppDatabase, $QuotesTable, QuoteRow> {
  $$QuotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $OpportunitiesTable _opportunityIdTable(_$AppDatabase db) =>
      db.opportunities.createAlias('quotes__opportunity_id__opportunities__id');

  $$OpportunitiesTableProcessedTableManager get opportunityId {
    final $_column = $_itemColumn<int>('opportunity_id')!;

    final manager = $$OpportunitiesTableTableManager(
      $_db,
      $_db.opportunities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_opportunityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$QuotesTableFilterComposer
    extends Composer<_$AppDatabase, $QuotesTable> {
  $$QuotesTableFilterComposer({
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

  ColumnFilters<String> get quoteNo => $composableBuilder(
    column: $table.quoteNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productModel => $composableBuilder(
    column: $table.productModel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitPriceMinor => $composableBuilder(
    column: $table.unitPriceMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalAmountMinor => $composableBuilder(
    column: $table.totalAmountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quotedAt => $composableBuilder(
    column: $table.quotedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get validUntil => $composableBuilder(
    column: $table.validUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get customerReceived => $composableBuilder(
    column: $table.customerReceived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerFeedback => $composableBuilder(
    column: $table.customerFeedback,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextFollowAt => $composableBuilder(
    column: $table.nextFollowAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get result => $composableBuilder(
    column: $table.result,
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

  $$OpportunitiesTableFilterComposer get opportunityId {
    final $$OpportunitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.opportunityId,
      referencedTable: $db.opportunities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OpportunitiesTableFilterComposer(
            $db: $db,
            $table: $db.opportunities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuotesTableOrderingComposer
    extends Composer<_$AppDatabase, $QuotesTable> {
  $$QuotesTableOrderingComposer({
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

  ColumnOrderings<String> get quoteNo => $composableBuilder(
    column: $table.quoteNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productModel => $composableBuilder(
    column: $table.productModel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitPriceMinor => $composableBuilder(
    column: $table.unitPriceMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalAmountMinor => $composableBuilder(
    column: $table.totalAmountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quotedAt => $composableBuilder(
    column: $table.quotedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get validUntil => $composableBuilder(
    column: $table.validUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get customerReceived => $composableBuilder(
    column: $table.customerReceived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerFeedback => $composableBuilder(
    column: $table.customerFeedback,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextFollowAt => $composableBuilder(
    column: $table.nextFollowAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get result => $composableBuilder(
    column: $table.result,
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

  $$OpportunitiesTableOrderingComposer get opportunityId {
    final $$OpportunitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.opportunityId,
      referencedTable: $db.opportunities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OpportunitiesTableOrderingComposer(
            $db: $db,
            $table: $db.opportunities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuotesTable> {
  $$QuotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get quoteNo =>
      $composableBuilder(column: $table.quoteNo, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get productModel => $composableBuilder(
    column: $table.productModel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<int> get unitPriceMinor => $composableBuilder(
    column: $table.unitPriceMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalAmountMinor => $composableBuilder(
    column: $table.totalAmountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quotedAt =>
      $composableBuilder(column: $table.quotedAt, builder: (column) => column);

  GeneratedColumn<int> get validUntil => $composableBuilder(
    column: $table.validUntil,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get customerReceived => $composableBuilder(
    column: $table.customerReceived,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customerFeedback => $composableBuilder(
    column: $table.customerFeedback,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nextFollowAt => $composableBuilder(
    column: $table.nextFollowAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get result =>
      $composableBuilder(column: $table.result, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$OpportunitiesTableAnnotationComposer get opportunityId {
    final $$OpportunitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.opportunityId,
      referencedTable: $db.opportunities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OpportunitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.opportunities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuotesTable,
          QuoteRow,
          $$QuotesTableFilterComposer,
          $$QuotesTableOrderingComposer,
          $$QuotesTableAnnotationComposer,
          $$QuotesTableCreateCompanionBuilder,
          $$QuotesTableUpdateCompanionBuilder,
          (QuoteRow, $$QuotesTableReferences),
          QuoteRow,
          PrefetchHooks Function({bool opportunityId})
        > {
  $$QuotesTableTableManager(_$AppDatabase db, $QuotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> opportunityId = const Value.absent(),
                Value<String> quoteNo = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String?> productModel = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int?> unitPriceMinor = const Value.absent(),
                Value<int?> totalAmountMinor = const Value.absent(),
                Value<int> quotedAt = const Value.absent(),
                Value<int?> validUntil = const Value.absent(),
                Value<bool> customerReceived = const Value.absent(),
                Value<String?> customerFeedback = const Value.absent(),
                Value<int?> nextFollowAt = const Value.absent(),
                Value<String?> result = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => QuotesCompanion(
                id: id,
                opportunityId: opportunityId,
                quoteNo: quoteNo,
                version: version,
                productModel: productModel,
                quantity: quantity,
                currency: currency,
                unitPriceMinor: unitPriceMinor,
                totalAmountMinor: totalAmountMinor,
                quotedAt: quotedAt,
                validUntil: validUntil,
                customerReceived: customerReceived,
                customerFeedback: customerFeedback,
                nextFollowAt: nextFollowAt,
                result: result,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int opportunityId,
                required String quoteNo,
                required int version,
                Value<String?> productModel = const Value.absent(),
                required int quantity,
                Value<String> currency = const Value.absent(),
                Value<int?> unitPriceMinor = const Value.absent(),
                Value<int?> totalAmountMinor = const Value.absent(),
                required int quotedAt,
                Value<int?> validUntil = const Value.absent(),
                Value<bool> customerReceived = const Value.absent(),
                Value<String?> customerFeedback = const Value.absent(),
                Value<int?> nextFollowAt = const Value.absent(),
                Value<String?> result = const Value.absent(),
                required int createdAt,
                required int updatedAt,
              }) => QuotesCompanion.insert(
                id: id,
                opportunityId: opportunityId,
                quoteNo: quoteNo,
                version: version,
                productModel: productModel,
                quantity: quantity,
                currency: currency,
                unitPriceMinor: unitPriceMinor,
                totalAmountMinor: totalAmountMinor,
                quotedAt: quotedAt,
                validUntil: validUntil,
                customerReceived: customerReceived,
                customerFeedback: customerFeedback,
                nextFollowAt: nextFollowAt,
                result: result,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$QuotesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({opportunityId = false}) {
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
                    if (opportunityId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.opportunityId,
                                referencedTable: $$QuotesTableReferences
                                    ._opportunityIdTable(db),
                                referencedColumn: $$QuotesTableReferences
                                    ._opportunityIdTable(db)
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

typedef $$QuotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuotesTable,
      QuoteRow,
      $$QuotesTableFilterComposer,
      $$QuotesTableOrderingComposer,
      $$QuotesTableAnnotationComposer,
      $$QuotesTableCreateCompanionBuilder,
      $$QuotesTableUpdateCompanionBuilder,
      (QuoteRow, $$QuotesTableReferences),
      QuoteRow,
      PrefetchHooks Function({bool opportunityId})
    >;
typedef $$SamplesTableCreateCompanionBuilder =
    SamplesCompanion Function({
      Value<int> id,
      required int opportunityId,
      Value<String?> sampleModel,
      required int quantity,
      Value<int?> feeMinor,
      Value<int?> sentAt,
      Value<String?> carrier,
      Value<String?> trackingNo,
      Value<int?> deliveredAt,
      Value<String?> recipient,
      Value<String?> tester,
      Value<int?> plannedTestAt,
      Value<String> status,
      Value<String?> testResult,
      Value<String?> nextAction,
      required int createdAt,
      required int updatedAt,
    });
typedef $$SamplesTableUpdateCompanionBuilder =
    SamplesCompanion Function({
      Value<int> id,
      Value<int> opportunityId,
      Value<String?> sampleModel,
      Value<int> quantity,
      Value<int?> feeMinor,
      Value<int?> sentAt,
      Value<String?> carrier,
      Value<String?> trackingNo,
      Value<int?> deliveredAt,
      Value<String?> recipient,
      Value<String?> tester,
      Value<int?> plannedTestAt,
      Value<String> status,
      Value<String?> testResult,
      Value<String?> nextAction,
      Value<int> createdAt,
      Value<int> updatedAt,
    });

final class $$SamplesTableReferences
    extends BaseReferences<_$AppDatabase, $SamplesTable, SampleRow> {
  $$SamplesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $OpportunitiesTable _opportunityIdTable(_$AppDatabase db) => db
      .opportunities
      .createAlias('samples__opportunity_id__opportunities__id');

  $$OpportunitiesTableProcessedTableManager get opportunityId {
    final $_column = $_itemColumn<int>('opportunity_id')!;

    final manager = $$OpportunitiesTableTableManager(
      $_db,
      $_db.opportunities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_opportunityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SamplesTableFilterComposer
    extends Composer<_$AppDatabase, $SamplesTable> {
  $$SamplesTableFilterComposer({
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

  ColumnFilters<String> get sampleModel => $composableBuilder(
    column: $table.sampleModel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get feeMinor => $composableBuilder(
    column: $table.feeMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sentAt => $composableBuilder(
    column: $table.sentAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get carrier => $composableBuilder(
    column: $table.carrier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trackingNo => $composableBuilder(
    column: $table.trackingNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deliveredAt => $composableBuilder(
    column: $table.deliveredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recipient => $composableBuilder(
    column: $table.recipient,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tester => $composableBuilder(
    column: $table.tester,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedTestAt => $composableBuilder(
    column: $table.plannedTestAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get testResult => $composableBuilder(
    column: $table.testResult,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nextAction => $composableBuilder(
    column: $table.nextAction,
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

  $$OpportunitiesTableFilterComposer get opportunityId {
    final $$OpportunitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.opportunityId,
      referencedTable: $db.opportunities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OpportunitiesTableFilterComposer(
            $db: $db,
            $table: $db.opportunities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SamplesTableOrderingComposer
    extends Composer<_$AppDatabase, $SamplesTable> {
  $$SamplesTableOrderingComposer({
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

  ColumnOrderings<String> get sampleModel => $composableBuilder(
    column: $table.sampleModel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get feeMinor => $composableBuilder(
    column: $table.feeMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sentAt => $composableBuilder(
    column: $table.sentAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get carrier => $composableBuilder(
    column: $table.carrier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trackingNo => $composableBuilder(
    column: $table.trackingNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deliveredAt => $composableBuilder(
    column: $table.deliveredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recipient => $composableBuilder(
    column: $table.recipient,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tester => $composableBuilder(
    column: $table.tester,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedTestAt => $composableBuilder(
    column: $table.plannedTestAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get testResult => $composableBuilder(
    column: $table.testResult,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nextAction => $composableBuilder(
    column: $table.nextAction,
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

  $$OpportunitiesTableOrderingComposer get opportunityId {
    final $$OpportunitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.opportunityId,
      referencedTable: $db.opportunities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OpportunitiesTableOrderingComposer(
            $db: $db,
            $table: $db.opportunities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SamplesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SamplesTable> {
  $$SamplesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sampleModel => $composableBuilder(
    column: $table.sampleModel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get feeMinor =>
      $composableBuilder(column: $table.feeMinor, builder: (column) => column);

  GeneratedColumn<int> get sentAt =>
      $composableBuilder(column: $table.sentAt, builder: (column) => column);

  GeneratedColumn<String> get carrier =>
      $composableBuilder(column: $table.carrier, builder: (column) => column);

  GeneratedColumn<String> get trackingNo => $composableBuilder(
    column: $table.trackingNo,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deliveredAt => $composableBuilder(
    column: $table.deliveredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recipient =>
      $composableBuilder(column: $table.recipient, builder: (column) => column);

  GeneratedColumn<String> get tester =>
      $composableBuilder(column: $table.tester, builder: (column) => column);

  GeneratedColumn<int> get plannedTestAt => $composableBuilder(
    column: $table.plannedTestAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get testResult => $composableBuilder(
    column: $table.testResult,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nextAction => $composableBuilder(
    column: $table.nextAction,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$OpportunitiesTableAnnotationComposer get opportunityId {
    final $$OpportunitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.opportunityId,
      referencedTable: $db.opportunities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OpportunitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.opportunities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SamplesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SamplesTable,
          SampleRow,
          $$SamplesTableFilterComposer,
          $$SamplesTableOrderingComposer,
          $$SamplesTableAnnotationComposer,
          $$SamplesTableCreateCompanionBuilder,
          $$SamplesTableUpdateCompanionBuilder,
          (SampleRow, $$SamplesTableReferences),
          SampleRow,
          PrefetchHooks Function({bool opportunityId})
        > {
  $$SamplesTableTableManager(_$AppDatabase db, $SamplesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SamplesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SamplesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SamplesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> opportunityId = const Value.absent(),
                Value<String?> sampleModel = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<int?> feeMinor = const Value.absent(),
                Value<int?> sentAt = const Value.absent(),
                Value<String?> carrier = const Value.absent(),
                Value<String?> trackingNo = const Value.absent(),
                Value<int?> deliveredAt = const Value.absent(),
                Value<String?> recipient = const Value.absent(),
                Value<String?> tester = const Value.absent(),
                Value<int?> plannedTestAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> testResult = const Value.absent(),
                Value<String?> nextAction = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => SamplesCompanion(
                id: id,
                opportunityId: opportunityId,
                sampleModel: sampleModel,
                quantity: quantity,
                feeMinor: feeMinor,
                sentAt: sentAt,
                carrier: carrier,
                trackingNo: trackingNo,
                deliveredAt: deliveredAt,
                recipient: recipient,
                tester: tester,
                plannedTestAt: plannedTestAt,
                status: status,
                testResult: testResult,
                nextAction: nextAction,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int opportunityId,
                Value<String?> sampleModel = const Value.absent(),
                required int quantity,
                Value<int?> feeMinor = const Value.absent(),
                Value<int?> sentAt = const Value.absent(),
                Value<String?> carrier = const Value.absent(),
                Value<String?> trackingNo = const Value.absent(),
                Value<int?> deliveredAt = const Value.absent(),
                Value<String?> recipient = const Value.absent(),
                Value<String?> tester = const Value.absent(),
                Value<int?> plannedTestAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> testResult = const Value.absent(),
                Value<String?> nextAction = const Value.absent(),
                required int createdAt,
                required int updatedAt,
              }) => SamplesCompanion.insert(
                id: id,
                opportunityId: opportunityId,
                sampleModel: sampleModel,
                quantity: quantity,
                feeMinor: feeMinor,
                sentAt: sentAt,
                carrier: carrier,
                trackingNo: trackingNo,
                deliveredAt: deliveredAt,
                recipient: recipient,
                tester: tester,
                plannedTestAt: plannedTestAt,
                status: status,
                testResult: testResult,
                nextAction: nextAction,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SamplesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({opportunityId = false}) {
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
                    if (opportunityId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.opportunityId,
                                referencedTable: $$SamplesTableReferences
                                    ._opportunityIdTable(db),
                                referencedColumn: $$SamplesTableReferences
                                    ._opportunityIdTable(db)
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

typedef $$SamplesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SamplesTable,
      SampleRow,
      $$SamplesTableFilterComposer,
      $$SamplesTableOrderingComposer,
      $$SamplesTableAnnotationComposer,
      $$SamplesTableCreateCompanionBuilder,
      $$SamplesTableUpdateCompanionBuilder,
      (SampleRow, $$SamplesTableReferences),
      SampleRow,
      PrefetchHooks Function({bool opportunityId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
  $$OpportunitiesTableTableManager get opportunities =>
      $$OpportunitiesTableTableManager(_db, _db.opportunities);
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
  $$QuotesTableTableManager get quotes =>
      $$QuotesTableTableManager(_db, _db.quotes);
  $$SamplesTableTableManager get samples =>
      $$SamplesTableTableManager(_db, _db.samples);
}
