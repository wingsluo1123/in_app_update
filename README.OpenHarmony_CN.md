# in_app_update 鸿蒙适配

基于 AppGallery Connect Upgrade Kit 实现应用内更新功能。

> HarmonyOS 7.0 兼容性：插件的目标设备类型包含 `phone`、`tablet` 和 `2in1`，从 API 设计上可运行在 HarmonyOS 7.0；但仓库目前没有覆盖所有 7.0 设备的自动化验证记录。实际运行需要匹配版本的 Flutter OpenHarmony SDK、DevEco Studio、HarmonyOS SDK、签名及 AppGallery Connect Upgrade Kit 配置。详细检查项请参阅 [`docs/harmonyos-7-compatibility.md`](docs/harmonyos-7-compatibility.md)。

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
