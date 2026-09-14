# in_app_update 鸿蒙适配

基于 AppGallery Connect Upgrade Kit 实现应用内更新功能。插件保留原有 Dart API，通过 Flutter 平台通道调用 OpenHarmony 原生实现。

## 环境要求

- 支持 OpenHarmony 的 Flutter SDK。
- 与工程匹配的 DevEco Studio 和 HarmonyOS/OpenHarmony SDK。
- `phone`、`tablet` 或 `2in1` 设备或模拟器。
- 已在 AppGallery Connect 中完成 Upgrade Kit 配置。

## 适配说明

| 项目 | 说明 |
|---|---|
| 原生 API | @ohos.appgalleryconnect.upgrade |
| 支持设备 | phone / tablet / 2in1 |
| MethodChannel | de.ffuf.in_app_update/methods |
| EventChannel | de.ffuf.in_app_update/stateEvents |

## API 映射

| Dart 方法 | 鸿蒙 API |
|---|---|
| checkForUpdate() | upgrade.getAppUpdateInfo() |
| performImmediateUpdate() | upgrade.showUpdateDialog(UpdateMode.FORCE) |
| startFlexibleUpdate() | upgrade.showUpdateDialog(UpdateMode.NORMAL) |
| completeFlexibleUpdate() | no-op (系统自动处理) |

## 使用方法

与原插件完全一致，无需修改 Dart 代码：

```dart
import 'package:in_app_update/in_app_update.dart';

final info = await InAppUpdate.checkForUpdate();
if (info.updateAvailability == UpdateAvailability.updateAvailable) {
  await InAppUpdate.performImmediateUpdate();
}
```
