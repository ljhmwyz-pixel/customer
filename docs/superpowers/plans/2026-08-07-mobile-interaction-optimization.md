# Mobile Interaction Optimization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 降低客户详情、跟进、筛选和业务节点维护的点击、滚动与认知成本，同时保留现有功能和数据安全约束。

**Architecture:** 将 1525 行客户详情拆为四个真正的 Tab 视图，共享同一个 `CustomerDetailData`；高频跟进保持一键直达，低频新增动作放入统一 action sheet。长表单使用“必填核心字段展开、低频字段折叠、底部固定保存”的共同结构。

**Tech Stack:** Flutter Material 3、Riverpod、go_router、现有 AppTokens 和语义色

## Global Constraints

- 不做营销页或视觉重皮，优先缩短业务操作路径。
- 320px 与 375px 宽度、深色模式、键盘弹出时不得溢出或遮挡保存操作。
- 所有可点击目标至少 44x44；图标按钮提供 tooltip。
- 不使用卡片套卡片；页面分区使用 Tab、标题和分隔，不堆叠装饰容器。
- 跟进主流程不得比当前增加点击数。

---

### Task 1: 建立交互基线测试

**Files:**
- Create: `test/features/customers/customer_workflow_test.dart`
- Modify: `test/features/customers/customer_pages_test.dart`

**Interfaces:**
- Produce: reusable test helpers `openCustomerDetail`, `openAddAction`, `selectDetailTab`

- [ ] **Step 1: 为五条高频路径记录最大点击数**

```text
首页任务 -> 新增跟进表单：最多 2 次
客户列表 -> 新增跟进表单：最多 3 次
客户详情 -> 新增报价/样品：最多 2 次
客户详情 -> 更新样品节点：最多 3 次
客户列表 -> 应用“报价停滞”筛选：最多 1 次
```

- [ ] **Step 2: 写现状失败测试或语义定位测试**

测试不得依赖屏幕坐标；使用稳定 `ValueKey`，同时断言返回页面后所选 Tab 和筛选状态保留。

### Task 2: 拆分客户详情为四个 Tab

**Files:**
- Modify: `lib/features/customers/customer_detail_page.dart`
- Create: `lib/features/customers/detail/customer_overview_tab.dart`
- Create: `lib/features/customers/detail/customer_projects_tab.dart`
- Create: `lib/features/customers/detail/customer_business_tab.dart`
- Create: `lib/features/customers/detail/customer_activity_tab.dart`
- Create: `lib/features/customers/detail/customer_detail_actions.dart`
- Test: `test/features/customers/customer_pages_test.dart`

**Interfaces:**
- Consume: existing `CustomerDetailData`
- Produce: `CustomerDetailTab { overview, projects, business, activity }`
- Produce: `showCustomerAddActionSheet(context, data, selectedOpportunityId)`

- [ ] **Step 1: 写 Tab 内容和状态保持失败测试**

概览显示下一步行动、关键联系人和异常；项目显示项目列表；业务显示报价/样品/注册/招标/订单；动态显示跟进与任务时间线。

- [ ] **Step 2: 把现有私有 widget 按职责迁出 1525 行文件**

只移动行为，不改变服务调用；每个新文件只负责一个 Tab，不创建第二套 provider。

- [ ] **Step 3: 使用 `TabBar` 与 `TabBarView` 实现真正视图切换**

返回详情时保留当前 Tab；多项目客户在项目与业务 Tab 顶部使用项目选择器，默认最近活动项目。

- [ ] **Step 4: 保留一键跟进主操作**

右下角主 FAB 直接进入跟进；相邻的加号图标打开新增联系人、项目、报价、样品、注册、招标和订单 action sheet。没有项目时禁用项目业务项并提供“先新增项目”。

- [ ] **Step 5: 删除原长页面重复入口**

同一新增操作只能有一个清晰主入口；记录行点击进入详情/编辑，附件入口放在记录详情而不是列表行堆多个图标。

### Task 3: 跟进表单保持五字段主路径

**Files:**
- Modify: `lib/features/customers/followup_form_page.dart`
- Create: `lib/widgets/sticky_form_scaffold.dart`
- Create: `lib/widgets/form_section.dart`
- Test: `test/features/customers/customer_pages_test.dart`

**Interfaces:**
- Produce: `StickyFormScaffold(title, body, submitLabel, onSubmit, submitting)`
- Produce: `FormSection(title, initiallyExpanded, hasError, child)`

- [ ] **Step 1: 写 320px、键盘和折叠状态测试**

核心字段始终可见：客户反馈、阶段、下一步、下次跟进/暂停；跟进方式、发生时间和补充内容默认折叠。

- [ ] **Step 2: 将保存按钮固定在 `SafeArea` 底部**

键盘弹出时按钮仍可触达；正文底部 padding 必须预留按钮高度，避免最后字段被遮挡。

