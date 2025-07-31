package com.example.beep_squared

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
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.Button
import android.widget.GridLayout
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.app.NotificationCompat
import java.text.SimpleDateFormat
import java.util.*
import kotlin.random.Random

/**
 * Modern Alarm Overlay Service - Completely rewritten for better UI and math challenges
 */
class AlarmOverlayService : Service() {
    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private var mediaPlayer: MediaPlayer? = null
    private val handler = Handler(Looper.getMainLooper())
    private var timeUpdateRunnable: Runnable? = null

    // Math challenge components
    private var currentAnswer: Int = 0
    private var userInput: String = ""
    private var mathQuestionText: TextView? = null
    private var mathInputText: TextView? = null
    private var dismissButton: Button? = null
    
    // Store current math settings for random button
    private var currentMathDifficulty: String = "easy"
    private var currentMathOperations: String = "mixed"
    
    // Store current alarm settings for snooze
    private var currentAlarmId: String = ""
    private var currentLabel: String = ""
    private var currentUnlockMethod: String = "simple"

    companion object {
        private const val SNOOZE_DURATION_MINUTES = 5
        const val SNOOZE_NOTIFICATION_CHANNEL_ID = "snooze_notification_channel"
        const val SNOOZE_NOTIFICATION_ID = 1001

        fun showAlarmOverlay(
            context: Context,
            alarmId: String,
            label: String,
            soundPath: String = "default",
            unlockMethod: String = "simple",
            mathDifficulty: String = "easy",
            mathOperations: String = "mixed"
        ) {
            val intent = Intent(context, AlarmOverlayService::class.java).apply {
                putExtra("alarmId", alarmId)
                putExtra("label", label)
                putExtra("soundPath", soundPath)
                putExtra("unlockMethod", unlockMethod)
                putExtra("mathDifficulty", mathDifficulty)
                putExtra("mathOperations", mathOperations)
            }
            context.startService(intent)
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
        Log.d("AlarmOverlayService", "Modern Service created")
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d("AlarmOverlayService", "Modern Service started")

        currentAlarmId = intent?.getStringExtra("alarmId") ?: "unknown"
        currentLabel = intent?.getStringExtra("label") ?: "Alarm"
        currentUnlockMethod = intent?.getStringExtra("unlockMethod") ?: "simple"
        currentMathDifficulty = intent?.getStringExtra("mathDifficulty") ?: "easy"
        currentMathOperations = intent?.getStringExtra("mathOperations") ?: "mixed"

        createSnoozeNotificationChannel()
        startAlarmSound()
        showModernAlarmOverlay(currentAlarmId, currentLabel, currentUnlockMethod, currentMathDifficulty, currentMathOperations)

        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

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
            Log.d("AlarmOverlayService", "Alarm sound started")
        } catch (e: Exception) {
            Log.e("AlarmOverlayService", "Error starting alarm sound: ${e.message}")
        }
    }

