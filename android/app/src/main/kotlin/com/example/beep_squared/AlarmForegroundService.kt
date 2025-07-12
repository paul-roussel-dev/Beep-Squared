package com.example.beep_squared

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat

class AlarmForegroundService : Service() {
    companion object {
        const val CHANNEL_ID = "alarm_foreground_channel"
        const val NOTIFICATION_ID = 1001
        
        fun startAlarmService(context: Context, alarmId: String, label: String) {
            val intent = Intent(context, AlarmForegroundService::class.java).apply {
                putExtra("alarmId", alarmId)
                putExtra("label", label)
            }
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }
    }
    
    override fun onCreate() {
        super.onCreate()
        Log.d("AlarmForegroundService", "=== ALARM FOREGROUND SERVICE CREATED ===")
        createNotificationChannel()
    }
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d("AlarmForegroundService", "=== ALARM FOREGROUND SERVICE STARTED ===")
        
        val alarmId = intent?.getStringExtra("alarmId") ?: "unknown"
        val label = intent?.getStringExtra("label") ?: "Alarm"
        
        Log.d("AlarmForegroundService", "Processing alarm: $alarmId with label: $label")
        
        // Start as foreground service
        val notification = createForegroundNotification(alarmId, label)
        startForeground(NOTIFICATION_ID, notification)
        
        // Now try to launch the alarm activity from the foreground service
        launchAlarmActivityFromService(alarmId, label)
        
        return START_NOT_STICKY
    }
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Alarm Foreground Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Channel for alarm foreground service"
            }
            
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }
    
    private fun createForegroundNotification(alarmId: String, label: String): Notification {
        val alarmIntent = Intent(this, AlarmActivity::class.java).apply {
            putExtra("alarmId", alarmId)
            putExtra("label", label)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        
        val pendingIntent = PendingIntent.getActivity(
            this,
            alarmId.hashCode(),
            alarmIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Alarm Active")
            .setContentText(label)
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentIntent(pendingIntent)
            .setFullScreenIntent(pendingIntent, true)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setOngoing(true)
            .build()
    }
    
    private fun launchAlarmActivityFromService(alarmId: String, label: String) {
        try {
            Log.d("AlarmForegroundService", "=== LAUNCHING ALARM ACTIVITY FROM FOREGROUND SERVICE ===")
            
            val alarmIntent = Intent(this, AlarmActivity::class.java).apply {
                putExtra("alarmId", alarmId)
                putExtra("label", label)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or 
                       Intent.FLAG_ACTIVITY_CLEAR_TOP or
                       Intent.FLAG_ACTIVITY_SINGLE_TOP or
                       Intent.FLAG_ACTIVITY_BROUGHT_TO_FRONT
            }
            
            Log.d("AlarmForegroundService", "Starting activity from foreground service...")
            startActivity(alarmIntent)
            Log.d("AlarmForegroundService", "Activity start command executed from service")
            
            // Stop the service after a delay
            android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                Log.d("AlarmForegroundService", "Stopping foreground service")
                stopSelf()
            }, 2000)
            
        } catch (e: Exception) {
            Log.e("AlarmForegroundService", "Error launching activity from service: ${e.message}", e)
        }
    }
    
    override fun onDestroy() {
        super.onDestroy()
        Log.d("AlarmForegroundService", "=== ALARM FOREGROUND SERVICE DESTROYED ===")
    }
    
    override fun onBind(intent: Intent?): IBinder? = null
}
