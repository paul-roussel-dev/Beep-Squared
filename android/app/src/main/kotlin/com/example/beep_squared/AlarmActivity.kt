package com.example.beep_squared

import android.app.Activity
import android.app.KeyguardManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.WindowManager

class AlarmActivity : Activity() {
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        Log.d("AlarmActivity", "AlarmActivity created")
        
        // Setup window for lock screen display
        setupLockScreenWindow()
        
        // Get alarm details from intent
        val alarmId = intent.getStringExtra("alarmId")
        val label = intent.getStringExtra("label") ?: "Alarm"
        
        Log.d("AlarmActivity", "Alarm received: $alarmId, label: $label")
        
        if (alarmId != null) {
            // Launch MainActivity with alarm trigger
            val mainIntent = Intent(this, MainActivity::class.java).apply {
                putExtra("triggerAlarm", true)
                putExtra("alarmId", alarmId)
                putExtra("label", label)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            
            Log.d("AlarmActivity", "Launching MainActivity with alarm: $alarmId")
            startActivity(mainIntent)
        }
        
        // Close this activity immediately
        finish()
    }

    private fun setupLockScreenWindow() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
            
            val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
            keyguardManager.requestDismissKeyguard(this, null)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_FULLSCREEN
            )
        }
    }
}
