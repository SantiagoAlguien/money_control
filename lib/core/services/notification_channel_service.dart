import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:money_control/core/constants/app_constants.dart';

class NotificationChannelService {
  final EventChannel _eventChannel =
      const EventChannel(AppConstants.eventChannelNotifications);

  Stream<Map<String, dynamic>>? _notificationStream;

  Stream<Map<String, dynamic>> get notificationStream {
    _notificationStream ??= _eventChannel
        .receiveBroadcastStream()
        .where((event) => event is String)
        .map((event) {
      try {
        return jsonDecode(event as String) as Map<String, dynamic>;
      } catch (_) {
        return <String, dynamic>{};
      }
    }).where((data) => data.isNotEmpty);

    return _notificationStream!;
  }

  bool get isSupported => Platform.isAndroid;
}
