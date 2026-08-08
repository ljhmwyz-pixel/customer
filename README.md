# 客户跟进助手

Android 单机 CRM，面向单人外贸销售。数据保存在设备本地，不依赖账号、网络或云端服务。

## 主要能力

- 客户、联系人和多项目管理
- 跟进时间线、今日任务和本地提醒
- 报价、样品、注册、招标、订单及附件
- 客户/联系人 CSV、Excel 导入
- 四表 Excel 导出
- 含 SQLite 与附件的完整备份和恢复

## 开发环境

- Flutter 3.44.8
- Dart 3.12.2
- Java 17
- Android SDK 37

```bash
flutter pub get
dart run build_runner build
flutter analyze
flutter test
```

依赖版本被刻意锁定，原因见 [TECH_STACK.md](docs/TECH_STACK.md)。

## 正式签名

Release 构建不会回退到 Android Debug 证书。首次构建前：

1. 在安全位置创建正式 keystore，并建立至少两份离线备份。
2. 将 `android/key.properties.example` 复制为 `android/key.properties`。
3. 填写 keystore 绝对路径、alias 和密码。
4. 永久保留同一证书；更换证书后不能直接覆盖升级既有安装。

`android/key.properties`、`*.jks` 和 `*.keystore` 已被 Git 忽略。不要把密钥或密码放入仓库、聊天记录或构建日志。

```bash
flutter build apk --release

APKSIGNER=$(find "$HOME/Library/Android/sdk/build-tools" -type f -name apksigner | sort -V | tail -1)
"$APKSIGNER" verify --print-certs build/app/outputs/flutter-apk/app-release.apk
shasum -a 256 build/app/outputs/flutter-apk/app-release.apk
```

## 数据边界

- Android 系统自动备份和设备迁移已禁用，避免绕过应用自己的校验恢复流程。
- 完整备份 ZIP 当前未加密，包含全部客户资料、数据库和附件，必须存放在受控位置。
- 卸载、清除应用数据或丢失设备会删除本机数据；正式使用必须定期把备份保存到其他设备。
- 通知在锁屏上使用私密可见性，具体显示仍受用户系统通知设置影响。

## 发布门槛

代码门槛见 [TEST_CHECKLIST.md](docs/TEST_CHECKLIST.md)。正式分发还必须完成：

1. 从干净、已打 tag 的提交构建。
2. 使用正式证书签名并记录证书摘要和 APK SHA-256。
3. 用生产类副本执行一次破坏性备份恢复演练。
4. 在一加 13 / ColorOS 15 完成连续 7 天提醒、重启、Doze、文件选择、相机和系统分享验收。
5. 从旧正式版本覆盖安装并验证数据库迁移、附件和未来提醒。

模拟器、CI 和临时签名只能证明候选包可构建，不能替代正式签名托管和目标真机验收。
