package com.example.beep_squared

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * Main alarm receiver for handling system alarm broadcasts
 * 
 * This receiver handles alarm triggers from Android's AlarmManager and
 * delegates to the appropriate alarm handler based on the alarm type.
 */
class AlarmReceiver : BroadcastReceiver() {
    
    companion object {
        private const val TAG = "AlarmReceiver"
    }
    
    override fun onReceive(context: Context, intent: Intent) {
        val alarmId = intent.getStringExtra(AlarmConfig.EXTRA_ALARM_ID)
        val label = intent.getStringExtra(AlarmConfig.EXTRA_LABEL) ?: "Alarm"
        val soundPath = intent.getStringExtra(AlarmConfig.EXTRA_SOUND_PATH) ?: AlarmConfig.DEFAULT_SOUND_PATH
        val unlockMethod = intent.getStringExtra("unlockMethod") ?: "simple"
        val mathDifficulty = intent.getStringExtra("mathDifficulty") ?: "easy"
        val mathOperations = intent.getStringExtra("mathOperations") ?: "mixed"
        
        Log.d(TAG, "Alarm received - ID: $alarmId, Label: $label, UnlockMethod: $unlockMethod, MathDifficulty: $mathDifficulty, MathOperations: $mathOperations")
        
        alarmId?.let { id ->
            try {
                // Delegate to alarm trigger handler
                AlarmTriggerHandler.handleAlarmTrigger(context, id, label, soundPath, unlockMethod, mathDifficulty, mathOperations)
                Log.d(TAG, "Alarm successfully handled: $id")
            } catch (e: Exception) {
                Log.e(TAG, "Error handling alarm $id: ${e.message}", e)
                // Fallback to simple notification
                AlarmNotificationHelper.showFallbackNotification(context, id, label)
            }
        } ?: run {
            Log.e(TAG, "No alarm ID provided in intent")
        }
    }

}
