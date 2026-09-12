import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_update_ohos/in_app_update.dart';

const _channel = MethodChannel('de.ffuf.in_app_update/methods');

Map<String, Object?> _updateResult({
  Object? updateAvailability = 1,
  Object? installStatus = 0,
}) {
  return <String, Object?>{
    'updateAvailability': updateAvailability,
    'immediateAllowed': false,
    'immediateAllowedPreconditions': null,
    'flexibleAllowed': false,
    'flexibleAllowedPreconditions': null,
    'availableVersionCode': null,
    'installStatus': installStatus,
    'packageName': 'com.example.app',
    'clientVersionStalenessDays': null,
    'updatePriority': 0,
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  });

  test('parses known update and install statuses', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
          expect(call.method, 'checkForUpdate');
          return _updateResult(updateAvailability: 2, installStatus: 4);
        });

    final info = await InAppUpdate.checkForUpdate();

    expect(info.updateAvailability, UpdateAvailability.updateAvailable);
    expect(info.installStatus, InstallStatus.installed);
  });

  test('uses unknown for an unrecognized update availability', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (_) async {
          return _updateResult(updateAvailability: 99);
        });

    final info = await InAppUpdate.checkForUpdate();

    expect(info.updateAvailability, UpdateAvailability.unknown);
  });

  test('uses unknown for a null update availability', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (_) async {
          return _updateResult(updateAvailability: null);
        });

    final info = await InAppUpdate.checkForUpdate();

    expect(info.updateAvailability, UpdateAvailability.unknown);
  });

  test('uses unknown for an unrecognized install status', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (_) async {
          return _updateResult(installStatus: 99);
        });

    final info = await InAppUpdate.checkForUpdate();

    expect(info.installStatus, InstallStatus.unknown);
  });

  test('uses unknown for a null install status', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (_) async {
          return _updateResult(installStatus: null);
        });

    final info = await InAppUpdate.checkForUpdate();

    expect(info.installStatus, InstallStatus.unknown);
  });
}
