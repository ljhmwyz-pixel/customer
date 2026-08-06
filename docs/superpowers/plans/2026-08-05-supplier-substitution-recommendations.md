# Phase F-1 供应商替代决策闭环实施计划

> 日期：2026-08-05  
> 范围：固定选项、可解释建议、项目表单、客户详情、服务校验与测试  
> 提交边界：独立本地提交；不升级数据库、不混入筛选/导出/备份/示例数据/说明书

## 目标与边界

复用 v6 `opportunities` 已有中文字符串字段完成供应商替代决策闭环。用户仍负责最终报价、授权及投入决策；系统只按明确字段给出一个主切入点、一个投入建议和可核对的依据，不生成对外承诺。

本阶段不修改 `schemaVersion`，不生成数据库迁移。历史自由文本采用“原值可保留、新值必须是固定选项”：编辑旧项目时下拉框临时显示带“历史值”标识的原值；若不改动可原样保存，若主动修改只能选择标准值。新建项目只能保存标准值或空值。

“首次政府招标”需要招标记录中的资格、资金和授权信息，不能从项目字段推断，因此不纳入本阶段自动规则；现有招标模块继续负责限定授权和资格/资金校验。

## 固定选项和公共接口

新增 `lib/features/opportunities/supplier_substitution.dart`，集中定义：

- `supplierProblemOptions`：价格高、质量问题、交期不稳定、型号不完整、注册文件不足、服务慢、MOQ高、暂无明显问题、尚未确认。
- `changeWillingnessOptions`：高、中、低、未确认。
- `substitutionDifficultyOptions`：容易、中等、困难。
- `entryPointOptions`：价格替代、第二供应商、连接管切入、非核心型号切入、样品测试、OEM、注册合作、新招标、补充缺失型号、暂不推进。
- `investmentAdviceOptions`：继续投入、限制样品投入、先确认订单、暂不承担注册费用、暂停跟进。
- `SupplierSubstitutionInput`：设备品牌、当前供应商、供应稳定性、供应商问题、更换意愿、替代难度、预计年用量、采购时间证据（预计成交日）、销售阶段。
- `SupplierSubstitutionRecommendation`：`entryPoint`、`investmentAdvice`、`summary`、`reasons`。
- `recommendSupplierSubstitution(input)`：无数据库和 UI 依赖的纯函数；输入不足时也返回可执行的确认方向。
- `optionsWithLegacyValue(options, currentValue)`：返回标准选项，并在必要时追加当前历史值，供 UI 兼容显示。

规则使用精确值或大小写不敏感的品牌标识，不用宽泛的自然语言猜测。优先级如下：

1. 供应商问题为“尚未确认”，或设备型号/年用量/采购时间等关键信息不足：切入点“暂不推进”，投入建议“先确认订单”，提醒补齐设备型号、年用量、采购时间和现有供应商。
2. 当前供应商或采购品牌明确包含 `Antmed`：先确认不满点和切换意愿；未确认时暂不推进，已确认问题时优先样品测试，并限制样品投入。
3. 设备品牌明确包含 `Medtron` 或 `Medtronic`：优先“连接管切入”；更换意愿低时改为“非核心型号切入”，避免正面替换设备品牌。
4. 供应稳定且问题为“暂无明显问题”：优先“第二供应商”；若问题为“型号不完整”则优先“补充缺失型号”。
5. 问题为“价格高”：优先“价格替代”；只有年用量或明确采购时间存在时才“继续投入”，否则“先确认订单”，并说明价格支持必须绑定数量或订单承诺。
6. 质量、交期、服务、MOQ、注册文件等其他明确问题：按样品测试、第二供应商、OEM 或注册合作给出保守建议；更换意愿低或替代困难时限制投入。

## F-1.1 固定选项与纯函数建议引擎

**文件**

- 新增 `lib/features/opportunities/supplier_substitution.dart`
- 新增 `test/features/opportunities/supplier_substitution_test.dart`

**步骤**

1. 先写失败测试，覆盖固定选项完整性、历史值合并去重、输入不足、Antmed、Medtron、稳定无问题、价格高有/无订单证据及其他问题分支。
2. 实现不可变输入/输出对象和纯函数，使每条结果都有 `summary` 与至少一条 `reason`。
3. 运行 `flutter test test/features/opportunities/supplier_substitution_test.dart`。

## F-1.2 Service 校验与历史值兼容

**文件**

- 修改 `lib/features/opportunities/opportunity_providers.dart`
- 修改 `test/features/opportunities/opportunity_service_test.dart`

