package com.example.gilact3

import android.os.Build
import android.view.WindowManager
import android.view.View
import android.content.Intent
import android.provider.Settings
import android.app.AlarmManager
import android.app.PendingIntent
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.content.Context
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "screen_recording_prevention"
    private val EVENT_CHANNEL = "screen_recording_prevention_events"
    private val NOTIFICATION_CHANNEL = "notification_permissions"
    private val NATIVE_ALARM_CHANNEL = "native_alarm_scheduler"
    private val VIBRATION_CHANNEL = "system_vibration"
    private val NOTIFICATION_RECORD_TRACKER_CHANNEL = "notification_record_tracker"
    private var isSecureFlagEnabled = false
    private var eventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Configurar MethodChannel para comandos
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "enableSecureFlag" -> {
                    enableSecureFlag()
                    result.success(true)
                }
                "disableSecureFlag" -> {
                    disableSecureFlag()
                    result.success(true)
                }
                "isScreenRecordingActive" -> {
                    val isRecording = isScreenRecordingActive()
                    result.success(isRecording)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        // Configurar MethodChannel para permisos de notificaciones
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NOTIFICATION_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "canScheduleExactAlarms" -> {
                    val canSchedule = canScheduleExactAlarms()
                    result.success(canSchedule)
                }
                "openAppSettings" -> {
                    openAppSettings()
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        // Configurar MethodChannel para programar alarmas nativas
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NATIVE_ALARM_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "scheduleSleepNotification" -> {
                    try {
                        val timestamp = call.argument<Long>("timestamp")
                        if (timestamp != null) {
                            scheduleNativeAlarm(timestamp)
                            result.success(true)
                        } else {
                            result.error("INVALID_ARGUMENT", "Timestamp is required", null)
                        }
                    } catch (e: Exception) {
                        result.error("SCHEDULE_ERROR", e.message, null)
                    }
                }
                "cancelSleepNotification" -> {
                    try {
                        cancelNativeAlarm()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("CANCEL_ERROR", e.message, null)
                    }
                }
                "scheduleLactationNotification" -> {
                    try {
                        val timestamp = call.argument<Long>("timestamp")
                        val notificationId = call.argument<Int>("notification_id") ?: 1000
                        val title = call.argument<String>("title") ?: "🍼 Recordatorio de Lactancia"
                        val body = call.argument<String>("body") ?: "Han pasado 2h desde la última toma"
                        if (timestamp != null) {
                            scheduleNativeLactationAlarm(timestamp, notificationId, title, body)
                            result.success(true)
                        } else {
                            result.error("INVALID_ARGUMENT", "Timestamp is required", null)
                        }
                    } catch (e: Exception) {
                        result.error("SCHEDULE_ERROR", e.message, null)
                    }
                }
                "cancelLactationNotification" -> {
                    try {
                        val notificationId = call.argument<Int>("notification_id") ?: 1000
                        cancelNativeLactationAlarm(notificationId)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("CANCEL_ERROR", e.message, null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        // Configurar EventChannel para eventos de broadcast
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            }
        )
        
        // Configurar MethodChannel para rastreo de registros y cancelación de reenvíos
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NOTIFICATION_RECORD_TRACKER_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "markSleepRecordSaved" -> {
                    try {
                        val prefs = getSharedPreferences("sleep_notifications", Context.MODE_PRIVATE)
                        prefs.edit().putLong("last_sleep_record_time", System.currentTimeMillis()).apply()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                "markLactationRecordSaved" -> {
                    try {
                        val prefs = getSharedPreferences("lactation_notifications", Context.MODE_PRIVATE)
                        prefs.edit().putLong("last_lactation_record_time", System.currentTimeMillis()).apply()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        // Configurar MethodChannel para vibraciones del sistema
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, VIBRATION_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "vibratePattern" -> {
                    try {
                        @Suppress("UNCHECKED_CAST")
                        val patternList = call.argument<List<Int>>("pattern")
                        @Suppress("UNCHECKED_CAST")
                        val amplitudesList = call.argument<List<Int>>("amplitudes")
                        if (patternList != null) {
                            // Convertir List<Int> a LongArray
                            val pattern = LongArray(patternList.size) { patternList[it].toLong() }
                            val amplitudes = amplitudesList?.map { it.toInt() }?.toIntArray()
                            vibratePattern(pattern, amplitudes)
                            result.success(true)
                        } else {
                            result.error("INVALID_ARGUMENT", "Pattern is required", null)
                        }
                    } catch (e: Exception) {
                        result.error("VIBRATION_ERROR", e.message, null)
                    }
                }
                "vibrateDuration" -> {
                    try {
                        val duration = call.argument<Long>("duration") ?: 100L
                        vibrateDuration(duration)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("VIBRATION_ERROR", e.message, null)
                    }
                }
                "cancel" -> {
                    try {
                        cancelVibration()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("VIBRATION_ERROR", e.message, null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    private fun getVibrator(): Vibrator? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val vibratorManager = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
            vibratorManager.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        }
    }
    
    private fun vibratePattern(pattern: LongArray, amplitudes: IntArray? = null) {
        val vibrator = getVibrator() ?: return
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // Android 8.0+ usa VibrationEffect con amplitudes
            val vibrationEffect = if (amplitudes != null && amplitudes.size == pattern.size) {
                // Usar amplitudes personalizadas para diferentes intensidades
                VibrationEffect.createWaveform(pattern, amplitudes, -1) // -1 = no repeat
            } else {
                // Sin amplitudes, usar intensidad por defecto
                VibrationEffect.createWaveform(pattern, -1) // -1 = no repeat
            }
            vibrator.vibrate(vibrationEffect)
        } else {
            // Android 7.1 y anteriores (no soporta amplitudes)
            @Suppress("DEPRECATION")
            vibrator.vibrate(pattern, -1) // -1 = no repeat
        }
    }
    
    private fun vibrateDuration(duration: Long) {
        val vibrator = getVibrator() ?: return
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // Android 8.0+ usa VibrationEffect
            val vibrationEffect = VibrationEffect.createOneShot(duration, VibrationEffect.DEFAULT_AMPLITUDE)
            vibrator.vibrate(vibrationEffect)
        } else {
            // Android 7.1 y anteriores
            @Suppress("DEPRECATION")
            vibrator.vibrate(duration)
        }
    }
    
    private fun cancelVibration() {
        val vibrator = getVibrator() ?: return
        vibrator.cancel()
    }

    private fun enableSecureFlag() {
        runOnUiThread {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB) {
                window.setFlags(
                    WindowManager.LayoutParams.FLAG_SECURE,
                    WindowManager.LayoutParams.FLAG_SECURE
                )
                isSecureFlagEnabled = true
            }
        }
    }

    private fun disableSecureFlag() {
        runOnUiThread {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB) {
                window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                isSecureFlagEnabled = false
            }
        }
    }

    private fun isScreenRecordingActive(): Boolean {
        // Nota: Android no proporciona una API pública confiable para detectar
        // si se está grabando la pantalla. FLAG_SECURE previene la grabación,
        // pero no podemos detectarla directamente.
        // Esta función se mantiene para compatibilidad futura.
        return false
    }

    override fun onResume() {
        super.onResume()
        // Re-aplicar FLAG_SECURE si estaba activo antes de pausar
        if (isSecureFlagEnabled) {
            enableSecureFlag()
        }
    }
    
    private fun canScheduleExactAlarms(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val alarmManager = getSystemService(ALARM_SERVICE) as AlarmManager
            alarmManager.canScheduleExactAlarms()
        } else {
            // En versiones anteriores a Android 12, siempre se puede programar alarmas exactas
            true
        }
    }
    
    private fun openAppSettings() {
        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
            data = android.net.Uri.fromParts("package", packageName, null)
        }
        startActivity(intent)
    }
    
    private fun scheduleNativeAlarm(timestamp: Long) {
        val alarmManager = getSystemService(ALARM_SERVICE) as AlarmManager
        val intent = Intent(this, SleepNotificationReceiver::class.java).apply {
            action = "com.example.gilact3.SLEEP_NOTIFICATION"
        }
        val pendingIntent = PendingIntent.getBroadcast(
            this,
            889,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                if (alarmManager.canScheduleExactAlarms()) {
                    alarmManager.setExactAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        timestamp,
                        pendingIntent
                    )
                } else {
                    // Fallback a modo inexacto si no hay permiso
                    alarmManager.setAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        timestamp,
                        pendingIntent
                    )
                }
            } else {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    timestamp,
                    pendingIntent
                )
            }
        } else {
            alarmManager.set(AlarmManager.RTC_WAKEUP, timestamp, pendingIntent)
        }
    }
    
    private fun cancelNativeAlarm() {
        val alarmManager = getSystemService(ALARM_SERVICE) as AlarmManager
        val intent = Intent(this, SleepNotificationReceiver::class.java).apply {
            action = "com.example.gilact3.SLEEP_NOTIFICATION"
        }
        val pendingIntent = PendingIntent.getBroadcast(
            this,
            889,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        alarmManager.cancel(pendingIntent)
    }
    
    private fun scheduleNativeLactationAlarm(
        timestamp: Long,
        notificationId: Int,
        title: String,
        body: String
    ) {
        val alarmManager = getSystemService(ALARM_SERVICE) as AlarmManager
        val intent = Intent(this, LactationNotificationReceiver::class.java).apply {
            action = "com.example.gilact3.LACTATION_NOTIFICATION"
            putExtra("notification_id", notificationId)
            putExtra("title", title)
            putExtra("body", body)
        }
        val pendingIntent = PendingIntent.getBroadcast(
            this,
            notificationId,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                if (alarmManager.canScheduleExactAlarms()) {
                    alarmManager.setExactAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        timestamp,
                        pendingIntent
                    )
                } else {
                    // Fallback a modo inexacto si no hay permiso
                    alarmManager.setAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        timestamp,
                        pendingIntent
                    )
                }
            } else {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    timestamp,
                    pendingIntent
                )
            }
        } else {
            alarmManager.set(AlarmManager.RTC_WAKEUP, timestamp, pendingIntent)
        }
    }
    
    private fun cancelNativeLactationAlarm(notificationId: Int) {
        val alarmManager = getSystemService(ALARM_SERVICE) as AlarmManager
        val intent = Intent(this, LactationNotificationReceiver::class.java).apply {
            action = "com.example.gilact3.LACTATION_NOTIFICATION"
        }
        val pendingIntent = PendingIntent.getBroadcast(
            this,
            notificationId,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        alarmManager.cancel(pendingIntent)
    }
}
