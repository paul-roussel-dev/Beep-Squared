package com.example.beep_squared

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat

object AlarmNotificationHelper {
    
    fun showSimpleAlarmNotification(context: Context, alarmId: String, label: String) {
        try {
            Log.d("AlarmNotificationHelper", "=== CREATING UNIFIED ALARM NOTIFICATION ===")
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            
            // Create notification channel
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val channel = NotificationChannel(
                    "unified_alarm_channel",
                    "Unified Alarm Channel",
                    NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description = "Channel for unified alarm notifications"
                    setBypassDnd(true)
                    lockscreenVisibility = NotificationCompat.VISIBILITY_PUBLIC
                    enableVibration(true)
                    vibrationPattern = longArrayOf(0, 1000, 500, 1000, 500, 1000)
                    setSound(android.provider.Settings.System.DEFAULT_ALARM_ALERT_URI, audioAttributes)
                    enableLights(true)
                    lightColor = android.graphics.Color.RED
                }
                notificationManager.createNotificationChannel(channel)
                Log.d("AlarmNotificationHelper", "Unified alarm channel created with sound")
            }
            
            // Build unified notification (same for in-app and background)
            val notification = NotificationCompat.Builder(context, "unified_alarm_channel")
                .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
                .setContentTitle("🔔 BEEP SQUARED ALARM")
                .setContentText("$label - Slide to dismiss")
                .setPriority(NotificationCompat.PRIORITY_MAX)
                .setCategory(NotificationCompat.CATEGORY_ALARM)
                .setAutoCancel(false)
                .setOngoing(true)
                .setVibrate(longArrayOf(0, 1000, 500, 1000, 500, 1000))
                .setSound(android.provider.Settings.System.DEFAULT_ALARM_ALERT_URI)
                .setDefaults(NotificationCompat.DEFAULT_LIGHTS)
                .setStyle(NotificationCompat.BigTextStyle()
                    .bigText("$label\n\n🚨 Alarm is ringing! 🚨\nSlide to dismiss the alarm."))
                .setFullScreenIntent(null, true)
                .build()
            
            notificationManager.notify(alarmId.hashCode(), notification)
            Log.d("AlarmNotificationHelper", "Unified alarm notification displayed successfully")
            
        } catch (e: Exception) {
            Log.e("AlarmNotificationHelper", "Error showing unified notification: ${e.message}")
        }
    }
    
    fun dismissAlarmNotification(context: Context, alarmId: String) {
        try {
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.cancel(alarmId.hashCode())
            Log.d("AlarmNotificationHelper", "Alarm notification dismissed for: $alarmId")
        } catch (e: Exception) {
            Log.e("AlarmNotificationHelper", "Error dismissing notification: ${e.message}")
        }
    }
}
