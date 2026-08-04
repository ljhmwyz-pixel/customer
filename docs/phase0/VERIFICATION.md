# 阶段 0 回归验收报告

验收日期 2026-08-04　　依据 [PLAN.md](PLAN.md) 第 4 节的 8 项标准

**结论：8 项全部通过，可进入阶段 1。**

验收环境：macOS 26.5.2 arm64，Flutter 3.44.8 / Dart 3.12.2，Pixel_8 模拟器
（Android 16，1080x2400）。目标真机一加 13 在阶段 2 才需接入。

## 逐条结论

### 1. flutter doctor 无 Android 相关报错，license 检查通过　✅

```
[✓] Android toolchain - develop for Android devices (Android SDK version 37.0.0)
```

`flutter doctor --android-licenses` 已全部接受。

余下三条提示均与 Android 工具链无关，不影响构建：

- Channel 显示 `[user-branch]`：升级走的是清华镜像 remote 而非官方 GitHub 源，
  故识别不出 channel。`flutter channel stable` 会卡在连 GitHub，不修。
- Network resources 检查 github.com 超时：本机环境限制。
- 无线设备「大宝的社会🚀」连接提示：与本项目无关的干扰项。

### 2. pubspec.yaml 依赖与文档一致，版本号无 `^`　✅

`pub get` 成功，177 个依赖。所有直接依赖均为精确版本，无 `^`。

但**实际组合与原 TECH_STACK.md 第 3 节有出入**，文档已按实际情况更新至 v1.1。
差异及原因如下，同时写进了 pubspec.yaml 的行内注释。

根源是一条约束链：`flutter_test` 把 `meta` 钉死 1.18.0，而 `analyzer` 13.1.0+
要求 `meta ^1.18.3`，导致整条 analyzer 13.1+ 生态都进不来。

| 包 | 文档原定 | 实际 |
|---|---|---|
| flutter_riverpod | 3.4.2 | 3.3.2 |
| riverpod_annotation | 4.0.6 | 4.0.3 |
| riverpod_generator | 4.0.8 | 4.0.4 |
| riverpod_lint | 3.1.8 | 3.1.4 |
| drift_dev | 2.34.5 | 2.34.0 |
| build_runner | 2.16.0 | 2.15.1 |
| archive | 4.0.9 | 3.6.1 |
| custom_lint | 0.8.1 | 移除 |
| file_picker | 11.0.3 | 移除 |

另有一处 `dependency_overrides` 锁 `sqlparser: 0.44.5`，因为 0.44.6 移除了
drift_dev 2.34.0 仍在调用的 `DartPlaceholder.when`。

`file_picker` 移除影响到 PRD 5.5 的附件功能：文档选择改用 Android 原生
`ACTION_OPEN_DOCUMENT` intent，阶段 4 实现。图片选择不受影响。

### 3. flutter pub get 与 build_runner 均成功执行　✅

```
Built with build_runner/aot in 19s; wrote 24 outputs.
```

首次执行失败过，报 `DartPlaceholder.when` 未定义，即上一条的 sqlparser 问题。
锁版本后通过。代码生成链路已验证可用，阶段 1 的 drift 表生成可以依赖它。

`flutter analyze` 无任何问题，`dart format` 已格式化。

### 4. flutter build apk --debug 成功产出 APK　✅

```
✓ Built build/app/outputs/flutter-apk/app-debug.apk
```

156 MB（debug 含全架构与调试符号，属正常）。首次构建 361 秒，增量 8 秒。

过程中排掉三个障碍，均已记入 TECH_STACK.md 第 1、8 节：

1. Gradle 发行包下载被截断（`ZipException: zip END header not found`），
   19 MB vs 完整 224 MB。从本机已有的完整副本拷贝解决。
2. 缺 Android SDK Platform 37，Gradle 自动下载同样被截断。用 `sdkmanager` 重装。
3. `flutter_local_notifications` 要求 core library desugaring。已在
   `build.gradle.kts` 开启并加 `desugar_jdk_libs:2.1.5`；`compileSdk` 写死 37。

### 5. APK 安装到模拟器可启动，四个 Tab 可切换且不崩溃　✅

安装成功，`am start` 后 `topResumedActivity` 为
`com.snyder.customer/.MainActivity`。

依次点击四个 Tab 并截图，每次点击后应用仍在前台。
logcat 过滤 `FATAL` 与 `AndroidRuntime` 无输出。
日志中仅有模拟器自身连不上 Google 服务的噪音，与应用无关。

### 6. tokens.dart 已按 UI 规范定义常量　✅

间距六档、圆角三档、字号六档、字重三档、语义色、最小触摸目标 48、
竖条与时间线尺寸均已定义。

`flutter test` 中有三项守护测试：间距均为 4 的倍数、卡片圆角不超过 8、字距为 0。

### 7. 明暗两套主题由 fromSeed 生成，跟随系统深色模式　✅

`cmd uimode night yes` 后应用即时切换到深色，未重启进程，无崩溃。

**本项发现并修复了一个真实问题。** 原设计里语义色是跨主题共用的单一常量，
但实测深色下红色 `0xFFC62828` 在近黑背景上对比度偏低。展开测算后发现浅色主题
本身也有两处不达 WCAG AA：

- `today` `0xFFE65100` 仅 3.6:1
- `inactive` `0xFF757575` 仅 4.38:1

改动三处：

1. 每个语义色增加深色变体，色相保持一致以稳定含义，明度按背景调整。
2. 新增 `lib/theme/semantic_colors.dart`，页面统一通过
   `AppSemanticColors.of(context)` 取色，不再直接读 `AppTokens`。
3. 加深 `today` 至 `0xFFBF360C`（5.33:1）、`inactive` 至 `0xFF616161`（5.74:1）。

现全部 10 个语义色值对各自主题 `surface` 的对比度均 ≥ 4.5:1，最低 4.87。
新增对比度测试守护此约束，UI_GUIDELINES.md 第 2 节已同步。

### 8. 首页所有间距与字号均引用常量，无字面量数字　✅

首页、空状态组件、导航外壳、客户页均无布局字面量，全部走 `AppTokens`。
唯一的数字是计数条占位文本 `'0'`，属展示内容而非布局数值。

## 测试结果

`flutter test` 8 项全通过：

```
四个 Tab 均可切换且不崩溃
空状态在客户页可见
明暗两套主题均由同一种子生成
字距为 0
间距均为 4 的倍数
卡片圆角不超过 8
语义色在各自主题背景上达到 WCAG AA 对比度
语义色随主题切换取到不同值
```

## 遗留事项

不阻塞阶段 1，但需记住：

1. **依赖版本受 meta 1.18.0 压制**。等 Flutter 放开后可整体升一轮，
   届时可移除 `dependency_overrides`。阶段 1 用 drift 时留意 2.34.0 的
   drift_dev 与 2.34.5 文档可能有细微差异。
2. **file_picker 缺位**，阶段 4 需自己写 `ACTION_OPEN_DOCUMENT` 的
   platform channel。
3. **Flutter channel 显示异常**，不影响编译。回退点 `00b0c91f062`（3.41.9）。
4. **大文件下载会被截断**，后续遇到 zip 相关报错先比对文件大小。
5. **未在真机验证**。阶段 0 只需模拟器；一加 13 真机在阶段 2 提醒链路验证时
   必须接入，那是硬门槛。

## 下一阶段

阶段 1　数据层：八张表 + DAO + 迁移机制，含性能测试与级联删除测试。
开工前先写 `docs/phase1/PLAN.md`。
