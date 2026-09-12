[![pub package](https://img.shields.io/pub/v/in_app_update.svg)](https://pub.dev/packages/in_app_update)

# in_app_update_ohos

Flutter 应用内更新插件，支持 Android 和 OpenHarmony（鸿蒙）。Android 使用 Google Play In-App Updates API，OpenHarmony 使用 AppGallery Connect Upgrade Kit。iOS 不提供应用内更新能力。

## 功能特性

- 检查应用是否有可用更新
- 立即更新（全屏流程）
- 灵活更新（后台下载）
- 监听安装状态
- Android 与 OpenHarmony 共用同一套 Dart API

## 环境要求

### Android

- Flutter 3.44 或更高版本
- Android SDK（插件当前使用 compileSdk 36，最低支持 Android API 16）
- 应用必须通过 Google Play 安装，应用内更新不能在本地直接安装的 APK 上验证

### OpenHarmony

- 支持 OpenHarmony 的 Flutter SDK（建议使用与项目匹配的 Flutter 3.44.x 版本）
- DevEco Studio、OpenHarmony SDK 和可运行的 phone/tablet/2in1 设备或模拟器
- 在 AppGallery Connect 配置 Upgrade Kit，并按平台要求完成应用签名和发布

## 安装

在应用的 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  in_app_update_ohos: ^5.0.0
```

然后执行：

```bash
flutter pub get
```

本仓库的 `example` 使用路径依赖指向插件根目录，可直接用于联调：

```bash
cd example
flutter pub get
```

## 快速开始

```dart
import 'package:in_app_update_ohos/in_app_update.dart';

Future<void> checkAndUpdate() async {
  final info = await InAppUpdate.checkForUpdate();

  if (info.updateAvailability == UpdateAvailability.updateAvailable) {
    if (info.immediateUpdateAllowed) {
      await InAppUpdate.performImmediateUpdate();
    } else if (info.flexibleUpdateAllowed) {
      await InAppUpdate.startFlexibleUpdate();
      // 下载完成后调用；OpenHarmony 上该操作由系统自动完成。
      await InAppUpdate.completeFlexibleUpdate();
    }
  }
}
```

### API

| Dart API | 说明 |
| --- | --- |
| `checkForUpdate()` | 获取更新可用性、版本号和安装状态 |
| `performImmediateUpdate()` | 启动立即更新流程，返回 `AppUpdateResult` |
| `startFlexibleUpdate()` | 启动灵活更新流程，返回 `AppUpdateResult` |
| `completeFlexibleUpdate()` | 完成灵活更新；OpenHarmony 上为系统自动处理的 no-op |
| `installUpdateListener` | 监听 `InstallStatus` 变化 |

当原生端返回未知或空的状态码时，插件会安全回退到 `UpdateAvailability.unknown` 或 `InstallStatus.unknown`，不会因枚举解析失败而抛出 `StateError`。

## 运行示例

```bash
cd example

# 查看可用设备
flutter devices

# Android
flutter run -d <android-device-id>

# OpenHarmony（使用支持 OHOS 的 Flutter SDK）
flutter run -d <ohos-device-id>
```

示例应用位于 [`example/lib/main.dart`](example/lib/main.dart)，包含检查更新、立即更新和灵活更新按钮。

## 项目结构

```text
in_app_update_ohos/
├─ lib/in_app_update.dart                 # Dart 公共 API、状态枚举和 MethodChannel
├─ android/src/main/kotlin/...            # Android Google Play 实现
├─ ohos/src/main/ets/components/plugin/   # OpenHarmony Upgrade Kit 实现
├─ ios/Classes/                           # iOS 占位插件（不支持应用内更新）
├─ example/                                # 可运行示例应用
├─ test/                                   # Dart 单元测试
├─ README.OpenHarmony_CN.md                # OpenHarmony 中文补充说明
└─ CHANGELOG*.md                           # 版本变更记录
```

Dart 层通过以下两个通道与原生层通信，Android 和 OpenHarmony 使用相同名称：

- MethodChannel：`de.ffuf.in_app_update/methods`
- EventChannel：`de.ffuf.in_app_update/stateEvents`

## 测试与静态检查

在仓库根目录执行：

```bash
flutter analyze
flutter test
```

OpenHarmony HAP 构建还需要本机正确安装并匹配版本的 OpenHarmony Flutter SDK、DevEco Studio 和相关 API。构建命令示例：

```bash
cd example
flutter build hap
```

## 常见问题

### Android 返回 `ERROR_API_NOT_AVAILABLE`

应用内更新只能对 Google Play 已发布并通过 Google Play 安装的应用进行测试。请参考 [Google 官方测试指南](https://developer.android.com/guide/playcore/in-app-updates/test)。

### 旧版 Android 不支持更新

Google Play In-App Updates 要求 Android API 21 或更高版本；插件的 Android library 最低编译兼容 API 为 16，但更新功能本身仍受 Google Play 要求限制。

### OpenHarmony 检查更新失败

确认应用已在 AppGallery Connect 配置 Upgrade Kit、设备已联网、签名和包名与发布版本一致，并检查 DevEco Studio 与 Flutter OpenHarmony SDK 的版本是否匹配。

## 参与贡献

1. Fork 本仓库并创建问题对应的分支，例如 `fix/issue-<编号>-<描述>`。
2. 修改代码并补充回归测试，确保 `flutter analyze` 和 `flutter test` 通过。
3. 提交清晰的 commit，并向 `oh-flutter/in_app_update:main` 创建 Pull Request。
4. 在 PR 描述中说明关联 Issue、修改内容和验证结果。

提交前请勿将 `.dart_tool/`、`build/`、`local.properties` 或其他本地生成文件加入版本控制。

## 许可证

本项目采用 [Apache License 2.0](LICENSE) 授权。
