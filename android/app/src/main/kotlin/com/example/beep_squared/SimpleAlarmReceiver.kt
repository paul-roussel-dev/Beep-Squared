package com.example.beep_squared

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat

class SimpleAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val alarmId = intent.getStringExtra("alarmId")
        val label = intent.getStringExtra("label") ?: "Alarm"
        
        Log.d("SimpleAlarmReceiver", "=== SIMPLE ALARM RECEIVED ===")
        Log.d("SimpleAlarmReceiver", "Alarm ID: $alarmId")
        
        if (alarmId != null) {
            showSimpleAlarmNotification(context, alarmId, label)
        }
    }
    
    private fun showSimpleAlarmNotification(context: Context, alarmId: String, label: String) {
        try {
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            
            // Create notification channel
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val channel = NotificationChannel(
                    "simple_alarm_channel",
                    "Simple Alarm Channel",
                    NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description = "Channel for simple alarm notifications"
                    setBypassDnd(true)
                    lockscreenVisibility = NotificationCompat.VISIBILITY_PUBLIC
                    enableVibration(true)
                    setSound(android.provider.Settings.System.DEFAULT_ALARM_ALERT_URI, audioAttributes)
                }
                notificationManager.createNotificationChannel(channel)
            }
            
            // Create dismiss intent
            val dismissIntent = Intent(context, AlarmDismissReceiver::class.java).apply {
                putExtra("alarmId", alarmId)
            }
            val dismissPendingIntent = PendingIntent.getBroadcast(
                context,
                alarmId.hashCode(),
                dismissIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            
            // Build simple but effective notification
            val notification = NotificationCompat.Builder(context, "simple_alarm_channel")
                .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
                .setContentTitle("🔔 ALARM - $label")
                .setContentText("Tap to dismiss alarm")
                .setPriority(NotificationCompat.PRIORITY_MAX)
                .setCategory(NotificationCompat.CATEGORY_ALARM)
                .setAutoCancel(true)
                .setOngoing(true)
                .setFullScreenIntent(dismissPendingIntent, true)
                .addAction(android.R.drawable.ic_menu_close_clear_cancel, "DISMISS", dismissPendingIntent)
                .setVibrate(longArrayOf(0, 1000, 1000, 1000, 1000))
                .setSound(android.provider.Settings.System.DEFAULT_ALARM_ALERT_URI)
                .build()
            
            notificationManager.notify(alarmId.hashCode(), notification)
            Log.d("SimpleAlarmReceiver", "Simple alarm notification shown successfully")
            
        } catch (e: Exception) {
            Log.e("SimpleAlarmReceiver", "Error showing simple notification: ${e.message}")
        }
    }
}

class AlarmDismissReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val alarmId = intent.getStringExtra("alarmId")
        Log.d("AlarmDismissReceiver", "Dismissing alarm: $alarmId")
        
        if (alarmId != null) {
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.cancel(alarmId.hashCode())
        }
    }
}
