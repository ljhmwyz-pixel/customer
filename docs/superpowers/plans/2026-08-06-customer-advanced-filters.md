# Customer Advanced Filters Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在现有客户快速筛选基础上增加产品、型号、设备品牌、项目状态、预计成交日期和三类业务异常筛选，并保证所有项目级条件由同一个项目满足。

**Architecture:** 保持现有 Flutter、Riverpod、Drift 分层。DAO 使用参数化 SQL 和相关子查询；Provider 保存不可变筛选状态；客户列表页沿用底部面板，并通过摘要 Chip 支持逐项清除。报价停滞、样品停滞和长期沉默复用现有业务规则，不修改数据库结构。

**Tech Stack:** Flutter, Dart, Riverpod, Drift/SQLite, flutter_test, Android Emulator

## Global Constraints

- 不修改 `lib/data/database.dart`、`lib/data/database.g.dart` 或 Drift schema 版本，不新增依赖。
- 保留现有关键字、快速筛选、默认紧急度排序和刷新行为。
- 产品字段和项目级异常必须位于同一个 `opportunities o` 的 `EXISTS` 中；多个项目不得拆分满足组合条件。
- 报价停滞：`quoted_at + 30 天 <= now` 且 `customer_received = false`。
- 样品停滞：已交付满 30 天，且 `test_result` 为 `NULL` 或 `TRIM` 后为空。
- 长期沉默：`COALESCE(last_follow_at, created_at)`；A 级 14 天、B 级 30 天、C/D 级 60 天，并排除成交、流失客户。
- 预计成交开始日期包含当天；结束日期包含全天，使用 `< startOfNextDay(endDate)`；只设置一端时单边生效。
- 本地日历边界转成项目现有 UTC 毫秒约定；UI 不得保存结束日早于开始日的范围。
- 动态文本选项均需 `TRIM`、去空、去重、排序。
- 每项任务先写失败测试，再最小实现，再运行目标验证。
- 实现阶段不创建中间提交；完整验证后由用户确认，再精确暂存并创建一个 F-3 提交。
- Android 验收仅覆盖安装，不卸载应用、不清除数据、不重置模拟器数据库。

---

## Task 1: 锁定 DAO 动态选项和基础高级字段契约

**Files:**

- Modify: `test/data/query_test.dart`
- Modify: `lib/data/daos/customer_dao.dart`

**Interfaces:**

- Consumes: 项目产品字段、`OpportunityStatus`、现有 `CustomerFilterOptions` 和客户查询入口。
- Produces: 三组清洗后的动态选项、DAO 高级筛选参数、`CustomerAnomalyFilter` 类型。

- [ ] 在 `test/data/query_test.dart` 写 `customer advanced filter options` 失败测试，插入前后空格、重复、`NULL`、空白值。
- [ ] 断言产品大类、具体型号、设备品牌的结果均已 `TRIM`、去空、去重、升序排列。
- [ ] 写 `customer project advanced fields` 失败测试，分别覆盖产品大类、型号、设备品牌、项目状态，再覆盖四项组合。
- [ ] 组合数据包含完全匹配、只匹配部分字段、属于另一客户的项目，只返回完全匹配客户。
- [ ] 运行失败测试：

```bash
flutter test test/data/query_test.dart --plain-name 'customer advanced filter options'
flutter test test/data/query_test.dart --plain-name 'customer project advanced fields'
```

预期：新增接口缺失导致编译失败，或新增断言因 DAO 尚未支持而失败。

- [ ] 在 `customer_dao.dart` 新增：

```dart
enum CustomerAnomalyFilter {
  stalledQuote,
  stalledSample,
  longSilence,
}
```

- [ ] 扩展 `CustomerFilterOptions`：

```dart
final List<String> productCategories;
final List<String> productModels;
final List<String> equipmentBrands;
```

- [ ] 扩展客户查询入口，参数保持可选：

```dart
String? productCategory,
String? productModel,
String? equipmentBrand,
OpportunityStatus? opportunityStatus,
DateTime? expectedCloseFrom,
DateTime? expectedCloseTo,
Set<CustomerAnomalyFilter> anomalies = const {},
```

- [ ] 三个动态选项查询分别实现等价逻辑：

```sql
SELECT DISTINCT TRIM(product_category)
FROM opportunities
WHERE product_category IS NOT NULL
  AND TRIM(product_category) <> ''
ORDER BY TRIM(product_category)
```

