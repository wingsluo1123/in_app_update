# HarmonyOS 7.0 兼容性说明

Issue #4：这个插件可以运行在鸿蒙 7.0 吗？

## 结论

插件的 OpenHarmony 原生模块面向 HarmonyOS/OpenHarmony 的 `phone`、`tablet` 和 `2in1` 设备，使用 AppGallery Connect Upgrade Kit（`@kit.StoreKit`）。因此从设备类型和 API 设计上，HarmonyOS 7.0 属于目标运行范围。

不过，仓库目前没有 HarmonyOS 7.0 真机或模拟器的自动化验证记录，不能承诺在所有 7.0 设备和构建环境中开箱即用。能否成功运行取决于 Flutter OpenHarmony SDK、DevEco Studio、API 版本、签名和 AppGallery Connect 配置是否匹配。

## 使用前检查

1. 使用支持 OpenHarmony 的 Flutter SDK，并确认 `flutter --version` 与项目使用的 Flutter 版本兼容。
2. 在 DevEco Studio 中安装与工程匹配的 HarmonyOS SDK/API；工程示例当前配置为 `compatibleSdkVersion: 5.1.0(18)`，如本机 SDK 不同，请按实际 SDK 调整工程配置。
3. 使用 `phone`、`tablet` 或 `2in1` 设备，并开启 USB 调试和开发者模式。
4. 在 AppGallery Connect 中完成 Upgrade Kit 配置，确保应用包名、签名证书和发布版本一致。应用内更新需要服务端存在可升级版本，无法仅靠本地安装包验证。
5. 确认设备可以访问 AppGallery Connect 服务，并在首次运行时授予必要权限。

## 验证步骤

在示例工程中执行：

```bash
cd example
flutter pub get
flutter devices
flutter run -d <ohos-device-id>
```

启动后点击“检查更新”。当 AppGallery Connect 检测到新版本时，再测试“立即更新”或“灵活更新”流程。若检查失败，请优先查看 DevEco Studio/Hilog 日志中的 Upgrade Kit 错误码。

## 已知限制

- 本插件只负责调用系统更新能力，不提供应用商店或版本发布服务。
- `completeFlexibleUpdate()` 在 OpenHarmony 上由系统自动完成，Dart 方法是兼容 API 的 no-op。
- HarmonyOS 7.0 的具体 API 行为可能因设备型号、系统补丁和 AppGallery Connect 配置而异；生产发布前请至少在一台目标设备上完成端到端升级测试。
