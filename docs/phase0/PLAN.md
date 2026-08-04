# 阶段 0 开发计划　环境与骨架

创建于 2026-08-04　　依据 [PRD.md](../PRD.md) 第 8 节、[TECH_STACK.md](../TECH_STACK.md)、[UI_GUIDELINES.md](../UI_GUIDELINES.md)

## 1. 本期目标

把开发环境补齐，建出能跑的项目骨架，并把设计规范落成代码常量。

本期不实现任何业务功能。四个 Tab 都是占位页，没有数据库、没有提醒。

目标是拿到一个可编译、可安装、能跟随系统深色模式切换的空壳，作为后续所有阶段的地基。

## 2. 待办清单

### 2.1 环境补齐

两项已知缺口，来自 TECH_STACK.md 第 1 节。

**JAVA_HOME 未设置**

系统 `java` 不在 PATH 中，但 Android Studio 自带 JDK 21。做法是把 `JAVA_HOME` 指向 Android Studio 的 jbr，并写入 `~/.zshrc` 使其持久生效。

```
/Applications/Android Studio.app/Contents/jbr/Contents/Home
```

**cmdline-tools 缺失**

这会导致 `flutter doctor` 的 Android license 检查无法通过。用 Android SDK 的 sdkmanager 安装，若 sdkmanager 本身不存在则需先下载 commandlinetools 包解压到 `~/Library/Android/sdk/cmdline-tools/latest`。

装好后执行 `flutter doctor --android-licenses` 接受全部许可。

### 2.2 项目创建

在当前目录创建 Flutter 项目，包名 `com.snyder.customer`，仅保留 Android 平台，不生成 iOS / Web / Desktop 目录。

项目名 `customer`，应用显示名「客户跟进」。

### 2.3 依赖安装

按 TECH_STACK.md 第 3 节写 `pubspec.yaml`，全部版本号写死不用 `^`。

本期只需保证依赖能正确解析并通过 `pub get`，不需要实际调用它们。

`build_runner` 本期需能成功空跑，验证代码生成链路可用。

**注意**：不添加 `sqlite3_flutter_libs`，它已 EOL。直接用 `sqlite3` 3.5.0。

### 2.4 设计常量落地

新建 `lib/theme/tokens.dart`，按 UI_GUIDELINES.md 定义：

- 主色种子 `0xFF7A8B3F`
- 间距六档 s4 / s8 / s12 / s16 / s24 / s32
- 圆角三档 r4 / r8 / r12
- 字号六档 f10 / f12 / f14 / f16 / f20 / f24
- 语义色 overdue / today / upcoming / done / inactive
- 最小触摸目标 48

新建 `lib/theme/theme.dart`，用 `ColorScheme.fromSeed` 生成明暗两套 `ThemeData`，统一设定输入框圆角、卡片圆角、字号阶梯与字重。

全局 `letterSpacing` 设为 0。

### 2.5 应用骨架

- `lib/main.dart`　入口，挂载 riverpod 的 ProviderScope
- `lib/app.dart`　MaterialApp.router，挂明暗主题与 themeMode: system
- `lib/router.dart`　go_router 配置，四条路由 + StatefulShellRoute 承载底部导航
- 四个占位页放在对应 feature 目录下

四个 Tab 按 PRD 的功能划分：

| Tab | 路由 | 图标 | 对应 PRD |
|---|---|---|---|
| 今日 | `/` | today | 5.3 今日待办 |
| 客户 | `/customers` | people | 5.1 客户管理 |
| 漏斗 | `/funnel` | filter_alt | 5.6 开发漏斗 |
| 我的 | `/settings` | settings | 5.7 备份设置 |

每个占位页用统一的空状态组件呈现，内容为一个图标加一句说明，符合 UI_GUIDELINES 第 6 节对空状态的要求。

首页额外展示一组 token 引用示例，用于验收第 8 项「无字面量数字」。

### 2.6 构建与安装

启动 Pixel_8 模拟器，构建 debug APK 并安装，验证启动与 Tab 切换。

切换模拟器系统深色模式，验证主题跟随。

## 3. 不在本期范围

- 任何数据库表与 DAO（阶段 1）
- 任何提醒与权限逻辑（阶段 2）
- 任何真实业务界面（阶段 3 及之后）
- 应用图标替换（阶段 5）
- release 签名（阶段 5）

## 4. 验收标准

来自 PRD.md 阶段 0，共 8 项。实现完成后逐条回归，全部通过才进入阶段 1。

1. `flutter doctor` 无 Android 相关报错，license 检查通过
2. `pubspec.yaml` 依赖与 TECH_STACK.md 第 3 节完全一致，版本号无 `^`
3. `flutter pub get` 与 `build_runner` 均成功执行
4. `flutter build apk --debug` 成功产出 APK
5. APK 安装到 Pixel_8 模拟器可启动，底部四个 Tab 可切换且不崩溃
6. `tokens.dart` 已按 UI_GUIDELINES.md 定义间距、圆角、字号、语义色常量
7. `theme.dart` 用 `ColorScheme.fromSeed` 生成明暗两套主题，切换系统深色模式应用跟随变化
8. 首页所有间距与字号均引用常量，无字面量数字

## 5. 风险与预案

**依赖版本冲突**　riverpod 3.x 与其他包可能存在传递依赖冲突。若 `pub get` 失败，以报错信息为准做最小幅度调整，并在回归报告中记录实际使用的版本与文档的差异。

**cmdline-tools 下载受阻**　若 sdkmanager 不可用且网络下载失败，回退方案是通过 Android Studio 的 SDK Manager 图形界面勾选安装。

**模拟器性能**　Pixel_8 模拟器在 arm64 Mac 上应可正常运行。若启动缓慢，本期验收可接受较长等待，不做优化。
