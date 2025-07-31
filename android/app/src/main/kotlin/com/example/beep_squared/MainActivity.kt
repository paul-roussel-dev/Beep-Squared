package com.example.beep_squared

import android.Manifest
import android.app.AlarmManager
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.*

class MainActivity : FlutterActivity() {
    private lateinit var alarmManager: AlarmManager
    
    companion object {
        private const val NOTIFICATION_PERMISSION_REQUEST_CODE = 1001
        private const val OVERLAY_PERMISSION_REQUEST_CODE = 1234
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        
        // Check and request notification permission for Android 13+
        requestNotificationPermission()
        
        // Check and request exact alarm permission
        if (!AlarmPermissionHelper.checkExactAlarmPermission(this)) {
            AlarmPermissionHelper.requestExactAlarmPermission(this)
        }
        
        // Check and request overlay permission
        checkOverlayPermission()
        
        // Check if we were launched by an alarm
        handleAlarmIntent()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleAlarmIntent()
    }

    private fun handleAlarmIntent() {
        val alarmId = intent.getStringExtra(AlarmConfig.EXTRA_ALARM_ID)
        val triggerAlarm = intent.getBooleanExtra("triggerAlarm", false)
        val action = intent.getStringExtra(AlarmConfig.EXTRA_ACTION)
        
        when (action) {
            AlarmConfig.ACTION_SNOOZE -> {
                val scheduledTime = intent.getLongExtra(AlarmConfig.EXTRA_SCHEDULED_TIME, 0)
                val label = intent.getStringExtra(AlarmConfig.EXTRA_LABEL) ?: "Snooze Alarm"
                val soundPath = intent.getStringExtra(AlarmConfig.EXTRA_SOUND_PATH) ?: AlarmConfig.DEFAULT_SOUND_PATH
                if (alarmId != null && scheduledTime > 0) {
                    scheduleAlarm(alarmId, scheduledTime, label, soundPath, "simple", "easy", "mixed")
                }
            }
            else -> {
                if (triggerAlarm && alarmId != null) {
                    // Trigger alarm in Flutter if app is active
                    triggerFlutterAlarm(alarmId)
                }
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, AlarmConfig.ALARM_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "scheduleAlarm" -> {
                        val alarmId = call.argument<String>(AlarmConfig.EXTRA_ALARM_ID)!!
                        val scheduledTime = call.argument<Long>(AlarmConfig.EXTRA_SCHEDULED_TIME)!!
                        val label = call.argument<String>(AlarmConfig.EXTRA_LABEL) ?: "Alarm"
                        val soundPath = call.argument<String>(AlarmConfig.EXTRA_SOUND_PATH) ?: AlarmConfig.DEFAULT_SOUND_PATH
                        val unlockMethod = call.argument<String>("unlockMethod") ?: "simple"
                        val mathDifficulty = call.argument<String>("mathDifficulty") ?: "easy"
                        val mathOperations = call.argument<String>("mathOperations") ?: "mixed"
                        
                        scheduleAlarm(alarmId, scheduledTime, label, soundPath, unlockMethod, mathDifficulty, mathOperations)
                        result.success(true)
                    }
                    "cancelAlarm" -> {
                        val alarmId = call.argument<String>(AlarmConfig.EXTRA_ALARM_ID)!!
                        cancelAlarm(alarmId)
                        result.success(true)
                    }
                    "cancelSnoozeAlarm" -> {
                        val alarmId = call.argument<String>(AlarmConfig.EXTRA_ALARM_ID)!!
                        cancelSnoozeAlarm(alarmId)
                        result.success(true)
                    }
                    "cancelAllAlarms" -> {
                        cancelAllAlarms()
                        result.success(true)
                    }
                    "triggerNativeAlarm" -> {
                        val alarmId = call.argument<String>(AlarmConfig.EXTRA_ALARM_ID) ?: "flutter_alarm"
                        val label = call.argument<String>(AlarmConfig.EXTRA_LABEL) ?: "Alarm"
                        val ringtone = call.argument<String>("ringtone") ?: AlarmConfig.DEFAULT_SOUND_PATH
                        val unlockMethod = call.argument<String>("unlockMethod") ?: "simple"
                        val immediate = call.argument<Boolean>("immediate") ?: false
                        
                        if (immediate) {
                            // Trigger alarm immediately using the modern overlay with configured sound
                            triggerImmediateAlarm(alarmId, label, ringtone, unlockMethod)
                        }
                        result.success(true)
                    }
                    "checkNotificationPermission" -> {
                        val hasPermission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED
                        } else {
                            true // No permission needed for older versions
                        }
                        
                        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                        val areEnabled = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                            notificationManager.areNotificationsEnabled()
                        } else {
                            true
                        }
                        
                        result.success(mapOf(
                            "hasPermission" to hasPermission,
                            "areEnabled" to areEnabled
                        ))
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun scheduleAlarm(alarmId: String, scheduledTime: Long, label: String, soundPath: String, unlockMethod: String = "simple", mathDifficulty: String = "easy", mathOperations: String = "mixed") {
        try {
            // Check permission before scheduling
            if (!AlarmPermissionHelper.checkExactAlarmPermission(this)) {
                println("Exact alarm permission not granted")
                AlarmPermissionHelper.requestExactAlarmPermission(this)
                return
            }
            
            val intent = Intent(this, AlarmReceiver::class.java).apply {
                putExtra("alarmId", alarmId)
                putExtra("label", label)
                putExtra("soundPath", soundPath) // Passer le son configuré
                putExtra("unlockMethod", unlockMethod) // Passer la méthode de déverrouillage
                putExtra("mathDifficulty", mathDifficulty) // Passer la difficulté
                putExtra("mathOperations", mathOperations) // Passer les opérations
            }
            
            val pendingIntent = PendingIntent.getBroadcast(
                this,
                alarmId.hashCode(),
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            // Schedule exact alarm with proper error handling
            try {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    scheduledTime,
                    pendingIntent
                )
                println("Native Android alarm scheduled successfully: $alarmId at $scheduledTime")
            } catch (e: SecurityException) {
                println("SecurityException scheduling alarm: ${e.message}")
                // Fall back to inexact alarm
                alarmManager.set(AlarmManager.RTC_WAKEUP, scheduledTime, pendingIntent)
            }
        } catch (e: Exception) {
            println("Error scheduling alarm: ${e.message}")
        }
    }

    private fun cancelAlarm(alarmId: String) {
        val intent = Intent(this, AlarmReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            this,
            alarmId.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        alarmManager.cancel(pendingIntent)
    }

    private fun cancelAllAlarms() {
        // Note: In a real implementation, you'd need to track all alarm IDs
        // For now, this is a placeholder
    }

    private fun checkOverlayPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (!Settings.canDrawOverlays(this)) {
                android.util.Log.d("MainActivity", "Requesting overlay permission...")
                val intent = Intent(
                    Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                    Uri.parse("package:$packageName")
                )
                startActivity(intent)
            } else {
                android.util.Log.d("MainActivity", "Overlay permission already granted")
            }
        }
    }
    
    private fun requestNotificationPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) 
                != PackageManager.PERMISSION_GRANTED) {
                
                android.util.Log.d("MainActivity", "Requesting notification permission for Android 13+")
                ActivityCompat.requestPermissions(
                    this,
                    arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                    NOTIFICATION_PERMISSION_REQUEST_CODE
                )
            } else {
                android.util.Log.d("MainActivity", "Notification permission already granted")
            }
        } else {
            android.util.Log.d("MainActivity", "Android version < 13, no notification permission needed")
        }
    }
    
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        
        when (requestCode) {
            NOTIFICATION_PERMISSION_REQUEST_CODE -> {
                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    android.util.Log.d("MainActivity", "Notification permission granted")
                } else {
                    android.util.Log.w("MainActivity", "Notification permission denied")
                }
            }
        }
    }

    private fun triggerFlutterAlarm(alarmId: String) {
        if (flutterEngine != null) {
            MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, AlarmConfig.ALARM_CHANNEL)
                .invokeMethod("onAlarmTriggered", alarmId)
        }
    }

    private fun triggerImmediateAlarm(alarmId: String, label: String, ringtone: String, unlockMethod: String = "simple") {
        android.util.Log.d("MainActivity", "=== TRIGGERING MODERN ALARM OVERLAY ===")
        android.util.Log.d("MainActivity", "AlarmId: $alarmId, Label: $label, Ringtone: $ringtone, UnlockMethod: $unlockMethod")
        
        try {
            // Use ONLY the modern alarm overlay for consistency with configured sound
            android.util.Log.d("MainActivity", "Starting modern alarm overlay with configured sound...")
            AlarmOverlayService.showAlarmOverlay(this, alarmId, label, ringtone, unlockMethod)
            
            android.util.Log.d("MainActivity", "=== MODERN ALARM OVERLAY TRIGGERED ===")
            
        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "Error triggering modern alarm: ${e.message}", e)
        }
    }
    
    /**
     * Cancel a snoozed alarm
     */
    private fun cancelSnoozeAlarm(alarmId: String) {
        try {
            println("Canceling snooze alarm: $alarmId")
            
            val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
            
            // Cancel the snooze alarm intent
            val snoozeIntent = Intent(this, AlarmOverlayService::class.java).apply {
                putExtra("alarmId", alarmId)
                putExtra("label", "Snoozed Alarm")
                putExtra("unlockMethod", "simple")
            }
            
            val pendingIntent = PendingIntent.getService(
                this, 
                alarmId.hashCode(), 
                snoozeIntent, 
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            
            alarmManager.cancel(pendingIntent)
            
            // Also cancel the snooze notification
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.cancel(AlarmOverlayService.SNOOZE_NOTIFICATION_ID)
            
            println("Snooze alarm cancelled: $alarmId")
        } catch (e: Exception) {
            println("Error canceling snooze alarm: ${e.message}")
            e.printStackTrace()
        }
    }
}
