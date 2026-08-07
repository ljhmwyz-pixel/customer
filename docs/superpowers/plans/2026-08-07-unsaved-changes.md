# 长表单未保存修改保护 Implementation Plan

> **For agentic workers:** Execute this plan task-by-task in the current session. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 为注册、招标、样品和报价结果表单增加一致的未保存修改退出确认，避免误操作导致输入丢失。

**Architecture:** 新建独立的 `UnsavedChangesGuard`，使用 Flutter `PopScope` 统一处理导航栏返回和 Android 系统返回，并由页面传入显式 dirty 状态。各页面在用户修改文本、下拉、开关、复选框或日期时标记 dirty；异步加载期间关闭追踪，保存成功或确认删除后显式放行。

**Tech Stack:** Flutter、Material、Riverpod、GoRouter、flutter_test

## Global Constraints

- 保留现有路由、数据库结构、服务 API、字段键值、业务规则和固定底部保存按钮。
- 用户可见文案使用中文。
- 先验证失败测试，再写最小实现。
- 不包含 OnePlus/ColorOS 真机验证；必须完成 Android 模拟器安装与启动验证。

---

### Task 1: 共享退出保护组件

**Files:**
- Create: `lib/widgets/unsaved_changes_guard.dart`
- Create: `test/widgets/unsaved_changes_guard_test.dart`

**Interfaces:**
- Produces: `UnsavedChangesGuard({required bool hasUnsavedChanges, required Widget child})`

- [x] **Step 1: 写失败测试**

覆盖 clean 直接退出、dirty 显示确认、继续编辑保留页面与输入、放弃修改退出，以及重复返回不叠加弹窗。

- [x] **Step 2: 验证测试先失败**

Run: `flutter test test/widgets/unsaved_changes_guard_test.dart`

Expected: FAIL，因为 `UnsavedChangesGuard` 尚不存在。

- [x] **Step 3: 实现最小共享组件**

使用 `PopScope(canPop: !hasUnsavedChanges)`；在拦截到退出时只打开一个 `AlertDialog`。用户确认后使用当前路由的 `Navigator.pop` 完成原退出请求。

- [x] **Step 4: 验证共享测试通过**

Run: `flutter test test/widgets/unsaved_changes_guard_test.dart`

Expected: PASS。

### Task 2: 接入四个业务表单

**Files:**
- Modify: `lib/features/business/registration_form_page.dart`
- Modify: `lib/features/business/tender_form_page.dart`
- Modify: `lib/features/business/sample_form_page.dart`
- Modify: `lib/features/business/quote_outcome_page.dart`
- Modify: `test/features/business/business_pages_test.dart`

**Interfaces:**
- Consumes: `UnsavedChangesGuard`
- Produces: 页面私有 `_dirty`、`_trackingChanges` 与离页放行逻辑

- [x] **Step 1: 写页面失败测试**

新增注册文本修改、样品下拉修改、报价开关修改、编辑页异步回填、保存成功、附件往返等集成测试。

- [x] **Step 2: 验证页面测试先失败**

Run: `flutter test test/features/business/business_pages_test.dart`

Expected: 新增断言 FAIL，因为页面尚未接入保护。

- [x] **Step 3: 接入文本与控件变更追踪**

文本控制器统一注册监听；下拉、日期、开关和复选框的用户回调显式标记 dirty。编辑页完成异步回填后再开启追踪，避免加载误报。

- [x] **Step 4: 放行成功保存与确认删除**

保存成功后清除 dirty 并在下一帧退出；确认删除完成后设置离页放行，再执行现有 `context.go`。保存失败继续保持 dirty。

- [x] **Step 5: 验证聚焦测试通过**

Run: `flutter test test/widgets/unsaved_changes_guard_test.dart test/features/business/business_pages_test.dart`

Expected: PASS。

### Task 3: 同步说明书并完成发布级验证

**Files:**
- Modify: `docs/USER_GUIDE.md`
- Modify: `lib/features/settings/user_guide_page.dart`

- [x] **Step 1: 同步两份说明**

在业务节点维护说明中增加：修改后返回会提示；“继续编辑”保留输入；保存成功、删除和附件往返不会误提示。

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

确认应用进程存在，且 `logcat` 无本次启动产生的 Flutter fatal exception。

- [x] **Step 5: 提交前检查并提交**

Run: `git diff --check`

Run: `git status --short`

Commit: `feat: protect unsaved form changes`