- [ ] 将普通项目字段放入同一个项目级 `EXISTS`，使用参数绑定；状态以 `OpportunityStatus` 数据库存储值精确匹配。
- [ ] 运行通过验证：

```bash
flutter test test/data/query_test.dart --plain-name 'customer advanced filter options'
flutter test test/data/query_test.dart --plain-name 'customer project advanced fields'
```

预期：新增测试全部通过；未传新增条件时原查询结果不变。

- [ ] 暂停并汇报 Task 1 的实现和证据；不提交 Git，确认差异后进入 Task 2。

---

## Task 2: 实现日期、异常和同项目组合语义

**Files:**

- Modify: `test/data/query_test.dart`
- Modify: `lib/data/daos/customer_dao.dart`

**Interfaces:**

- Consumes: Task 1 DAO 参数、报价、样品、客户等级/阶段/最后跟进时间。
- Produces: 日期范围、三类异常筛选及不可跨项目误命中的组合查询。

- [ ] 写 `customer expected close date filters` 失败测试：开始日当天命中、开始日前不命中、结束日末命中、次日零点不命中、仅开始、仅结束。
- [ ] 写 `customer anomaly filters` 失败测试：报价 29 天不命中、30 天命中、已收到不命中；样品 29 天不命中、30 天命中、有结果不命中、空白结果命中、未交付不命中。
- [ ] 长期沉默覆盖 A 级 13/14、B 级 29/30、C/D 级 59/60 天边界，并验证成交/流失始终排除。
- [ ] 写 `customer advanced filters require the same opportunity` 失败测试：产品条件在项目 A、停滞报价在项目 B 时不得命中。
- [ ] 同时选择报价、样品停滞时，项目 A 只有报价、项目 B 只有样品不得命中；同一项目全部满足时才命中。
- [ ] 写 `customer default urgency order remains unchanged` 回归测试。
- [ ] 运行失败测试：

```bash
flutter test test/data/query_test.dart --plain-name 'customer expected close date filters'
flutter test test/data/query_test.dart --plain-name 'customer anomaly filters'
flutter test test/data/query_test.dart --plain-name 'customer advanced filters require the same opportunity'
flutter test test/data/query_test.dart --plain-name 'customer default urgency order remains unchanged'
```

预期：前三组因能力缺失失败；已有默认排序仍通过。

- [ ] DAO 为每次查询只获取一次 `now` 快照；如现有接口无可测试时钟，则加入可选 `DateTime? now`，生产默认当前时间。
- [ ] 日期边界按本地日历构造，再转成项目现有 UTC 毫秒：

```dart
DateTime startOfLocalDay(DateTime value) =>
    DateTime(value.year, value.month, value.day);
DateTime startOfNextLocalDay(DateTime value) =>
    DateTime(value.year, value.month, value.day + 1);
```

- [ ] 开始条件为 `o.expected_close_at >= ?`；结束条件为 `o.expected_close_at < ?`。
- [ ] 普通项目条件和项目级异常使用同一个相关子查询：

```sql
EXISTS (
  SELECT 1
  FROM opportunities o
  WHERE o.customer_id = c.id
    AND /* project predicates */
    AND EXISTS (
      SELECT 1 FROM quotes q
      WHERE q.opportunity_id = o.id
        AND q.customer_received = 0
        AND q.quoted_at <= ?
    )
    AND EXISTS (
      SELECT 1 FROM samples s
      WHERE s.opportunity_id = o.id
        AND s.delivered_at IS NOT NULL
        AND s.delivered_at <= ?
        AND (s.test_result IS NULL OR TRIM(s.test_result) = '')
    )
)
```

- [ ] 仅在对应异常被选择时拼接内部 `EXISTS`；报价和样品阈值均绑定同一 `now - 30 天`。
- [ ] 将 `Quotes`、`Samples` 加入 DAO 导入、`@DriftAccessor` 和流查询 `readsFrom`，优先引用现有表，不生成 schema 文件。
- [ ] 长期沉默作为客户级外层条件：

```sql
c.stage NOT IN ('deal', 'lost')
AND (? - COALESCE(c.last_follow_at, c.created_at)) >=
  CASE c.grade
    WHEN 'a' THEN 14 * 86400000
    WHEN 'b' THEN 30 * 86400000
    ELSE 60 * 86400000
  END
```

