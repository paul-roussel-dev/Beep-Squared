package com.example.beep_squared

import android.app.KeyguardManager
import android.app.NotificationManager
import android.content.Context
import android.graphics.Color
import android.media.AudioManager
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.os.VibrationEffect
import android.os.Vibrator
import android.util.Log
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import androidx.activity.ComponentActivity

class AlarmActivity : ComponentActivity() {
    private var wakeLock: PowerManager.WakeLock? = null
    private var mediaPlayer: MediaPlayer? = null
    private var vibrator: Vibrator? = null
    
    init {
        Log.d("AlarmActivity", "=== AlarmActivity CLASS INSTANTIATED ===")
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        Log.d("AlarmActivity", "=== ONCREATE START ===")
        Log.d("AlarmActivity", "Thread: ${Thread.currentThread().name}")
        Log.d("AlarmActivity", "Process: ${android.os.Process.myPid()}")
        
        super.onCreate(savedInstanceState)
        
        Log.d("AlarmActivity", "=== SUPER.ONCREATE COMPLETED ===")
        Log.d("AlarmActivity", "=== ALARM ACTIVITY CREATED SUCCESSFULLY ===")
        
        try {
            val alarmId = intent.getStringExtra("alarmId") ?: "unknown"
            val label = intent.getStringExtra("label") ?: "Alarm"
            
            Log.d("AlarmActivity", "Alarm ID: $alarmId, Label: $label")
            
            // Cancel any notification that might have triggered this
            try {
                val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                notificationManager.cancel(alarmId.hashCode())
                Log.d("AlarmActivity", "Notification cancelled")
            } catch (e: Exception) {
                Log.e("AlarmActivity", "Error cancelling notification: ${e.message}")
            }
            
            // Setup window to show over lock screen
            setupLockScreenWindow()
            
            // Acquire wake lock to keep screen on
            acquireWakeLock()
            
            // Create and set content view
            Log.d("AlarmActivity", "=== CREATING ALARM VIEW ===")
            val view = createAlarmView(label)
            Log.d("AlarmActivity", "=== ALARM VIEW CREATED ===")
            
            setContentView(view)
            Log.d("AlarmActivity", "=== CONTENT VIEW SET ===")
            
            Log.d("AlarmActivity", "AlarmActivity setup completed successfully")
            
        } catch (e: Exception) {
            Log.e("AlarmActivity", "Critical error in onCreate: ${e.message}", e)
            // Try to show a minimal view even if there's an error
            setContentView(createMinimalView())
        }
    }
    
    private fun setupLockScreenWindow() {
        try {
            Log.d("AlarmActivity", "Setting up lock screen window")
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
                setShowWhenLocked(true)
                setTurnScreenOn(true)
                
                val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
                keyguardManager.requestDismissKeyguard(this, null)
            } else {
                window.addFlags(
                    WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                    WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or
                    WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
                    WindowManager.LayoutParams.FLAG_ALLOW_LOCK_WHILE_SCREEN_ON
                )
            }
            
            // Additional window flags
            window.addFlags(
                WindowManager.LayoutParams.FLAG_FULLSCREEN or
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
            )
            
            Log.d("AlarmActivity", "Lock screen window configured")
        } catch (e: Exception) {
            Log.e("AlarmActivity", "Error setting up lock screen window: ${e.message}")
        }
    }
    
    private fun acquireWakeLock() {
        try {
            val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
            wakeLock = powerManager.newWakeLock(
                PowerManager.FULL_WAKE_LOCK or 
                PowerManager.ACQUIRE_CAUSES_WAKEUP or 
                PowerManager.ON_AFTER_RELEASE,
                "BeepSquared:AlarmWakeLock"
            )
            wakeLock?.acquire(10 * 60 * 1000L) // 10 minutes
            Log.d("AlarmActivity", "Wake lock acquired")
        } catch (e: Exception) {
            Log.e("AlarmActivity", "Error acquiring wake lock: ${e.message}")
        }
    }
    
    private fun createAlarmView(label: String): View {
        Log.d("AlarmActivity", "=== CREATING ALARM VIEW UI ===")
        Log.d("AlarmActivity", "Label: $label")
        
        return LinearLayout(this).apply {
            Log.d("AlarmActivity", "Creating LinearLayout...")
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(Color.RED)
            gravity = Gravity.CENTER
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
            
            Log.d("AlarmActivity", "Adding title TextView...")
            // Title
            addView(TextView(this@AlarmActivity).apply {
                text = "🔔 ALARM"
                textSize = 32f
                setTextColor(Color.WHITE)
                gravity = Gravity.CENTER
            })
            
            Log.d("AlarmActivity", "Adding label TextView...")
            // Label
            addView(TextView(this@AlarmActivity).apply {
                text = label
                textSize = 24f
                setTextColor(Color.WHITE)
                gravity = Gravity.CENTER
                setPadding(0, 32, 0, 64)
            })
            
            Log.d("AlarmActivity", "Adding dismiss button...")
            // Dismiss button
            addView(Button(this@AlarmActivity).apply {
                text = "DISMISS"
                textSize = 20f
                setOnClickListener {
                    Log.d("AlarmActivity", "Alarm dismissed by user")
                    finish()
                }
                layoutParams = LinearLayout.LayoutParams(400, 120).apply {
                    gravity = Gravity.CENTER
                }
            })
            
            Log.d("AlarmActivity", "=== ALARM VIEW UI COMPLETED ===")
        }
    }
    
    private fun createMinimalView(): View {
        return TextView(this).apply {
            text = "ALARM - TAP TO DISMISS"
            textSize = 24f
            setTextColor(Color.WHITE)
            setBackgroundColor(Color.RED)
            gravity = Gravity.CENTER
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
            setOnClickListener {
                Log.d("AlarmActivity", "Minimal alarm dismissed")
                finish()
            }
        }
    }
    
    override fun onStart() {
        super.onStart()
        Log.d("AlarmActivity", "=== ACTIVITY ONSTART ===")
    }
    
    override fun onResume() {
        super.onResume()
        Log.d("AlarmActivity", "=== ACTIVITY ONRESUME ===")
    }
    
    override fun onPause() {
        super.onPause()
        Log.d("AlarmActivity", "=== ACTIVITY ONPAUSE ===")
    }
    
    override fun onStop() {
        super.onStop()
        Log.d("AlarmActivity", "=== ACTIVITY ONSTOP ===")
    }
    
    override fun onDestroy() {
        super.onDestroy()
        Log.d("AlarmActivity", "=== ACTIVITY ONDESTROY ===")
        Log.d("AlarmActivity", "AlarmActivity destroyed")
        
        wakeLock?.let {
            if (it.isHeld) {
                it.release()
                Log.d("AlarmActivity", "Wake lock released")
            }
        }
    }
    
    override fun onBackPressed() {
        Log.d("AlarmActivity", "Back pressed - dismissing alarm")
        super.onBackPressed()
    }
}
