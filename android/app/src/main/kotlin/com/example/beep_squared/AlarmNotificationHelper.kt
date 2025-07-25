package com.example.beep_squared

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat

/**
 * Helper for creating and managing alarm notifications
 * 
 * Provides unified notification creation and management for alarm system
 */
object AlarmNotificationHelper {
    
    private const val TAG = "AlarmNotificationHelper"
    
    /**
     * Show unified alarm notification (primary notification method)
     */
    fun showUnifiedAlarmNotification(context: Context, alarmId: String, label: String) {
        try {
            Log.d(TAG, "Creating unified alarm notification for: $alarmId")
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            
            // Create notification channel
            createUnifiedAlarmChannel(notificationManager)
            
            // Create full-screen intent
            val alarmIntent = Intent(context, AlarmActivity::class.java).apply {
                putExtra(AlarmConfig.EXTRA_ALARM_ID, alarmId)
                putExtra(AlarmConfig.EXTRA_LABEL, label)
                flags = AlarmConfig.ALARM_ACTIVITY_FLAGS
            }
            
            val pendingIntent = PendingIntent.getActivity(
                context,
                alarmId.hashCode(),
                alarmIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            
            // Build unified notification
            val notification = NotificationCompat.Builder(context, AlarmConfig.UNIFIED_ALARM_CHANNEL_ID)
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
                .setFullScreenIntent(pendingIntent, true)
                .build()
            
            notificationManager.notify(alarmId.hashCode(), notification)
            Log.d(TAG, "Unified alarm notification displayed successfully")
            
        } catch (e: Exception) {
            Log.e(TAG, "Error showing unified notification: ${e.message}")
        }
    }
    
    /**
     * Show fallback notification (simple notification for errors)
     */
    fun showFallbackNotification(context: Context, alarmId: String, label: String) {
        try {
            Log.d(TAG, "Creating fallback notification for: $alarmId")
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            
            // Create simple channel
            createSimpleAlarmChannel(notificationManager)
            
            // Build simple notification
            val notification = NotificationCompat.Builder(context, AlarmConfig.SIMPLE_ALARM_CHANNEL_ID)
                .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
                .setContentTitle("🔔 ALARM RINGING!")
                .setContentText("$label - Tap to open app")
                .setPriority(NotificationCompat.PRIORITY_MAX)
                .setCategory(NotificationCompat.CATEGORY_ALARM)
                .setAutoCancel(true)
                .setOngoing(true)
                .setVibrate(longArrayOf(0, 1000, 1000, 1000, 1000))
                .setDefaults(NotificationCompat.DEFAULT_ALL)
                .build()
            
            notificationManager.notify(alarmId.hashCode(), notification)
            Log.d(TAG, "Fallback notification displayed successfully")
            
        } catch (e: Exception) {
            Log.e(TAG, "Error showing fallback notification: ${e.message}")
        }
    }
    
    /**
     * Dismiss alarm notification
     */
    fun dismissAlarmNotification(context: Context, alarmId: String) {
        try {
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.cancel(alarmId.hashCode())
            Log.d(TAG, "Alarm notification dismissed for: $alarmId")
        } catch (e: Exception) {
            Log.e(TAG, "Error dismissing notification: ${e.message}")
        }
    }
    
    /**
     * Create unified alarm notification channel
     */
    private fun createUnifiedAlarmChannel(notificationManager: NotificationManager) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                AlarmConfig.UNIFIED_ALARM_CHANNEL_ID,
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
            Log.d(TAG, "Unified alarm channel created")
        }
    }
    
    /**
     * Create simple alarm notification channel
     */
    private fun createSimpleAlarmChannel(notificationManager: NotificationManager) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                AlarmConfig.SIMPLE_ALARM_CHANNEL_ID,
                "Simple Alarm Channel",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Channel for simple alarm notifications"
                setBypassDnd(true)
                lockscreenVisibility = NotificationCompat.VISIBILITY_PUBLIC
                enableVibration(true)
            }
            notificationManager.createNotificationChannel(channel)
            Log.d(TAG, "Simple alarm channel created")
        }
    }
}
