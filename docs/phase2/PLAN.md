# 阶段 2 开发计划　提醒链路

创建于 2026-08-04　　依据 [PRD.md](../PRD.md) 第 6 节与第 8 节阶段 2

## 1. 本期目标与切分方式

把「到点提醒」这条链路打通并验到底：权限引导、闹钟调度、通知展示与交互、
重启恢复、触发日志。不做任何界面美化。

PRD 把这一期排在所有界面之前，理由写在 PRD 第 9 节：提醒可靠性受 Android 系统与
国产 ROM 限制，存在无法通过代码完全解决的风险。若放到最后做，可能出现所有界面都
完成才发现提醒不可靠，届时返工成本极高。

### 1.1 为什么拆成 2A 与 2B

目标真机一加 13 当前无法接入，只有 Android 17 (API 37) 模拟器可用。

模拟器跑的是 AOSP，ColorOS 特有的电池管控、自启动管理、后台弹出界面权限在
AOSP 里**不存在对应设置页**，相关代码在模拟器上必然走不通。而 PRD 验收第 8 项
明确要求「在一加 13 真机上连续验证 3 天」。

所以本期切成两段：

| | 范围 | 环境 | 门槛 |
|---|---|---|---|
| **2A** | 功能链路实现 + AOSP 标准行为验证 | 模拟器 | 全部通过才进 2B |
| **2B** | ColorOS 专项适配与可靠性验证 | 一加 13 真机 | **硬门槛，不通过不进阶段 3** |

**2A 全绿不代表真机能过。** ColorOS 掐后台闹钟以激进著称，完全可能出现
「AOSP 一切正常、装到一加上就是不响」。因此 2A 的调度层必须做成可替换的，
见第 4 节的降级预案。

### 1.2 验收项归属

PRD 阶段 2 共 11 项验收标准，按可验环境分配如下。

| # | 验收标准 | 2A 模拟器 | 2B 真机 |
|---|---|---|---|
| 1 | 首次启动依次引导五项权限，拒绝后有再次引导入口 | 部分 | 补全 |
| 2 | 5 分钟后的提醒锁屏准时弹出，误差 ≤ 60 秒 | ✅ | 复验 |
| 3 | 强杀应用后提醒仍触发 | ✅ | 复验 |
| 4 | 飞行模式下提醒仍触发 | ✅ | 复验 |
| 5 | 重启手机后未来提醒全部仍能触发 | ✅ | 复验 |
| 6 | 点通知直达对应客户详情页 | ✅ | — |
| 7 | 通知上「已完成」「推迟一天」生效且数据库同步 | ✅ | — |
| 8 | **真机连续 3 天、每天至少 2 个提醒、触发率 100%** | ✗ | **硬门槛** |
| 9 | 触发日志可在应用内查看，含计划时间与实际触发时间 | ✅ | — |
| 10 | 权限引导能跳转 ColorOS 设置页，失败时回退 | 仅回退路径 | 跳转路径 |
| 11 | 次日早晨提醒，整夜息屏充电仍准时触发 | ✗ | ✅ |

第 1 项拆开的原因：通知权限与精确闹钟权限是 AOSP 标准，模拟器可验；
电池优化白名单在 AOSP 有对应页面，可验；自启动与后台弹出界面是 ColorOS 私有，
只能到 2B。

第 8 与第 11 项在模拟器上无法验证，标 ✗。模拟器不进入 Doze 深度睡眠，
跑 3 天也证明不了 ColorOS 的行为。

## 2. 技术前提（已查证）

以下结论来自本机 `~/.pub-cache` 中实际安装的插件源码与官方文档，不凭印象。

### 2.1 精确闹钟权限在 Android 14+ 默认拒绝

`android_alarm_manager_plus` 5.1.1 的 README 明确写着：
`SCHEDULE_EXACT_ALARM` 在 Android 12 引入，Android 13 默认授予，
**Android 14 起默认拒绝**，需引导用户手动开启，且该插件自己不提供申请入口。

本项目 `targetSdk = 36`，这条一定适用。申请入口用 `permission_handler` 的
`Permission.scheduleExactAlarm`，其 Android 实现走
`Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM`，跳系统设置页而非弹运行时对话框。

### 2.2 Manifest 现有权限声明存在矛盾，本期必须修正

