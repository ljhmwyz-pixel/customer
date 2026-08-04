# 技术选型

版本 v1.1　　最后更新 2026-08-04

第 3 节的依赖清单是 pub 求解器在本机实际算出并通过 `pub get` 的组合，
不是各包的理论最新版。多处刻意停留在旧版，原因逐条记在注释里。

## 1. 本机环境现状

全部就绪，阶段 0 已验证：

- Flutter 3.44.8 / Dart 3.12.2，位于 `/Users/snyder/development/flutter`
- Android SDK，platforms 至 android-37.0，build-tools 至 37.0.0，NDK 已装
- Android Studio 自带 JDK 21，`JAVA_HOME` 已写入 `~/.zshrc`
- `cmdline-tools` 19.0 已装，`flutter doctor --android-licenses` 全部接受
- Pixel_8 模拟器可用

两项环境注意事项，后续阶段仍会遇到：

**GitHub 直连不通**　所有访问 github.com 的操作都会超时。Flutter 自身的升级走
清华镜像 remote（`https://mirrors.tuna.tsinghua.edu.cn/git/flutter-sdk.git`），
拉取产物必须带镜像环境变量：

```bash
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
```

因为是用镜像 remote 切分支，`flutter --version` 会显示 `channel [user-branch]`
而非 stable。不影响编译，不必修。回退点 `00b0c91f062`（3.41.9）。

**大文件下载会被截断**　Gradle 发行包和 SDK 组件的自动下载都出现过中途断流，
症状是 `ZipException: zip END header not found`。判断方法是比对文件大小，
`gradle-8.14-all.zip` 完整为 224116304 字节。修法是从 `~/.gradle/wrapper/dists/`
下已有的完整副本拷过去，或改用 `sdkmanager` 重装（它会重试）。

## 2. 核心选型决策

### 状态管理　riverpod 3.3.2

选它而非 provider 或 bloc 的原因：编译期安全、不依赖 BuildContext、测试时替换依赖简单。单人项目里 bloc 的模板代码量是负担。

注意 riverpod 已进入 3.x，与网上大量 2.x 教程的 API 有差异。以官方文档为准，遇到 `StateNotifierProvider` 这类 2.x 写法要换成 3.x 的 `Notifier` / `AsyncNotifier`。

### 本地数据库　drift 2.34.3 + drift_dev 2.34.0

选它而非裸 sqflite 或 Isar 的原因：类型安全的查询 DSL、编译期校验 SQL、迁移机制成熟。CRM 数据是典型关系型，需要多表连接与聚合，drift 在这方面明显优于文档型方案。

**一个必须注意的变更**：`sqlite3_flutter_libs` 已标记 EOL（最新版本号为 `0.6.0+eol`，描述为 "Not used anymore"）。现在应直接依赖 `sqlite3` 3.5.0，它已内置原生库，不再需要额外的 flutter libs 包。按旧教程添加 `sqlite3_flutter_libs` 会引入已废弃依赖。

### 路由　go_router 17.3.0

声明式路由，支持通知点击后的深链跳转，这是提醒功能的必要能力。

### 提醒　flutter_local_notifications 22.2.0 + android_alarm_manager_plus 5.1.1

两者分工不同，都需要：

- `flutter_local_notifications` 负责通知的展示、通知渠道、通知上的操作按钮
- `android_alarm_manager_plus` 负责在应用未运行时唤醒执行调度逻辑

`timezone` 0.11.1 是前者的硬性依赖，用于处理精确定时的时区计算。

## 3. 完整依赖清单

全部写死版本，不使用 `^` 范围。单人维护的项目，最不需要的是某天 `pub get`
之后突然编译不过。

以 `pubspec.yaml` 为准，本节说明为什么是这些版本。

### 约束的总根源

`flutter_test` 把 `meta` 钉死在 1.18.0，而 `analyzer` 从 13.1.0 起要求
`meta ^1.18.3`。于是整条 analyzer 13.1+ 生态都进不来，凡是依赖它的包都要
停在旧版。这一条解释了下面大部分「为什么不用最新版」。

等 Flutter 放开 meta 之后，可以整体升一轮，届时 `dependency_overrides` 也能移除。

### 与理论最新版的差异

