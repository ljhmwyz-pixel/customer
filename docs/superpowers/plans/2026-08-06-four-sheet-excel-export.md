# Four-Sheet Excel Export Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Export the complete operational view as a shareable `.xlsx` workbook with four Chinese worksheets, correct typed values, filters, frozen headers, status formatting, and formulas.

**Architecture:** A read-only export DAO takes one consistent Drift snapshot and maps joined rows into four explicit export record types. A pure workbook builder uses `excel` for cells/styles and structurally patches the OOXML archive with `xml` for features the package does not expose; a small file/share adapter owns temporary output and Android sharing.

**Tech Stack:** Flutter 3.44.8, Drift 2.34.3, excel 4.0.6, archive 3.6.1, xml 6.6.1, share_plus 13.3.0, flutter_test.

## Global Constraints

- Export is read-only and never imports or writes business rows.
- Export always contains exactly four sheets: `今日任务及看板`, `客户及项目`, `跟进记录`, `报价样品订单追踪`.
- Every sheet has a frozen first row and an autofilter covering its full used range.
- Dates are real Excel date cells, money is numeric major-unit data with currency formatting, and percentages are numeric percentage cells.
- Status columns carry conditional formatting for active/warning/success/closed values.
- Formula cells use formulas and workbook calculation mode is automatic.
- Empty databases still produce valid sheets with headers.
- Chinese text must round-trip through XLSX decoding without corruption.
- Do not stage or modify `docs/superpowers/plans/2026-08-06-business-attachments.md`.
- Run Flutter commands serially.

---

### Task 1: Consistent Export Snapshot

**Files:**
- Create: `lib/data/daos/export_dao.dart`
- Modify: `lib/data/database.dart`
- Modify generated: `lib/data/database.g.dart`
- Create: `test/data/export_dao_test.dart`

**Interfaces:**
- Produces `Future<ExcelExportSnapshot> loadExcelSnapshot({required DateTime now})`.
- `ExcelExportSnapshot` contains `todayTasks`, `customerProjects`, `followups`, and `businessEvents` as immutable typed lists.
- The fourth list uses `BusinessExportType` values `quote`, `sample`, `registration`, `tender`, and `order` rather than lossy free text internally.

- [ ] Write failing tests that seed two customers and multiple projects, then assert all joins preserve customer/project names, enum labels, nullable fields, currency/minor amounts, and deterministic ordering.
- [ ] Run `flutter test test/data/export_dao_test.dart` and confirm failure because the DAO does not exist.
- [ ] Implement all four reads inside one `transaction` so rows cannot come from different database moments.
- [ ] Keep SQL ordering explicit: tasks by due time/id, projects by customer/id, follow-ups by occurrence/id, business events by event time/type/id.
- [ ] Regenerate Drift, format, and rerun the focused test.
- [ ] Commit with `阶段 F-6：建立 Excel 导出快照`.

### Task 2: Valid Four-Sheet Workbook

**Files:**
- Modify: `pubspec.yaml`
- Modify: `pubspec.lock`
- Create: `lib/services/excel_export_service.dart`
- Create: `test/services/excel_export_service_test.dart`

**Interfaces:**
- Produces `Uint8List ExcelWorkbookBuilder.build(ExcelExportSnapshot snapshot)`.
- Produces `ExcelWorkbookInspector` only in tests by decoding the XLSX ZIP with `archive` and parsing XML with `xml`.

- [ ] Write failing tests for exact sheet names and header order, Chinese round-trip, empty workbook validity, real date/numeric/percentage cells, formulas, auto calculation, frozen first rows, full-range filters, and conditional-format nodes.
- [ ] Add direct dependency `xml: 6.6.1`, matching the already resolved lockfile version.
- [ ] Build sheets with typed `TextCellValue`, `DateCellValue`, `IntCellValue`, `DoubleCellValue`, and `FormulaCellValue`; never pre-format dates or amounts as strings.
- [ ] Use a shared header style, bounded column widths, wrapped long text, and stable status colors that remain readable in common spreadsheet software.
- [ ] Decode the generated ZIP, map workbook relationships to each sheet XML, and use `XmlDocument` mutations to add `pane`, `selection`, `autoFilter`, and conditional-format rules. Set workbook calculation properties to automatic, then re-encode the archive.
- [ ] Parse the final bytes again in tests and assert all OOXML requirements rather than trusting builder calls.
- [ ] Run focused tests and `flutter analyze`.
- [ ] Commit with `阶段 F-7：生成四表 Excel 工作簿`.

### Task 3: File Export And Settings UI

**Files:**
- Create: `lib/services/excel_export_providers.dart`
- Create: `lib/features/settings/excel_export_page.dart`
- Modify: `lib/features/settings/settings_page.dart`
- Modify: `lib/router.dart`
- Create: `test/features/settings/excel_export_page_test.dart`

**Interfaces:**
- Produces `Future<ExcelExportResult> exportAndShare()` with file path, byte size, and share result.
- Route: `/settings/excel-export`.

- [ ] Write widget/service tests proving page open has no side effect, explicit export shows progress, double taps are blocked, success shows filename/size, and generation/share failures remain retryable.
- [ ] Generate under the cache directory with filename `客户业务导出_yyyyMMdd_HHmmss.xlsx`, write atomically through a temporary file plus rename, and share as XLSX MIME type through `SharePlus.instance.share(ShareParams(files: ...))`.
- [ ] Add a settings tile with `Icons.table_view_outlined`, title `Excel 导出`, and an enabled route.
- [ ] Format and pass focused tests plus `test/app_skeleton_test.dart`.
- [ ] Commit with `阶段 F-8：接入 Excel 导出入口`.

### Task 4: Acceptance And Handoff

**Files:**
- Modify: `docs/TEST_CHECKLIST.md`
- Modify: `docs/phase4/VERIFICATION.md`

- [ ] Run `flutter analyze` and full `flutter test` serially.
- [ ] Build debug and release APKs serially and record SHA-256 values.
- [ ] Export the retained emulator database, save through Android Sharesheet, and verify the resulting file is a nonempty ZIP/XLSX.
- [ ] Open the workbook in an installed compatible viewer when available; independently inspect OOXML for exact sheets, Unicode, pane/filter/conditional-format nodes, formulas, and typed date/money cells.
- [ ] Record evidence and any remaining OnePlus 13 / ColorOS 15 share-provider boundary.
- [ ] Commit with `阶段 F-9：完成 Excel 导出验收与交接`.
