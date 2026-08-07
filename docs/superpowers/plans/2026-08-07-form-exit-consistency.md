# 核心表单退出一致性 Implementation Plan

> **For agentic workers:** Execute this plan task-by-task in the current session. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 锁定样品维护页不可保存的字段，并将未保存修改保护扩展到订单、跟进和项目表单。

**Architecture:** 复用 `UnsavedChangesGuardWidget.protectUnsavedChanges`。订单和项目在异步加载期间关闭变更追踪，完成回填后开启；跟进页只在用户操作回调和文本监听中标记 dirty。三页保存成功后先放行保护，再执行现有 GoRouter 导航。

**Tech Stack:** Flutter、Material、Riverpod、GoRouter、flutter_test

## Global Constraints

- 保留数据库结构、服务 API、路由、字段键值、校验规则和业务状态机。
- 用户可见文案使用中文。
- 先验证失败测试，再写最小实现。
- 不包含 OnePlus/ColorOS 真机验证；必须完成 Android 模拟器安装与启动验证。

---

### Task 1: 修正样品编辑语义

**Files:**
- Modify: `lib/features/business/sample_form_page.dart`
- Modify: `test/features/business/business_pages_test.dart`

- [x] **Step 1: 写失败测试**

断言新增页型号和数量可编辑；编辑页两字段 `readOnly` 且显示锁定说明。

- [x] **Step 2: 验证测试先失败**

Run: `flutter test test/features/business/business_pages_test.dart`

Expected: 编辑页只读断言 FAIL。

- [x] **Step 3: 实现只读语义**

根据 `editing` 设置型号和数量字段 `readOnly`，并只在编辑页显示带锁图标的说明，不改变保存服务。

- [x] **Step 4: 验证样品测试通过**

Run: `flutter test test/features/business/business_pages_test.dart`

Expected: PASS。

### Task 2: 保护订单、跟进和项目表单

**Files:**
- Modify: `lib/features/orders/order_form_page.dart`
- Modify: `lib/features/customers/followup_form_page.dart`
- Modify: `lib/features/opportunities/opportunity_form_page.dart`
- Modify: `test/features/customers/customer_pages_test.dart`

- [x] **Step 1: 写页面失败测试**

分别覆盖订单、跟进和项目文本修改后返回提示，以及订单编辑异步回填后 clean 返回。

- [x] **Step 2: 验证页面测试先失败**

Run: `flutter test test/features/customers/customer_pages_test.dart --plain-name '核心表单未保存修改保护'`

Expected: 新增断言 FAIL。

- [x] **Step 3: 接入文本与非文本控件**

文本控制器注册监听；下拉、开关、分段选择、快捷日期、日期时间和“采用建议”回调标记 dirty。订单与项目完成异步回填后再开启追踪。

- [x] **Step 4: 放行成功保存**

保存成功后更新保护状态并等待一帧，再执行原有 `context.go`；失败时保留 dirty。

- [x] **Step 5: 验证聚焦测试通过**

Run: `flutter test test/features/business/business_pages_test.dart test/features/customers/customer_pages_test.dart --plain-name '核心表单未保存修改保护'`

Expected: PASS。

### Task 3: 同步说明并完成发布级验证

**Files:**
- Modify: `docs/USER_GUIDE.md`
- Modify: `lib/features/settings/user_guide_page.dart`

- [x] **Step 1: 同步两份说明**

说明样品维护页只推进节点，以及订单、跟进、项目修改后返回会受到保护。

- [x] **Step 2: 格式化与静态分析**

Run: `dart format lib test`

Run: `flutter analyze`

- [x] **Step 3: 运行全量测试和 release 构建**

Run: `flutter test`

Run: `flutter build apk --release`

- [x] **Step 4: 模拟器安装与启动验证**

Run: `adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-release.apk`

Run: `adb -s emulator-5554 shell am force-stop com.snyder.customer`

Run: `adb -s emulator-5554 shell monkey -p com.snyder.customer -c android.intent.category.LAUNCHER 1`

- [x] **Step 5: 提交前检查并提交**

Run: `git diff --check`

Commit: `feat: protect core data entry forms`
