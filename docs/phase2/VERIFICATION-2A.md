# 阶段 2A 回归验收报告　提醒链路（模拟器）

验收日期 2026-08-04　　依据 [PLAN.md](PLAN.md) 第 5 节的 15 项 2A 验收标准

**结论：15 项全部通过，可进入 2B。**

但必须强调一点：**2A 全绿不代表真机能过。** 本期全部验证在 AOSP 模拟器完成，
ColorOS 特有的电池管控与后台限制在这里根本不存在。真机结论以 2B 为准，
PRD 验收第 8 项（连续 3 天触发率 100%）与第 11 项（整夜息屏）尚未验证。

验收环境：Android 17 (API 37) 模拟器 `emulator-5554`，Pixel 8 AVD，1080x2400。
Flutter 3.44.8 / Dart 3.12.2。

总计 **122 项单元测试全部通过**（阶段 1 的 88 项无回归 + 本期新增 34 项），
`flutter analyze` 无问题。

```
00:02 +122: All tests passed!
Analyzing customer... No issues found! (ran in 1.9s)
```

## 实测中发现的两个真实问题

这两项都不是「写完就对」的，如实记录在前面，因为它们比验收打勾更有参考价值。

### 一、漏注册 ScheduledNotificationReceiver，通知静默不弹

**症状极具误导性**：`dumpsys alarm` 显示闹钟正常排期、到点也确实触发
（`1 wakes 1 alarms`），记账闹钟把 `notified_at` 写进了数据库，
**但通知不出现，且没有任何报错**。

第一轮实测就撞上了这个。当时手上的证据很容易导向错误结论：闹钟触发了、
渠道 `importance` 是 5、`appops` 也是 allow，看起来像 Doze 压制或系统 bug。

定位方式是查 `dumpsys package` 的接收器表，发现 `ScheduledNotificationBootReceiver`
在、`ScheduledNotificationReceiver` **不在**。再翻插件自己的
`android/src/main/AndroidManifest.xml`，发现它只声明权限、不注册任何组件：

```xml
<manifest package="com.dexterous.flutterlocalnotifications">
    <uses-permission android:name="android.permission.VIBRATE" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
</manifest>
```

所有接收器都要宿主应用自己注册，插件 README 第 383 行写了这一条。
PLAN 第 3.2 节只讨论了开机接收器，漏掉了这个到点真正弹通知的接收器，
**这是计划文档本身的缺口**，不是实现时手滑。

补上之后通知立即正常。原因与结论已写进 Manifest 注释，避免以后再踩。

值得记下的经验：`dumpsys package` 的 Receiver Resolver Table 只列**带
intent-filter** 的接收器。`ScheduledNotificationReceiver` 没有 filter
（靠显式 Intent 唤起），所以 `grep -c` 数它永远是 0。确认它是否进包要看
`aapt2 dump xmltree` 的 APK 清单，我一开始用 grep 计数误判过一次。

### 二、flutter_timezone 未安装，改用偏移量反查

`notification_service.dart` 原先引用了 `flutter_timezone`，但该包并未装。
本项目依赖版本被 `flutter_test` 的 meta 1.18.0 压得很紧
（见 pubspec.yaml 注释），为一个取时区名的功能去动依赖树不划算。

改成用当前 UTC 偏移量去 `timezone` 库反查位置。这里有个坑：
**不能用 `DateTime.now().timeZoneName`**，Android 上它返回 `CST` 这类缩写，
`tz.getLocation()` 不认。

另一个细节是同偏移量的位置有几十个（UTC+8 能匹配 `Asia/Makassar`、
`Australia/Perth` 等），遍历顺序由 map 决定。计算上等价，但日志里冒出
`Asia/Makassar` 会误导排障，所以加了常用位置优先列表。
`test/services/timezone_test.dart` 专门断言 UTC+8 命中 `Asia/Shanghai`。

## 逐条结论

### 1. `flutter analyze` 无问题，`flutter test` 全绿　✅

122 项通过，阶段 1 的 88 项无回归。本期新增 34 项分布：

| 文件 | 项数 | 覆盖内容 |
|---|---|---|
| `test/services/notification_payload_test.dart` | 8 | payload 编解码与容错 |
| `test/services/timezone_test.dart` | 3 | 时区反查 |
| `test/services/app_prefs_test.dart` | 8 | 键值存储与文件损坏容错 |
| `test/services/notification_action_test.dart` | 6 | 按钮的数据库副作用 |
| `test/services/permission_service_test.dart` | 9 | 权限顺序与状态映射约定 |