`android/app/src/main/AndroidManifest.xml` 当前同时声明了：

```xml
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
```

这两个不该并存。`USE_EXACT_ALARM` 是免申请的替代权限，一旦声明，系统直接授予
精确闹钟能力，`SCHEDULE_EXACT_ALARM` 的申请流程**永远不会触发**。
后果是验收第 1 项里「引导精确闹钟权限」这段代码走不到，不是代码写错，
而是权限组合让它无法验证。

另外 `USE_EXACT_ALARM` 仅允许闹钟、日历类应用使用，本应用是 CRM 工具，
用它属于滥用。虽然自用不上架、不受 Google Play 审核约束，但会掩盖真实的权限状态,
让 2A 的验证结论失真。

**决策：移除 `USE_EXACT_ALARM`，保留 `SCHEDULE_EXACT_ALARM` 并实现完整申请引导。**

### 2.3 调度模式选 alarmClock

`flutter_local_notifications` 22.2.0 的 `AndroidScheduleMode` 有五档。
源码注释说明各档差异，其中：

- `alarmClock`　底层走 `setAlarmClock()`，系统视作用户设置的闹铃，
  Doze 与省电策略对它的压制最弱，优先级最高
- `exactAllowWhileIdle`　精确且可在 Doze 中执行，但优先级低于上者
- `exact`　精确但 Doze 中可能不执行

**决策：用 `alarmClock`。** 本应用的提醒对用户就是「闹钟」性质，
且这是对抗 ColorOS 管控最有力的一档。降级顺序见第 4 节。

### 2.4 两个插件的分工

`flutter_local_notifications` 与 `android_alarm_manager_plus` 功能有重叠,
同时使用容易产生两套互相不知情的调度。

**决策：以 `flutter_local_notifications` 的 `zonedSchedule()` 为唯一调度入口。**
`android_alarm_manager_plus` 不参与通知调度，但**本期实际用到了它**，
且**不能在阶段 5 移除**。

> **2026-08-04 实测修正。** 原文写的是「本期不使用」，这个判断是错的。
>
> `zonedSchedule()` 到点后通知完全由原生侧弹出，Dart 侧不会被唤醒，
> 插件也不提供任何「已投递」回调，`ActiveNotification` 同样不带投递时间字段。
> 结果是 `follow_plans.notified_at` 永远为空，验收第 9 项
> 「触发日志含实际触发时间」无从记录。
>
> 解法是给每条提醒并排一个同时刻的 `android_alarm_manager_plus` 记账闹钟，
> 由它拉起后台 isolate 把真实触发时刻落库。两条都用 `alarmClock` 档，
> 被系统延迟的程度接近，记下的时刻才有参考价值。记账闹钟只写库不弹通知,
> 失败最多是日志缺一条。详见 `notification_service.dart` 的
> `_scheduleNotifiedMark` 与 `markPlanNotified`。
>
> 它同时仍是 4.2 的降级选项之一。

### 2.5 API 变更注意

`flutter_local_notifications` 20.0.0 起 `initialize()`、`show()`、
`zonedSchedule()`、`cancel()` 的位置参数全部改为命名参数。网上多数示例代码
是旧版写法，直接抄会编译不过。实际签名：

```dart
Future<void> zonedSchedule({
  required int id,
  required TZDateTime scheduledDate,
  required NotificationDetails notificationDetails,
  required AndroidScheduleMode androidScheduleMode,
  String? title,
  String? body,
  String? payload,
  DateTimeComponents? matchDateTimeComponents,
})
```

## 3. 实现清单

### 3.1 通知与调度服务

`lib/services/notification_service.dart`

- 初始化通知渠道。渠道重要性设 `Importance.max`,
  否则锁屏不弹横幅，验收第 2 项过不了
- `scheduleForPlan(FollowPlanRow)`　按计划排一个闹钟。
  通知 id 直接用 `plan.id`,这样取消与更新不需要额外映射表
- `cancelForPlan(int planId)`
- `rescheduleAll()`　清空后按 `PlanDao.listUpcoming()` 全量重建。
  开机恢复与时区变更都调它
- 通知 payload 存 `planId` 与 `customerId`，供点击跳转使用

