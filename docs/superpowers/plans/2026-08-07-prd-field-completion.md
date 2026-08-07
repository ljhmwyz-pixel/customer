# PRD Field Completion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 通过 v9 无损迁移补齐客户、联系人和跟进记录缺失字段，并在录入、详情、搜索、导出和备份中形成闭环。

**Architecture:** 新字段采用增量可空列，旧数据不得伪造业务事实；负责人可安全回填“本人”。联系人改为独立表单页面，跟进通过 `contactId` 关联并保存客户态度和负责人快照。

**Tech Stack:** Drift migration、Flutter、Riverpod、Excel export、现有 backup snapshot

## Global Constraints

- schemaVersion 从 8 升至 9，只做 additive migration。
- 旧联系人、旧跟进和客户招标能力字段保持 null/未知，不做推断。
- 跟进历史快照只新增不编辑。
- 新字段必须进入备份 JSON、Excel 导出、示例数据和搜索索引的适用部分。

---

### Task 1: v9 数据模型与迁移

**Files:**
- Modify: `lib/data/tables/customers.dart`
- Modify: `lib/data/tables/contacts.dart`
- Modify: `lib/data/tables/followups.dart`
- Modify: `lib/data/database.dart`
- Regenerate: `lib/data/database.g.dart`, DAO generated files
- Create: `test/data/prd_fields_v9_migration_test.dart`
- Modify: `test/data/migration_test.dart`

**Fields:**
- Customer: `customerNo`, `customerType`, `owner`, `tenderExperience`, `tenderQualification`, `tenderBidder`, `localTeamStatus`, `fundingStatus`
- Contact: `email`, `whatsapp`, `communicationPreference`, `note`
- Followup: nullable `contactId` with `SET NULL`, `attitude`, `owner`

- [ ] **Step 1: 写 v8 -> v9 保留数据失败测试**

```dart
expect(db.schemaVersion, 9);
expect(customer.owner, '本人');
expect(contact.email, isNull);
expect(followup.contactId, isNull);
```

- [ ] **Step 2: 添加表列和约束**

`customerNo` 允许 null，但非空值唯一；邮箱/WhatsApp 不做数据库格式约束，由服务校验；跟进 attitude 使用固定 enum dbValue。

- [ ] **Step 3: 编写 `_upgradeToV9`**

只回填 `customers.owner = '本人'`；其他字段保持 null。添加客户编号局部唯一索引和联系人邮箱/WhatsApp 搜索索引。

- [ ] **Step 4: 重新生成 Drift 代码并运行迁移测试**

Run: `dart run build_runner build --delete-conflicting-outputs`

Run: `flutter test test/data/prd_fields_v9_migration_test.dart test/data/migration_test.dart`

### Task 2: 服务 DTO、DAO 与校验

**Files:**
- Modify: `lib/models/enums.dart`
- Modify: `lib/features/customers/customer_providers.dart`
- Modify: `lib/data/daos/customer_dao.dart`
- Modify: `lib/data/daos/contact_dao.dart`
- Modify: `lib/data/daos/followup_dao.dart`
- Test: `test/features/customers/customer_service_test.dart`
- Test: `test/data/query_test.dart`

**Interfaces:**
- Extend: `CustomerDraft`, `ContactDraft`, `FollowupDraft`
- Produce: `enum CustomerAttitude { positive, normal, evaluating, delaying, seenNoReply, rejected }`

- [ ] **Step 1: 写规范化和所有权失败测试**

联系人必须属于当前客户；跟进选择的联系人必须属于同一客户；owner 保存项目负责人当时的快照。

- [ ] **Step 2: 实现邮箱与 WhatsApp 轻量校验**

邮箱非空时必须包含单个 `@` 且两侧非空；WhatsApp 保留 `+`、数字、空格和短横线，入库前清理首尾空格。

- [ ] **Step 3: 扩展搜索**

客户关键词搜索命中客户名称/电话、联系人姓名/电话/邮箱/WhatsApp 和客户编号；结果按客户去重。

- [ ] **Step 4: 跟进写入联系人、态度和负责人快照**

历史记录读取 null 时显示“未记录”，不回填当前联系人或当前负责人。

### Task 3: 客户与联系人录入交互

**Files:**
- Modify: `lib/features/customers/customer_form_page.dart`
- Modify: `lib/features/customers/customer_detail_page.dart`
- Create: `lib/features/customers/contact_form_page.dart`
- Modify: `lib/router.dart`
- Test: `test/features/customers/customer_pages_test.dart`

- [ ] **Step 1: 客户表单分组补齐字段**

首屏仍只要求客户名称；客户编号、类型、负责人放在“客户管理”，招标经验/资格/主体/团队/资金放在“招投标能力”。

- [ ] **Step 2: 将联系人编辑从 Dialog 改为独立页面**

字段较多后不再使用窄 Dialog；新增和编辑路由共享表单，支持姓名、职位、电话、邮箱、WhatsApp、沟通偏好、决策人和备注。

- [ ] **Step 3: 客户概览突出关键联系人**

优先展示决策人，其次最近跟进联系人；电话、邮件、WhatsApp 只使用对应图标操作并提供 tooltip。

### Task 4: 跟进联系人和客户态度

**Files:**
- Modify: `lib/features/customers/followup_form_page.dart`
- Modify: `lib/features/customers/detail/customer_activity_tab.dart`
- Test: `test/features/customers/customer_pages_test.dart`

- [ ] **Step 1: 在核心区加入联系人和客户态度**

有联系人时默认最近使用联系人；允许选择“未指定联系人”。态度用下拉选择，不使用占宽过大的六段 segmented control。

- [ ] **Step 2: 动态时间线显示不可变快照**

每条跟进显示联系人、态度、方式、发生时间、负责人、反馈、阶段和下一步；后续编辑联系人不会改变历史显示。

- [ ] **Step 3: 更新五字段定义**

联系人和态度作为辅助项，不增加原 PRD 五个核心“更新项目状态”字段的数量；默认值应减少额外点击。

### Task 5: 导出、备份与示例数据

**Files:**
- Modify: `lib/data/daos/export_dao.dart`
- Modify: `lib/services/excel_export_service.dart`
- Modify: `lib/services/backup_restore_service.dart`
- Modify: `lib/services/sample_data_service.dart`
- Test: `test/services/excel_export_service_test.dart`
- Test: `test/services/backup_restore_service_test.dart`
- Test: `test/services/sample_data_service_test.dart`

- [ ] **Step 1: 四表导出增加适用字段列**

客户及项目表增加客户编号/类型/负责人/招标能力；跟进表增加联系人、态度和负责人；保持首行冻结、筛选和日期格式。

- [ ] **Step 2: 备份 JSON 快照覆盖新列**

恢复校验允许旧 v8 备份按迁移链升级；不允许未知未来版本直接恢复。

- [ ] **Step 3: 九条示例数据填入代表性新字段**

撤销仍按 `sampleBatchId` 整体完成，不影响正式记录。

### Task 6: v9 完整验收

- [ ] Run: `dart format lib test`
- [ ] Run: `flutter analyze`
- [ ] Run: `flutter test test/data/prd_fields_v9_migration_test.dart`
- [ ] Run: `flutter test`
- [ ] Run: `flutter build apk --release`
- [ ] Run: `git diff --check`
- [ ] 更新 PRD 字段映射和迁移验证记录；真机状态保持未验收。