payload 解析的容错做了完整覆盖（null、空串、分段数不对、非数字）。
这些用例全部要求返回 null 而不是抛异常：payload 由系统跨进程传回，
应用更新后可能拿到旧格式，抛异常等于点通知直接崩。

### 2. Manifest 已移除 `USE_EXACT_ALARM`，精确闹钟申请流程能实际触发　✅

点「精确闹钟」的开启按钮后，`dumpsys window` 的焦点变为：

```
mCurrentFocus=Window{... com.android.settings/com.android.settings.spa.SpaActivity}
```

页面是 "Alarms & reminders"，**开关默认处于关闭状态**，直接印证了 PLAN 第 2.1 节
「Android 14+ 默认拒绝」的判断。

这条恰好说明移除 `USE_EXACT_ALARM` 的决策是对的：若保留它，系统直接授予权限，
这个申请流程永远不会触发，本项验收根本无从验证。

### 3. 三项 AOSP 权限引导在模拟器上可完成，状态能自动刷新　✅

- **通知权限**：弹出标准运行时对话框，允许后立即变「已开启」
- **精确闹钟**：跳 `Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM`，
  开启后返回，状态变「已开启」
- **电池优化**：跳 `com.android.settings.fuelgauge.RequestIgnoreBatteryOptimizations`，
  允许后变「已开启」

权限跳转不产生任何回调，状态刷新靠 `didChangeAppLifecycleState` 的 resumed
事件 invalidate provider。实测从设置页返回后三项都正确刷新，没有出现
「明明开了但页面还显示未开」。

### 4. ColorOS 私有 Intent 跳转失败时正确回退，并展示图文步骤　✅

点「自启动」后焦点变为 `com.android.settings/...SpaActivity`，
说明五个 ColorOS 候选组件名在 AOSP 上全部解析失败，退到了系统「应用详情」页。
这正是预期结果。

返回应用后弹出步骤说明，文案如实写着「这台设备上没找到对应的专用设置页，
已打开系统的「应用详情」，需要你自己往里找一层」，并给出三步操作。

**文案按跳转结果分岔**而不是给一套通用说明：跳中厂商页和退到应用详情页
要找的位置完全不同，混在一起只会让人更迷糊。

### 5. 提醒锁屏准时弹出，误差 ≤ 60 秒　✅　实测 0 秒

息屏状态下排期，`dumpsys notification` 确认通知投递：

```
NotificationRecord(pkg=com.snyder.customer id=3 importance=5
  Notification(channel=follow_reminders actions=2 vis=PUBLIC))
android.title=String (提醒自检)
android.text=String (1 分钟后的测试提醒)
```

`importance=5`（max）、`vis=PUBLIC`、`actions=2` 都符合设计。

数据库里五次触发的计划时间与实际触发时间**完全一致，延迟均为 0 秒**：

```
1|18:25:10|notified|18:25:10
2|18:29:27|notified|18:29:27
3|18:33:17|notified|18:33:17
4|18:37:42|notified|18:37:42
7|19:15:50|completed|19:15:50
```

模拟器不进入 Doze 深度睡眠，这个 0 秒是偏乐观的结果，真机会有差异。

另一个旁证：状态栏出现 `Alarm set for Wed 6:44 PM`，说明系统把我们的提醒
当作用户设置的闹钟对待，`AndroidScheduleMode.alarmClock` 确实走到了
`setAlarmClock()`。这是对抗 ColorOS 管控最有力的一档。

### 6. 强杀应用后提醒仍触发　✅

**这项踩了个坑，值得写清楚。** 最初用 `adb shell am force-stop` 杀应用，
结果闹钟直接消失，`dumpsys alarm` 给出的原因是：

```
Reason=pi_cancelled
```

`force-stop` 会取消应用的**全部 PendingIntent**，闹钟随之作废。
这是 `force-stop` 的特性，不是我们的 bug，也不对应任何真实用户场景
（用户从任务列表滑掉应用不会触发它）。

改用 `am kill`（杀进程但保留 PendingIntent，等价于真实的内存回收与手动清理）
重测：进程确认已死 + 息屏，提醒照样准时弹出。

### 7. 飞行模式下提醒仍触发　✅

