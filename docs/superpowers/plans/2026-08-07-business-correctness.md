# Business Correctness Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 接通自动业务任务生产链路，并修正看板的多币种、停滞统计和异常入口。

**Architecture:** 保留 `BusinessTaskRules` 作为唯一规则计算器，扩展为可重复执行的 reconcile 操作；业务服务完成数据写入后统一调用它。看板金额改为按币种分组，不引入汇率；异常类型复用已有客户筛选口径。

**Tech Stack:** Flutter、Riverpod、Drift/SQLite、flutter_test、现有 `ReminderScheduler`

## Global Constraints

- 不包含一加 13 / ColorOS 15 真机验收。
- 不引入网络、账号、云同步或汇率服务。
- 业务记录必须先持久化；提醒排程失败不得回滚业务数据。
- 自动任务必须保持 `sourceType + sourceId + ruleKey` 去重。
- 每个任务先写失败测试，再实现，再运行定向及完整测试。

---

### Task 1: 自动任务协调器与失效任务清理

**Files:**
- Modify: `lib/services/business_task_rules.dart`
- Modify: `lib/data/daos/plan_dao.dart`
- Test: `test/services/business_task_rules_test.dart`
- Test: `test/data/query_test.dart`

**Interfaces:**
- Produce: `Future<BusinessTaskSyncResult> reconcileForOpportunity(int opportunityId, {required DateTime now})`
- Produce: `Future<List<FollowPlanRow>> listOpenAutomaticOfOpportunity(int opportunityId)`
- Produce: `BusinessTaskSyncResult(createdIds, cancelledIds, warnings)`

- [ ] **Step 1: 写失败测试，覆盖重复 reconcile 不新增任务**

```dart
final first = await rules.reconcileForOpportunity(id, now: now);
final second = await rules.reconcileForOpportunity(id, now: now);
expect(first.createdIds, isNotEmpty);
expect(second.createdIds, isEmpty);
```

- [ ] **Step 2: 写失败测试，业务状态变化后取消不再适用的开放任务**

```dart
await rules.reconcileForOpportunity(id, now: now);
await db.sampleDao.updateMilestone(sampleId, status: SampleStatus.cancelled);
final result = await rules.reconcileForOpportunity(id, now: now);
expect(result.cancelledIds, isNotEmpty);
```

- [ ] **Step 3: 在 `PlanDao` 增加自动开放任务查询**

查询条件必须同时满足：项目相同、状态开放、`source_type` 属于 quote/sample/registration/tender/repurchase、`rule_key IS NOT NULL`。

- [ ] **Step 4: 将候选规则键集合与现有开放任务做差集**

保留已经完成或已取消的历史记录；只取消当前已不适用的开放任务，并逐条调用 `ReminderScheduler.cancelForPlan`。

- [ ] **Step 5: 返回结构化同步结果**

```dart
class BusinessTaskSyncResult {
  const BusinessTaskSyncResult({
    this.createdIds = const [],
    this.cancelledIds = const [],
    this.warnings = const [],
  });
  final List<int> createdIds;
  final List<int> cancelledIds;
  final List<String> warnings;
}
```

- [ ] **Step 6: 运行定向测试**

Run: `flutter test test/services/business_task_rules_test.dart test/data/query_test.dart`

Expected: 新增 reconcile、去重、取消和调度降级用例全部通过。

### Task 2: 接入报价、样品、注册、招标和订单服务

**Files:**
- Modify: `lib/features/business/business_providers.dart`
- Modify: `lib/features/orders/order_providers.dart`
- Modify: `lib/services/service_providers.dart`
- Test: `test/features/business/business_service_test.dart`
- Test: `test/features/orders/order_service_test.dart`
- Test: `test/features/business/business_pages_test.dart`
- Test: `test/features/business/phase_e_pages_test.dart`

**Interfaces:**
- Consume: `BusinessTaskRules.reconcileForOpportunity(...)`
- Produce: `WriteResult<int>` for creates and `WriteResult<void>` for updates where the UI needs a warning

- [ ] **Step 1: 新增 `businessTaskRulesProvider`**

```dart
final businessTaskRulesProvider = Provider<BusinessTaskRules>(
  (ref) => BusinessTaskRules(
    ref.watch(databaseProvider),
    ref.watch(reminderSchedulerProvider),
  ),
);
```