- [ ] 仅选长期沉默时不要求客户存在项目；叠加项目条件时两类条件同时生效。
- [ ] 运行通过验证：

```bash
flutter test test/data/query_test.dart --plain-name 'customer expected close date filters'
flutter test test/data/query_test.dart --plain-name 'customer anomaly filters'
flutter test test/data/query_test.dart --plain-name 'customer advanced filters require the same opportunity'
flutter test test/data/query_test.dart --plain-name 'customer default urgency order remains unchanged'
```

预期：日期、异常、同项目约束和排序测试全部通过。

- [ ] 暂停并汇报 Task 2；不提交 Git，明确生成文件预期为零。

---

## Task 3: 扩展 Riverpod 筛选状态并接通 DAO

**Files:**

- Modify: `test/features/customers/customer_pages_test.dart`
- Modify: `lib/features/customers/customer_providers.dart`

**Interfaces:**

- Consumes: DAO 新参数和 `CustomerAnomalyFilter`。
- Produces: 不可变高级筛选状态、更新/清除方法、完整 DAO 参数透传。

- [ ] 写 `customer advanced filter state` 失败测试，验证每个 setter 只更新对应字段。
- [ ] 验证异常可多选、再次切换可移除，且外部集合修改不会影响 `copyWith` 后的状态。
- [ ] 验证三个文本字段、项目状态、日期起止、每个异常分别计数。
- [ ] 写 `customer advanced filter clear behavior`：清除筛选保留关键字；清除关键字保留高级筛选。
- [ ] 运行失败测试：

```bash
flutter test test/features/customers/customer_pages_test.dart --plain-name 'customer advanced filter state'
flutter test test/features/customers/customer_pages_test.dart --plain-name 'customer advanced filter clear behavior'
```

预期：新增字段/方法缺失或状态断言失败。

- [ ] 扩展 `CustomerFilter`：

```dart
final String? productCategory;
final String? productModel;
final String? equipmentBrand;
final OpportunityStatus? opportunityStatus;
final DateTime? expectedCloseFrom;
final DateTime? expectedCloseTo;
final Set<CustomerAnomalyFilter> anomalies;
```

- [ ] 构造函数和 `copyWith` 对异常集合使用 `Set.unmodifiable(...)` 防御性复制。
- [ ] Notifier 增加三个文本 setter、项目状态 setter、两个日期 setter、`toggleAnomaly` 和 `clearAnomalies`。
- [ ] 空白文本归一为 `null`。日期策略固定为：设置开始日晚于现有结束日时清除结束日；设置结束日早于开始日时拒绝该值。
- [ ] 更新 `activeFilterCount`；日期两端各计一项，每个异常各计一项。
- [ ] 现有清除筛选重置快速和高级筛选但保留关键字；独立关键字清除不碰筛选。
- [ ] 将全部新字段传给 `CustomerDao.watchCustomers(...)`，任一变化均重新订阅查询。
- [ ] 运行通过验证：

```bash
flutter test test/features/customers/customer_pages_test.dart --plain-name 'customer advanced filter state'
flutter test test/features/customers/customer_pages_test.dart --plain-name 'customer advanced filter clear behavior'
flutter test test/data/query_test.dart
```

预期：状态、清除和 DAO 查询测试通过。

- [ ] 暂停并汇报 Task 3；不提交 Git。

---

## Task 4: 实现高级筛选控件、日期和异常多选

**Files:**

- Modify: `test/features/customers/customer_pages_test.dart`
- Modify: `lib/features/customers/customers_page.dart`

**Interfaces:**

- Consumes: 新动态选项、筛选状态和 Notifier。
- Produces: 底部面板中的高级控件、合法日期交互、异常多选。

- [ ] 写 `customer advanced filter controls` 失败测试并操作以下 Key：

```text
customer-product-category-filter
customer-product-model-filter
customer-equipment-brand-filter
customer-opportunity-status-filter
customer-expected-close-from
customer-expected-close-to
customer-anomaly-stalled-quote
customer-anomaly-stalled-sample
customer-anomaly-long-silence
```

