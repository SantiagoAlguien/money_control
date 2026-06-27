package com.example.money_control

import android.content.ComponentName
import android.content.Intent
import android.provider.Settings
import android.service.notification.NotificationListenerService
import android.text.TextUtils
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val methodChannel = "com.example.money_control/notification_permission"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.example.money_control/notifications"
        ).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                com.example.money_control.NotificationListenerService.eventSink = events
            }

            override fun onCancel(arguments: Any?) {
                com.example.money_control.NotificationListenerService.eventSink = null
            }
        })

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            methodChannel
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "isNotificationListenerEnabled" -> {
                    result.success(isNotificationListenerEnabled())
                }
                "openNotificationListenerSettings" -> {
                    openNotificationListenerSettings()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun isNotificationListenerEnabled(): Boolean {
        val enabledListeners = Settings.Secure.getString(
            contentResolver,
            "enabled_notification_listeners"
        ) ?: return false

        val componentName = ComponentName(this, com.example.money_control.NotificationListenerService::class.java)
        return enabledListeners.contains(componentName.flattenToString()) ||
                enabledListeners.contains(componentName.flattenToShortString())
    }

    private fun openNotificationListenerSettings() {
        val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
        startActivity(intent)
    }
}
