package com.example.money_control

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import io.flutter.plugin.common.EventChannel
import org.json.JSONObject

class NotificationListenerService : NotificationListenerService() {

    companion object {
        var eventSink: EventChannel.EventSink? = null
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        sbn ?: return

        val packageName = sbn.packageName ?: return
        val title = sbn.notification.extras.getString("android.title") ?: ""
        val text = sbn.notification.extras.getCharSequence("android.text")?.toString() ?: ""
        val timestamp = sbn.postTime

        val payload = JSONObject().apply {
            put("packageName", packageName)
            put("title", title)
            put("text", text)
            put("timestamp", timestamp)
        }.toString()

        eventSink?.success(payload)
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification?) {}
}