| 包 | 采用 | 最新 | 原因 |
|---|---|---|---|
| flutter_riverpod | 3.3.2 | 3.4.2 | 3.4.x 经 riverpod_annotation 拉高 analyzer，与上述 meta 约束冲突 |
| riverpod_annotation | 4.0.3 | 4.0.6 | 4.0.5+ 要求 riverpod 3.4.x，同上 |
| riverpod_generator | 4.0.4 | 4.0.8 | 4.0.6+ 要求 analyzer ^13.0.0 |
| riverpod_lint | 3.1.4 | 3.1.8 | 同上 |
| drift_dev | 2.34.0 | 2.34.5 | 2.34.1+ 要求 analyzer ^13.0.0 |
| build_runner | 2.15.1 | 2.16.0 | 2.15.2+ 要求 analyzer >=13.3.0 |
| archive | 3.6.1 | 4.0.9 | excel 4.0.6 依赖 archive ^3.6.1 |

### 一处 dependency_overrides

```yaml
dependency_overrides:
  sqlparser: 0.44.5
```

drift_dev 2.34.0 声明 `sqlparser: ^0.44.0`，但 0.44.6 移除了
`DartPlaceholder.when`，而 drift_dev 2.34.0 仍在调用它。上游把破坏性变更
发在了补丁号上，`^` 约束挡不住。不锁的话 `build_runner` 连构建脚本都编译不过：

```
Error: The method 'when' isn't defined for the type 'DartPlaceholder'.
```

drift_dev 2.34.2+1 起改成了 `^0.45.0`，但那个版本要求 analyzer ^13，走不通。
所以只能锁 sqlparser。

### 两个被移除的包

**custom_lint**　riverpod_lint 3.1.x 已迁到 Dart 的 `analysis_server_plugin`
机制，不再需要 custom_lint，同时装会有 analyzer_plugin 版本冲突。

**file_picker**　稳定版 11.0.3 依赖 win32 5.x，与 share_plus 13.x /
device_info_plus 13.x 需要的 win32 6.x 冲突。虽然本项目只出 Android，
但 pub 的求解是跨平台的，冲突照样成立。

附件里的文档选择改用 Android 原生 intent（`ACTION_OPEN_DOCUMENT`）实现，
在阶段 4 做。图片选择不受影响，仍用 `image_picker`。

各包用途说明：

- `permission_handler` 统一处理通知、精确闹钟、存储、相机权限申请
- `device_info_plus` 用于识别 ColorOS，决定权限引导跳转哪个设置页
- `url_launcher` 用于一键拨号，以及跳转系统设置页
- `flutter_contacts` 从系统通讯录导入客户电话
- `photo_view` 附件图片的放大预览
- `open_filex` 调用系统应用打开 PDF 等文档
- `share_plus` 导出备份文件后分享到其他应用或存到网盘
- `riverpod_lint` 在编辑器里提示 riverpod 用法错误

## 4. 组件库选型

### 结论　不引入第三方 UI 组件库

Flutter 内置的 Material 3 已经覆盖本项目全部需求，额外引入 UI 库是净负担。理由有三点。

第一，Material 3 自带完整的暗色模式映射、无障碍语义、最小点击区域、动效曲线。这些是第三方库常常做得更差的地方。

第二，CRM 是工具型应用，视觉诉求是克制规整而非视觉个性。第三方库的独特外观在这里反而是减分项。

第三，第三方 UI 库是长期维护风险。单人项目一旦库停更，迁移成本全部落在你身上。

### 需要自建的复合组件

以下组件 Material 3 没有现成的，但都是用内置组件拼装，不是从零画：

- **客户卡片**　`Card` + `Row` + `Column` + 状态标记
- **跟进时间线**　`ListView` + 左侧 `Container` 竖线 + 圆点
- **阶段标记**　带背景色的小圆角 `Container`
- **漏斗视图**　`Column` + 按比例宽度的 `Container`
- **快捷时间选择**　`Wrap` + `ChoiceChip`
- **逾期提示条**　`Container` + 错误色系

这些都是半小时量级的工作，集中放在 `lib/widgets/` 下。

### 图标

使用 Material Icons 内置图标集，不引入第三方图标库。工具类操作一律用图标而非文字按钮，配 `Tooltip` 说明。

## 5. 项目结构

按功能分层，不按文件类型分层。这样改一个功能时相关文件都在一起。

