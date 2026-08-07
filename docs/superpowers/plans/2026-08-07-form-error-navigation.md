# 长表单首个错误自动定位 Implementation Plan

> **For agentic workers:** Execute this plan task-by-task in the current session. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 让订单、跟进、项目和招标在保存校验失败时自动展开、滚动并聚焦首个可处理错误。

**Architecture:** 新增无业务状态的 `revealFormError` 共享函数，接收目标 `GlobalKey` 和可选 `FocusNode`，等待当前校验帧后使用 `Scrollable.ensureVisible` 定位并请求焦点。订单和项目将显式字段列表改为 `SingleChildScrollView + Column`，确保滚动到页尾时顶部字段仍参与 `Form.validate()`；跟进保留现有非惰性滚动容器。各页面继续拥有自己的校验顺序和业务规则，招标在调用共享函数前控制相应 `FormSection` 展开状态。

**Tech Stack:** Flutter、Material、Riverpod、GoRouter、flutter_test

## Global Constraints

- 保留数据库结构、服务 API、路由、字段键值、必填规则和保存成功流程。
- 保留现有中文错误文案。
- 定位动画时长固定为 250ms，目标对齐视口 15% 位置。
- 先验证失败测试，再写最小实现。
- 不包含 OnePlus/ColorOS 真机验证；必须完成 Android 模拟器安装与启动验证。

---

### Task 1: 写长表单定位失败测试

**Files:**
- Modify: `test/features/customers/customer_pages_test.dart`
- Modify: `test/features/business/phase_e_pages_test.dart`

- [x] **Step 1: 覆盖订单、跟进和项目**

将表单滚动到底部后触发保存，断言首个错误字段重新进入视口；文本错误字段对应的 `EditableText.focusNode.hasFocus` 为 true。

- [x] **Step 2: 覆盖招标折叠区**

分别构造无效保证金和缺少高风险确认，保存前收起对应区块，断言保存后区块展开、目标进入视口，保证金输入获得焦点。

- [x] **Step 3: 验证测试先失败**

Run: `flutter test test/features/customers/customer_pages_test.dart test/features/business/phase_e_pages_test.dart --plain-name '长表单首个错误自动定位'`

Expected: 目标仍在屏幕外、折叠区未展开或输入未获得焦点，测试 FAIL。

### Task 2: 新增共享错误定位工具

**Files:**
- Create: `lib/widgets/form_error_navigation.dart`
- Create: `test/widgets/form_error_navigation_test.dart`

- [x] **Step 1: 定义共享接口**

实现 `Future<void> revealFormError({required GlobalKey targetKey, FocusNode? focusNode})`；等待 `endOfFrame`，目标存在时使用 250ms `Scrollable.ensureVisible` 和 0.15 alignment，随后请求可选焦点。

- [x] **Step 2: 覆盖工具行为**

Widget test 构建长列表，调用工具后断言目标进入视口且指定文本字段获得焦点；目标未挂载时正常返回不抛异常。

- [x] **Step 3: 验证工具测试通过**

Run: `flutter test test/widgets/form_error_navigation_test.dart`

Expected: PASS。

### Task 3: 接入订单、跟进和项目

**Files:**
- Modify: `lib/features/orders/order_form_page.dart`
- Modify: `lib/features/customers/followup_form_page.dart`
- Modify: `lib/features/opportunities/opportunity_form_page.dart`

- [x] **Step 1: 为可定位字段增加目标与焦点**

保留现有 `ValueKey`，在字段外增加 `GlobalKey` 目标；为订单号、金额、跟进文本及项目文本字段配置并释放 `FocusNode`。将订单和项目的显式 `ListView` 改为 `SingleChildScrollView + Column`，避免离屏字段脱离 Form 树。

- [x] **Step 2: 按页面顺序选择首错**

保存时始终先执行 `Form.validate()`；失败后根据当前值选择第一个目标并调用 `revealFormError`。项目本地整数和金额解析异常携带字段 key，以便在显示原有 SnackBar 前定位对应字段。

- [x] **Step 3: 验证客户侧聚焦测试通过**

Run: `flutter test test/features/customers/customer_pages_test.dart --plain-name '长表单首个错误自动定位'`

Expected: PASS。

### Task 4: 接入招标折叠区

**Files:**
- Modify: `lib/features/business/tender_form_page.dart`

- [x] **Step 1: 控制资格区展开状态**

为“资格核验”增加受控展开状态；保证金无效时先展开资格区，再调用共享定位并聚焦保证金。

- [x] **Step 2: 前置风险确认定位**

保存前复用现有 `_requiresRiskAcknowledgement` 判断；未确认时展开风险区、定位确认项并显示现有错误文案，不进入服务写入。

- [x] **Step 3: 验证招标聚焦测试通过**

Run: `flutter test test/features/business/phase_e_pages_test.dart --plain-name '长表单首个错误自动定位'`

Expected: PASS。

### Task 5: 同步说明并完成发布级验证

**Files:**
- Modify: `docs/USER_GUIDE.md`
- Modify: `lib/features/settings/user_guide_page.dart`

- [x] **Step 1: 同步两份说明**

说明长表单保存失败会自动展开并定位首个错误，用户无需自行查找。

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

Commit: `feat: navigate to form validation errors`
