import 'dart:convert';
import 'dart:typed_data';

import 'package:customer/data/database.dart';
import 'package:customer/services/customer_contact_import_service.dart';
import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../data/helpers.dart';

void main() {
  late AppDatabase db;
  late CustomerContactImportService service;

  setUp(() async {
    db = await openTestDb();
    service = CustomerContactImportService(db);
  });

  tearDown(() => db.close());

  test('CSV 解析并校验客户和联系人字段', () {
    final preview = service.preview(
      Uint8List.fromList(
        utf8.encode(
          '客户编号,客户名称,公司,客户阶段,客户等级,联系人姓名,联系人邮箱,是否决策人\n'
          'C-001, 星河 ,星河科技,意向明确,A,李经理,li@example.com,是\n'
          ',,缺名公司,,,王工,bad,否\n',
        ),
      ),
      fileName: 'customers.csv',
    );

    expect(preview.rows, hasLength(2));
    expect(preview.rows.first.name, '星河');
    expect(preview.rows.first.stage, '意向明确');
    expect(preview.issues.map((e) => e.message), contains('客户名称不能为空'));
    expect(preview.issues.map((e) => e.message), contains('联系人邮箱格式无效'));
  });

  test('文件内重复客户编号会阻止导入', () {
    final preview = service.preview(
      Uint8List.fromList(utf8.encode('客户编号,客户名称\nC-1,A\nC-1,B\n')),
      fileName: 'customers.csv',
    );
    expect(preview.canImport, isFalse);
    expect(preview.issues.single.message, contains('客户编号重复'));
    expect(preview.issues.single.field, '客户编号');
  });

  test('修正错误字段后保留原行数据并重新校验全部行', () {
    final preview = service.preview(
      Uint8List.fromList(
        utf8.encode(
          '客户编号,客户名称,联系人姓名,联系人邮箱\n'
          'C-1,甲客户,李经理,bad-email\n'
          'C-1,乙客户,王经理,wang@example.com\n',
        ),
      ),
      fileName: 'customers.csv',
    );

    expect(
      preview.issues.map((issue) => issue.field),
      containsAll(<String>['联系人邮箱', '客户编号']),
    );

    final correctedRows = preview.rows
        .map(
          (row) => row.line == 2
              ? row.withValues({'联系人邮箱': 'li@example.com'})
              : row.line == 3
              ? row.withValues({'客户编号': 'C-2'})
              : row,
        )
        .toList();
    final corrected = service.revalidate(correctedRows);

    expect(corrected.issues, isEmpty);
    expect(corrected.rows.first.line, 2);
    expect(corrected.rows.first.name, '甲客户');
    expect(corrected.rows.first.contactName, '李经理');
    expect(corrected.rows.first.contactEmail, 'li@example.com');
    expect(corrected.rows.last.customerNo, 'C-2');
  });

  test('排除重复编号行后重新校验为可导入', () {
    final preview = service.preview(
      Uint8List.fromList(utf8.encode('客户编号,客户名称\nC-1,A\nC-1,B\n')),
      fileName: 'customers.csv',
    );

    final corrected = service.revalidate(
      preview.rows.where((row) => row.line != 3).toList(),
    );

    expect(corrected.rows.single.line, 2);
    expect(corrected.issues, isEmpty);
    expect(corrected.canImport, isTrue);
  });

  test('可以读取 Excel 第一张工作表', () {
    final workbook = Excel.createExcel();
    final sheet = workbook['Sheet1'];
    sheet.appendRow([TextCellValue('客户名称'), TextCellValue('客户等级')]);
    sheet.appendRow([TextCellValue('Excel 客户'), TextCellValue('B')]);
    final bytes = workbook.encode();
    expect(bytes, isNotNull);
    final preview = service.preview(Uint8List.fromList(bytes!));
    expect(preview.issues, isEmpty);
    expect(preview.rows.single.name, 'Excel 客户');
  });

  test('导入会创建客户、联系人，并按客户编号更新', () async {
    final first = service.preview(
      Uint8List.fromList(utf8.encode('客户编号,客户名称,公司,联系人姓名\nC-1,A,甲公司,李经理\n')),
      fileName: 'customers.csv',
    );
    final created = await service.importPreview(first);
    expect(created.createdCustomers, 1);
    expect(created.createdContacts, 1);

    final second = service.preview(
      Uint8List.fromList(utf8.encode('客户编号,客户名称,公司,联系人姓名\nC-1,A2,乙公司,李经理\n')),
      fileName: 'customers.csv',
    );
    final updated = await service.importPreview(second);
    expect(updated.updatedCustomers, 1);
    expect(updated.updatedContacts, 1);
    final customer = (await db.customerDao.allCustomers()).single;
    expect(customer.name, 'A2');
    expect(customer.company, '乙公司');
  });

  test('修正后的预览按修正值完成导入', () async {
    final invalid = service.preview(
      Uint8List.fromList(utf8.encode('客户编号,客户名称,联系人邮箱\nC-9,,bad\n')),
      fileName: 'customers.csv',
    );
    final corrected = service.revalidate([
      invalid.rows.single.withValues({'客户名称': '修正客户', '联系人邮箱': ''}),
    ]);

    final result = await service.importPreview(corrected);

    expect(result.createdCustomers, 1);
    expect((await db.customerDao.allCustomers()).single.name, '修正客户');
  });
}
