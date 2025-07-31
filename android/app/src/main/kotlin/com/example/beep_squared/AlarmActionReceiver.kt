package com.example.beep_squared

import android.app.AlarmManager
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * BroadcastReceiver for handling alarm notification actions
 * 
 * Handles actions from notifications like canceling snooze alarms
 */
class AlarmActionReceiver : BroadcastReceiver() {
    
    companion object {
        private const val TAG = "AlarmActionReceiver"
    }
    
    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action
        val alarmId = intent.getStringExtra(AlarmConfig.EXTRA_ALARM_ID)
        
        Log.d(TAG, "Received action: $action for alarm: $alarmId")
        
        when (action) {
            AlarmConfig.ACTION_CANCEL_SNOOZE -> {
                handleCancelSnooze(context, alarmId)
            }
            else -> {
                Log.w(TAG, "Unknown action received: $action")
            }
        }
    }
    
    /**
     * Handle canceling a snoozed alarm
     */
    private fun handleCancelSnooze(context: Context, alarmId: String?) {
        if (alarmId == null) {
            Log.e(TAG, "Cannot cancel snooze: alarmId is null")
            return
        }
        
        try {
            Log.d(TAG, "Canceling snoozed alarm: $alarmId")
            
            // Cancel the scheduled snooze alarm from AlarmManager
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val snoozeIntent = Intent(context, AlarmOverlayService::class.java).apply {
                putExtra("alarmId", alarmId)
                putExtra("label", "Snoozed Alarm")
                putExtra("unlockMethod", "simple")
            }
            
            val pendingIntent = PendingIntent.getService(
                context, 
                alarmId.hashCode(), 
                snoozeIntent, 
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            
            // Cancel the alarm
            alarmManager.cancel(pendingIntent)
            Log.d(TAG, "Canceled scheduled snooze alarm for: $alarmId")
            
            // Cancel the snooze notification
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.cancel(AlarmOverlayService.SNOOZE_NOTIFICATION_ID)
            Log.d(TAG, "Canceled snooze notification for: $alarmId")
            
            // Show confirmation notification
            showCancellationConfirmation(context, alarmId)
            
        } catch (e: Exception) {
            Log.e(TAG, "Error canceling snoozed alarm: $alarmId", e)
        }
    }
    
    /**
     * Show a brief confirmation that the snooze was canceled
     */
    private fun showCancellationConfirmation(context: Context, alarmId: String) {
        try {
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            
            // Create a simple confirmation notification
            val notification = androidx.core.app.NotificationCompat.Builder(context, AlarmOverlayService.SNOOZE_NOTIFICATION_CHANNEL_ID)
                .setSmallIcon(android.R.drawable.ic_menu_close_clear_cancel)
                .setContentTitle("Alarm Canceled")
                .setContentText("Temporary alarm has been removed")
                .setPriority(androidx.core.app.NotificationCompat.PRIORITY_LOW)
                .setAutoCancel(true)
                .setTimeoutAfter(3000) // Auto dismiss after 3 seconds
                .build()
            
            // Use a different notification ID for the confirmation
            notificationManager.notify(alarmId.hashCode() + 2000, notification)
            Log.d(TAG, "Shown cancellation confirmation for: $alarmId")
            
        } catch (e: Exception) {
            Log.e(TAG, "Error showing cancellation confirmation", e)
        }
    }
}