- [ ] **Step 3: 优化日期快捷项**

保留明天、3 天、1 周、1 月和自定义；根据客户等级只突出建议项，不静默替用户选择。

- [ ] **Step 4: 校验失败自动展开对应区块并滚动到首个错误**

暂停原因、项目选择和核心字段错误必须在一次提交后直接可见。

### Task 4: 长业务表单渐进展开

**Files:**
- Modify: `lib/features/business/registration_form_page.dart`
- Modify: `lib/features/business/tender_form_page.dart`
- Modify: `lib/features/orders/order_form_page.dart`
- Modify: `lib/features/opportunities/opportunity_form_page.dart`
- Reuse: `lib/widgets/sticky_form_scaffold.dart`
- Reuse: `lib/widgets/form_section.dart`
- Test: `test/features/business/phase_e_pages_test.dart`
- Test: `test/features/orders/order_service_test.dart`
- Test: `test/features/customers/customer_pages_test.dart`

- [ ] **Step 1: 注册表单分为基本、资料与时间、阻碍与行动**

新增时展开基本和下一步；资料清单、实际完成日期等按状态展开。被校验命中的区块自动展开。

- [ ] **Step 2: 招标表单分为基本、资格核验、授权与风险**

授权与底价仅在用户选择相关能力后展开；高风险确认紧邻触发字段，不放在页面最末端。

- [ ] **Step 3: 订单表单分为订单核心、履约进度、复购与说明**

新增只需项目、订单号、日期、金额、币种；付款/生产/发货在履约区；金额前缀随币种变化，禁止固定显示 `¥`。

- [ ] **Step 4: 项目表单保留当前折叠分组并统一 sticky save**

项目名称、阶段、状态、下一步在第一屏；预测、供应商和替代策略分组保持可独立展开。

### Task 5: 补齐业务记录详情与节点更新入口

**Files:**
- Modify: `lib/router.dart`
- Modify: `lib/features/business/quote_form_page.dart`
- Modify: `lib/features/business/sample_form_page.dart`
- Modify: `lib/features/business/registration_form_page.dart`
- Modify: `lib/features/business/tender_form_page.dart`
- Create: `lib/features/business/business_record_detail_page.dart`
- Modify: `lib/features/business/business_providers.dart`
- Test: `test/features/business/business_pages_test.dart`
- Test: `test/features/business/phase_e_pages_test.dart`

**Interfaces:**
- Routes: `.../quotes/:quoteId`, `.../samples/:sampleId/edit`, `.../registrations/:registrationId/edit`, `.../tenders/:tenderId/edit`
- Produce: `BusinessService.updateQuoteOutcome(...)`

- [ ] **Step 1: 报价核心价格保持版本不可变**

详情页允许更新“客户已收到、反馈、下次跟进、结果”；价格变化必须使用“新增版本”，预填上一版本数据并递增版本号。

- [ ] **Step 2: 样品提供节点式快捷推进**

列表/详情显示“寄出、签收、开始测试、通过、失败”合法下一动作；动作进入精简表单，只要求该节点所需字段。

- [ ] **Step 3: 注册和招标路由支持加载既有值并更新**

复用现有 service update 方法；保存后回到业务 Tab 并保持选中项目。

- [ ] **Step 4: 记录详情统一附件和删除入口**

删除必须二次确认；附件计数、添加和预览集中在详情页。

### Task 6: 客户列表快捷筛选

**Files:**
- Modify: `lib/features/customers/customers_page.dart`
- Modify: `lib/features/customers/customer_providers.dart`
- Test: `test/features/customers/customer_pages_test.dart`

**Interfaces:**
- Produce: `CustomerQuickFilter { overdue, gradeA, stalledQuote, stalledSample, longSilence }`

- [ ] **Step 1: 列表搜索框下加入可横向滚动快捷筛选**

“逾期、A 级、报价停滞、样品停滞、长期沉默”一按即应用；再次点击取消。高级筛选仍保留完整组合能力。

- [ ] **Step 2: 高级筛选按业务维度分组**

客户、产品项目、状态日期、异常四组；底部固定显示“重置”和“查看 N 个结果”。

- [ ] **Step 3: 保留筛选上下文**

从客户详情返回列表时搜索、快捷筛选、高级筛选和滚动位置不清空；显式点击重置才清除。

### Task 7: 交互回归验收

- [ ] Run: `flutter test test/features/customers/customer_workflow_test.dart`
- [ ] Run: `flutter test test/features/customers test/features/business test/features/funnel`
- [ ] Run: `flutter analyze`
- [ ] Run: `flutter test`
- [ ] 在 320x700、375x812、1080x2400 的浅色/深色 widget surface 检查溢出。
- [ ] 更新 `docs/USER_GUIDE.md`，只说明业务操作路径，不描述视觉样式或开发细节。

