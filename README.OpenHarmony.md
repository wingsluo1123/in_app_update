# in_app_update OpenHarmony Adaptation

In-app update functionality based on AppGallery Connect Upgrade Kit. The plugin keeps the existing Dart API and bridges it to the OpenHarmony native implementation through Flutter platform channels.

## Requirements

- An OpenHarmony-compatible Flutter SDK.
- DevEco Studio with the HarmonyOS/OpenHarmony SDK matching the project.
- A supported `phone`, `tablet`, or `2in1` device or emulator.
- AppGallery Connect Upgrade Kit configured for the application.

## Usage

Same as the original plugin - no Dart code changes required.

```dart
import 'package:in_app_update/in_app_update.dart';

final info = await InAppUpdate.checkForUpdate();
if (info.updateAvailability == UpdateAvailability.updateAvailable) {
  await InAppUpdate.performImmediateUpdate();
}
```
