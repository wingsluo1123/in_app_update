import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_update_ohos/in_app_update.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'In App Update Example',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _statusText = '尚未检查更新';
  bool _hasUpdate = false;
  bool _flexibleUpdateAvailable = false;

  Future<void> checkForUpdate() async {
    try {
      final info = await InAppUpdate.checkForUpdate();
      setState(() {
        _hasUpdate = info.updateAvailability == UpdateAvailability.updateAvailable;
        _statusText = _hasUpdate
            ? '发现新版本 (versionCode: ${info.availableVersionCode})'
            : '当前已是最新版本';
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_statusText)),
      );
    } catch (e) {
      setState(() { _statusText = '检查失败: $e'; });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('检查失败: $e')),
      );
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('应用内更新示例')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: Text(_statusText, style: TextStyle(fontSize: 16))),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(onPressed: checkForUpdate, child: Text('检查更新')),
            ElevatedButton(
              onPressed: !_hasUpdate ? null : () {
                InAppUpdate.performImmediateUpdate().catchError((e) {
                  _showError(e.toString());
                  return AppUpdateResult.inAppUpdateFailed;
                });
              },
              child: Text('立即更新（强制）'),
            ),
            ElevatedButton(
              onPressed: !_hasUpdate ? null : () {
                InAppUpdate.startFlexibleUpdate().then((_) {
                  setState(() { _flexibleUpdateAvailable = true; });
                }).catchError((e) { _showError(e.toString()); });
              },
              child: Text('灵活更新'),
            ),
            ElevatedButton(
              onPressed: !_flexibleUpdateAvailable ? null : () {
                InAppUpdate.completeFlexibleUpdate().then((_) {
                  _showError('完成灵活更新');
                }).catchError((e) { _showError(e.toString()); });
              },
              child: Text('完成灵活更新'),
            ),
          ],
        ),
      ),
    );
  }
}
