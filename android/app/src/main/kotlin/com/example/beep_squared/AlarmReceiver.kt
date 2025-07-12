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

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val alarmId = intent.getStringExtra("alarmId")
        val label = intent.getStringExtra("label") ?: "Alarm"
        val soundPath = intent.getStringExtra("soundPath") ?: "default"
        
        Log.d("AlarmReceiver", "=== ALARM RECEIVED ===")
        Log.d("AlarmReceiver", "Alarm ID: $alarmId")
        Log.d("AlarmReceiver", "Label: $label")
        Log.d("AlarmReceiver", "Sound Path: $soundPath")
        Log.d("AlarmReceiver", "Context: $context")
        Log.d("AlarmReceiver", "Process ID: ${android.os.Process.myPid()}")
        
        if (alarmId != null) {
            // Use ONLY the modern unified alarm overlay with configured sound
            Log.d("AlarmReceiver", "=== USING MODERN UNIFIED ALARM OVERLAY ===")
            AlarmOverlayService.showAlarmOverlay(context, alarmId, label, soundPath)
            
            Log.d("AlarmReceiver", "=== MODERN ALARM OVERLAY TRIGGERED ===")
        } else {
            Log.e("AlarmReceiver", "No alarm ID provided!")
        }
    }
    
    private fun launchAlarmActivity(context: Context, alarmId: String, label: String) {
        try {
            Log.d("AlarmReceiver", "=== ATTEMPTING TO LAUNCH ALARM ACTIVITY ===")
            Log.d("AlarmReceiver", "Context: $context")
            Log.d("AlarmReceiver", "AlarmID: $alarmId")
            Log.d("AlarmReceiver", "Label: $label")
            
            val alarmIntent = Intent(context, AlarmActivity::class.java).apply {
                putExtra("alarmId", alarmId)
                putExtra("label", label)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or 
                       Intent.FLAG_ACTIVITY_CLEAR_TOP or
                       Intent.FLAG_ACTIVITY_SINGLE_TOP or
                       Intent.FLAG_ACTIVITY_NO_HISTORY or
                       Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS
            }
            
            Log.d("AlarmReceiver", "Intent created: $alarmIntent")
            Log.d("AlarmReceiver", "Intent extras: ${alarmIntent.extras}")
            Log.d("AlarmReceiver", "Intent flags: ${alarmIntent.flags}")
            
            context.startActivity(alarmIntent)
            
            Log.d("AlarmReceiver", "=== ACTIVITY START COMMAND EXECUTED ===")
            Log.d("AlarmReceiver", "AlarmActivity should be launching now...")
            
            // Give it a moment and log again
            android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                Log.d("AlarmReceiver", "500ms after startActivity() call - checking if AlarmActivity launched")
            }, 500)
            
        } catch (e: Exception) {
            Log.e("AlarmReceiver", "=== CRITICAL ERROR LAUNCHING ACTIVITY ===")
            Log.e("AlarmReceiver", "Exception: ${e.javaClass.simpleName}")
            Log.e("AlarmReceiver", "Message: ${e.message}")
            Log.e("AlarmReceiver", "Stack trace:", e)
        }
    }
    
    private fun showFullScreenNotification(context: Context, alarmId: String, label: String) {
        try {
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            
            // Create notification channel for Android O+
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val channel = NotificationChannel(
                    "alarm_channel",
                    "Alarm Channel",
                    NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description = "Channel for alarm notifications"
                    setBypassDnd(true)
                    lockscreenVisibility = NotificationCompat.VISIBILITY_PUBLIC
                }
                notificationManager.createNotificationChannel(channel)
            }
            
            // Create intent for full-screen notification
            val fullScreenIntent = Intent(context, AlarmActivity::class.java).apply {
                putExtra("alarmId", alarmId)
                putExtra("label", label)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            
            val fullScreenPendingIntent = PendingIntent.getActivity(
                context, 
                alarmId.hashCode(), 
                fullScreenIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            
            // Build notification
            val notification = NotificationCompat.Builder(context, "alarm_channel")
                .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
                .setContentTitle("Alarm")
                .setContentText(label)
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setCategory(NotificationCompat.CATEGORY_ALARM)
                .setFullScreenIntent(fullScreenPendingIntent, true)
                .setAutoCancel(true)
                .setOngoing(true)
                .build()
            
            notificationManager.notify(alarmId.hashCode(), notification)
            Log.d("AlarmReceiver", "Full-screen notification shown for: $alarmId")
            
        } catch (e: Exception) {
            Log.e("AlarmReceiver", "Failed to show notification: ${e.message}")
        }
    }
    
    private fun showSimpleAlarmNotification(context: Context, alarmId: String, label: String) {
        try {
            Log.d("AlarmReceiver", "=== CREATING SIMPLE ALARM NOTIFICATION ===")
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
                }
                notificationManager.createNotificationChannel(channel)
                Log.d("AlarmReceiver", "Simple alarm channel created")
            }
            
            // Build prominent notification
            val notification = NotificationCompat.Builder(context, "simple_alarm_channel")
                .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
                .setContentTitle("🔔 ALARM RINGING!")
                .setContentText("$label - Tap to dismiss")
                .setPriority(NotificationCompat.PRIORITY_MAX)
                .setCategory(NotificationCompat.CATEGORY_ALARM)
                .setAutoCancel(true)
                .setOngoing(true)
                .setVibrate(longArrayOf(0, 1000, 1000, 1000, 1000))
                .setDefaults(NotificationCompat.DEFAULT_ALL)
                .build()
            
            notificationManager.notify(alarmId.hashCode(), notification)
            Log.d("AlarmReceiver", "Simple alarm notification displayed successfully")
            
        } catch (e: Exception) {
            Log.e("AlarmReceiver", "Error showing simple notification: ${e.message}")
        }
    }
}