时区处理：`zonedSchedule` 要 `TZDateTime`,必须先 `tz.initializeTimeZones()`
并设本地时区。库里存的是 UTC 毫秒，转换时不能用 `DateTime.now()` 的隐式本地时区,
否则跨时区或夏令时会偏。

### 3.2 开机与时区恢复

`android/app/src/main/kotlin/.../BootReceiver.kt` 或复用插件自带接收器。

`flutter_local_notifications` 自带 `ScheduledNotificationBootReceiver`,
需在 Manifest 注册。要接的广播不止 `BOOT_COMPLETED`：

- `android.intent.action.BOOT_COMPLETED`　开机
- `android.intent.action.QUICKBOOT_POWERON`　部分国产 ROM 用这个替代
- `android.intent.action.MY_PACKAGE_REPLACED`　应用更新后闹钟会被清空
- `android.intent.action.TIMEZONE_CHANGED`　时区变更需重排

`MY_PACKAGE_REPLACED` 容易漏。开发期频繁 `flutter run` 覆盖安装,
每次覆盖都会清掉全部已排闹钟,漏了这条会让 2A 的验证时断时续,
而且症状看起来像「闹钟随机失效」,极难定位。

> **2026-08-04 实测修正，两处。**
>
> **一、本节漏了最关键的接收器。** 插件的 `AndroidManifest.xml` 只声明权限、
> 不注册任何组件，**所有**接收器都要宿主自己注册，包括到点真正弹通知的
> `ScheduledNotificationReceiver`（插件 README 第 383 行）。
>
> 漏掉它的症状极具误导性：闹钟正常排期、到点确实触发（`1 wakes 1 alarms`）、
> 记账闹钟也把时间写进了库，**但通知不出现且无任何报错**，
> 很容易误判成 Doze 压制或渠道重要性不足。第一轮实测就撞上了。
>
> 另外 `dumpsys package` 的 Receiver Resolver Table 只列带 intent-filter 的
> 接收器，这个接收器靠显式 Intent 唤起、没有 filter，`grep` 数它永远是 0。
> 确认它是否进包要看 `aapt2 dump xmltree` 的 APK 清单。
>
> **二、`TIMEZONE_CHANGED` 加了也没用。** 插件自带的
> `ScheduledNotificationBootReceiver` 并不处理该 action。当前依赖
> 「下次启动应用时 `rescheduleAll()`」，对单人自用场景够了。
> 若 2B 发现问题再补自写的原生接收器。

### 3.3 权限引导

`lib/services/permission_service.dart` 与 `lib/features/reminders/` 下的引导页。

五项权限按依赖顺序引导，每项都要能单独重试：

| 顺序 | 权限 | 入口 | 环境 |
|---|---|---|---|
| 1 | 通知 | `Permission.notification` | AOSP |
| 2 | 精确闹钟 | `Permission.scheduleExactAlarm` | AOSP |
| 3 | 电池优化白名单 | `Permission.ignoreBatteryOptimizations` | AOSP |
| 4 | 自启动 | ColorOS 私有 Intent | 仅 ColorOS |
| 5 | 后台弹出界面 | ColorOS 私有 Intent | 仅 ColorOS |

第 4、5 项在模拟器上必然跳转失败,这正好用来验证验收第 10 项的**回退路径**:
`try` 私有 Intent，失败则退到 `Settings.ACTION_APPLICATION_DETAILS_SETTINGS`,
并展示图文步骤说明。回退逻辑写好后，2B 只需补验私有 Intent 能否真的跳中。

权限状态需持久化「用户已明确拒绝」标记,避免每次启动都弹。再次引导入口放设置页。

### 3.4 通知交互

- 点通知体　跳客户详情页。阶段 3 才有该页面,2A 先跳到一个占位页并断言路由参数正确
- 「已完成」按钮　调 `PlanDao.markCompleted()`,通知消失
- 「推迟一天」按钮　调 `PlanDao.postpone()`,重新排闹钟

两个按钮要在应用未启动时也能工作,所以回调必须走后台 isolate,
需要 `@pragma('vm:entry-point')` 标注,否则 release 构建会被 tree-shaking 掉。
后台 isolate 里拿不到主 isolate 的数据库实例,要单独开连接。

### 3.5 触发日志

验收第 9 项要求应用内可查看,含计划时间与实际触发时间。

