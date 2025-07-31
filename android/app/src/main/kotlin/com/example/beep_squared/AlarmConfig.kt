package com.example.beep_squared

import android.content.Intent

/**
 * Centralized configuration for alarm system
 * Contains all constants, channel IDs, and configuration values
 */
object AlarmConfig {
    // MethodChannel configuration
    const val ALARM_CHANNEL = "beep_squared.alarm/native"
    
    // Notification channels
    const val ALARM_CHANNEL_ID = "alarm_channel"
    const val SIMPLE_ALARM_CHANNEL_ID = "simple_alarm_channel"
    const val UNIFIED_ALARM_CHANNEL_ID = "unified_alarm_channel"
    
    // Intent extras
    const val EXTRA_ALARM_ID = "alarmId"
    const val EXTRA_LABEL = "label"
    const val EXTRA_SOUND_PATH = "soundPath"
    const val EXTRA_SCHEDULED_TIME = "scheduledTime"
    const val EXTRA_ACTION = "action"
    
    // Actions
    const val ACTION_SNOOZE = "snooze"
    const val ACTION_DISMISS = "dismiss"
    const val ACTION_CANCEL_SNOOZE = "cancel_snooze"
    
    // Default values
    const val DEFAULT_SOUND_PATH = "default"
    const val DEFAULT_SNOOZE_MINUTES = 5
    
    // Intent flags for alarm activities
    const val ALARM_ACTIVITY_FLAGS = Intent.FLAG_ACTIVITY_NEW_TASK or 
                                   Intent.FLAG_ACTIVITY_CLEAR_TOP or
                                   Intent.FLAG_ACTIVITY_SINGLE_TOP or
                                   Intent.FLAG_ACTIVITY_NO_HISTORY or
                                   Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS
}
