# HarmonyOS 7.0 兼容性说明

Issue #4：这个插件可以运行在鸿蒙 7.0 吗？

## 结论

插件的 OpenHarmony 原生模块面向 HarmonyOS/OpenHarmony 的 `phone`、`tablet` 和 `2in1` 设备，使用 AppGallery Connect Upgrade Kit（`@kit.StoreKit`）。因此从设备类型和 API 设计上，HarmonyOS 7.0 属于目标运行范围。

本仓库已在 HarmonyOS 7 真机上完成构建、签名 HAP 安装、启动和检查更新调用验证。该结果覆盖当前验证设备和工具链，不代表所有 7.0 设备及发布配置都无需额外适配。

## 使用前检查

1. 使用支持 OpenHarmony 的 Flutter SDK，并确认 `flutter --version` 与项目使用的 Flutter 版本兼容。
2. 在 DevEco Studio 中安装与工程匹配的 HarmonyOS SDK/API；当前验证使用 HarmonyOS SDK API 26（`26.0.0.105`）。
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

## 本地实测记录

本仓库已在以下设备上完成示例应用验证：

- 设备系统：HarmonyOS `7.0.0.105`（API 26）
- 设备架构：`ohos-arm64`
- Flutter：`3.44.9+ohos-0.0.1-canary1`
- 结果：`flutter devices` 和 `hdc list targets` 正确识别设备；Hvigor、ArkTS 编译和 HAP 打包通过，使用此前生成的签名 HAP 完成安装和启动。当前机器重新签名时因工程引用的证书文件缺失而在 `SignHap` 阶段失败，该问题属于本地签名配置，不影响插件兼容性验证。
- 插件调用：点击“检查更新”后，`InAppUpdateOhosPlugin` 日志记录 `Checking for update...` 和 `Update available: false`，Dart 与 `@kit.StoreKit` 调用链正常返回。本次设备对应的 AppGallery Connect 配置没有可升级版本，因此未测试实际下载和安装新版本。

此前使用旧 SDK 时出现的 `autoFillManager` API 编译错误，来自 Flutter embedding 与 SDK 版本不匹配；切换到 API 26 后该错误消失，不是 `in_app_update` 的 Upgrade Kit 代码或 Dart API 引起。

## 已知限制

- 本插件只负责调用系统更新能力，不提供应用商店或版本发布服务。
- `completeFlexibleUpdate()` 在 OpenHarmony 上由系统自动完成，Dart 方法是兼容 API 的 no-op。
- HarmonyOS 7.0 的具体 API 行为可能因设备型号、系统补丁和 AppGallery Connect 配置而异；生产发布前请至少在一台目标设备上完成端到端升级测试。
