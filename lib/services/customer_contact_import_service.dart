import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:excel/excel.dart';

import '../data/database.dart';
import '../models/enums.dart';

class CustomerContactImportRow {
  const CustomerContactImportRow({required this.line, required this.values});

  final int line;
  final Map<String, String> values;

  CustomerContactImportRow withValues(Map<String, String> updates) =>
      CustomerContactImportRow(
        line: line,
        values: Map<String, String>.unmodifiable({...values, ...updates}),
      );

  String? get customerNo => _value('客户编号');
  String? get name => _value('客户名称');
  String? get company => _value('公司');
  String? get country => _value('国家/地区');
  String? get customerType => _value('客户类型');
  String? get owner => _value('负责人');
  String? get phone => _value('电话');
  String? get wechat => _value('微信');
  String? get address => _value('地址');
  String? get source => _value('来源');
  String? get note => _value('备注');
  String? get stage => _value('客户阶段');
  String? get grade => _value('客户等级');
  String? get tenderExperience => _value('招投标经验');
  String? get tenderQualification => _value('投标资格');
  String? get tenderBidder => _value('投标主体');
  String? get localTeamStatus => _value('当地团队');
  String? get fundingStatus => _value('资金状态');
  String? get contactName => _value('联系人姓名');
  String? get contactPosition => _value('联系人职位');
  String? get contactPhone => _value('联系人电话');
  String? get contactEmail => _value('联系人邮箱');
  String? get contactWhatsapp => _value('联系人 WhatsApp');
  String? get communicationPreference => _value('沟通偏好');
  String? get contactNote => _value('联系人备注');
  String? get decisionMaker => _value('是否决策人');

  String? _value(String key) {
    final value = values[key]?.trim();
    return value == null || value.isEmpty ? null : value;
  }
}

class CustomerContactImportIssue {
  const CustomerContactImportIssue({
    required this.line,
    required this.field,
    required this.message,
  });

  final int line;
  final String field;
  final String message;
}

class CustomerContactImportPreview {
  const CustomerContactImportPreview({
    required this.rows,
    required this.issues,
    required this.headers,
  });

  final List<CustomerContactImportRow> rows;
  final List<CustomerContactImportIssue> issues;
  final List<String> headers;

  int get validCount => rows.length - issues.map((e) => e.line).toSet().length;
  bool get canImport => issues.isEmpty && rows.isNotEmpty;
}

class CustomerContactImportResult {
  const CustomerContactImportResult({
    required this.createdCustomers,
    required this.updatedCustomers,
    required this.createdContacts,
    required this.updatedContacts,
  });

  final int createdCustomers;
  final int updatedCustomers;
  final int createdContacts;
  final int updatedContacts;
}

class CustomerContactImportService {
  CustomerContactImportService(this.database);

  final AppDatabase database;

  static const headers = <String>[
    '客户编号',
    '客户名称',
    '公司',
    '国家/地区',
    '客户类型',
    '负责人',
    '电话',
    '微信',
    '地址',
    '来源',
    '备注',
    '客户阶段',
    '客户等级',
    '招投标经验',
    '投标资格',
    '投标主体',
    '当地团队',
    '资金状态',
    '联系人姓名',
    '联系人职位',
    '联系人电话',
    '联系人邮箱',
    '联系人 WhatsApp',
    '沟通偏好',
    '是否决策人',
    '联系人备注',
  ];

  CustomerContactImportPreview preview(Uint8List bytes, {String? fileName}) {
    final rows = _decode(bytes, fileName: fileName);
    return revalidate(
      rows,
      headers: rows.isEmpty ? const [] : rows.first.values.keys.toList(),
    );
  }