- [ ] 验证选择产品、型号、品牌、项目状态后筛选数量增加，重开面板仍保留。
- [ ] 写 `customer expected close date controls`：两端显示本地日期，结束日早于开始日时不保存无效范围。
- [ ] 写 `customer anomaly multi select`：三项可同时启用，再点单项只移除该项，计数同步。
- [ ] 运行失败测试：

```bash
flutter test test/features/customers/customer_pages_test.dart --plain-name 'customer advanced filter controls'
flutter test test/features/customers/customer_pages_test.dart --plain-name 'customer expected close date controls'
flutter test test/features/customers/customer_pages_test.dart --plain-name 'customer anomaly multi select'
```

预期：新增 Key 不存在或交互断言失败。

- [ ] 在现有 `customer-filters-sheet` / `customer-filters-list` 增加项目信息、预计成交日期、业务异常分组。
- [ ] 产品字段沿用动态选择样式；项目状态显示本地化文案但保存枚举。
- [ ] 日期使用纵向 `ListTile` 或全宽按钮调用 `showDatePicker`，每端可单独清除；不做窄屏横排。
- [ ] 结束日期选择器不得选择早于开始日的日期；`initialDate`、`firstDate`、`lastDate` 始终合法。
- [ ] 异常文案固定为“报价停滞（30 天未确认收到）”“样品停滞（交付 30 天无测试反馈）”“长期沉默（按客户等级）”。
- [ ] UI 只编辑枚举，不复制 DAO 的 SQL 判断。
- [ ] 运行通过验证：

```bash
flutter test test/features/customers/customer_pages_test.dart --plain-name 'customer advanced filter controls'
flutter test test/features/customers/customer_pages_test.dart --plain-name 'customer expected close date controls'
flutter test test/features/customers/customer_pages_test.dart --plain-name 'customer anomaly multi select'
```

预期：控件、日期合法性和异常多选全部通过。

- [ ] 暂停并汇报 Task 4；不提交 Git。

---

## Task 5: 摘要逐项删除、清除语义和窄屏回归

**Files:**

- Modify: `test/features/customers/customer_pages_test.dart`
- Modify: `lib/features/customers/customers_page.dart`

**Interfaces:**

- Consumes: Task 4 UI 和 Task 3 清除方法。
- Produces: 独立摘要 Chip、互不干扰的清除行为、320×700 无溢出布局。

- [ ] 写 `customer advanced filter summary chips` 失败测试，覆盖以下 Key：

```text
customer-filter-chip-product-category
customer-filter-chip-product-model
customer-filter-chip-equipment-brand
customer-filter-chip-opportunity-status
customer-filter-chip-expected-close-from
customer-filter-chip-expected-close-to
customer-filter-chip-stalled-quote
customer-filter-chip-stalled-sample
customer-filter-chip-long-silence
```

- [ ] 逐项删除 Chip，验证只清对应条件，其他筛选和关键字不变，计数减一。
- [ ] 写 `customer advanced filters clear independently from keyword`，验证两个方向的独立清除语义。
- [ ] 写 `customer advanced filters fit 320x700`，打开面板、滚动、启用多项条件并返回列表，断言无 overflow。
- [ ] 运行失败测试：

```bash
flutter test test/features/customers/customer_pages_test.dart --plain-name 'customer advanced filter summary chips'
flutter test test/features/customers/customer_pages_test.dart --plain-name 'customer advanced filters clear independently from keyword'
flutter test test/features/customers/customer_pages_test.dart --plain-name 'customer advanced filters fit 320x700'
```

预期：摘要 Key、清除或布局断言失败。

- [ ] 为每个非空高级条件渲染独立可删除 Chip；日期文案为“预计成交自/至 YYYY-MM-DD”。
- [ ] Chip 删除动作调用对应 setter 或 `toggleAnomaly`，不得重建并误清其他条件。
- [ ] 摘要可换行或横向滚动，底部面板主体保持可滚动并适配安全区。
- [ ] 复用 `clear-customer-filters`、`clear-customer-filter-sheet` 的既有语义和 Key。
- [ ] 运行通过验证：

```bash
flutter test test/features/customers/customer_pages_test.dart --plain-name 'customer advanced filter summary chips'
flutter test test/features/customers/customer_pages_test.dart --plain-name 'customer advanced filters clear independently from keyword'
flutter test test/features/customers/customer_pages_test.dart --plain-name 'customer advanced filters fit 320x700'
flutter test test/features/customers/customer_pages_test.dart
```

