package com.example.beep_squared

import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.media.AudioManager
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.os.Build
import android.os.IBinder
import android.os.VibrationEffect
import android.os.Vibrator
import android.util.Log
import android.view.Gravity
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.Button
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView
import kotlin.math.abs

class AlarmOverlayService : Service() {
    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private var mediaPlayer: MediaPlayer? = null
    private var vibrator: Vibrator? = null
    
    companion object {
        fun showAlarmOverlay(context: Context, alarmId: String, label: String, soundPath: String = AlarmConfig.DEFAULT_SOUND_PATH) {
            val intent = Intent(context, AlarmOverlayService::class.java).apply {
                putExtra(AlarmConfig.EXTRA_ALARM_ID, alarmId)
                putExtra(AlarmConfig.EXTRA_LABEL, label)
                putExtra(AlarmConfig.EXTRA_SOUND_PATH, soundPath)
            }
            context.startService(intent)
        }
        
        fun stopAlarmOverlay(context: Context, alarmId: String) {
            val intent = Intent(context, AlarmOverlayService::class.java)
            context.stopService(intent)
        }
    }
    
    override fun onCreate() {
        super.onCreate()
        Log.d("AlarmOverlayService", "=== ALARM OVERLAY SERVICE CREATED ===")
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        
        // Initialize sound and vibration
        initializeAlarmSound()
        initializeVibration()
    }
    
    private fun initializeAlarmSound() {
        try {
            mediaPlayer = MediaPlayer().apply {
                setAudioStreamType(AudioManager.STREAM_ALARM)
                val alarmUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                setDataSource(this@AlarmOverlayService, alarmUri)
                isLooping = true
                prepare()
            }
            Log.d("AlarmOverlayService", "Alarm sound initialized")
        } catch (e: Exception) {
            Log.e("AlarmOverlayService", "Error initializing alarm sound: ${e.message}")
        }
    }
    
    private fun initializeVibration() {
        try {
            vibrator = getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
            Log.d("AlarmOverlayService", "Vibration initialized")
        } catch (e: Exception) {
            Log.e("AlarmOverlayService", "Error initializing vibration: ${e.message}")
        }
    }
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d("AlarmOverlayService", "=== MODERN ALARM OVERLAY SERVICE STARTED ===")
        
        val alarmId = intent?.getStringExtra("alarmId") ?: "unknown"
        val label = intent?.getStringExtra("label") ?: "Alarm"
        val soundPath = intent?.getStringExtra("soundPath") ?: "default"
        
        Log.d("AlarmOverlayService", "Creating modern overlay for alarm: $alarmId")
        Log.d("AlarmOverlayService", "Label: $label, Sound Path: $soundPath")
        
        // Start alarm sound and vibration with configured sound
        startAlarmSound(soundPath)
        startVibration()
        
        showAlarmOverlay(alarmId, label)
        
