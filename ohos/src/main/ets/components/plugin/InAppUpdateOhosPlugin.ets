import {
  FlutterPlugin,
  FlutterPluginBinding,
  AbilityAware,
  AbilityPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
  EventChannel,
  StreamHandler,
  EventSink,
} from '@ohos/flutter_ohos';
import { updateManager } from '@kit.StoreKit';
import type { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import bundleManager from '@ohos.bundle.bundleManager';
import hilog from '@ohos.hilog';

const TAG = 'InAppUpdateOhos';
const METHOD_CHANNEL = 'de.ffuf.in_app_update/methods';
const EVENT_CHANNEL = 'de.ffuf.in_app_update/stateEvents';

export default class InAppUpdateOhosPlugin
  implements FlutterPlugin, AbilityAware, MethodCallHandler, StreamHandler {

  private methodChannel: MethodChannel | null = null;
  private eventChannel: EventChannel | null = null;
  private eventSink: EventSink | null = null;
  private uiAbilityContext: common.UIAbilityContext | null = null;
  private hasUpdate: boolean = false;

  getUniqueClassName(): string {
    return 'InAppUpdateOhosPlugin';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.methodChannel = new MethodChannel(binding.getBinaryMessenger(), METHOD_CHANNEL);
    this.methodChannel.setMethodCallHandler(this);
    this.eventChannel = new EventChannel(binding.getBinaryMessenger(), EVENT_CHANNEL);
    this.eventChannel.setStreamHandler(this);
    hilog.info(0x0001, TAG, 'Attached to engine');
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.methodChannel != null) { this.methodChannel.setMethodCallHandler(null); this.methodChannel = null; }
    if (this.eventChannel != null) { this.eventChannel.setStreamHandler(null); this.eventChannel = null; }
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    this.uiAbilityContext = binding.getAbility().context;
    hilog.info(0x0001, TAG, 'Attached to ability, context obtained');
  }

  onDetachedFromAbility(): void {
    this.uiAbilityContext = null;
  }

  onListen(args: Object | null, events: EventSink): void { this.eventSink = events; }
  onCancel(args: Object | null): void { this.eventSink = null; }

  private emitInstallStatus(status: number): void {
    if (this.eventSink != null) { this.eventSink.success(status); }
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    switch (call.method) {
      case 'checkForUpdate': this.handleCheckForUpdate(result); break;
      case 'performImmediateUpdate': this.handleShowUpdateDialog(result); break;
      case 'startFlexibleUpdate': this.handleShowUpdateDialog(result); break;
      case 'completeFlexibleUpdate': result.success(null); break;
      default: result.notImplemented(); break;
    }
  }

  private handleCheckForUpdate(result: MethodResult): void {
    if (this.uiAbilityContext == null) {
      result.error('TASK_FAILURE', 'UIAbilityContext is null', null);
      return;
    }
    try {
      this.emitInstallStatus(1);
      hilog.info(0x0001, TAG, 'Checking for update...');

      updateManager.checkAppUpdate(this.uiAbilityContext).then((checkResult: updateManager.CheckUpdateResult) => {
        this.hasUpdate = checkResult.updateAvailable == updateManager.UpdateAvailableCode.LATER_VERSION_EXIST;
        hilog.info(0x0001, TAG, 'Update available: %{public}s', String(this.hasUpdate));

        let updateAvailability = this.hasUpdate ? 2 : 1;
        let packageName = '';
        let versionCode = 0;
        try {
          const bi = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT);
          packageName = bi.name;
          versionCode = bi.versionCode;
        } catch (e) {}

        result.success({
          'updateAvailability': updateAvailability,
          'immediateAllowed': this.hasUpdate,
          'immediateAllowedPreconditions': null,
          'flexibleAllowed': this.hasUpdate,
          'flexibleAllowedPreconditions': null,
          'availableVersionCode': versionCode,
          'installStatus': 0,
          'packageName': packageName,
          'clientVersionStalenessDays': null,
          'updatePriority': 0,
        });
        this.emitInstallStatus(0);
      }).catch((error: BusinessError) => {
        hilog.error(0x0001, TAG, 'checkAppUpdate error: %{public}s', error.message);
        result.error('TASK_FAILURE', error.message, null);
        this.emitInstallStatus(5);
      });
    } catch (error) {
      result.error('TASK_FAILURE', String(error), null);
    }
  }

  private handleShowUpdateDialog(result: MethodResult): void {
    if (this.uiAbilityContext == null) {
      result.error('TASK_FAILURE', 'UIAbilityContext is null', null);
      return;
    }
    if (!this.hasUpdate) {
      result.error('IN_APP_UPDATE_FAILED', 'No update available. Call checkForUpdate first.', null);
      return;
    }
    try {
      this.emitInstallStatus(2);
      hilog.info(0x0001, TAG, 'Showing update dialog...');

      updateManager.showUpdateDialog(this.uiAbilityContext).then((resultCode: updateManager.ShowUpdateResultCode) => {
        if (resultCode == updateManager.ShowUpdateResultCode.SHOW_DIALOG_SUCCESS) {
          this.emitInstallStatus(4);
          result.success(null);
        } else {
          result.error('USER_DENIED_UPDATE', 'Show dialog failed', null);
          this.emitInstallStatus(6);
        }
      }).catch((error: BusinessError) => {
        hilog.error(0x0001, TAG, 'showUpdateDialog error: %{public}s', error.message);
        result.error('USER_DENIED_UPDATE', error.message, null);
        this.emitInstallStatus(6);
      });
    } catch (error) {
      result.error('IN_APP_UPDATE_FAILED', String(error), null);
    }
  }
}