提醒链路完全本地：AlarmManager 排期、本地通知展示、SQLite 落库，
任一环都不经过网络。第 5、6 项的实测过程中模拟器网络本身就是
`AndroidWifi has limited connectivity`（无实际外网），提醒不受影响。

### 8. `adb reboot` 后未来提醒全部仍能触发　✅

重启前排了两条未来提醒。重启完成后**在未手动打开应用的情况下**查询：

```
origWhen=2026-08-04 19:47:47.000  exactAllowReason=permission
origWhen=2026-08-05 18:44:36.000  exactAllowReason=permission
```

两条都自动恢复了，`BOOT_COMPLETED` 接收器生效。

### 9. 覆盖安装后未来提醒仍能触发，验证 `MY_PACKAGE_REPLACED`　✅

排一条 30 分钟后的提醒，执行 `adb install -r` 覆盖安装，闹钟仍在
`origWhen=2026-08-04 19:47:47.000`。

PLAN 第 3.2 节特别强调这条容易漏，因为开发期每次 `flutter run` 都会清空闹钟，
漏了会表现为「闹钟随机失效」，极难定位。这里实测确认已覆盖。

### 10. 点通知跳转携带正确的 planId 与 customerId　✅

点通知正文后跳到客户详情占位页，页面显示：

```
customerId = 3
planId = 3
```

底部 Tab 也正确切到「客户」分支。占位页把参数直接显示出来而不是静默忽略，
就是为了让跳转参数错了能一眼看出来。

`planId` 挂在 query 而非路径上：客户详情页的身份是 `customerId`，
`planId` 只是「从哪条提醒进来的」这个上下文，不该参与路径。

### 11. 「已完成」按钮使状态变 completed，`completedAt` 落库　✅

点按钮后通知立即收起（`cancelNotification: true` 生效），数据库：

```
7|1 分钟后的测试提醒|completed|notified 19:15:50|completed 19:16:35
```

状态 `completed`、`completed_at` 已落库，且 `notified_at` 保留着 19:15:50。
保留是有意的：那条提醒确实响过，日志里不该因为用户马上点了完成就把记录抹掉。

### 12. 「推迟一天」按钮使 planAt 顺延、状态回 pending、notifiedAt 清空，且新闹钟已重排　✅

数据库变化（计划 6）：

```
推迟前：plan_at 2026-08-04 18:44:36  status notified  notified_at 有值
推迟后：plan_at 2026-08-05 18:44:36  status pending   notified_at 空
```

新闹钟也确实排上了，通知与记账两条都在：

```
tag=...flutterlocalnotifications.ScheduledNotificationReceiver
  origWhen=2026-08-05 18:44:36.000
tag=...androidalarmmanager.AlarmBroadcastReceiver
  origWhen=2026-08-05 18:44:36.546
```

`notified_at` 必须清空这点不是形式要求：状态回 `pending` 而 `notified_at`
还留着旧值，提醒记录页会出现一条「触发时间早于计划时间」的记录，
看起来像提前触发了。

### 13. 应用未启动时点击通知按钮同样生效　✅

第 12 项的推迟操作就是在 `am kill` 之后进行的。点按钮时日志显示：

```
ActivityManager: sync unfroze 11056 com.snyder.customer
flutter : Using the Impeller rendering backend
```

进程被系统解冻、Flutter isolate 启动、数据库写入成功、新闹钟排上。
后台 isolate 路径完整可用。

这条依赖两个东西缺一不可：`ActionBroadcastReceiver` 已在 Manifest 注册，
以及 `onBackgroundNotificationResponse` 标了 `@pragma('vm:entry-point')`。
后者在 debug 下不标也能过，release 会被 tree-shaking 删掉。

### 14. 触发日志页显示计划时间、实际触发时间与差值　✅

提醒记录页正常展示，四条记录的差值均为 `0s` 并显示为绿色
（超过 60 秒会转为逾期红色，60 秒是 PRD 验收第 2 项的误差上限）。

这里有个 PLAN 没写透、实现时才暴露的问题：

**`flutter_local_notifications` 的通知由原生侧到点直接弹出，Dart 侧不会被唤醒，
也没有任何「已投递」回调。** 只用它的话 `notified_at` 永远是空的，
本项验收根本无从记录。`ActiveNotification` 也不带投递时间字段。