**步骤**

1. 先增加创建非法固定值失败、标准值成功、更新时历史原值可保留、历史值不可改成另一个自由文本值的测试。
2. `createOpportunity` 对五个决策字段执行“空值或标准选项”校验。
3. `updateOpportunity` 在规范化前读取旧记录，对每个字段允许标准值、空值或与数据库旧值相同的历史值；其他值抛出字段明确的 `OpportunityValidationException`。
4. 保持字段仍为 `String?`，不改表结构和 DAO。
5. 运行 `flutter test test/features/opportunities/opportunity_service_test.dart`。

## F-1.3 表单下拉与自动建议预览

**文件**

- 修改 `lib/features/opportunities/opportunity_form_page.dart`
- 修改 `test/features/customers/customer_pages_test.dart`

**步骤**

1. 先写 Widget 测试：新建页面显示五组下拉；选择供应商问题后出现建议卡；编辑历史值能显示并原样保存；应用建议只写入切入点和投入建议，不替用户自动保存。
2. 将供应商问题、更换意愿、替代难度、切入点、投入建议改为可清空的下拉控件；编辑态通过 `optionsWithLegacyValue` 追加历史值并标注。
3. 根据设备品牌、供应商、稳定性、问题、意愿、难度、年用量、预计成交日和阶段实时计算建议。通过 controller listener 或下拉回调刷新，避免在 `build` 中改 controller。
4. 在“投入建议与前置事项”中展示解释卡，包含建议切入点、建议投入、摘要和依据；“采用建议”按钮仅更新两个下拉值。
5. 运行相关 Widget 测试，检查窄屏无溢出。

## F-1.4 客户详情展示与跟进方向

**文件**

- 修改 `lib/features/customers/customer_detail_page.dart`
- 修改 `lib/features/customers/customer_providers.dart`
- 修改 `test/features/customers/customer_pages_test.dart`
- 修改 `test/features/customers/customer_service_test.dart`

**步骤**

1. 在项目卡片展示已保存的“切入点 · 投入建议”；字段为空时计算并显示带“建议”前缀的可解释结果，避免覆盖用户保存的决策。
2. 扩展跟进方向生成函数，使其可选接收供应商替代建议；创建跟进计划时在阶段方向后追加简短的供应商切入提醒。
3. 保留原有仅按阶段调用的兼容行为，确保其他业务测试不需要无关改写。
4. 增加详情可见性和计划方向组合测试。

## F-1.5 完整验证、模拟器验收与提交

**验证顺序（Flutter 命令串行）**

1. `flutter test test/features/opportunities/supplier_substitution_test.dart`
2. `flutter test test/features/opportunities/opportunity_service_test.dart`
3. `flutter test test/features/customers/customer_pages_test.dart test/features/customers/customer_service_test.dart`
4. `dart format --output=none --set-exit-if-changed lib test`
5. `flutter analyze`
6. `flutter test`
7. `flutter build apk --debug`
8. 在现有 Android 模拟器安装/启动，验证新建项目、编辑历史值、应用建议、详情回显和应用重启后数据保留；不清除 v6 数据。

**提交前检查**

- `git diff --check`
- `git status --short`
- 精确暂存本阶段文件并检查 `git diff --cached --stat`、`git diff --cached --check`。
- 本地提交建议标题：`阶段 F-1：完成供应商替代决策闭环`
- 提交后确认工作区干净；不 push，不提交 APK、模拟器截图或临时证据。

## SPRD 覆盖自检

- 固定选项：五组中文选项全部逐项列出并进入 Service 校验。
- 自动建议：稳定供应商、价格偏高、Medtron、Antmed、信息不足均有可测试规则。
- 首次政府招标：明确由已有招标模块处理，不从缺失数据猜测。
- 决策边界：建议可解释、需用户主动采用，不自动报价、授权或保存。
- 历史数据：无需迁移，旧自由文本可原样保留但不可继续制造新自由文本。
- 交付边界：本提交不包含快速筛选、Excel、备份恢复、示例数据和使用说明。

## 完成标准

- 新建数据只能使用固定选项；历史数据可安全编辑且不会静默丢失。
- 建议引擎在相同输入下稳定输出，并能说明触发依据。
- 表单能预览和主动采用建议，客户详情能看到已保存或自动建议的替代策略。
- 定向测试、格式、静态分析、全量测试、APK 构建和 Android 模拟器验收全部通过。
- 仅在所有验证证据为新鲜结果后创建独立本地提交。
