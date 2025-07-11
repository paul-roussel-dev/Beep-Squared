package com.example.beep_squared

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val alarmId = intent.getStringExtra("alarmId")
        val label = intent.getStringExtra("label") ?: "Alarm"
        
        Log.d("AlarmReceiver", "Alarm received: $alarmId")
        
        if (alarmId != null) {
            // Launch AlarmActivity to show the alarm screen
            val alarmIntent = Intent(context, AlarmActivity::class.java).apply {
                putExtra("alarmId", alarmId)
                putExtra("label", label)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or 
                       Intent.FLAG_ACTIVITY_CLEAR_TOP or
                       Intent.FLAG_ACTIVITY_SINGLE_TOP
            }
            
            context.startActivity(alarmIntent)
            Log.d("AlarmReceiver", "AlarmActivity started for: $alarmId")
        }
    }
}
