# in_app_update 鸿蒙适配

基于 AppGallery Connect Upgrade Kit 实现应用内更新功能。

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
