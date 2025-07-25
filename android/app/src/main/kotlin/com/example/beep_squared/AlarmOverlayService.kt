package com.example.beep_squared

import android.animation.AnimatorSet
import android.animation.ObjectAnimator
import android.animation.ValueAnimator
import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.media.AudioManager
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.Log
import android.util.TypedValue
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import android.view.animation.AccelerateDecelerateInterpolator
import android.view.animation.BounceInterpolator
import android.widget.Button
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.RelativeLayout
import android.widget.TextView
import androidx.core.app.NotificationCompat
import java.text.SimpleDateFormat
import java.util.*

class AlarmOverlayService : Service() {
    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private var mediaPlayer: MediaPlayer? = null
    private val handler = Handler(Looper.getMainLooper())
    private var timeUpdateRunnable: Runnable? = null
    private var pulseAnimator: ValueAnimator? = null
    
    companion object {
        private const val SNOOZE_DURATION_MINUTES = 5
        private const val SNOOZE_NOTIFICATION_CHANNEL_ID = "snooze_notification_channel"
        private const val SNOOZE_NOTIFICATION_ID = 1001
        
        fun showAlarmOverlay(context: Context, alarmId: String, label: String, soundPath: String = "default") {
            val intent = Intent(context, AlarmOverlayService::class.java).apply {
                putExtra("alarmId", alarmId)
                putExtra("label", label)
                putExtra("soundPath", soundPath)
            }
            context.startService(intent)
        }
        
        /**
         * Test method to show a simple notification for debugging
         */
        fun testNotification(context: Context) {
            try {
                val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                
                // Create test channel
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    val testChannel = NotificationChannel(
                        "test_channel",
                        "Test Notifications",
                        NotificationManager.IMPORTANCE_HIGH
                    )
                    notificationManager.createNotificationChannel(testChannel)
                }
                
                val notification = NotificationCompat.Builder(context, "test_channel")
                    .setSmallIcon(android.R.drawable.ic_dialog_info)
                    .setContentTitle("Test Notification")
                    .setContentText("This is a test notification")
                    .setPriority(NotificationCompat.PRIORITY_HIGH)
                    .setAutoCancel(true)
                    .build()
                
                notificationManager.notify(9999, notification)
                Log.d("AlarmOverlayService", "Test notification posted")
                
            } catch (e: Exception) {
                Log.e("AlarmOverlayService", "Error posting test notification", e)
            }
        }
        fun cancelSnoozeNotification(context: Context, alarmId: String) {
            try {
                val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                notificationManager.cancel(SNOOZE_NOTIFICATION_ID)
                Log.d("AlarmOverlayService", "Cancelled snooze notification for alarm: $alarmId")
            } catch (e: Exception) {
                Log.e("AlarmOverlayService", "Error cancelling snooze notification for $alarmId", e)
            }
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
        
        // Create notification channel first to ensure it exists
        createSnoozeNotificationChannel()
        
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
            
            overlayView = createModernOverlayView(alarmId, label)
            
            val layoutParams = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                WindowManager.LayoutParams(
                    WindowManager.LayoutParams.MATCH_PARENT,
                    WindowManager.LayoutParams.MATCH_PARENT,
                    WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
                    WindowManager.LayoutParams.FLAG_FULLSCREEN or
                    WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                    WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON,
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
                    WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON,
                    PixelFormat.TRANSLUCENT
                )
            }
            
