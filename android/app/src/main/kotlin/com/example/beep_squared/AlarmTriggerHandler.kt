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
    fun handleAlarmTrigger(context: Context, alarmId: String, label: String, soundPath: String, unlockMethod: String = "simple", mathDifficulty: String = "easy", mathOperations: String = "mixed") {
        Log.d(TAG, "Processing alarm trigger: $alarmId with unlock method: $unlockMethod, difficulty: $mathDifficulty, operations: $mathOperations")
        
        // Check if this is a snooze alarm
        if (alarmId.startsWith("snooze_")) {
            handleSnoozeAlarmTrigger(context, alarmId, label, soundPath, unlockMethod, mathDifficulty, mathOperations)
            return
        }
        
        try {
            // Primary: Use modern overlay service for consistent behavior
            if (canShowOverlay(context)) {
                Log.d(TAG, "Using overlay service for alarm: $alarmId")
                AlarmOverlayService.showAlarmOverlay(context, alarmId, label, soundPath, unlockMethod, mathDifficulty, mathOperations)
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
     * Handle snooze alarm triggers
     * Re-triggers the original alarm after snooze period
     */
    private fun handleSnoozeAlarmTrigger(context: Context, snoozeAlarmId: String, label: String, soundPath: String, unlockMethod: String = "simple", mathDifficulty: String = "easy", mathOperations: String = "mixed") {
        Log.d(TAG, "Processing snooze alarm trigger: $snoozeAlarmId with unlock method: $unlockMethod")
        
        // Extract original alarm ID (remove "snooze_" prefix)
        val originalAlarmId = snoozeAlarmId.removePrefix("snooze_")
        
        try {
            // Cancel the snooze notification
            AlarmOverlayService.cancelSnoozeNotification(context, originalAlarmId)
            
            // Trigger the original alarm again
            if (canShowOverlay(context)) {
                Log.d(TAG, "Triggering snoozed alarm via overlay: $originalAlarmId")
                AlarmOverlayService.showAlarmOverlay(context, originalAlarmId, label, soundPath, unlockMethod, mathDifficulty, mathOperations)
            } else {
                Log.d(TAG, "Triggering snoozed alarm via notification: $originalAlarmId")
                AlarmNotificationHelper.showUnifiedAlarmNotification(context, originalAlarmId, label)
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Error handling snooze alarm trigger for $snoozeAlarmId", e)
            // Fallback: show the alarm anyway
            AlarmNotificationHelper.showFallbackNotification(context, originalAlarmId, label)
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
