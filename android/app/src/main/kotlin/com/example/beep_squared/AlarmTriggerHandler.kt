package com.example.beep_squared

import android.content.Context
import android.util.Log

/**
 * Central handler for alarm triggers
 * 
 * This class manages the logic for handling alarm triggers from various sources
 * and determines the appropriate response (overlay, notification, activity, etc.)
 */
object AlarmTriggerHandler {
    
    private const val TAG = "AlarmTriggerHandler"
    
    /**
     * Main alarm trigger handler
     * Determines the best way to display the alarm based on device state
     */
    fun handleAlarmTrigger(context: Context, alarmId: String, label: String, soundPath: String) {
        Log.d(TAG, "Processing alarm trigger: $alarmId")
        
        try {
            // Primary: Use modern overlay service for consistent behavior
            if (canShowOverlay(context)) {
                Log.d(TAG, "Using overlay service for alarm: $alarmId")
                AlarmOverlayService.showAlarmOverlay(context, alarmId, label, soundPath)
            } else {
                // Fallback: Use notification with full-screen intent
                Log.d(TAG, "Using notification fallback for alarm: $alarmId")
                AlarmNotificationHelper.showUnifiedAlarmNotification(context, alarmId, label)
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Error handling alarm trigger for $alarmId", e)
            // Final fallback: simple notification
            AlarmNotificationHelper.showFallbackNotification(context, alarmId, label)
        }
    }
    
    /**
     * Check if overlay permission is available
     */
    private fun canShowOverlay(context: Context): Boolean {
        return if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
            android.provider.Settings.canDrawOverlays(context)
        } else {
            true // Permission not required on older versions
        }
    }
}