    private fun showModernAlarmOverlay(
        alarmId: String,
        label: String,
        unlockMethod: String,
        mathDifficulty: String,
        mathOperations: String
    ) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                if (!android.provider.Settings.canDrawOverlays(this)) {
                    Log.e("AlarmOverlayService", "No overlay permission")
                    stopSelf()
                    return
                }
            }

            overlayView = createModernAlarmView(alarmId, label, unlockMethod, mathDifficulty, mathOperations)

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
            Log.d("AlarmOverlayService", "Modern overlay view added to window")

        } catch (e: Exception) {
            Log.e("AlarmOverlayService", "Error creating modern overlay: ${e.message}")
            stopSelf()
        }
    }

    private fun createModernAlarmView(
        alarmId: String,
        label: String,
        unlockMethod: String,
        mathDifficulty: String,
        mathOperations: String
    ): View {
        return LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )

            // Modern gradient background
            background = GradientDrawable().apply {
                colors = intArrayOf(
                    Color.parseColor("#0D47A1"), // Deep blue
                    Color.parseColor("#1565C0"), // Medium blue
                    Color.parseColor("#1976D2")  // Light blue
                )
                orientation = GradientDrawable.Orientation.TOP_BOTTOM
            }

            setPadding(dpToPx(20), dpToPx(20), dpToPx(20), dpToPx(20))
            gravity = Gravity.CENTER

            // Header Section
            addView(createHeaderSection(label))

            // Time Display
            addView(createTimeDisplay())

            // Math Challenge or Simple Dismiss
            if (unlockMethod == "math") {
                addView(createMathChallengeSection(mathDifficulty, mathOperations, alarmId))
            } else {
                addView(createSimpleDismissSection(alarmId))
            }
        }
    }

    private fun createHeaderSection(label: String): LinearLayout {
        return LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, dpToPx(8))

            // Alarm Icon
            addView(TextView(this@AlarmOverlayService).apply {
                text = "⏰"
                textSize = 36f
                setTextColor(Color.WHITE)
                gravity = Gravity.CENTER
                layoutParams = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                ).apply {
                    bottomMargin = dpToPx(4)
                }
            })

            // Title
            addView(TextView(this@AlarmOverlayService).apply {
                text = "ALARM"
                textSize = 20f
                setTextColor(Color.WHITE)
                gravity = Gravity.CENTER
                typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
                layoutParams = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                ).apply {
                    bottomMargin = dpToPx(2)
                }
            })

            // Label
            addView(TextView(this@AlarmOverlayService).apply {
                text = label
                textSize = 14f
                setTextColor(Color.parseColor("#E3F2FD"))
                gravity = Gravity.CENTER
                layoutParams = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                )
            })
        }
    }

    private fun createTimeDisplay(): TextView {
        return TextView(this).apply {
            textSize = 26f
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
            typeface = Typeface.create(Typeface.MONOSPACE, Typeface.BOLD)
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                bottomMargin = dpToPx(16)
            }

            // Start time updates
            startTimeUpdates()
        }
    }

    private fun createMathChallengeSection(
        mathDifficulty: String,
        mathOperations: String,
        alarmId: String
    ): LinearLayout {
        // Store current settings for random button
        currentMathDifficulty = mathDifficulty
        currentMathOperations = mathOperations
        
        return LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setPadding(dpToPx(12), dpToPx(12), dpToPx(12), dpToPx(12))

            // Background card
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#1A237E"))
                cornerRadius = dpToPx(16).toFloat()
                setStroke(dpToPx(2), Color.parseColor("#3F51B5"))
            }

            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                bottomMargin = dpToPx(8)
            }

            // Math Challenge Title
            addView(TextView(this@AlarmOverlayService).apply {
                text = "Solve to dismiss alarm"
                textSize = 12f
                setTextColor(Color.parseColor("#BBDEFB"))
                gravity = Gravity.CENTER
                layoutParams = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                ).apply {
                    bottomMargin = dpToPx(8)
                }
            })

            // Math Question
            mathQuestionText = TextView(this@AlarmOverlayService).apply {
                textSize = 20f
                setTextColor(Color.WHITE)
                gravity = Gravity.CENTER
                typeface = Typeface.create(Typeface.MONOSPACE, Typeface.BOLD)
                layoutParams = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                ).apply {
                    bottomMargin = dpToPx(10)
                }
            }
            addView(mathQuestionText)

            // User Input Display
            mathInputText = TextView(this@AlarmOverlayService).apply {
                text = "Enter answer: _"
                textSize = 16f
                setTextColor(Color.parseColor("#64B5F6"))
                gravity = Gravity.CENTER
                background = GradientDrawable().apply {
                    setColor(Color.parseColor("#0D47A1"))
                    cornerRadius = dpToPx(8).toFloat()
                }
                setPadding(dpToPx(12), dpToPx(8), dpToPx(12), dpToPx(8))
                layoutParams = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                ).apply {
                    bottomMargin = dpToPx(12)
                }
            }
            addView(mathInputText)

            // Number Keypad
            addView(createNumberKeypad())

            // Action Buttons Row 1: Random & Clear
            addView(LinearLayout(this@AlarmOverlayService).apply {
                orientation = LinearLayout.HORIZONTAL
                gravity = Gravity.CENTER
                layoutParams = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                ).apply {
                    bottomMargin = dpToPx(8)
                }
                
                // Random Button (dice)
                addView(createActionButton("🎲", Color.parseColor("#9C27B0")) {
                    generateMathChallenge(currentMathDifficulty, currentMathOperations)
                    clearInput()
                })

                // Space
                addView(View(this@AlarmOverlayService).apply {
                    layoutParams = LinearLayout.LayoutParams(dpToPx(16), 0)
                })

                // Clear Button
                addView(createActionButton("CLEAR", Color.parseColor("#F44336")) {
                    clearInput()
                })
            })

            // Action Buttons Row 2: Validate & Snooze
            addView(LinearLayout(this@AlarmOverlayService).apply {
                orientation = LinearLayout.HORIZONTAL
                gravity = Gravity.CENTER
                
                // Validate Button
                dismissButton = createActionButton("VALIDATE", Color.parseColor("#4CAF50")) {
                    checkAnswer(alarmId)
                }
                dismissButton?.isEnabled = false
                addView(dismissButton)

                // Space
                addView(View(this@AlarmOverlayService).apply {
                    layoutParams = LinearLayout.LayoutParams(dpToPx(16), 0)
                })

                // Snooze Button
                addView(createActionButton("SNOOZE", Color.parseColor("#FF7043")) {
                    snoozeAlarm(alarmId)
                })
            })

            // Generate first math challenge
            generateMathChallenge(mathDifficulty, mathOperations)
        }
    }

    private fun createNumberKeypad(): GridLayout {
        return GridLayout(this).apply {
            rowCount = 4
            columnCount = 3
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                gravity = Gravity.CENTER_HORIZONTAL
                bottomMargin = dpToPx(8)
            }

            // Create number buttons 1-9, 0
            val numbers = listOf("1", "2", "3", "4", "5", "6", "7", "8", "9", "", "0", "⌫")
            
            numbers.forEach { number ->
                if (number.isEmpty()) {
                    // Empty space
                    addView(View(this@AlarmOverlayService).apply {
                        layoutParams = GridLayout.LayoutParams().apply {
                            width = dpToPx(70)   // Increased from 56 to match button size
                            height = dpToPx(70)  // Increased from 56 to match button size
                            setMargins(dpToPx(4), dpToPx(4), dpToPx(4), dpToPx(4))  // Match button margins
                        }
                    })
                } else {
                    addView(createKeypadButton(number))
                }
            }
        }
    }

    private fun createKeypadButton(text: String): Button {
        return Button(this).apply {
            this.text = text
            textSize = 24f  // Increased from 20f for better readability
            setTextColor(Color.WHITE)
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
            
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#283593"))
                cornerRadius = dpToPx(8).toFloat()
                setStroke(dpToPx(1), Color.parseColor("#3F51B5"))
            }
            
            layoutParams = GridLayout.LayoutParams().apply {
                width = dpToPx(70)   // Increased from 50 for bigger buttons
                height = dpToPx(70)  // Increased from 50 for bigger buttons
                setMargins(dpToPx(4), dpToPx(4), dpToPx(4), dpToPx(4))  // Slightly increased margins
            }

            setOnClickListener {
                when (text) {
                    "⌫" -> backspaceInput()
                    else -> addToInput(text)
                }
            }
        }
    }

    private fun createActionButton(text: String, color: Int, onClick: () -> Unit): Button {
        return Button(this).apply {
            this.text = text
            textSize = 16f
            setTextColor(Color.WHITE)
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
            
            background = GradientDrawable().apply {
                setColor(color)
                cornerRadius = dpToPx(12).toFloat()
            }

            layoutParams = LinearLayout.LayoutParams(
                dpToPx(120),
                dpToPx(48)
            )

            setOnClickListener { onClick() }
        }
    }

    private fun createSimpleDismissSection(alarmId: String): LinearLayout {
        return LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setPadding(dpToPx(20), dpToPx(20), dpToPx(20), dpToPx(20))
            
            // Background card
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#1A237E"))
                cornerRadius = dpToPx(16).toFloat()
                setStroke(dpToPx(2), Color.parseColor("#3F51B5"))
            }

            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                bottomMargin = dpToPx(16)
            }
            
            // Title
            addView(TextView(this@AlarmOverlayService).apply {
                text = "Slide to dismiss alarm"
                textSize = 16f
                setTextColor(Color.parseColor("#BBDEFB"))
                gravity = Gravity.CENTER
                layoutParams = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                ).apply {
                    bottomMargin = dpToPx(20)
                }
            })

            // Slider Container
            addView(createSliderContainer(alarmId))
            
            // Space between slider and snooze button
            addView(View(this@AlarmOverlayService).apply {
                layoutParams = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    dpToPx(20)
                )
            })

            // Snooze Button
            addView(createSnoozeButton(alarmId))
        }
    }

    private fun createSliderContainer(alarmId: String): LinearLayout {
        return LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            setPadding(dpToPx(4), dpToPx(4), dpToPx(4), dpToPx(4))
            
            // Slider track background
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#0D47A1"))
                cornerRadius = dpToPx(30).toFloat()
                setStroke(dpToPx(2), Color.parseColor("#1976D2"))
            }
            
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                dpToPx(64)
            ).apply {
                bottomMargin = dpToPx(8)
            }

            // Create slider track with animated button
            addView(createInteractiveSlider(alarmId))
        }
    }

    private fun createInteractiveSlider(alarmId: String): LinearLayout {
        return LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.MATCH_PARENT
            )

            // Slider track with touch handling
            val sliderTrack = LinearLayout(this@AlarmOverlayService).apply {
                orientation = LinearLayout.HORIZONTAL
                gravity = Gravity.CENTER_VERTICAL or Gravity.LEFT
                setPadding(dpToPx(8), 0, dpToPx(8), 0)
                layoutParams = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.MATCH_PARENT
                )
            }

            // Draggable slider button (positioned at LEFT, slides to RIGHT)
            val sliderButton = TextView(this@AlarmOverlayService).apply {
                text = "➤"
                textSize = 24f
                setTextColor(Color.WHITE)
                gravity = Gravity.CENTER
                background = GradientDrawable().apply {
                    colors = intArrayOf(
                        Color.parseColor("#4CAF50"),
                        Color.parseColor("#66BB6A")
                    )
                    orientation = GradientDrawable.Orientation.LEFT_RIGHT
                    cornerRadius = dpToPx(26).toFloat()
                    setStroke(dpToPx(2), Color.parseColor("#81C784"))
                }
                layoutParams = LinearLayout.LayoutParams(
                    dpToPx(56),
                    dpToPx(56)
                ).apply {
                    leftMargin = dpToPx(4)  // Start from left
                }
            }

            // Right section with text (takes remaining space)
            val rightSection = LinearLayout(this@AlarmOverlayService).apply {
                orientation = LinearLayout.HORIZONTAL
                gravity = Gravity.CENTER_VERTICAL
                setPadding(dpToPx(16), 0, dpToPx(16), 0)
                layoutParams = LinearLayout.LayoutParams(
                    0,
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    1f
                )

                // Text only (no icon)
                addView(TextView(this@AlarmOverlayService).apply {
                    text = "Slide to dismiss"
                    textSize = 14f
                    setTextColor(Color.parseColor("#64B5F6"))
                    gravity = Gravity.CENTER
                    typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
                    layoutParams = LinearLayout.LayoutParams(
                        LinearLayout.LayoutParams.MATCH_PARENT,
                        LinearLayout.LayoutParams.WRAP_CONTENT
                    )
                })
            }

            // Add button first (left), then text section (right)
            sliderTrack.addView(sliderButton)
            sliderTrack.addView(rightSection)
            addView(sliderTrack)

            // Implement touch sliding functionality
            setupSliderTouchHandling(sliderTrack, sliderButton, alarmId)
        }
    }

    private fun setupSliderTouchHandling(
        sliderTrack: LinearLayout, 
        sliderButton: TextView, 
        alarmId: String
    ) {
        var initialX = 0f
        var initialTouchX = 0f
        val slideThreshold = dpToPx(150) // Minimum slide distance to trigger
        
        sliderButton.setOnTouchListener { view, event ->
            when (event.action) {
                android.view.MotionEvent.ACTION_DOWN -> {
                    initialX = view.x
                    initialTouchX = event.rawX
                    
                    // Visual feedback - slight scale
                    view.animate()
                        .scaleX(1.05f)
                        .scaleY(1.05f)
                        .setDuration(100)
                    
                    Log.d("AlarmOverlayService", "Slider touch DOWN at: $initialTouchX, view.x: $initialX")
                    true
                }
                
                android.view.MotionEvent.ACTION_MOVE -> {
                    val deltaX = event.rawX - initialTouchX
                    val trackWidth = sliderTrack.width
                    val buttonWidth = view.width
                    val maxSlideDistance = trackWidth - buttonWidth - dpToPx(16) // Account for padding
                    
                    // Ensure we have valid dimensions
                    if (trackWidth > 0 && buttonWidth > 0) {
                        // Only allow rightward movement (positive deltaX)
                        val newX = Math.max(0f, Math.min(deltaX, maxSlideDistance.toFloat()))
                        view.x = initialX + newX
                        
                        // Calculate slide progress
                        val slideProgress = if (maxSlideDistance > 0) newX / maxSlideDistance else 0f
                        
                        Log.d("AlarmOverlayService", "Slider MOVE: deltaX=$deltaX, newX=$newX, progress=$slideProgress, maxDistance=$maxSlideDistance")
                        
                        // Change button appearance as it slides
                        if (slideProgress > 0.6f) {
                            // Near completion - change to success color
                            view.background = GradientDrawable().apply {
                                colors = intArrayOf(
                                    Color.parseColor("#2E7D32"),
                                    Color.parseColor("#4CAF50")
                                )
                                orientation = GradientDrawable.Orientation.LEFT_RIGHT
                                cornerRadius = dpToPx(26).toFloat()
                                setStroke(dpToPx(2), Color.parseColor("#66BB6A"))
                            }
                            (view as TextView).text = "✓"
                        } else {
                            // Normal state
                            view.background = GradientDrawable().apply {
                                colors = intArrayOf(
                                    Color.parseColor("#4CAF50"),
                                    Color.parseColor("#66BB6A")
                                )
                                orientation = GradientDrawable.Orientation.LEFT_RIGHT
                                cornerRadius = dpToPx(26).toFloat()
                                setStroke(dpToPx(2), Color.parseColor("#81C784"))
                            }
                            (view as TextView).text = "➤"
                        }
                    }
                    true
                }
                
                android.view.MotionEvent.ACTION_UP, android.view.MotionEvent.ACTION_CANCEL -> {
                    val deltaX = event.rawX - initialTouchX
                    
                    Log.d("AlarmOverlayService", "Slider touch UP: deltaX=$deltaX, threshold=$slideThreshold")
                    
                    // Reset scale
                    view.animate()
                        .scaleX(1f)
                        .scaleY(1f)
                        .setDuration(100)
                    
                    if (deltaX >= slideThreshold) {
                        // Slide completed - dismiss alarm
                        Log.d("AlarmOverlayService", "Slider threshold reached - dismissing alarm")
                        view.animate()
                            .x(sliderTrack.width - view.width - dpToPx(8).toFloat())
                            .setDuration(200)
                            .withEndAction {
                                dismissAlarm(alarmId)
                            }
                    } else {
                        // Slide not completed - snap back to left position
                        Log.d("AlarmOverlayService", "Slider threshold not reached - snapping back")
                        view.animate()
                            .x(dpToPx(4).toFloat()) // Back to left position
                            .setDuration(300)
                            .withEndAction {
                                // Reset appearance
                                view.background = GradientDrawable().apply {
                                    colors = intArrayOf(
                                        Color.parseColor("#4CAF50"),
                                        Color.parseColor("#66BB6A")
                                    )
                                    orientation = GradientDrawable.Orientation.LEFT_RIGHT
                                    cornerRadius = dpToPx(26).toFloat()
                                    setStroke(dpToPx(2), Color.parseColor("#81C784"))
                                }
                                (view as TextView).text = "➤"
                            }
                    }
                    true
                }
                
                else -> false
            }
        }
        
        // Add fallback click functionality for testing
        sliderButton.setOnClickListener {
            Log.d("AlarmOverlayService", "Slider button clicked - dismissing alarm (fallback)")
            dismissAlarm(alarmId)
        }
    }

    private fun createSnoozeButton(alarmId: String): Button {
        return Button(this).apply {
            text = "💤 SNOOZE ($SNOOZE_DURATION_MINUTES MIN)"
            textSize = 16f
            setTextColor(Color.WHITE)
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
            
            background = GradientDrawable().apply {
                colors = intArrayOf(
                    Color.parseColor("#FF7043"),
                    Color.parseColor("#FF8A65")
                )
                orientation = GradientDrawable.Orientation.LEFT_RIGHT
                cornerRadius = dpToPx(12).toFloat()
                setStroke(dpToPx(2), Color.parseColor("#FFAB91"))
            }

            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                dpToPx(56)
            )

            // Add press animation
            setOnClickListener {
                animate()
                    .scaleX(0.95f)
                    .scaleY(0.95f)
                    .setDuration(100)
                    .withEndAction {
                        animate()
                            .scaleX(1f)
                            .scaleY(1f)
                            .setDuration(100)
                            .withEndAction {
                                snoozeAlarm(alarmId)
                            }
                    }
            }
        }
    }

    private fun createSnoozeSection(alarmId: String): LinearLayout {
        return LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setPadding(0, dpToPx(12), 0, 0)

            addView(createActionButton("SNOOZE ($SNOOZE_DURATION_MINUTES MIN)", Color.parseColor("#FF7043")) {
                snoozeAlarm(alarmId)
            })
        }
    }

    // Math Challenge Logic
    private fun generateMathChallenge(difficulty: String, operations: String) {
        val (question, answer) = when (operations) {
            "additionOnly" -> generateAddition(difficulty)
            "subtractionOnly" -> generateSubtraction(difficulty)
            "multiplicationOnly" -> generateMultiplication(difficulty)
            "mixed" -> generateMixed(difficulty)
            else -> generateMixed(difficulty)
        }

        currentAnswer = answer
        mathQuestionText?.text = question
        Log.d("AlarmOverlayService", "Generated math challenge: $question = $answer")
    }

    private fun generateAddition(difficulty: String): Pair<String, Int> {
        return when (difficulty) {
            "easy" -> {
                val a = Random.nextInt(10, 50)
                val b = Random.nextInt(10, 50)
                Pair("$a + $b = ?", a + b)
            }
            "medium" -> {
                val a = Random.nextInt(20, 100)
                val b = Random.nextInt(20, 100)
                Pair("$a + $b = ?", a + b)
            }
            "hard" -> {
                val a = Random.nextInt(100, 500)
                val b = Random.nextInt(100, 500)
                Pair("$a + $b = ?", a + b)
            }
            else -> generateAddition("easy")
        }
    }

    private fun generateSubtraction(difficulty: String): Pair<String, Int> {
        return when (difficulty) {
            "easy" -> {
                val a = Random.nextInt(20, 60)
                val b = Random.nextInt(10, a)
                Pair("$a - $b = ?", a - b)
            }
            "medium" -> {
                val a = Random.nextInt(50, 150)
                val b = Random.nextInt(20, a)
                Pair("$a - $b = ?", a - b)
            }
            "hard" -> {
                val a = Random.nextInt(200, 800)
                val b = Random.nextInt(100, a)
                Pair("$a - $b = ?", a - b)
            }
            else -> generateSubtraction("easy")
        }
    }

    private fun generateMultiplication(difficulty: String): Pair<String, Int> {
        return when (difficulty) {
            "easy" -> {
                val a = Random.nextInt(2, 12)
                val b = Random.nextInt(2, 12)
                Pair("$a × $b = ?", a * b)
            }
            "medium" -> {
                val a = Random.nextInt(5, 20)
                val b = Random.nextInt(5, 20)
                Pair("$a × $b = ?", a * b)
            }
            "hard" -> {
                val a = Random.nextInt(10, 30)
                val b = Random.nextInt(10, 30)
                Pair("$a × $b = ?", a * b)
            }
            else -> generateMultiplication("easy")
        }
    }

    private fun generateMixed(difficulty: String): Pair<String, Int> {
        return when (Random.nextInt(3)) {
            0 -> generateAddition(difficulty)
            1 -> generateSubtraction(difficulty)
            2 -> generateMultiplication(difficulty)
            else -> generateAddition(difficulty)
        }
    }

    // Input handling
    private fun addToInput(digit: String) {
        if (userInput.length < 6) { // Limit input length
            userInput += digit
            updateInputDisplay()
        }
    }

    private fun backspaceInput() {
        if (userInput.isNotEmpty()) {
            userInput = userInput.dropLast(1)
            updateInputDisplay()
        }
    }

    private fun clearInput() {
        userInput = ""
        updateInputDisplay()
    }

    private fun updateInputDisplay() {
        val displayText = if (userInput.isEmpty()) {
            "Enter answer: _"
        } else {
            "Answer: $userInput"
        }
        mathInputText?.text = displayText
        dismissButton?.isEnabled = userInput.isNotEmpty()
    }

    private fun checkAnswer(alarmId: String) {
        try {
            val userAnswer = userInput.toInt()
            if (userAnswer == currentAnswer) {
                dismissAlarm(alarmId)
            } else {
                // Wrong answer - clear input and generate new challenge
                userInput = ""
                updateInputDisplay()
                mathQuestionText?.text = "Wrong! Try again..."
                handler.postDelayed({
                    generateMathChallenge("easy", "mixed") // Reset to easier challenge
                }, 1000)
            }
        } catch (e: NumberFormatException) {
            clearInput()
        }
    }

    // Alarm Actions
    private fun dismissAlarm(alarmId: String) {
        Log.d("AlarmOverlayService", "Dismissing alarm: $alarmId")
        stopAlarmAndCleanup()
    }

    private fun snoozeAlarm(alarmId: String) {
        Log.d("AlarmOverlayService", "Snoozing alarm: $alarmId")
        
        // Schedule snooze alarm
        val snoozeTime = System.currentTimeMillis() + (SNOOZE_DURATION_MINUTES * 60 * 1000)
        scheduleSnoozeAlarm(alarmId, snoozeTime)
        
        // Show snooze notification
        showSnoozeNotification(alarmId, snoozeTime)
        
        stopAlarmAndCleanup()
    }

    // Utility methods
    private fun startTimeUpdates() {
        timeUpdateRunnable = object : Runnable {
            override fun run() {
                val timeFormat = SimpleDateFormat("HH:mm:ss", Locale.getDefault())
                val currentTime = timeFormat.format(Date())
                (overlayView?.findViewById<TextView>(android.R.id.text1) ?: 
                 overlayView?.let { findTimeTextView(it) })?.text = currentTime
                handler.postDelayed(this, 1000)
            }
        }
        handler.post(timeUpdateRunnable!!)
    }

    private fun findTimeTextView(view: View): TextView? {
        if (view is TextView && view.textSize > 40f) {
            return view
        }
        if (view is ViewGroup) {
            for (i in 0 until view.childCount) {
                val result = findTimeTextView(view.getChildAt(i))
                if (result != null) return result
            }
        }
        return null
    }

    private fun dpToPx(dp: Int): Int {
        return TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP,
            dp.toFloat(),
            resources.displayMetrics
        ).toInt()
    }

    private fun createSnoozeNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                SNOOZE_NOTIFICATION_CHANNEL_ID,
                "Snooze Notifications",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Notifications for snoozed alarms"
                enableLights(true)
                lightColor = Color.BLUE
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 250, 250, 250)
            }

            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun scheduleSnoozeAlarm(alarmId: String, snoozeTime: Long) {
        try {
            val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val intent = Intent(this, AlarmOverlayService::class.java).apply {
                putExtra("alarmId", alarmId)
                putExtra("label", currentLabel)
                putExtra("unlockMethod", currentUnlockMethod)
                putExtra("mathDifficulty", currentMathDifficulty)
                putExtra("mathOperations", currentMathOperations)
            }
            
            val pendingIntent = PendingIntent.getService(
                this, 
                alarmId.hashCode(), 
                intent, 
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, snoozeTime, pendingIntent)
            } else {
                alarmManager.setExact(AlarmManager.RTC_WAKEUP, snoozeTime, pendingIntent)
            }

            Log.d("AlarmOverlayService", "Snooze alarm scheduled for: ${Date(snoozeTime)} with unlock method: $currentUnlockMethod")
        } catch (e: Exception) {
            Log.e("AlarmOverlayService", "Error scheduling snooze alarm", e)
        }
    }

    private fun showSnoozeNotification(alarmId: String, snoozeTime: Long) {
        try {
            val timeFormat = SimpleDateFormat("HH:mm", Locale.getDefault())
            val snoozeTimeString = timeFormat.format(Date(snoozeTime))

            // Create cancel snooze action
            val cancelSnoozeIntent = Intent(this, AlarmActionReceiver::class.java).apply {
                action = AlarmConfig.ACTION_CANCEL_SNOOZE
                putExtra(AlarmConfig.EXTRA_ALARM_ID, alarmId)
            }
            val cancelSnoozePendingIntent = PendingIntent.getBroadcast(
                this,
                alarmId.hashCode() + 1000, // Unique request code
                cancelSnoozeIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            val notification = NotificationCompat.Builder(this, SNOOZE_NOTIFICATION_CHANNEL_ID)
                .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
                .setContentTitle("Alarm Snoozed")
                .setContentText("Next alarm at $snoozeTimeString")
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setAutoCancel(true)
                .addAction(
                    android.R.drawable.ic_menu_close_clear_cancel,
                    "Cancel",
                    cancelSnoozePendingIntent
                )
                .setStyle(NotificationCompat.BigTextStyle()
                    .bigText("Next alarm at $snoozeTimeString\n\nTap 'Cancel' to remove this temporary alarm."))
                .build()

            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.notify(SNOOZE_NOTIFICATION_ID, notification)

            Log.d("AlarmOverlayService", "Snooze notification posted for $snoozeTimeString with cancel action")
        } catch (e: Exception) {
            Log.e("AlarmOverlayService", "Error posting snooze notification", e)
        }
    }

    private fun stopAlarmAndCleanup() {
        try {
            // Stop alarm sound
            mediaPlayer?.let {
                if (it.isPlaying) {
                    it.stop()
                }
                it.release()
            }
            mediaPlayer = null

            // Stop time updates
            timeUpdateRunnable?.let { handler.removeCallbacks(it) }

            // Remove overlay
            overlayView?.let { windowManager?.removeView(it) }
            overlayView = null

            // Stop service
            stopSelf()

            Log.d("AlarmOverlayService", "Alarm stopped and cleaned up")
        } catch (e: Exception) {
            Log.e("AlarmOverlayService", "Error during cleanup", e)
        }
    }

    override fun onDestroy() {
        stopAlarmAndCleanup()
        super.onDestroy()
    }
}
