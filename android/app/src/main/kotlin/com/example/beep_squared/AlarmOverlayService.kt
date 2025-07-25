package com.example.beep_squared

import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.media.AudioManager
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.os.Build
import android.os.IBinder
import android.util.Log
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView

class AlarmOverlayService : Service() {
    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private var mediaPlayer: MediaPlayer? = null
    
    companion object {
        fun showAlarmOverlay(context: Context, alarmId: String, label: String, soundPath: String = "default") {
            val intent = Intent(context, AlarmOverlayService::class.java).apply {
                putExtra("alarmId", alarmId)
                putExtra("label", label)
                putExtra("soundPath", soundPath)
            }
            context.startService(intent)
        }
    }
    
    override fun onCreate() {
        super.onCreate()
        Log.d("AlarmOverlayService", "Service created")
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
    }
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d("AlarmOverlayService", "Service started")
        
        val alarmId = intent?.getStringExtra("alarmId") ?: "unknown"
        val label = intent?.getStringExtra("label") ?: "Alarm"
        
        startAlarmSound()
        showAlarmOverlay(alarmId, label)
        
        return START_NOT_STICKY
    }
    
    private fun startAlarmSound() {
        try {
            val alarmUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
            mediaPlayer = MediaPlayer().apply {
                setAudioStreamType(AudioManager.STREAM_ALARM)
                setDataSource(this@AlarmOverlayService, alarmUri)
                isLooping = true
                prepare()
                start()
            }
        } catch (e: Exception) {
            Log.e("AlarmOverlayService", "Error starting alarm sound: ${e.message}")
        }
    }
    
    private fun showAlarmOverlay(alarmId: String, label: String) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                if (!android.provider.Settings.canDrawOverlays(this)) {
                    Log.e("AlarmOverlayService", "No overlay permission")
                    stopSelf()
                    return
                }
            }
            
            overlayView = createOverlayView(alarmId, label)
            
            val layoutParams = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                WindowManager.LayoutParams(
                    WindowManager.LayoutParams.MATCH_PARENT,
                    WindowManager.LayoutParams.MATCH_PARENT,
                    WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
                    WindowManager.LayoutParams.FLAG_FULLSCREEN or
                    WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON,
                    PixelFormat.TRANSLUCENT
                )
            } else {
                WindowManager.LayoutParams(
                    WindowManager.LayoutParams.MATCH_PARENT,
                    WindowManager.LayoutParams.MATCH_PARENT,
                    WindowManager.LayoutParams.TYPE_SYSTEM_ALERT,
                    WindowManager.LayoutParams.FLAG_FULLSCREEN or
                    WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON,
                    PixelFormat.TRANSLUCENT
                )
            }
            
            windowManager?.addView(overlayView, layoutParams)
            
        } catch (e: Exception) {
            Log.e("AlarmOverlayService", "Error creating overlay: ${e.message}")
            stopSelf()
        }
    }

    private fun createOverlayView(alarmId: String, label: String): View {
        return LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            
            // Modern blue gradient background
            background = GradientDrawable().apply {
                colors = intArrayOf(
                    Color.parseColor("#283593"), // Dark blue
                    Color.parseColor("#3F51B5"), // Indigo  
                    Color.parseColor("#1A237E")  // Very dark blue
                )
                orientation = GradientDrawable.Orientation.TOP_BOTTOM
            }
            
            gravity = Gravity.CENTER
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
            setPadding(dpToPx(32), dpToPx(64), dpToPx(32), dpToPx(64))
            
            // Alarm icon
            addView(TextView(this@AlarmOverlayService).apply {
                text = "⏰"
                textSize = 80f
                setTextColor(Color.WHITE)
                gravity = Gravity.CENTER
                setPadding(0, 0, 0, dpToPx(24))
            })
            
            // Title
            addView(TextView(this@AlarmOverlayService).apply {
                text = "ALARM"
                textSize = 36f
                setTextColor(Color.WHITE)
                gravity = Gravity.CENTER
                typeface = android.graphics.Typeface.DEFAULT_BOLD
                setPadding(0, 0, 0, dpToPx(16))
            })
            
            // Label
            addView(TextView(this@AlarmOverlayService).apply {
                text = label
                textSize = 20f
                setTextColor(Color.parseColor("#E8EAF6"))
                gravity = Gravity.CENTER
                setPadding(dpToPx(16), 0, dpToPx(16), dpToPx(24))
            })
            
            // Current time
            addView(TextView(this@AlarmOverlayService).apply {
                text = java.text.SimpleDateFormat("HH:mm", java.util.Locale.getDefault()).format(java.util.Date())
                textSize = 48f
                setTextColor(Color.WHITE)
                gravity = Gravity.CENTER
                typeface = android.graphics.Typeface.DEFAULT_BOLD
                setPadding(0, 0, 0, dpToPx(48))
            })
            
            // Dismiss button
            addView(Button(this@AlarmOverlayService).apply {
                text = "DISMISS"
                textSize = 18f
                setTextColor(Color.parseColor("#1565C0"))
                background = GradientDrawable().apply {
                    setColor(Color.WHITE)
                    cornerRadius = dpToPx(12).toFloat()
                }
                layoutParams = LinearLayout.LayoutParams(dpToPx(200), dpToPx(60))
                setOnClickListener { dismissAlarm() }
            })
        }
    }
    
    private fun dismissAlarm() {
        stopAlarmSound()
        removeOverlay()
        stopSelf()
    }
    
    private fun stopAlarmSound() {
        try {
            mediaPlayer?.let {
                if (it.isPlaying) {
                    it.stop()
                }
                it.release()
                mediaPlayer = null
            }
        } catch (e: Exception) {
            Log.e("AlarmOverlayService", "Error stopping sound: ${e.message}")
        }
    }
    
    private fun dpToPx(dp: Int): Int {
        return TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP,
            dp.toFloat(),
            resources.displayMetrics
        ).toInt()
    }
    
    private fun removeOverlay() {
        try {
            overlayView?.let { view ->
                windowManager?.removeView(view)
                overlayView = null
            }
        } catch (e: Exception) {
            Log.e("AlarmOverlayService", "Error removing overlay: ${e.message}")
        }
    }
    
    override fun onDestroy() {
        super.onDestroy()
        stopAlarmSound()
        removeOverlay()
    }
    
    override fun onBind(intent: Intent?): IBinder? = null
}