        return START_NOT_STICKY
    }
    
    private fun startAlarmSound(soundPath: String) {
        try {
            mediaPlayer = MediaPlayer().apply {
                setAudioStreamType(AudioManager.STREAM_ALARM)
                
                // Use configured sound or default alarm
                val alarmUri = when {
                    soundPath == "default" -> RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                    soundPath == "notification" -> RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
                    soundPath == "ringtone" -> RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)
                    soundPath.startsWith("assets/sounds/") -> {
                        // Fichier depuis les assets
                        try {
                            val assetFileName = soundPath.replace("assets/sounds/", "").replace(".mp3", "")
                            val assetUri = android.net.Uri.parse("android.resource://${packageName}/raw/$assetFileName")
                            Log.d("AlarmOverlayService", "Loading custom sound from assets: $assetUri")
                            assetUri
                        } catch (e: Exception) {
                            Log.w("AlarmOverlayService", "Custom sound not found in assets: $soundPath, using default")
                            RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                        }
                    }
                    else -> {
                        // Try to parse as URI or fallback to default
                        try {
                            val customUri = android.net.Uri.parse(soundPath)
                            Log.d("AlarmOverlayService", "Loading custom sound URI: $customUri")
                            customUri
                        } catch (e: Exception) {
                            Log.w("AlarmOverlayService", "Invalid sound path: $soundPath, using default")
                            RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                        }
                    }
                }
                
                setDataSource(this@AlarmOverlayService, alarmUri)
                isLooping = true
                prepare()
                start()
            }
            Log.d("AlarmOverlayService", "Alarm sound started with configured sound: $soundPath")
        } catch (e: Exception) {
            Log.e("AlarmOverlayService", "Error starting alarm sound: ${e.message}")
            // Fallback vers le son par défaut
            try {
                mediaPlayer = MediaPlayer().apply {
                    setAudioStreamType(AudioManager.STREAM_ALARM)
                    setDataSource(this@AlarmOverlayService, RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM))
                    isLooping = true
                    prepare()
                    start()
                }
                Log.d("AlarmOverlayService", "Fallback alarm sound started")
            } catch (fallbackException: Exception) {
                Log.e("AlarmOverlayService", "Failed to start fallback sound: ${fallbackException.message}")
            }
        }
    }
    
    private fun startVibration() {
        try {
            val pattern = longArrayOf(0, 1000, 500, 1000, 500, 1000)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                vibrator?.vibrate(VibrationEffect.createWaveform(pattern, 0))
            } else {
                @Suppress("DEPRECATION")
                vibrator?.vibrate(pattern, 0)
            }
            Log.d("AlarmOverlayService", "Vibration started")
        } catch (e: Exception) {
            Log.e("AlarmOverlayService", "Error starting vibration: ${e.message}")
        }
    }
    
    private fun stopAlarmSound() {
        try {
            mediaPlayer?.stop()
            mediaPlayer?.release()
            mediaPlayer = null
            Log.d("AlarmOverlayService", "Alarm sound stopped")
        } catch (e: Exception) {
            Log.e("AlarmOverlayService", "Error stopping alarm sound: ${e.message}")
        }
    }
    
    private fun stopVibration() {
        try {
            vibrator?.cancel()
            Log.d("AlarmOverlayService", "Vibration stopped")
        } catch (e: Exception) {
            Log.e("AlarmOverlayService", "Error stopping vibration: ${e.message}")
        }
    }

    private fun showAlarmOverlay(alarmId: String, label: String) {
        try {
            Log.d("AlarmOverlayService", "=== CREATING SYSTEM OVERLAY ===")
            
            // Check if we have overlay permission
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                if (!android.provider.Settings.canDrawOverlays(this)) {
                    Log.e("AlarmOverlayService", "CRITICAL: No SYSTEM_ALERT_WINDOW permission!")
                    Log.e("AlarmOverlayService", "Cannot display overlay without permission")
                    // Try to use a different approach
                    stopSelf()
                    return
                }
                Log.d("AlarmOverlayService", "Overlay permission granted")
            }
            
            // Create overlay view
            overlayView = createOverlayView(alarmId, label)
            
            // Setup window parameters
            val layoutParams = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                WindowManager.LayoutParams(
                    WindowManager.LayoutParams.MATCH_PARENT,
                    WindowManager.LayoutParams.MATCH_PARENT,
                    WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
                    WindowManager.LayoutParams.FLAG_FULLSCREEN or
                    WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                    WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
                    WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or
                    WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
                    PixelFormat.TRANSLUCENT
                )
            } else {
                WindowManager.LayoutParams(
                    WindowManager.LayoutParams.MATCH_PARENT,
                    WindowManager.LayoutParams.MATCH_PARENT,
                    WindowManager.LayoutParams.TYPE_SYSTEM_ALERT,
                    WindowManager.LayoutParams.FLAG_FULLSCREEN or
                    WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                    WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
                    WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or
                    WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
                    PixelFormat.TRANSLUCENT
                )
            }
            
            layoutParams.gravity = Gravity.CENTER
            
            Log.d("AlarmOverlayService", "Layout params: ${layoutParams.type}, flags: ${layoutParams.flags}")
            Log.d("AlarmOverlayService", "Adding overlay view to window manager...")
            windowManager?.addView(overlayView, layoutParams)
            Log.d("AlarmOverlayService", "=== OVERLAY VIEW ADDED SUCCESSFULLY ===")
            
        } catch (e: SecurityException) {
            Log.e("AlarmOverlayService", "SecurityException: ${e.message}")
            Log.e("AlarmOverlayService", "Overlay permission required!")
        } catch (e: Exception) {
            Log.e("AlarmOverlayService", "Error creating overlay: ${e.message}", e)
        }
    }
    
    private fun createOverlayView(alarmId: String, label: String): View {
        Log.d("AlarmOverlayService", "Creating modern overlay UI for alarm: $alarmId")
        
        return LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            // Gradient background moderne
            background = android.graphics.drawable.GradientDrawable().apply {
                colors = intArrayOf(
                    android.graphics.Color.parseColor("#FF6B35"), // Orange vif
                    android.graphics.Color.parseColor("#F7931E")  // Orange plus clair
                )
                orientation = android.graphics.drawable.GradientDrawable.Orientation.TOP_BOTTOM
            }
            gravity = Gravity.CENTER
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
            setPadding(64, 100, 64, 100)
            
            // Container principal avec coins arrondis
            val container = LinearLayout(this@AlarmOverlayService).apply {
                orientation = LinearLayout.VERTICAL
                background = android.graphics.drawable.GradientDrawable().apply {
                    setColor(android.graphics.Color.WHITE)
                    cornerRadius = 32f
                    setStroke(4, android.graphics.Color.parseColor("#FF6B35"))
                }
                gravity = Gravity.CENTER
                setPadding(48, 64, 48, 64)
                layoutParams = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                )
                elevation = 20f
            }
            
            // Icône d'alarme animée
            container.addView(TextView(this@AlarmOverlayService).apply {
                text = "⏰"
                textSize = 72f
                gravity = Gravity.CENTER
                setPadding(0, 0, 0, 24)
                // Animation simple
                animate().scaleX(1.2f).scaleY(1.2f).setDuration(1000).withEndAction {
                    animate().scaleX(1.0f).scaleY(1.0f).setDuration(1000).start()
                }.start()
            })
            
            // Titre moderne
            container.addView(TextView(this@AlarmOverlayService).apply {
                text = "ALARM"
                textSize = 32f
                setTextColor(android.graphics.Color.parseColor("#FF6B35"))
                gravity = Gravity.CENTER
                typeface = android.graphics.Typeface.DEFAULT_BOLD
                setPadding(0, 0, 0, 16)
            })
            
            // Label de l'alarme
            container.addView(TextView(this@AlarmOverlayService).apply {
                text = label
                textSize = 20f
                setTextColor(android.graphics.Color.parseColor("#333333"))
                gravity = Gravity.CENTER
                setPadding(0, 0, 0, 48)
            })
            
            // Heure actuelle
            container.addView(TextView(this@AlarmOverlayService).apply {
                text = java.text.SimpleDateFormat("HH:mm", java.util.Locale.getDefault()).format(java.util.Date())
                textSize = 48f
                setTextColor(android.graphics.Color.parseColor("#FF6B35"))
                gravity = Gravity.CENTER
                typeface = android.graphics.Typeface.DEFAULT_BOLD
                setPadding(0, 0, 0, 64)
            })
            
            // Container pour le slider fonctionnel
            val sliderContainer = FrameLayout(this@AlarmOverlayService).apply {
                layoutParams = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    120
                )
                background = android.graphics.drawable.GradientDrawable().apply {
                    setColor(android.graphics.Color.parseColor("#F0F0F0"))
                    cornerRadius = 60f
                }
                setPadding(16, 16, 16, 16)
            }
            
            // Track de fond pour le slider
            val sliderTrack = View(this@AlarmOverlayService).apply {
                layoutParams = FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.MATCH_PARENT,
                    88
                ).apply {
                    gravity = Gravity.CENTER_VERTICAL
                }
                background = android.graphics.drawable.GradientDrawable().apply {
                    setColor(android.graphics.Color.parseColor("#E0E0E0"))
                    cornerRadius = 44f
                }
            }
            
            // Texte "Slide to dismiss"
            val instructionText = TextView(this@AlarmOverlayService).apply {
                text = "Slide to dismiss >"
                textSize = 16f
                setTextColor(android.graphics.Color.parseColor("#666666"))
                gravity = Gravity.CENTER
                layoutParams = FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.MATCH_PARENT,
                    FrameLayout.LayoutParams.WRAP_CONTENT
                ).apply {
                    gravity = Gravity.CENTER
                }
            }
            
            // Indicateur de progression du slider
            val progressIndicator = View(this@AlarmOverlayService).apply {
                layoutParams = FrameLayout.LayoutParams(
                    0, // Width will be updated dynamically
                    88
                ).apply {
                    gravity = Gravity.CENTER_VERTICAL or Gravity.START
                }
                background = android.graphics.drawable.GradientDrawable().apply {
                    setColor(android.graphics.Color.parseColor("#FFE0D1")) // Orange très clair
                    cornerRadius = 44f
                }
                alpha = 0.7f
            }
            
            // Bouton slider draggable
            val sliderButton = Button(this@AlarmOverlayService).apply {
                text = "→"
                textSize = 24f
                setTextColor(android.graphics.Color.WHITE)
                background = android.graphics.drawable.GradientDrawable().apply {
                    setColor(android.graphics.Color.parseColor("#FF6B35"))
                    cornerRadius = 40f
                }
                layoutParams = FrameLayout.LayoutParams(80, 80).apply {
                    gravity = Gravity.CENTER_VERTICAL or Gravity.START
                    marginStart = 8
                }
                
                // Variables pour le drag
                var isDragging = false
                var startX = 0f
                var currentX = 0f
                
                setOnTouchListener { view, event ->
                    val maxSlideDistance = sliderContainer.width - view.width - 32 // 32 = padding total
                    when (event.action) {
                        MotionEvent.ACTION_DOWN -> {
                            isDragging = true
                            startX = event.rawX
                            currentX = view.x
                            true
                        }
                        
                        MotionEvent.ACTION_MOVE -> {
                            if (isDragging && maxSlideDistance > 0) {
                                val deltaX = event.rawX - startX
                                val newX = (currentX + deltaX).coerceIn(8f, maxSlideDistance.toFloat())
                                
                                view.x = newX
                                
                                // Mettre à jour l'indicateur de progression
                                val progress = if (maxSlideDistance > 8) (newX - 8f) / (maxSlideDistance - 8f) else 0f
                                progressIndicator.layoutParams = (progressIndicator.layoutParams as FrameLayout.LayoutParams).apply {
                                    width = (newX + view.width / 2).toInt()
                                }
                                progressIndicator.requestLayout()
                                
                                // Changer la couleur selon le progrès
                                val alpha = (0.3f + progress * 0.7f).coerceIn(0.3f, 1.0f)
                                progressIndicator.alpha = alpha
                                
                                // Changer le texte selon le progrès
                                val progressPercent = (progress * 100).toInt()
                                when {
                                    progressPercent < 75 -> {
                                        instructionText.text = "Slide to dismiss > ($progressPercent%)"
                                        instructionText.setTextColor(android.graphics.Color.parseColor("#666666"))
                                    }
                                    else -> {
                                        instructionText.text = "Release to dismiss! ($progressPercent%)"
                                        instructionText.setTextColor(android.graphics.Color.parseColor("#FF6B35"))
                                    }
                                }
                            }
                            true
                        }
                        
                        MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                            if (isDragging && maxSlideDistance > 0) {
                                isDragging = false
                                
                                val finalX = view.x
                                val progress = if (maxSlideDistance > 8) (finalX - 8f) / (maxSlideDistance - 8f) else 0f
                                val progressPercent = (progress * 100).toInt()
                                
                                if (progressPercent >= 75) {
                                    // Slider suffisamment glissé - désactiver l'alarme
                                    Log.d("AlarmOverlayService", "Alarm dismissed via slider at $progressPercent%")
                                    
                                    // Animation de validation
                                    view.animate()
                                        .x(maxSlideDistance.toFloat())
                                        .alpha(0f)
                                        .setDuration(200)
                                        .withEndAction {
                                            stopAlarmSound()
                                            stopVibration()
                                            removeOverlay()
                                            stopSelf()
                                        }
                                        .start()
                                    
                                    progressIndicator.animate()
                                        .alpha(1f)
                                        .setDuration(200)
                                        .start()
                                        
                                    instructionText.text = "Alarm dismissed!"
                                    instructionText.setTextColor(android.graphics.Color.parseColor("#4CAF50"))
                                        
                                } else {
                                    // Pas assez glissé - retour à la position initiale
                                    Log.d("AlarmOverlayService", "Slider released at $progressPercent% - not enough")
                                    
                                    view.animate()
                                        .x(8f)
                                        .setDuration(300)
                                        .start()
                                    
                                    progressIndicator.animate()
                                        .alpha(0.3f)
                                        .setDuration(300)
                                        .start()
                                    
                                    progressIndicator.layoutParams = (progressIndicator.layoutParams as FrameLayout.LayoutParams).apply {
                                        width = 0
                                    }
                                    progressIndicator.requestLayout()
                                    
                                    instructionText.text = "Slide to dismiss > (Need 75%)"
                                    instructionText.setTextColor(android.graphics.Color.parseColor("#666666"))
                                }
                            }
                            true
                        }
                        
                        else -> false
                    }
                }
            }
            
            // Assembler le slider
            sliderContainer.addView(sliderTrack)
            sliderContainer.addView(progressIndicator)
            sliderContainer.addView(instructionText)
            sliderContainer.addView(sliderButton)
            
            container.addView(sliderContainer)
            
            // Instructions en bas (sans possibilité de clic)
            container.addView(TextView(this@AlarmOverlayService).apply {
                text = "Use the slider above to dismiss the alarm"
                textSize = 14f
                setTextColor(android.graphics.Color.parseColor("#999999"))
                gravity = Gravity.CENTER
                setPadding(0, 32, 0, 0)
            })
            
            addView(container)
            
            Log.d("AlarmOverlayService", "Modern overlay UI created successfully")
        }
    }
    
    private fun removeOverlay() {
        try {
            overlayView?.let { view ->
                Log.d("AlarmOverlayService", "Removing overlay view...")
                windowManager?.removeView(view)
                overlayView = null
                Log.d("AlarmOverlayService", "Overlay removed successfully")
            }
        } catch (e: Exception) {
            Log.e("AlarmOverlayService", "Error removing overlay: ${e.message}")
        }
    }
    
    override fun onDestroy() {
        super.onDestroy()
        Log.d("AlarmOverlayService", "=== ALARM OVERLAY SERVICE DESTROYED ===")
        stopAlarmSound()
        stopVibration()
        removeOverlay()
    }
    
    override fun onBind(intent: Intent?): IBinder? = null
}