阶段 1 已在 `follow_plans` 表留了 `notifiedAt` 字段,`PlanDao.markNotified()`
存的是**真实触发时刻**而非计划时刻。两者差值就是系统延迟,
这是判断 ColorOS 有没有掐闹钟的直接证据。

本期加一个简单的日志列表页,展示 `planAt` / `notifiedAt` / 差值。
不做美化,能看清数字即可。

**不新增日志表**,复用 `notifiedAt`。理由:阶段 1 的八张表结构已定稿并通过验收,
加第九张表会打破 `migration_test.dart` 的表清单断言,而现有字段已够用。

## 4. 风险与降级预案

### 4.1 主要风险

**ColorOS 掐闹钟**　最大风险。所有权限都给了仍可能被压制。这是 2B 才能暴露的问题。

**后台 isolate 拿不到数据库**　通知按钮回调在独立 isolate 执行,
drift 的数据库实例不能跨 isolate 共享。需在回调内新开连接,
并注意与主 isolate 的写冲突。

**覆盖安装清空闹钟**　见 3.2,开发期最容易误判为「闹钟随机失效」。

### 4.2 降级顺序

调度层写成接口,便于整体替换而不是散落各处改:

1. `alarmClock` + `flutter_local_notifications`（首选,本期实现）
2. 降到 `exactAllowWhileIdle`,若 ColorOS 对 `setAlarmClock` 有特殊限制
3. 换 `android_alarm_manager_plus` 直接调 `AlarmManager`,自己发通知
4. 前台服务常驻 + 自建轮询,最后手段。代价是常驻通知栏图标与耗电

第 4 条明显影响体验,只在前三条都失败时用。若走到这一步,
需按 PRD 第 8 节「未通过则重新评估技术方案」的要求,先和用户确认再继续。

## 5. 2A 验收标准

2A 全部通过才进 2B。真机相关项在 2A 报告中标注「待真机确认」而非打勾。

1. `flutter analyze` 无问题,`flutter test` 全绿（含阶段 1 的 88 项不回归）
2. Manifest 已移除 `USE_EXACT_ALARM`,精确闹钟申请流程能实际触发系统设置页
3. 通知权限、精确闹钟、电池优化三项引导在模拟器上可完成,拒绝后能从设置页再次进入
4. ColorOS 私有 Intent 跳转失败时正确回退到应用详情页,并展示图文步骤
5. 设 5 分钟后提醒,锁屏状态准时弹出,误差 ≤ 60 秒
6. 强杀应用后提醒仍触发
7. 飞行模式下提醒仍触发
8. `adb reboot` 后未来提醒全部仍能触发
9. 覆盖安装（`flutter run` 重装）后未来提醒仍能触发,验证 `MY_PACKAGE_REPLACED`
10. 点通知跳转携带正确的 planId 与 customerId
11. 「已完成」按钮使计划状态变为 completed,`completedAt` 落库
12. 「推迟一天」按钮使 planAt 顺延 24 小时、状态回 pending、`notifiedAt` 清空,
    且新闹钟已重新排期
13. 应用未启动时点击通知按钮同样生效（验证后台 isolate 路径）
14. 触发日志页显示计划时间、实际触发时间与差值
15. 时区变更后已排闹钟按新时区重排

## 6. 不在本期范围

- 客户详情页真实内容（阶段 3）。2A 只验路由参数正确
- 任何界面美化。PRD 明确本期不做
- 周期性提醒与生日提醒。已确认不做（PRD 第 10 节决策 2）
- 订单、漏斗、附件（阶段 4）

## 7. 2B 待办（真机到手后）

1. 补 ColorOS 自启动与后台弹出界面权限的私有 Intent,验证能真的跳中
2. 复验 2A 的第 5 至 8 项
3. 验收第 11 项:次日早晨提醒 + 整夜息屏充电
4. **验收第 8 项硬门槛:连续 3 天、每天至少 2 个提醒、触发率 100%**
5. 写 `docs/phase2/VERIFICATION-2B.md`,给出是否进入阶段 3 的结论

3 天观察窗口无法压缩。建议真机一到手就先把测试提醒排进去,
让观察期与阶段 3 的准备工作并行,而不是等 2A 全部做完才开始数天数。
