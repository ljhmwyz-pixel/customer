import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:excel/excel.dart';
import 'package:xml/xml.dart';

import '../data/daos/export_dao.dart';

class ExcelWorkbookBuilder {
  const ExcelWorkbookBuilder();

  static const sheetNames = ['今日任务及看板', '客户及项目', '跟进记录', '报价样品订单追踪'];

  Uint8List build(ExcelExportSnapshot snapshot) {
    final excel = Excel.createExcel();
    excel.rename('Sheet1', sheetNames.first);
    for (final name in sheetNames.skip(1)) {
      excel[name];
    }
    _tasks(excel[sheetNames[0]], snapshot.todayTasks);
    _projects(excel[sheetNames[1]], snapshot.customerProjects);
    _followups(excel[sheetNames[2]], snapshot.followups);
    _business(excel[sheetNames[3]], snapshot.businessEvents);
    final encoded = excel.encode();
    if (encoded == null) throw StateError('Excel 编码失败');
    return _patchOoxml(Uint8List.fromList(encoded));
  }

  void _tasks(Sheet sheet, List<TaskExportRow> rows) {
    _header(sheet, [
      '计划日期',
      '逾期天数',
      '状态',
      '客户',
      '项目',
      '原因',
      '下一步',
      '负责人',
      '沟通方向',
    ]);
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      sheet.appendRow([
        _date(row.planAt),
        FormulaCellValue('MAX(0,TODAY()-A${i + 2})'),
        _text(row.statusLabel),
        _text(row.customerName),
        _text(row.opportunityName),
        _text(row.reason),
        _text(row.nextAction),
        _text(row.owner),
        _text(row.talkingDirection),
      ]);
    }
    _finish(sheet, moneyColumns: const {}, percentColumns: const {});
  }

  void _projects(Sheet sheet, List<CustomerProjectExportRow> rows) {
    _header(sheet, [
      '客户',
      '公司',
      '国家/地区',
      '客户阶段',
      '等级',
      '项目',
      '负责人',
      '项目阶段',
      '项目状态',
      '产品',
      '预计金额',
      '币种',
      '成交概率',
      '预计关闭',
      '当前供应商',
      '最新反馈',
      '当前阻碍',
      '下一步',
      '下次跟进',
    ]);
    for (final row in rows) {
      sheet.appendRow([
        _text(row.customerName),
        _text(row.company),
        _text(row.country),
        _text(row.customerStageLabel),
        _text(row.grade),
        _text(row.opportunityName),
        _text(row.owner),
        _text(row.opportunityStageLabel),
        _text(row.opportunityStatusLabel),
        _text(row.productModel ?? row.productCategory),
        _money(row.forecastAmountMinor),
        _text(row.currency),
        row.probabilityPercent == null
            ? null
            : DoubleCellValue(row.probabilityPercent! / 100),
        _date(row.expectedCloseAt),
        _text(row.currentSupplier),
        _text(row.latestFeedback),
        _text(row.currentObstacle),
        _text(row.nextAction),
        _date(row.nextFollowAt),
      ]);
    }
    _finish(sheet, moneyColumns: const {10}, percentColumns: const {12});
  }

  void _followups(Sheet sheet, List<FollowupExportRow> rows) {
    _header(sheet, [
      '跟进日期',
      '客户',
      '项目',
      '方式',
      '沟通内容',
      '结论',
      '客户反馈',
      '阶段',
      '下一步',
      '下次跟进',
    ]);
    for (final row in rows) {
      sheet.appendRow([
        _date(row.occurredAt),
        _text(row.customerName),
        _text(row.opportunityName),
        _text(row.methodLabel),
        _text(row.content),
        _text(row.conclusion),
        _text(row.feedback),
        _text(row.stageLabel),
        _text(row.nextAction),
        _date(row.nextFollowAt),
      ]);
    }
    _finish(sheet, moneyColumns: const {}, percentColumns: const {});
  }

  void _business(Sheet sheet, List<BusinessExportRow> rows) {
    _header(sheet, [
      '业务日期',
      '类型',
      '客户',
      '项目',
      '编号/引用',
      '状态',
      '产品',
      '数量',
      '金额',
      '币种',
      '下一节点',
      '备注',
    ]);
    for (final row in rows) {
      sheet.appendRow([
        _date(row.eventAt),
        _text(_businessType(row.type)),
        _text(row.customerName),
        _text(row.opportunityName),
        _text(row.reference),
        _text(row.statusLabel),
        _text(row.product),
        row.quantity == null ? null : IntCellValue(row.quantity!),
        _money(row.amountMinor),
        _text(row.currency),
        _date(row.nextAt),
        _text(row.detail),
      ]);
    }
    _finish(sheet, moneyColumns: const {8}, percentColumns: const {});
  }

  void _header(Sheet sheet, List<String> headers) {
    sheet.appendRow(headers.map(TextCellValue.new).toList());
    final style = CellStyle(
      bold: true,
      fontColorHex: ExcelColor.white,
      backgroundColorHex: ExcelColor.fromHexString('FF1F4E78'),
      verticalAlign: VerticalAlign.Center,
    );
    for (var i = 0; i < headers.length; i++) {
      sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
              .cellStyle =
          style;
      sheet.setColumnWidth(i, i < 5 ? 16 : 22);
    }
    sheet.setRowHeight(0, 24);
  }

  void _finish(
    Sheet sheet, {
    required Set<int> moneyColumns,
    required Set<int> percentColumns,
  }) {
    for (var row = 1; row < sheet.maxRows; row++) {
      for (var column = 0; column < sheet.maxColumns; column++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: column, rowIndex: row),
        );
        cell.cellStyle = CellStyle(
          verticalAlign: VerticalAlign.Top,
          textWrapping: TextWrapping.WrapText,
          numberFormat: moneyColumns.contains(column)
              ? NumFormat.standard_4
              : percentColumns.contains(column)
              ? NumFormat.standard_9
              : NumFormat.defaultFor(cell.value),
        );
      }
    }
  }

  CellValue? _text(String? value) =>
      value == null || value.isEmpty ? null : TextCellValue(value);
  CellValue? _date(DateTime? value) =>
      value == null ? null : DateCellValue.fromDateTime(value.toLocal());
  CellValue? _money(int? minor) =>
      minor == null ? null : DoubleCellValue(minor / 100);

  String _businessType(BusinessExportType type) => switch (type) {
    BusinessExportType.quote => '报价',
    BusinessExportType.sample => '样品',
    BusinessExportType.registration => '注册',
    BusinessExportType.tender => '招标',
    BusinessExportType.order => '订单',
  };

  Uint8List _patchOoxml(Uint8List bytes) {
    final source = ZipDecoder().decodeBytes(bytes);
    final replacements = <String, List<int>>{};
    final workbook = _document(source, 'xl/workbook.xml');
    final calc = workbook.findAllElements('calcPr').firstOrNull;
    if (calc == null) {
      workbook.rootElement.children.add(
        XmlElement(XmlName('calcPr'), [
          XmlAttribute(XmlName('calcMode'), 'auto'),
        ]),
      );
    } else {
      calc.setAttribute('calcMode', 'auto');
      calc.setAttribute('fullCalcOnLoad', '1');
    }
    replacements['xl/workbook.xml'] = utf8.encode(workbook.toXmlString());

    final styles = _document(source, 'xl/styles.xml');
    _differentialStyles(styles);
    replacements['xl/styles.xml'] = utf8.encode(styles.toXmlString());

    const statusColumns = ['C', 'I', 'H', 'F'];
    for (var i = 0; i < sheetNames.length; i++) {
      final path = 'xl/worksheets/sheet${i + 1}.xml';
      final sheet = _document(source, path);
      final dimension = sheet
          .findAllElements('dimension')
          .first
          .getAttribute('ref')!;
      final endCell = dimension.contains(':')
          ? dimension.split(':').last
          : dimension;
      final lastRow = int.parse(RegExp(r'\d+').firstMatch(endCell)!.group(0)!);
      _freeze(sheet);
      _filter(sheet, dimension);
      _conditional(sheet, statusColumns[i], lastRow < 2 ? 2 : lastRow);
      replacements[path] = utf8.encode(sheet.toXmlString());
    }

    final output = Archive();
    for (final file in source.files) {
      if (!file.isFile) continue;
      final content =
          replacements[file.name] ?? List<int>.from(file.content as List<int>);
      output.addFile(ArchiveFile(file.name, content.length, content));
    }
    final encoded = ZipEncoder().encode(output);
    if (encoded == null) throw StateError('Excel OOXML 打包失败');
    return Uint8List.fromList(encoded);
  }

  void _freeze(XmlDocument document) {
    final sheetViews = document.findAllElements('sheetViews').first;
    final view = sheetViews.findElements('sheetView').first;
    view.children.removeWhere(
      (node) =>
          node is XmlElement && {'pane', 'selection'}.contains(node.name.local),
    );
    view.children.addAll([
      XmlElement(XmlName('pane'), [
        XmlAttribute(XmlName('ySplit'), '1'),
        XmlAttribute(XmlName('topLeftCell'), 'A2'),
        XmlAttribute(XmlName('activePane'), 'bottomLeft'),
        XmlAttribute(XmlName('state'), 'frozen'),
      ]),
      XmlElement(XmlName('selection'), [
        XmlAttribute(XmlName('pane'), 'bottomLeft'),
        XmlAttribute(XmlName('activeCell'), 'A2'),
        XmlAttribute(XmlName('sqref'), 'A2'),
      ]),
    ]);
  }

  void _filter(XmlDocument document, String range) {
    final root = document.rootElement;
    root.children.removeWhere(
      (node) => node is XmlElement && node.name.local == 'autoFilter',
    );
    final sheetData = root.findElements('sheetData').first;
    final index = root.children.indexOf(sheetData);
    root.children.insert(
      index + 1,
      XmlElement(XmlName('autoFilter'), [XmlAttribute(XmlName('ref'), range)]),
    );
  }

  void _conditional(XmlDocument document, String column, int lastRow) {
    final root = document.rootElement;
    final rules = <XmlNode>[];
    for (final definition in const [
      (text: '逾期', dxfId: '0', priority: '1'),
      (text: '等待', dxfId: '1', priority: '2'),
      (text: '完成', dxfId: '2', priority: '3'),
    ]) {
      rules.add(
        XmlElement(
          XmlName('cfRule'),
          [
            XmlAttribute(XmlName('type'), 'containsText'),
            XmlAttribute(XmlName('operator'), 'containsText'),
            XmlAttribute(XmlName('text'), definition.text),
            XmlAttribute(XmlName('dxfId'), definition.dxfId),
            XmlAttribute(XmlName('priority'), definition.priority),
          ],
          [
            XmlElement(XmlName('formula'), [], [
              XmlText('NOT(ISERROR(SEARCH("${definition.text}",${column}2)))'),
            ]),
          ],
        ),
      );
    }
    final element = XmlElement(XmlName('conditionalFormatting'), [
      XmlAttribute(XmlName('sqref'), '${column}2:$column$lastRow'),
    ], rules);
    final sheetData = root.findElements('sheetData').first;
    root.children.insert(root.children.indexOf(sheetData) + 2, element);
  }

  void _differentialStyles(XmlDocument document) {
    final root = document.rootElement;
    root.children.removeWhere(
      (node) => node is XmlElement && node.name.local == 'dxfs',
    );
    final dxfs = XmlElement(
      XmlName('dxfs'),
      [XmlAttribute(XmlName('count'), '3')],
      [
        _dxf('FFF4CCCC', 'FF9C0006'),
        _dxf('FFFFEB9C', 'FF9C6500'),
        _dxf('FFC6EFCE', 'FF006100'),
      ],
    );
    final cellStyles = root.findElements('cellStyles').firstOrNull;
    final index = cellStyles == null
        ? root.children.length
        : root.children.indexOf(cellStyles) + 1;
    root.children.insert(index, dxfs);
  }

  XmlElement _dxf(String fillColor, String fontColor) => XmlElement(
    XmlName('dxf'),
    const [],
    [
      XmlElement(XmlName('font'), const [], [
        XmlElement(XmlName('color'), [XmlAttribute(XmlName('rgb'), fontColor)]),
      ]),
      XmlElement(XmlName('fill'), const [], [
        XmlElement(
          XmlName('patternFill'),
          [XmlAttribute(XmlName('patternType'), 'solid')],
          [
            XmlElement(XmlName('fgColor'), [
              XmlAttribute(XmlName('rgb'), fillColor),
            ]),
            XmlElement(XmlName('bgColor'), [
              XmlAttribute(XmlName('indexed'), '64'),
            ]),
          ],
        ),
      ]),
    ],
  );

  XmlDocument _document(Archive archive, String name) {
    final file = archive.files.singleWhere((entry) => entry.name == name);
    return XmlDocument.parse(utf8.decode(file.content as List<int>));
  }
}
