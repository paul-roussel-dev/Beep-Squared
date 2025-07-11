package com.example.beep_squared

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Bundle
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
        
        if (triggerAlarm && alarmId != null) {
            // Trigger alarm in Flutter
            triggerFlutterAlarm(alarmId)
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
                        
                        scheduleAlarm(alarmId, scheduledTime, label)
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
                    else -> result.notImplemented()
                }
            }
    }

    private fun scheduleAlarm(alarmId: String, scheduledTime: Long, label: String) {
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

    private fun triggerFlutterAlarm(alarmId: String) {
        if (flutterEngine != null) {
            MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, ALARM_CHANNEL)
                .invokeMethod("onAlarmTriggered", alarmId)
        }
    }
}