- [ ] **Step 2: 向 `BusinessService` 和 `OrderService` 注入规则协调器**

构造器测试可传 fake；生产 provider 必须注入 `businessTaskRulesProvider`。

- [ ] **Step 3: 为每个 create/update 写失败服务测试**

断言保存报价、样品节点、注册、招标和已完成订单后，对应 `follow_plans` 中出现预期规则键；再次保存不重复。

- [ ] **Step 4: 业务写入成功后执行 reconcile**

DAO 写入和业务校验保持原事务边界；reconcile 在业务提交后执行。规则或排程异常转为 warning，不删除已保存记录。

- [ ] **Step 5: 页面显示非阻断警告并刷新首页/客户详情/看板 provider**

保存成功仍返回详情；warning 使用 `SnackBar`，文案明确“记录已保存，任务将在下次启动重建提醒”。

- [ ] **Step 6: 运行服务和页面测试**

Run: `flutter test test/features/business test/features/orders`

### Task 3: 按币种统计看板金额

**Files:**
- Modify: `lib/data/daos/customer_dao.dart`
- Modify: `lib/features/funnel/funnel_page.dart`
- Test: `test/data/dashboard_query_test.dart`
- Test: `test/features/funnel/funnel_page_test.dart`

**Interfaces:**
- Produce: `Map<String, int> forecastByCurrency`
- Produce: `Map<String, int> weightedForecastByCurrency`
- Produce: `Map<String, int> wonByCurrency`

- [ ] **Step 1: 写 USD、EUR、JPY 混合数据失败测试**

```dart
expect(metrics.forecastByCurrency, {'USD': 120000, 'EUR': 90000});
expect(metrics.wonByCurrency, {'USD': 88000, 'JPY': 1200000});
```

- [ ] **Step 2: 将 SQL 改为 `GROUP BY currency`**

预测读取 `opportunities.currency`；成交读取 `orders.currency`。币种统一大写，空值按模型默认值处理。

- [ ] **Step 3: 页面按币种逐行格式化**

新增纯函数 `formatMinorAmount(String currency, int amountMinor)`；USD/EUR/CNY 显示两位小数，JPY 显示整数。禁止再显示原始最小单位总和。

- [ ] **Step 4: 删除旧的单整数 DashboardMetrics 字段**

同步修正所有构造、fixture 和测试，不保留容易误用的兼容 getter。

- [ ] **Step 5: 运行定向测试**

Run: `flutter test test/data/dashboard_query_test.dart test/features/funnel/funnel_page_test.dart`

### Task 4: 补齐报价/样品停滞统计与异常入口

**Files:**
- Modify: `lib/data/daos/customer_dao.dart`
- Modify: `lib/features/customers/customer_providers.dart`
- Modify: `lib/features/funnel/funnel_page.dart`
- Test: `test/data/dashboard_query_test.dart`
- Test: `test/features/funnel/funnel_page_test.dart`

**Interfaces:**
- Extend: `DashboardAnomalyKind.stalledQuote`, `quoteExpiring`, `stalledSample`
- Change: `stalledQuoteCount` and `stalledSampleCount` to non-nullable `int`

- [ ] **Step 1: 用边界时间写失败测试**

报价 29/30 天、有效期 8/7 天、样品签收 29/30 天分别覆盖不命中和命中。

- [ ] **Step 2: 复用高级筛选已有 SQL 判定口径**

不要在 Dart 中复制另一套天数逻辑；将共同 SQL 条件提取为 DAO 私有构造或同一 CTE。

- [ ] **Step 3: 在看板显示计数与可点击异常行**

点击后跳到客户列表，并应用对应 `CustomerAnomalyFilter`；报价到期若需新筛选类型，同步扩展枚举和路由参数。

- [ ] **Step 4: 验证空状态和多异常排序**

排序按严重程度、到期时间、客户等级稳定执行。

### Task 5: 完整正确性验收

**Files:**
- Modify: `docs/APP_PRD_COMPETITOR_AUDIT_2026-08-07.md`
- Modify: relevant phase verification document

- [ ] Run: `dart format lib test`
- [ ] Run: `flutter analyze`
- [ ] Run: `flutter test`
- [ ] Run: `flutter build apk --release`
- [ ] Run: `git diff --check`
- [ ] 更新验收项 5、7、8、11 的代码证据；不修改真机验收项 15 的状态。