  CustomerContactImportPreview revalidate(
    List<CustomerContactImportRow> rows, {
    List<String>? headers,
  }) {
    final issues = <CustomerContactImportIssue>[];
    final seenNumbers = <String>{};
    for (final row in rows) {
      if (row.name == null) {
        issues.add(
          CustomerContactImportIssue(
            line: row.line,
            field: '客户名称',
            message: '客户名称不能为空',
          ),
        );
      }
      final no = row.customerNo;
      if (no != null && !seenNumbers.add(no)) {
        issues.add(
          CustomerContactImportIssue(
            line: row.line,
            field: '客户编号',
            message: '文件内客户编号重复：$no',
          ),
        );
      }
      if (row.contactEmail != null && !_validEmail(row.contactEmail!)) {
        issues.add(
          CustomerContactImportIssue(
            line: row.line,
            field: '联系人邮箱',
            message: '联系人邮箱格式无效',
          ),
        );
      }
      if (row.stage != null && _stage(row.stage!) == null) {
        issues.add(
          CustomerContactImportIssue(
            line: row.line,
            field: '客户阶段',
            message: '客户阶段无效：${row.stage}',
          ),
        );
      }
      if (row.grade != null && _grade(row.grade!) == null) {
        issues.add(
          CustomerContactImportIssue(
            line: row.line,
            field: '客户等级',
            message: '客户等级无效：${row.grade}',
          ),
        );
      }
      if (row.contactName != null &&
          row.customerNo == null &&
          row.name == null) {
        issues.add(
          CustomerContactImportIssue(
            line: row.line,
            field: '客户名称',
            message: '联系人无法归属客户',
          ),
        );
      }
    }
    return CustomerContactImportPreview(
      rows: List<CustomerContactImportRow>.unmodifiable(rows),
      issues: List<CustomerContactImportIssue>.unmodifiable(issues),
      headers: List<String>.unmodifiable(
        headers ?? (rows.isEmpty ? const [] : rows.first.values.keys),
      ),
    );
  }

  Future<CustomerContactImportResult> importPreview(
    CustomerContactImportPreview preview,
  ) async {
    if (!preview.canImport) throw const FormatException('导入文件存在错误');
    var createdCustomers = 0;
    var updatedCustomers = 0;
    var createdContacts = 0;
    var updatedContacts = 0;
    await database.transaction(() async {
      final existing = {
        for (final customer in await database.customerDao.allCustomers())
          if (customer.customerNo != null) customer.customerNo!: customer,
      };
      final existingByCompanyCountry = <String, CustomerRow>{};
      final ambiguousCompanyCountry = <String>{};
      for (final customer in await database.customerDao.allCustomers()) {
        final company = customer.company?.trim();
        final country = customer.country?.trim();
        if (company == null ||
            company.isEmpty ||
            country == null ||
            country.isEmpty) {
          continue;
        }
        final key = '$company\u0000$country';
        if (existingByCompanyCountry.containsKey(key)) {
          ambiguousCompanyCountry.add(key);
        } else {
          existingByCompanyCountry[key] = customer;
        }
      }
      for (final row in preview.rows) {
        final stage = _stage(row.stage ?? '') ?? CustomerStage.potential;
        final grade = _grade(row.grade ?? '') ?? CustomerGrade.c;
        final companyKey = row.company == null || row.country == null
            ? null
            : '${row.company!.trim()}\u0000${row.country!.trim()}';
        final current = row.customerNo != null
            ? existing[row.customerNo]
            : companyKey == null || ambiguousCompanyCountry.contains(companyKey)
            ? null
            : existingByCompanyCountry[companyKey];
        late int id;
        if (current == null) {
          id = await database.customerDao.insertCustomer(
            name: row.name!,
            customerNo: row.customerNo,
            customerType: row.customerType,
            owner: row.owner ?? '本人',
            company: row.company,
            country: row.country,
            phone: row.phone,
            wechat: row.wechat,
            address: row.address,
            source: row.source,
            note: row.note,
            tenderExperience: row.tenderExperience,
            tenderQualification: row.tenderQualification,
            tenderBidder: row.tenderBidder,
            localTeamStatus: row.localTeamStatus,
            fundingStatus: row.fundingStatus,
            stage: stage,
            grade: grade,
          );
          createdCustomers++;
        } else {
          id = current.id;
          await database.customerDao.updateCustomer(
            id,
            name: row.name,
            customerNo: Value(row.customerNo),
            customerType: Value(row.customerType),
            owner: row.owner,
            company: Value(row.company),
            country: Value(row.country),
            phone: Value(row.phone),
            wechat: Value(row.wechat),
            address: Value(row.address),
            source: Value(row.source),
            note: Value(row.note),
            tenderExperience: Value(row.tenderExperience),
            tenderQualification: Value(row.tenderQualification),
            tenderBidder: Value(row.tenderBidder),
            localTeamStatus: Value(row.localTeamStatus),
            fundingStatus: Value(row.fundingStatus),
            stage: stage,
            grade: grade,
          );
          updatedCustomers++;
        }
        if (row.contactName != null) {
          final contacts = await database.contactDao.listOf(id);
          final contact = contacts
              .where((c) => c.name == row.contactName)
              .firstOrNull;
          if (contact == null) {
            await database.contactDao.insertContact(
              customerId: id,
              name: row.contactName!,
              position: row.contactPosition,
              phone: row.contactPhone,
              email: row.contactEmail,
              whatsapp: row.contactWhatsapp,
              communicationPreference: row.communicationPreference,
              note: row.contactNote,
              isDecisionMaker: _bool(row.decisionMaker),
            );
            createdContacts++;
          } else {
            await database.contactDao.updateContact(
              contact.id,
              name: row.contactName,
              position: Value(row.contactPosition),
              phone: Value(row.contactPhone),
              email: Value(row.contactEmail),
              whatsapp: Value(row.contactWhatsapp),
              communicationPreference: Value(row.communicationPreference),
              note: Value(row.contactNote),
              isDecisionMaker: _bool(row.decisionMaker),
            );
            updatedContacts++;
          }
        }
      }
    });
    return CustomerContactImportResult(
      createdCustomers: createdCustomers,
      updatedCustomers: updatedCustomers,
      createdContacts: createdContacts,
      updatedContacts: updatedContacts,
    );
  }

