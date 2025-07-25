package com.example.beep_squared

import android.app.KeyguardManager
import android.app.NotificationManager
import android.content.Context
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.media.AudioManager
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.os.VibrationEffect
import android.os.Vibrator
import android.util.Log
import android.util.TypedValue
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
        Log.d("AlarmActivity", "=== CREATING MODERN ALARM VIEW UI ===")
        Log.d("AlarmActivity", "Label: $label")
        
        return LinearLayout(this).apply {
            Log.d("AlarmActivity", "Creating LinearLayout...")
            orientation = LinearLayout.VERTICAL
            
            // Create modern blue gradient background
            val gradientDrawable = GradientDrawable(
                GradientDrawable.Orientation.TOP_BOTTOM,
                intArrayOf(
                    Color.parseColor("#283593"), // Dark blue
                    Color.parseColor("#3F51B5"), // Indigo
                    Color.parseColor("#1A237E")  // Very dark blue
                )
            )
            background = gradientDrawable
            
            gravity = Gravity.CENTER
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
            setPadding(dpToPx(32), dpToPx(64), dpToPx(32), dpToPx(64))
            
            Log.d("AlarmActivity", "Adding alarm icon and title...")
            // Modern alarm icon with larger size
            addView(TextView(this@AlarmActivity).apply {
                text = "⏰"
                textSize = 80f
                setTextColor(Color.WHITE)
                gravity = Gravity.CENTER
                setPadding(0, 0, 0, dpToPx(24))
            })
            
            // Main title with modern typography
            addView(TextView(this@AlarmActivity).apply {
                text = "ALARM"
                textSize = 36f
                setTextColor(Color.WHITE)
                gravity = Gravity.CENTER
                setTypeface(null, android.graphics.Typeface.BOLD)
                letterSpacing = 0.1f
                setPadding(0, 0, 0, dpToPx(16))
            })
            
            Log.d("AlarmActivity", "Adding alarm label...")
            // Alarm label with modern styling
            addView(TextView(this@AlarmActivity).apply {
                text = label
                textSize = 20f
                setTextColor(Color.parseColor("#E8EAF6")) // Light gray from theme
                gravity = Gravity.CENTER
                setPadding(dpToPx(16), 0, dpToPx(16), dpToPx(48))
                alpha = 0.9f
            })
            
            Log.d("AlarmActivity", "Adding action buttons...")
            // Buttons container
            addView(LinearLayout(this@AlarmActivity).apply {
                orientation = LinearLayout.HORIZONTAL
                gravity = Gravity.CENTER
                
                // Snooze button (modern style)
                addView(createModernButton("SNOOZE", false) {
                    Log.d("AlarmActivity", "Alarm snoozed by user")
                    // TODO: Implement snooze logic
                    finish()
                })
                
                // Space between buttons
                addView(View(this@AlarmActivity).apply {
                    layoutParams = LinearLayout.LayoutParams(dpToPx(24), 0)
                })
                
                // Dismiss button (primary style)
                addView(createModernButton("DISMISS", true) {
                    Log.d("AlarmActivity", "Alarm dismissed by user")
                    finish()
                })
            })
            
            Log.d("AlarmActivity", "=== MODERN ALARM VIEW UI COMPLETED ===")
        }
    }
    
    private fun createModernButton(text: String, isPrimary: Boolean, onClick: () -> Unit): Button {
        return Button(this).apply {
            this.text = text
            textSize = 16f
            setTypeface(null, android.graphics.Typeface.BOLD)
            
            if (isPrimary) {
                // Primary button (white background, blue text)
                setTextColor(Color.parseColor("#1565C0"))
                background = createButtonBackground(Color.WHITE, Color.parseColor("#E3F2FD"))
            } else {
                // Secondary button (transparent background, white text)
                setTextColor(Color.WHITE)
                background = createButtonBackground(Color.TRANSPARENT, Color.parseColor("#5C6BC0"))
            }
            
            layoutParams = LinearLayout.LayoutParams(dpToPx(120), dpToPx(56)).apply {
                gravity = Gravity.CENTER
            }
            
            setOnClickListener { onClick() }
            
            // Add elevation effect
            elevation = dpToPx(4).toFloat()
            stateListAnimator = null
        }
    }
    
    private fun createButtonBackground(backgroundColor: Int, pressedColor: Int): GradientDrawable {
        return GradientDrawable().apply {
            shape = GradientDrawable.RECTANGLE
            setColor(backgroundColor)
            cornerRadius = dpToPx(12).toFloat()
            setStroke(if (backgroundColor == Color.TRANSPARENT) dpToPx(2) else 0, Color.WHITE)
        }
    }
    
    private fun dpToPx(dp: Int): Int {
        return TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP,
            dp.toFloat(),
            resources.displayMetrics
        ).toInt()
    }
    
    private fun createMinimalView(): View {
        return TextView(this).apply {
            text = "⏰ ALARM - TAP TO DISMISS"
            textSize = 28f
            setTextColor(Color.WHITE)
            
            // Apply blue gradient background even for minimal view
            val gradientDrawable = GradientDrawable(
                GradientDrawable.Orientation.TOP_BOTTOM,
                intArrayOf(
                    Color.parseColor("#283593"),
                    Color.parseColor("#3F51B5")
                )
            )
            background = gradientDrawable
            
            gravity = Gravity.CENTER
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
            setPadding(dpToPx(32), dpToPx(32), dpToPx(32), dpToPx(32))
            setTypeface(null, android.graphics.Typeface.BOLD)
            
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