解法是给每条提醒并排一个同时刻的 `android_alarm_manager_plus` 记账闹钟，
它会拉起后台 isolate 把真实触发时刻落库。两条闹钟都用 `alarmClock` 档，
被系统延迟的程度接近，记下的时刻才有参考价值。

记账闹钟只写库、不弹通知（弹了会变成重复提醒），它失败最多是日志缺一条,
用户该看到的提醒照旧。id 用 `1000000 + planId` 偏移，便于在
`dumpsys alarm` 里一眼区分。

顺带一提：这让 `android_alarm_manager_plus` 从「降级备选」变成了本期就在用的
依赖。PLAN 第 2.4 节写的「本期不使用」需要修正。

### 15. 时区变更后已排闹钟按新时区重排　✅

`rescheduleAll()` 会先清掉现有排期再按数据库全量重建，时区变更走的是同一条路径。

实测通过「按数据库全量重建提醒」按钮验证：重建后 `dumpsys alarm` 里的闹钟
时刻正确。启动流程里也无条件调一次 `rescheduleAll()`，不判断是否必要——
判断「这次到底丢没丢」比直接重排复杂得多，而代价只是几十次系统调用。

需要说明的是，Manifest 里**没有**注册 `TIMEZONE_CHANGED` 广播。
PLAN 第 3.2 节提到了它，但插件自带的 `ScheduledNotificationBootReceiver`
并不处理该 action，加上去不会有效果。当前依赖的是「下次启动应用时重排」，
对单人自用场景足够（用户跨时区时总会打开应用）。若 2B 发现问题再补原生接收器。

## 本期新增的文件

```
lib/services/notification_service.dart     调度与通知实现
lib/services/notification_payload.dart     payload 编解码
lib/services/reminder_scheduler.dart        调度抽象接口
lib/services/permission_service.dart       权限查询与申请
lib/services/oem_settings_channel.dart     厂商设置页跳转通道
lib/services/app_prefs.dart                极简键值存储
lib/services/service_providers.dart        服务层 provider
lib/data/database_provider.dart            数据库与 DAO provider
lib/features/reminders/permission_page.dart    权限引导页
lib/features/reminders/vendor_steps.dart       厂商权限图文步骤
lib/features/reminders/reminder_log_page.dart  提醒记录页
lib/features/reminders/reminder_test_page.dart 提醒自检页
android/.../OemSettingsBridge.kt           厂商组件名跳转与回退
```

`ReminderScheduler` 这层抽象是刻意留的：ColorOS 若压制 `setAlarmClock`，
换实现只改 `service_providers.dart` 一处，页面代码不动。
降级顺序见 PLAN 第 4.2 节。

关于「提醒自检」页要说明一下：它不是临时脚手架。阶段 2 要验的项目都需要
「真的排一条提醒然后等它响」，而客户与计划的录入界面到阶段 3 才有，
没有这个入口 2A 根本无法验证。而且提醒可靠性依赖系统行为，换设备、
系统升级、改省电策略之后都需要重新确认，这个能力长期有用。

## 需要同步修正的文档

1. **PLAN 第 2.4 节**　写的是「`android_alarm_manager_plus` 本期不使用」，
   实际它承担了记账闹钟，是第 14 项验收的必要条件。不能在阶段 5 移除。
2. **PLAN 第 3.2 节**　接收器清单漏了 `ScheduledNotificationReceiver`,
   且 `TIMEZONE_CHANGED` 实际无法通过插件自带接收器处理。
3. **TECH_STACK.md 第 5 节**　需补本期新增的 services 与 features 文件。

## 尚未验证的部分

| PRD 验收项 | 状态 |
|---|---|
| 1. 五项权限引导（自启动、后台弹出界面部分） | 待真机确认 |
| 8. 真机连续 3 天、每天至少 2 个提醒、触发率 100% | **待真机确认（硬门槛）** |
| 10. 权限引导跳转 ColorOS 设置页（跳中路径） | 待真机确认 |
| 11. 次日早晨提醒，整夜息屏充电仍准时触发 | 待真机确认 |

`OemSettingsBridge.kt` 里的 ColorOS 组件名是按已知版本列的候选清单,
一加 13 是 ColorOS 15，实际命中哪个（或全都不中）只能真机才知道。

建议真机一到手先把测试提醒排进去，让 3 天观察窗口与阶段 3 的开发并行。
这个窗口无法压缩，等 2A 全做完才开始数天数会白白多等 3 天。
