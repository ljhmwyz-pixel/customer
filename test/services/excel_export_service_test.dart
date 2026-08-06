import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:customer/data/daos/export_dao.dart';
import 'package:customer/services/excel_export_service.dart';
import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';

void main() {
  test('生成四个中文工作表并保留类型、公式和中文', () {
    final bytes = const ExcelWorkbookBuilder().build(_snapshot());
    final workbook = Excel.decodeBytes(bytes);

    expect(workbook.tables.keys.toList(), ExcelWorkbookBuilder.sheetNames);
    expect(
      workbook.tables['客户及项目']!.cell(CellIndex.indexByString('A2')).value,
      isA<TextCellValue>().having((v) => v.value.text, 'text', '上海医械'),
    );
    expect(
      workbook.tables['客户及项目']!.cell(CellIndex.indexByString('K2')).value,
      isA<DoubleCellValue>().having((v) => v.value, 'amount', 1234.56),
    );
    expect(
      workbook.tables['客户及项目']!.cell(CellIndex.indexByString('M2')).value,
      isA<DoubleCellValue>().having((v) => v.value, 'probability', 0.6),
    );
    expect(
      workbook.tables['今日任务及看板']!.cell(CellIndex.indexByString('B2')).value,
      isA<FormulaCellValue>(),
    );
  });

  test('最终 OOXML 包含冻结、筛选、条件格式和自动计算', () {
    final bytes = const ExcelWorkbookBuilder().build(_snapshot());
    final archive = ZipDecoder().decodeBytes(bytes);
    final workbookXml = _xml(archive, 'xl/workbook.xml');
    final calc = workbookXml.findAllElements('calcPr').single;
    expect(calc.getAttribute('calcMode'), 'auto');
    final styles = _xml(archive, 'xl/styles.xml');
    expect(styles.findAllElements('dxfs').single.getAttribute('count'), '3');
    expect(styles.findAllElements('dxf'), hasLength(3));

    for (var index = 1; index <= 4; index++) {
      final sheet = _xml(archive, 'xl/worksheets/sheet$index.xml');
      final pane = sheet.findAllElements('pane').single;
      expect(pane.getAttribute('state'), 'frozen');
      expect(pane.getAttribute('ySplit'), '1');
      expect(sheet.findAllElements('autoFilter'), hasLength(1));
      expect(sheet.findAllElements('conditionalFormatting'), isNotEmpty);
      final rules = sheet.findAllElements('cfRule').toList();
      expect(rules, hasLength(3));
      expect(rules.map((rule) => rule.getAttribute('dxfId')), ['0', '1', '2']);
    }
  });

  test('空快照仍生成只有表头的有效四表文件', () {
    const empty = ExcelExportSnapshot(
      todayTasks: [],
      customerProjects: [],
      followups: [],
      businessEvents: [],
    );
    final bytes = const ExcelWorkbookBuilder().build(empty);
    expect(bytes, isNotEmpty);
    final workbook = Excel.decodeBytes(bytes);
    expect(workbook.tables.keys.toList(), ExcelWorkbookBuilder.sheetNames);
    expect(workbook.tables.values.every((sheet) => sheet.maxRows == 1), isTrue);
  });
}

ExcelExportSnapshot _snapshot() {
  final at = DateTime.utc(2026, 8, 6, 9);
  return ExcelExportSnapshot(
    todayTasks: [
      TaskExportRow(
        id: 1,
        planAt: at,
        statusLabel: '已逾期',
        customerName: '上海医械',
        opportunityName: 'CT 双筒项目',
        reason: '报价跟进',
        nextAction: '确认报价反馈',
        owner: '本人',
        talkingDirection: '确认采购时间',
      ),
    ],
    customerProjects: [
      CustomerProjectExportRow(
        customerId: 1,
        customerName: '上海医械',
        company: '上海医械有限公司',
        country: '中国',
        customerStageLabel: '意向明确',
        grade: 'A',
        opportunityId: 2,
        opportunityName: 'CT 双筒项目',
        owner: '本人',
        opportunityStageLabel: '已报价',
        opportunityStatusLabel: '活跃',
        productCategory: '高压注射器耗材',
        productModel: 'CT-200',
        equipmentBrand: 'Stellant',
        forecastAmountMinor: 123456,
        currency: 'USD',
        probabilityPercent: 60,
        expectedCloseAt: at,
        currentSupplier: 'Antmed',
        latestFeedback: '等待确认',
        currentObstacle: '价格',
        nextAction: '再次联系',
        nextFollowAt: at,
      ),
    ],
    followups: [
      FollowupExportRow(
        id: 3,
        occurredAt: at,
        customerName: '上海医械',
        opportunityName: 'CT 双筒项目',
        methodLabel: '微信',
        content: '发送报价',
        conclusion: '继续推进',
        feedback: '等待确认',
        stageLabel: '已报价',
        nextAction: '再次联系',
        nextFollowAt: at,
      ),
    ],
    businessEvents: [
      BusinessExportRow(
        type: BusinessExportType.quote,
        sourceId: 4,
        eventAt: at,
        customerName: '上海医械',
        opportunityName: 'CT 双筒项目',
        reference: 'Q-001 v1',
        statusLabel: '等待反馈',
        product: 'CT-200',
        quantity: 100,
        currency: 'USD',
        amountMinor: 123456,
        nextAt: at,
        detail: '中文正常',
      ),
    ],
  );
}

XmlDocument _xml(Archive archive, String name) {
  final file = archive.files.singleWhere((entry) => entry.name == name);
  return XmlDocument.parse(utf8.decode(file.content as List<int>));
}