  List<CustomerContactImportRow> _decode(Uint8List bytes, {String? fileName}) {
    final isCsv = fileName?.toLowerCase().endsWith('.csv') ?? false;
    if (isCsv) return _csv(utf8.decode(bytes));
    final workbook = Excel.decodeBytes(bytes);
    if (workbook.tables.isEmpty) throw const FormatException('Excel 文件没有工作表');
    final sheet = workbook.tables.values.first;
    if (sheet.rows.isEmpty) return const [];
    final header = sheet.rows.first
        .map((cell) => cell?.value?.toString().trim() ?? '')
        .toList();
    final result = <CustomerContactImportRow>[];
    for (var i = 1; i < sheet.rows.length; i++) {
      final values = <String, String>{};
      for (var c = 0; c < header.length && c < sheet.rows[i].length; c++) {
        if (header[c].isNotEmpty) {
          values[header[c]] = sheet.rows[i][c]?.value?.toString() ?? '';
        }
      }
      if (values.values.every((value) => value.trim().isEmpty)) continue;
      result.add(CustomerContactImportRow(line: i + 1, values: values));
    }
    return result;
  }

  List<CustomerContactImportRow> _csv(String text) {
    final records = <List<String>>[];
    var row = <String>[];
    var field = StringBuffer();
    var quoted = false;
    for (var i = 0; i < text.length; i++) {
      final char = text[i];
      if (char == '"') {
        if (quoted && i + 1 < text.length && text[i + 1] == '"') {
          field.write('"');
          i++;
        } else {
          quoted = !quoted;
        }
      } else if (char == ',' && !quoted) {
        row.add(field.toString());
        field = StringBuffer();
      } else if ((char == '\n' || char == '\r') && !quoted) {
        if (char == '\r' && i + 1 < text.length && text[i + 1] == '\n') i++;
        row.add(field.toString());
        field = StringBuffer();
        if (row.any((v) => v.trim().isNotEmpty)) records.add(row);
        row = <String>[];
      } else {
        field.write(char);
      }
    }
    if (field.isNotEmpty || row.isNotEmpty) {
      row.add(field.toString());
      records.add(row);
    }
    if (records.isEmpty) return const [];
    final headers = records.first.map((v) => v.trim()).toList();
    return [
      for (var i = 1; i < records.length; i++)
        CustomerContactImportRow(
          line: i + 1,
          values: {
            for (var c = 0; c < headers.length && c < records[i].length; c++)
              headers[c]: records[i][c],
          },
        ),
    ];
  }

  static bool _validEmail(String value) {
    final parts = value.split('@');
    return parts.length == 2 &&
        parts.first.isNotEmpty &&
        parts.last.contains('.');
  }

  static bool _bool(String? value) =>
      {'是', '是的', 'true', '1', 'yes'}.contains(value?.trim().toLowerCase());
  static CustomerStage? _stage(String value) => CustomerStage.values
      .where((e) => e.dbValue == value || e.label == value)
      .firstOrNull;
  static CustomerGrade? _grade(String value) => CustomerGrade.values
      .where(
        (e) =>
            e.dbValue == value.toLowerCase() || e.label == value.toUpperCase(),
      )
      .firstOrNull;
}
