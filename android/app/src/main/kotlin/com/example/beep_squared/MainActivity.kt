package com.example.beep_squared

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.*

class MainActivity : FlutterActivity() {
    private val ALARM_CHANNEL = "beep_squared.alarm/native"
    private lateinit var alarmManager: AlarmManager

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        
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
        val alarmId = intent.getStringExtra("alarmId")
        val triggerAlarm = intent.getBooleanExtra("triggerAlarm", false)
        val action = intent.getStringExtra("action")
        
        when (action) {
            "snooze" -> {
                val scheduledTime = intent.getLongExtra("scheduledTime", 0)
                val label = intent.getStringExtra("label") ?: "Snooze Alarm"
                val soundPath = intent.getStringExtra("soundPath") ?: "default"
                if (alarmId != null && scheduledTime > 0) {
                    scheduleAlarm(alarmId, scheduledTime, label, soundPath)
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
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ALARM_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "scheduleAlarm" -> {
                        val alarmId = call.argument<String>("alarmId")!!
                        val scheduledTime = call.argument<Long>("scheduledTime")!!
                        val label = call.argument<String>("label") ?: "Alarm"
                        val soundPath = call.argument<String>("soundPath") ?: "default"
                        
                        scheduleAlarm(alarmId, scheduledTime, label, soundPath)
                        result.success(true)
                    }
                    "cancelAlarm" -> {
                        val alarmId = call.argument<String>("alarmId")!!
                        cancelAlarm(alarmId)
                        result.success(true)
                    }
                    "cancelAllAlarms" -> {
                        cancelAllAlarms()
                        result.success(true)
                    }
                    "triggerNativeAlarm" -> {
                        val alarmId = call.argument<String>("alarmId") ?: "flutter_alarm"
                        val label = call.argument<String>("label") ?: "Alarm"
                        val ringtone = call.argument<String>("ringtone") ?: "default"
                        val immediate = call.argument<Boolean>("immediate") ?: false
                        
                        if (immediate) {
                            // Trigger alarm immediately using the modern overlay with configured sound
                            triggerImmediateAlarm(alarmId, label, ringtone)
                        }
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun scheduleAlarm(alarmId: String, scheduledTime: Long, label: String, soundPath: String) {
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

    private fun triggerFlutterAlarm(alarmId: String) {
        if (flutterEngine != null) {
            MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, ALARM_CHANNEL)
                .invokeMethod("onAlarmTriggered", alarmId)
        }
    }

    private fun triggerImmediateAlarm(alarmId: String, label: String, ringtone: String) {
        android.util.Log.d("MainActivity", "=== TRIGGERING MODERN ALARM OVERLAY ===")
        android.util.Log.d("MainActivity", "AlarmId: $alarmId, Label: $label, Ringtone: $ringtone")
        
        try {
            // Use ONLY the modern alarm overlay for consistency with configured sound
            android.util.Log.d("MainActivity", "Starting modern alarm overlay with configured sound...")
            AlarmOverlayService.showAlarmOverlay(this, alarmId, label, ringtone)
            
            android.util.Log.d("MainActivity", "=== MODERN ALARM OVERLAY TRIGGERED ===")
            
        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "Error triggering modern alarm: ${e.message}", e)
        }
    }

    companion object {
        private const val OVERLAY_PERMISSION_REQUEST_CODE = 1234
    }
}