```
lib/
  main.dart
  app.dart                    # MaterialApp 与路由挂载
  theme/
    theme.dart                # 配色、圆角、间距、字号的唯一来源
    tokens.dart               # 设计常量定义
    semantic_colors.dart      # 业务语义色按主题取值
  data/
    database.dart             # drift 数据库定义
    attachment_path.dart      # 附件相对路径生成与解析，纯函数
    database_provider.dart    # 数据库与六个 DAO 的 provider
    tables/                   # 八张表的定义
    daos/                     # 各表的数据访问对象
  models/                     # 领域模型与枚举
  features/
    home/                     # 今日待办首页
    customers/                # 客户列表、详情、编辑
    followups/                # 跟进记录与时间线
    reminders/                # 提醒相关页面
      permission_page.dart    # 五项权限引导
      vendor_steps.dart       # 厂商权限图文步骤
      reminder_log_page.dart  # 提醒记录，含计划/实际时间与差值
      reminder_test_page.dart # 提醒自检，排测试提醒
    orders/                   # 订单
    funnel/                   # 开发漏斗
    backup/                   # 导出与恢复
  widgets/                    # 跨功能复用组件
  services/
    reminder_scheduler.dart   # 调度抽象接口，便于整体替换实现
    notification_service.dart # 通知与闹钟封装，含时区反查
    notification_payload.dart # 通知 payload 编解码
    permission_service.dart   # 权限查询与申请
    oem_settings_channel.dart # 厂商设置页跳转通道
    app_prefs.dart            # 极简键值存储，落 JSON 文件
    service_providers.dart    # 服务层 provider
    attachment_service.dart   # 附件存取与压缩
    backup_service.dart       # zip 打包与还原
  utils/
```

`reminder_scheduler.dart` 这层抽象是刻意留的：ColorOS 对后台闹钟的管控很激进,
真机验证可能发现首选方案被压制，届时只需换一个实现并改
`service_providers.dart` 一处，不必翻遍散落各处的调用点。

`app_prefs.dart` 没有用 `shared_preferences`：依赖版本被 `flutter_test` 的
meta 1.18.0 压得很紧（见第 3 节），为存两三个布尔值去动依赖树不划算。
需要持久化的量级也确实只有这些，业务数据全在 drift 里。

原生侧另有 `android/app/src/main/kotlin/com/snyder/customer/OemSettingsBridge.kt`,
负责厂商私有权限页的组件名跳转与三层回退。这两项权限没有任何公开 API,
只能靠未文档化的 Activity 组件名，每次跳转都必须假定它会失败。

## 6. 代码规范

- 启用 `flutter_lints` 6.0.0 默认规则集
- 所有异步数据访问返回 `Future`，不在 UI 层直接写 SQL
- 数据库访问一律经过 DAO，页面不直接触碰 `database.dart`
- 枚举值存库用字符串而非整数，便于人工检视导出的 JSON
- 时间统一存 UTC 毫秒时间戳，展示时转本地时区
- 金额用整数存分，不用 `double`，避免浮点误差

最后两条是数据层的硬约定，写错了后期修正代价很高。

## 7. 已排除的技术方案

记录排除理由，避免后续反复讨论。

- **Supabase / 任何后端**　单人本地使用，无同步需求，引入后端会带来账号、网络异常、延迟等一整套复杂度
- **Isar / Hive**　文档型数据库不适合需要多表连接与聚合的 CRM
- **bloc**　模板代码量对单人项目是负担
- **第三方 UI 库**　见第 4 节
- **FCM 推送**　国内不可用，且本项目无服务端，纯本地闹钟即可
- **uni-app / React Native**　Flutter 的原生能力接入更直接，提醒是本项目核心风险点

## 8. Android 构建配置

以下几项不是默认值，是阶段 0 实测必须改的。写在这里避免后续误删。

`android/app/build.gradle.kts`：

```kotlin
compileSdk = 37                          // 插件依赖已要求 37，编译版本向后兼容
minSdk = 26                              // 精确闹钟与通知渠道 API 的下限
isCoreLibraryDesugaringEnabled = true    // flutter_local_notifications 强制要求

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
```

不开 desugaring 会直接构建失败：

```
Dependency ':flutter_local_notifications' requires core library desugaring
```

`compileSdk` 用 `flutter.compileSdkVersion` 会低于插件要求，必须写死 37。

`AndroidManifest.xml` 已声明的权限，阶段 2、4 会用到：

| 权限 | 用途 |
|---|---|
| `POST_NOTIFICATIONS` | 展示提醒，Android 13+ 需运行时申请 |
| `SCHEDULE_EXACT_ALARM` / `USE_EXACT_ALARM` | 精确闹钟，保证按分钟触发 |
| `RECEIVE_BOOT_COMPLETED` | 开机后重建已排期的提醒 |
| `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` | 引导加入电池白名单 |
| `WAKE_LOCK` | 排期与备份写入期间保持唤醒 |
| `READ_CONTACTS` | 从系统通讯录导入客户 |

另外声明了 `DIAL` 与 `smsto` 两个 `queries` intent，供客户详情页一键联系用。
Android 11+ 不声明的话查不到可处理的应用。
