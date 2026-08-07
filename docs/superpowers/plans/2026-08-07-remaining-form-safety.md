# 客户、联系人和新增报价表单安全 Implementation Plan

> **For agentic workers:** Execute this plan task-by-task in the current session. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 为客户、联系人和新增报价补齐未保存修改保护，并允许恢复初始值后无提示退出。

**Architecture:** 每个页面维护包含全部可持久化字段的不可变 record 基线；文本控制器变化触发重建，非文本控件沿用现有 `setState`。页面以当前 record 与基线的值相等性计算是否 dirty，并复用 `UnsavedChangesGuardWidget.protectUnsavedChanges`；异步加载完成后才捕获基线，保存成功后显式放行。

**Tech Stack:** Flutter、Material、Riverpod、GoRouter、flutter_test

## Global Constraints

- 保留数据库结构、服务 API、路由、字段键值、校验规则和保存后流程。
- 默认值、路由预填值及异步加载值不计为用户修改。
- 纯展示展开状态不计为用户修改。
- 用户可见文案使用中文。
- 先验证失败测试，再写最小实现。
- 不包含 OnePlus/ColorOS 真机验证；必须完成 Android 模拟器安装与启动验证。

---

### Task 1: 写退出保护与基线比较失败测试

**Files:**
- Modify: `test/features/customers/customer_pages_test.dart`
- Modify: `test/features/business/business_pages_test.dart`

- [x] **Step 1: 覆盖客户与联系人**

新增 widget test，验证客户文本修改、联系人“决策人”修改后返回显示确认；恢复初始值后直接退出；编辑页异步加载完成后直接返回不提示。

- [x] **Step 2: 覆盖新增报价**

新增 widget test，验证报价编号修改后返回显示确认、恢复空值后直接退出，以及基于已有报价异步预填完成后直接返回不提示。

- [x] **Step 3: 验证测试先失败**

Run: `flutter test test/features/customers/customer_pages_test.dart test/features/business/business_pages_test.dart --plain-name '剩余表单退出保护'`

Expected: 页面直接退出或找不到确认弹窗，测试 FAIL。

### Task 2: 实现客户与联系人基线保护

**Files:**
- Modify: `lib/features/customers/customer_form_page.dart`
- Modify: `lib/features/customers/contact_form_page.dart`

- [x] **Step 1: 捕获初始基线**

为全部可持久化文本及枚举/布尔字段生成 record；新建页初始化后捕获，编辑页异步回填完成后捕获。给文本控制器注册仅负责触发重建的监听器。

- [x] **Step 2: 接入统一退出保护**

用 `baseline != currentValue` 计算实际修改并传入 `protectUnsavedChanges`；保存成功后在现有 `pop/go` 或创建成功对话框前放行。

- [x] **Step 3: 验证客户测试通过**

Run: `flutter test test/features/customers/customer_pages_test.dart --plain-name '剩余表单退出保护'`

Expected: PASS。

### Task 3: 实现新增报价基线保护

**Files:**
- Modify: `lib/features/business/quote_form_page.dart`

- [x] **Step 1: 处理默认值与异步来源**

无来源报价以空编号、数量 1、空金额为基线；基于已有报价新增版本时关闭追踪，完成有效或无效来源加载后再捕获当前基线。

- [x] **Step 2: 接入保护并放行保存**

监听三个文本控制器，用当前 record 与基线计算 dirty；保存成功后先放行再执行现有 `context.pop()`。

- [x] **Step 3: 验证聚焦测试通过**

Run: `flutter test test/features/customers/customer_pages_test.dart test/features/business/business_pages_test.dart --plain-name '剩余表单退出保护'`

Expected: PASS。

### Task 4: 同步说明并完成发布级验证

**Files:**
- Modify: `docs/USER_GUIDE.md`
- Modify: `lib/features/settings/user_guide_page.dart`

- [x] **Step 1: 同步两份说明**

将客户、联系人和新增报价加入退出保护范围，并说明恢复进入页面时的值后不会询问。

- [x] **Step 2: 格式化、静态分析与全量测试**

Run: `dart format lib test`

Run: `flutter analyze`

Run: `flutter test`

- [x] **Step 3: release 与模拟器验证**

Run: `flutter build apk --release`

Run: `adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-release.apk`

Run: `adb -s emulator-5554 shell am force-stop com.snyder.customer`

Run: `adb -s emulator-5554 shell monkey -p com.snyder.customer -c android.intent.category.LAUNCHER 1`

- [x] **Step 4: 提交前检查并独立提交**

Run: `git diff --check`

Commit: `feat: complete form exit protection`
