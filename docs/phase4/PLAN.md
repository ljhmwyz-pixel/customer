# 阶段 4 开发计划　订单、附件与开发漏斗

创建于 2026-08-05　　依据 [PRD.md](../PRD.md) 第 8 节与
[TECH_STACK.md](../TECH_STACK.md)

## 1. 目标与边界

阶段 4 补齐订单增删改查、受控状态流转、客户累计成交金额、订单与跟进附件、阶段漏斗
和久未联系客户。阶段 2B 的一加 13 / ColorOS 15 真机验收仍未完成；模拟器和自动化
测试只能验证应用逻辑、Android 通用文件选择与页面交互，不能替代相机、文档提供器、
外部 PDF 应用和厂商权限行为的真机验收。

本阶段不新增数据库表，不改变已有八表结构。金额始终以整数分存储；时间始终以 UTC
毫秒存储；页面不得直接访问 DAO。

## 2. 批次与职责

### 批次 A：订单闭环

- `lib/models/enums.dart`：定义合法订单后继状态，只有 `completed` 计入成交金额。
- `lib/data/daos/order_dao.dart`：按客户读取订单，只聚合 `completed` 金额。
- `lib/features/orders/order_providers.dart`：订单输入清理、校验、CRUD 与状态机服务。
- `lib/features/orders/order_form_page.dart`：新增和编辑订单，金额文本精确解析为分。
- `lib/features/customers/customer_providers.dart`：聚合客户订单与累计成交金额。
- `lib/features/customers/customer_detail_page.dart`：订单列表、新增、编辑、推进、取消、删除。
- `lib/router.dart`：增加订单新增和编辑路由。
- `test/data/`、`test/features/orders/`、`test/features/customers/`：聚合、状态机和页面测试。

订单状态只允许 `pending → shipped → paid → completed` 逐级前进；`pending`、`shipped`、
`paid` 可转为 `cancelled`；`completed` 和 `cancelled` 是终态。编辑表单不直接修改状态。
订单号去首尾空格后须为 1–50 字符且全局唯一，金额须大于 0。

### 批次 B：附件

- `lib/services/attachment_service.dart`：拍照、相册、系统文件选择、私有目录写入与物理删除。
- `lib/features/attachments/`：附件来源菜单、图片预览、PDF 外部打开和附件列表。
- 订单详情与跟进记录接入附件入口；删除带附件订单时先删除私有目录文件，再删数据库记录。

图片使用 `flutter_image_compress` 压缩，长边不超过 1920px，并迭代降低质量直至小于
500KB。文件选择通过 Android `ACTION_OPEN_DOCUMENT`，路径只在数据库保存应用目录相对
路径。图片使用 `photo_view` 预览，PDF 使用 `open_filex` 调用系统应用。

### 批次 C：漏斗与久未联系

- `lib/features/funnel/funnel_page.dart`：真实阶段计数、比例漏斗、下钻入口和久未联系列表。
- `lib/features/customers/customers_page.dart`：接收阶段或久未联系筛选条件。
- DAO 增加批量统计和久未联系查询，排除 `deal`、`lost`。

漏斗按六个客户阶段统计，点击阶段进入已应用阶段筛选的客户列表。久未联系阈值由当前
日期计算，无跟进记录时使用客户创建时间，并明确排除已成交和已流失客户。

## 3. 验收映射

| # | 验收要求 | 实现与验证 |
|---:|---|---|
| 1 | 订单正确关联客户 | 服务校验客户存在与归属，详情页 widget 测试 |
| 2 | 非法状态流转被阻止 | 状态机服务单元测试覆盖跨级、倒退与终态 |
| 3 | 仅统计已完成订单 | DAO 聚合测试和客户详情测试 |
| 4 | 漏斗计数及下钻正确 | DAO 查询测试和路由 widget 测试 |
| 5 | 久未联系排除已成交、已流失 | DAO 边界日期与阶段测试 |
| 6 | 三种附件来源 | 服务测试、模拟器检查、真机复验 |
| 7 | 图片长边与体积限制 | 4000px 测试图片集成测试 |
| 8 | 图片缩放、PDF 外部打开 | widget 测试、模拟器检查、真机复验 |
| 9 | 删除订单物理删除附件 | 临时目录集成测试和数据库级联测试 |

## 4. 验证顺序

每个批次先运行定向测试，再依次运行 `dart format`、`flutter analyze`、`flutter test`、
`flutter build apk --release` 和 `git diff --check`。批次 B 另在 Android 模拟器检查相册、
文件选择、图片预览和 PDF 调用；相机、ColorOS 文档提供器及外部应用兼容性登记为真机
待验项，不能用模拟器结果标记通过。
