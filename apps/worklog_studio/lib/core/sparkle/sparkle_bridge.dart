import 'package:flutter/services.dart';

class SparkleBridge {
  static const _channel = MethodChannel('worklog_studio/updater');

  static Future<void> checkForUpdates() async {
    await _channel.invokeMethod('checkForUpdates');
  }

  static Future<void> checkSilently() async {
    await _channel.invokeMethod('checkSilently');
  }

  static Future<String> getVersion() async {
    return await _channel.invokeMethod('getVersion');
  }
}