            windowManager?.addView(overlayView, layoutParams)
            startEntranceAnimation()
            
        } catch (e: Exception) {
            Log.e("AlarmOverlayService", "Error creating overlay: ${e.message}")
            stopSelf()
        }
    }

    private fun createModernOverlayView(alarmId: String, label: String): View {
        return RelativeLayout(this).apply {
            // Beautiful gradient background with multiple colors
            background = GradientDrawable().apply {
                colors = intArrayOf(
                    Color.parseColor("#0D47A1"), // Deep blue
                    Color.parseColor("#1565C0"), // Blue  
                    Color.parseColor("#1976D2"), // Light blue
                    Color.parseColor("#283593")  // Dark indigo
                )
                orientation = GradientDrawable.Orientation.TL_BR
            }
            
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
            
            // Add floating particles effect container
            addView(createParticlesEffect())
            
            // Main content container
            addView(LinearLayout(this@AlarmOverlayService).apply {
                orientation = LinearLayout.VERTICAL
                gravity = Gravity.CENTER
                layoutParams = RelativeLayout.LayoutParams(
                    RelativeLayout.LayoutParams.MATCH_PARENT,
                    RelativeLayout.LayoutParams.MATCH_PARENT
                ).apply {
                    addRule(RelativeLayout.CENTER_IN_PARENT)
                }
                setPadding(dpToPx(40), dpToPx(80), dpToPx(40), dpToPx(80))
                
                // Animated alarm icon with glow effect
                addView(createAnimatedAlarmIcon())
                
                // Elegant title with custom typography
                addView(createStyledTitle())
                
                // Alarm label with beautiful styling
                addView(createStyledLabel(label))
                
                // Large time display with animation
                addView(createAnimatedTimeDisplay())
                
                // Modern action buttons with slide gestures
                addView(createModernActionButtons(alarmId))
                
                // Slide to dismiss area
                addView(createSlideToDismissArea())
            })
            
            // Add status indicators
            addView(createStatusIndicators())
        }
    }
    
    private fun createParticlesEffect(): View {
        return FrameLayout(this).apply {
            layoutParams = RelativeLayout.LayoutParams(
                RelativeLayout.LayoutParams.MATCH_PARENT,
                RelativeLayout.LayoutParams.MATCH_PARENT
            )
            
            // Add floating particles
            repeat(12) { index ->
                addView(TextView(this@AlarmOverlayService).apply {
                    text = listOf("✦", "✧", "⭐", "◆", "◇")[index % 5]
                    textSize = (8 + index % 6).toFloat()
                    setTextColor(Color.parseColor("#64B5F6"))
                    alpha = 0.3f + (index % 3) * 0.2f
                    
                    layoutParams = FrameLayout.LayoutParams(
                        FrameLayout.LayoutParams.WRAP_CONTENT,
                        FrameLayout.LayoutParams.WRAP_CONTENT
                    ).apply {
                        leftMargin = dpToPx(20 + index * 30)
                        topMargin = dpToPx(50 + index * 40)
                    }
                    
                    // Floating animation
                    post {
                        startFloatingAnimation(index * 300L)
                    }
                })
            }
        }
    }
    
    private fun createAnimatedAlarmIcon(): TextView {
        return TextView(this).apply {
            text = "⏰"
            textSize = 100f
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, dpToPx(20))
            
            // Add shadow/glow effect
            setShadowLayer(20f, 0f, 0f, Color.parseColor("#81C784"))
            
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                gravity = Gravity.CENTER_HORIZONTAL
            }
            
            // Start pulsing animation
            post { startPulseAnimation() }
        }
    }
    
    private fun createStyledTitle(): TextView {
        return TextView(this).apply {
            text = "ALARM"
            textSize = 42f
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
            letterSpacing = 0.15f
            setPadding(0, 0, 0, dpToPx(12))
            
            // Glowing text effect
            setShadowLayer(15f, 0f, 0f, Color.parseColor("#90CAF9"))
            
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                gravity = Gravity.CENTER_HORIZONTAL
            }
        }
    }
    
    private fun createStyledLabel(label: String): TextView {
        return TextView(this).apply {
            text = label
            textSize = 22f
            setTextColor(Color.parseColor("#E3F2FD"))
            gravity = Gravity.CENTER
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.NORMAL)
            setPadding(dpToPx(20), 0, dpToPx(20), dpToPx(32))
            alpha = 0.9f
            
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                gravity = Gravity.CENTER_HORIZONTAL
            }
        }
    }
    
    private fun createAnimatedTimeDisplay(): TextView {
        return TextView(this).apply {
            textSize = 56f
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
            typeface = Typeface.create(Typeface.MONOSPACE, Typeface.BOLD)
            setPadding(0, 0, 0, dpToPx(40))
            
            // Subtle glow
            setShadowLayer(10f, 0f, 0f, Color.parseColor("#42A5F5"))
            
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                gravity = Gravity.CENTER_HORIZONTAL
            }
            
            // Update time every second
            post { startTimeUpdates(this) }
        }
    }
    
    private fun createModernActionButtons(alarmId: String): LinearLayout {
        return LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, dpToPx(32))
            
            // Snooze button
            addView(createStyledButton("SNOOZE", false, Color.parseColor("#FF7043")) {
                snoozeAlarm(alarmId)
            })
            
            // Space
            addView(View(this@AlarmOverlayService).apply {
                layoutParams = LinearLayout.LayoutParams(dpToPx(24), 0)
            })
            
            // Dismiss button
            addView(createStyledButton("DISMISS", true, Color.parseColor("#4CAF50")) {
                dismissAlarmWithAnimation()
            })
        }
    }
    
    private fun createStyledButton(text: String, isPrimary: Boolean, accentColor: Int, onClick: () -> Unit): Button {
        return Button(this).apply {
            this.text = text
            textSize = 16f
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
            
            background = GradientDrawable().apply {
                shape = GradientDrawable.RECTANGLE
                cornerRadius = dpToPx(25).toFloat()
                
                if (isPrimary) {
                    colors = intArrayOf(accentColor, darkenColor(accentColor, 0.2f))
                    orientation = GradientDrawable.Orientation.TOP_BOTTOM
                    setTextColor(Color.WHITE)
                } else {
                    setColor(Color.TRANSPARENT)
                    setStroke(dpToPx(2), accentColor)
                    setTextColor(accentColor)
                }
            }
            
            layoutParams = LinearLayout.LayoutParams(dpToPx(140), dpToPx(50))
            elevation = dpToPx(8).toFloat()
            
            setOnClickListener { button ->
                (button as Button).startButtonAnimation {
                    onClick()
                }
            }
        }
    }
    
    private fun createSlideToDismissArea(): FrameLayout {
        return FrameLayout(this).apply {
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                dpToPx(70)
            )
            
            // Background track
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#1A237E"))
                cornerRadius = dpToPx(35).toFloat()
                alpha = 150
            }
            
            // Instruction text
            addView(TextView(this@AlarmOverlayService).apply {
                text = "← Swipe to dismiss →"
                textSize = 16f
                setTextColor(Color.parseColor("#90CAF9"))
                gravity = Gravity.CENTER
                typeface = Typeface.create(Typeface.DEFAULT, Typeface.ITALIC)
                layoutParams = FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.MATCH_PARENT,
                    FrameLayout.LayoutParams.MATCH_PARENT
                )
                alpha = 0.8f
            })
            
            // Touch handling
            setupSwipeGesture()
        }
    }
    
    private fun createStatusIndicators(): LinearLayout {
        return LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER
            layoutParams = RelativeLayout.LayoutParams(
                RelativeLayout.LayoutParams.WRAP_CONTENT,
                RelativeLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                addRule(RelativeLayout.ALIGN_PARENT_TOP)
                addRule(RelativeLayout.CENTER_HORIZONTAL)
                topMargin = dpToPx(40)
            }
            
            // Sound indicator
            addView(TextView(this@AlarmOverlayService).apply {
                text = "🔊"
                textSize = 24f
                setPadding(dpToPx(16), 0, dpToPx(16), 0)
                alpha = 0.7f
            })
            
            // Time indicator
            addView(TextView(this@AlarmOverlayService).apply {
                text = SimpleDateFormat("dd MMM", Locale.getDefault()).format(Date())
                textSize = 14f
                setTextColor(Color.parseColor("#90CAF9"))
                alpha = 0.8f
            })
        }
    }
    
    // Animation methods
    private fun startEntranceAnimation() {
        overlayView?.let { view ->
            view.alpha = 0f
            view.scaleX = 0.8f
            view.scaleY = 0.8f
            
            view.animate()
                .alpha(1f)
                .scaleX(1f)
                .scaleY(1f)
                .setDuration(600)
                .setInterpolator(BounceInterpolator())
                .start()
        }
    }
    
    private fun TextView.startPulseAnimation() {
        pulseAnimator = ValueAnimator.ofFloat(1f, 1.1f, 1f).apply {
            duration = 1500
            repeatCount = ValueAnimator.INFINITE
            interpolator = AccelerateDecelerateInterpolator()
            addUpdateListener { animation ->
                val scale = animation.animatedValue as Float
                this@startPulseAnimation.scaleX = scale
                this@startPulseAnimation.scaleY = scale
            }
            start()
        }
    }
    
    private fun TextView.startFloatingAnimation(delay: Long) {
        postDelayed({
            val animator = ObjectAnimator.ofFloat(this, "translationY", 0f, -dpToPx(20).toFloat(), 0f)
            animator.duration = (3000 + (0..1000).random()).toLong()
            animator.repeatCount = ObjectAnimator.INFINITE
            animator.interpolator = AccelerateDecelerateInterpolator()
            animator.start()
        }, delay)
    }
    
    private fun startTimeUpdates(timeView: TextView) {
        timeUpdateRunnable = object : Runnable {
            override fun run() {
                timeView.text = SimpleDateFormat("HH:mm:ss", Locale.getDefault()).format(Date())
                handler.postDelayed(this, 1000)
            }
        }
        handler.post(timeUpdateRunnable!!)
    }
    
    private fun FrameLayout.setupSwipeGesture() {
        var startX = 0f
        var startY = 0f
        
        setOnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    startX = event.x
                    startY = event.y
                    alpha = 0.8f
                    true
                }
                MotionEvent.ACTION_MOVE -> {
                    val deltaX = kotlin.math.abs(event.x - startX)
                    val deltaY = kotlin.math.abs(event.y - startY)
                    
                    if (deltaX > deltaY && deltaX > dpToPx(50)) {
                        alpha = 1f - (deltaX / width * 0.5f)
                        
                        if (deltaX > width * 0.6f) {
                            dismissAlarmWithAnimation()
                            return@setOnTouchListener true
                        }
                    }
                    true
                }
                MotionEvent.ACTION_UP -> {
                    this.animate().alpha(1f).setDuration(200).start()
                    false
                }
                else -> false
            }
        }
    }
    
    private fun Button.startButtonAnimation(onComplete: () -> Unit) {
        this.animate()
            .scaleX(0.95f)
            .scaleY(0.95f)
            .setDuration(100)
            .withEndAction {
                this.animate()
                    .scaleX(1f)
                    .scaleY(1f)
                    .setDuration(100)
                    .withEndAction { onComplete() }
                    .start()
            }
            .start()
    }
    
    private fun dismissAlarmWithAnimation() {
        overlayView?.animate()
            ?.alpha(0f)
            ?.scaleX(0.8f)
            ?.scaleY(0.8f)
            ?.setDuration(300)
            ?.withEndAction {
                dismissAlarm()
            }
            ?.start()
    }
    
    // Snooze functionality
    private fun snoozeAlarm(alarmId: String) {
        Log.d("AlarmOverlayService", "Snoozing alarm: $alarmId")
        
        // Calculate snooze time
        val snoozeTime = Calendar.getInstance().apply {
            add(Calendar.MINUTE, SNOOZE_DURATION_MINUTES)
        }
        
        Log.d("AlarmOverlayService", "Snooze time calculated: ${snoozeTime.time}")
        
        // Show snooze notification
        showSnoozeNotification(snoozeTime.time)
        
        // Schedule snooze alarm
        scheduleSnoozeAlarm(alarmId, snoozeTime.timeInMillis)
        
        // Dismiss current alarm with animation
        dismissAlarmWithAnimation()
    }
    
    private fun showSnoozeNotification(snoozeTime: Date) {
        try {
            createSnoozeNotificationChannel()
            
            val timeFormat = SimpleDateFormat("HH:mm", Locale.getDefault())
            val snoozeTimeString = timeFormat.format(snoozeTime)
            
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            
            // Check if notifications are enabled
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N && !notificationManager.areNotificationsEnabled()) {
                Log.w("AlarmOverlayService", "Notifications are disabled by user")
                return
            }
            
            // Create notification with higher priority and better visibility
            val notification = NotificationCompat.Builder(this, SNOOZE_NOTIFICATION_CHANNEL_ID)
                .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
                .setContentTitle("⏰ Alarm Snoozed")
                .setContentText("Next alarm: $snoozeTimeString (in $SNOOZE_DURATION_MINUTES min)")
                .setStyle(NotificationCompat.BigTextStyle()
                    .bigText("Your alarm has been snoozed for $SNOOZE_DURATION_MINUTES minutes.\n\nNext alarm will ring at: $snoozeTimeString"))
                .setPriority(NotificationCompat.PRIORITY_HIGH) // Changed to HIGH priority
                .setCategory(NotificationCompat.CATEGORY_ALARM)
                .setAutoCancel(true)
                .setOngoing(false) // Make it dismissible
                .setShowWhen(true)
                .setWhen(snoozeTime.time)
                .setColor(Color.parseColor("#1565C0"))
                .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                .setDefaults(NotificationCompat.DEFAULT_LIGHTS) // Add lights
                .setLights(Color.parseColor("#1565C0"), 1000, 1000) // Blue light blink
                .build()
            
            notificationManager.notify(SNOOZE_NOTIFICATION_ID, notification)
            
            Log.d("AlarmOverlayService", "Snooze notification created and posted for: $snoozeTimeString")
            Log.d("AlarmOverlayService", "Notification ID: $SNOOZE_NOTIFICATION_ID, Channel: $SNOOZE_NOTIFICATION_CHANNEL_ID")
            
        } catch (e: Exception) {
            Log.e("AlarmOverlayService", "Error showing snooze notification", e)
        }
    }
    
    private fun createSnoozeNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager = getSystemService(NotificationManager::class.java)
            
            // Check if channel already exists
            val existingChannel = notificationManager.getNotificationChannel(SNOOZE_NOTIFICATION_CHANNEL_ID)
            if (existingChannel != null) {
                Log.d("AlarmOverlayService", "Notification channel already exists")
                return
            }
            
            val channel = NotificationChannel(
                SNOOZE_NOTIFICATION_CHANNEL_ID,
                "Snooze Notifications",
                NotificationManager.IMPORTANCE_HIGH // Changed to HIGH importance
            ).apply {
                description = "Notifications shown when alarms are snoozed"
                enableLights(true)
                lightColor = Color.parseColor("#1565C0")
                enableVibration(false) // No vibration for snooze notifications
                setShowBadge(true)
                lockscreenVisibility = NotificationCompat.VISIBILITY_PUBLIC
                
                // Make sure the channel allows notifications
                setBypassDnd(false)
                canBypassDnd()
            }
            
            notificationManager.createNotificationChannel(channel)
            Log.d("AlarmOverlayService", "Snooze notification channel created with HIGH importance")
        } else {
            Log.d("AlarmOverlayService", "Android version < O, no channel needed")
        }
    }
    
    private fun scheduleSnoozeAlarm(alarmId: String, snoozeTimeMillis: Long) {
        try {
            val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
            
            // Create intent for snooze alarm
            val snoozeIntent = Intent(this, AlarmReceiver::class.java).apply {
                putExtra(AlarmConfig.EXTRA_ALARM_ID, "${alarmId}_snooze")
                putExtra(AlarmConfig.EXTRA_LABEL, "Snoozed Alarm")
                putExtra(AlarmConfig.EXTRA_SOUND_PATH, "default")
                action = "SNOOZE_ALARM_TRIGGER"
            }
            
            val pendingIntent = PendingIntent.getBroadcast(
                this,
                alarmId.hashCode() + 1000, // Unique ID for snooze
                snoozeIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            
            // Schedule exact alarm for snooze
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    snoozeTimeMillis,
                    pendingIntent
                )
            } else {
                alarmManager.setExact(
                    AlarmManager.RTC_WAKEUP,
                    snoozeTimeMillis,
                    pendingIntent
                )
            }
            
            Log.d("AlarmOverlayService", "Snooze alarm scheduled for: ${Date(snoozeTimeMillis)}")
            
        } catch (e: Exception) {
            Log.e("AlarmOverlayService", "Error scheduling snooze alarm: ${e.message}")
        }
    }
    
    // Utility functions
    private fun darkenColor(color: Int, factor: Float): Int {
        val a = Color.alpha(color)
        val r = (Color.red(color) * (1 - factor)).toInt()
        val g = (Color.green(color) * (1 - factor)).toInt()
        val b = (Color.blue(color) * (1 - factor)).toInt()
        return Color.argb(a, r, g, b)
    }
    
    private fun dismissAlarm() {
        stopAlarmSound()
        stopAnimations()
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
    
    private fun stopAnimations() {
        pulseAnimator?.cancel()
        timeUpdateRunnable?.let { handler.removeCallbacks(it) }
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
        stopAnimations()
        removeOverlay()
    }
    
    override fun onBind(intent: Intent?): IBinder? = null
}