预期：摘要、清除、窄屏和客户页面全量测试通过。

- [ ] 暂停并汇报 Task 5；不提交 Git。

---

## Task 6: 性能、质量门禁、APK 和 Android 验收

**Files:**

- Modify: `test/data/performance_test.dart`
- Verify: `lib/data/daos/customer_dao.dart`
- Verify: `lib/features/customers/customer_providers.dart`
- Verify: `lib/features/customers/customers_page.dart`
- Verify: `test/data/query_test.dart`
- Verify: `test/features/customers/customer_pages_test.dart`

**Interfaces:**

- Consumes: 完整 F-3 实现。
- Produces: 500 客户性能证据、全量验证、APK 和模拟器验收记录。

- [ ] 写 `500 customer advanced combined filter completes under 200ms`，构造 500 客户、多项目、多报价、多样品和不同沉默等级。
- [ ] 组合至少包含产品、型号、品牌、项目状态、预计成交范围、报价停滞和样品停滞；预热一次后测量，要求 `< 200ms`。
- [ ] 运行性能测试：

```bash
flutter test test/data/performance_test.dart --plain-name '500 customer advanced combined filter completes under 200ms'
```

预期：测试通过并记录实际耗时；失败时检查查询计划，不放宽阈值掩盖问题。

- [ ] 检查差异只包含 F-3 预期文件：

```bash
git status --short
git diff -- lib/data/daos/customer_dao.dart lib/features/customers/customer_providers.dart lib/features/customers/customers_page.dart test/data/query_test.dart test/data/performance_test.dart test/features/customers/customer_pages_test.dart
```

- [ ] 运行完整质量门禁：

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
git diff --check
```

预期：格式退出码 0；分析为 `No issues found!`；全量测试通过；APK 位于 `build/app/outputs/flutter-apk/app-debug.apk`；无空白错误。

- [ ] 检查现有 Android 设备：

```bash
adb devices -l
flutter devices
```

- [ ] 优先对 `emulator-5554` 覆盖安装，保留数据：

```bash
adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-debug.apk
```

预期：输出 `Success`。

- [ ] 人工验证面板滚动、产品字段、项目状态、单边/双边日期、反向日期阻止、异常多选、摘要逐项删除、两类清除行为和窄屏布局。
- [ ] 只记录模拟器现有数据可观察到的结果；缺少异常样本时以自动化边界测试为规则证据，不夸大人工覆盖。
- [ ] 最终检查：

```bash
git diff --check
git status --short --branch
```

- [ ] 汇报改动、测试、性能、APK、模拟器证据和限制，等待用户明确确认后进入 Task 7。

---

## Task 7: 用户确认后精确暂存并提交 F-3

**Files:**

- Stage: `lib/data/daos/customer_dao.dart`
- Stage: `lib/features/customers/customer_providers.dart`
- Stage: `lib/features/customers/customers_page.dart`
- Stage: `test/data/query_test.dart`
- Stage: `test/data/performance_test.dart`
- Stage: `test/features/customers/customer_pages_test.dart`
- Stage: `docs/superpowers/plans/2026-08-06-customer-advanced-filters.md`

**Interfaces:**

- Consumes: 用户对 Task 6 结果的明确确认。
- Produces: 单一、可审计的 F-3 Git 提交。

- [ ] 未获得用户确认时停止，不暂存、不提交。
- [ ] 提交前检查：

```bash
git diff --check
git status --short --branch
```

- [ ] 只精确暂存 F-3 文件：

```bash
git add lib/data/daos/customer_dao.dart lib/features/customers/customer_providers.dart lib/features/customers/customers_page.dart test/data/query_test.dart test/data/performance_test.dart test/features/customers/customer_pages_test.dart docs/superpowers/plans/2026-08-06-customer-advanced-filters.md
```

- [ ] 检查暂存内容：

```bash
git diff --cached --check
git diff --cached --stat
git status --short
```

- [ ] 创建单一提交：

```bash
git commit -m "阶段 F-3：实现客户项目高级筛选"
```

- [ ] 验证提交：

```bash
git show --stat --oneline --summary HEAD
git status --short --branch
```

预期：HEAD 信息为 `阶段 F-3：实现客户项目高级筛选`，没有无关文件。

- [ ] 汇报提交哈希、最终验证和工作区状态，再共同确定下一阶段。
