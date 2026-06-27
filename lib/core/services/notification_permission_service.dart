import 'dart:io';

import 'package:flutter/services.dart';

class NotificationPermissionService {
  static const MethodChannel _channel = MethodChannel(
    'com.example.money_control/notification_permission',
  );

  static Future<bool> isGranted() async {
    if (!Platform.isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('isNotificationListenerEnabled') ??
          false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> openSettings() async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod('openNotificationListenerSettings');
  }
}
