package com.example.gilact3

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

class SleepNotificationReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == "com.example.gilact3.SLEEP_NOTIFICATION") {
            val isReminder = intent.getBooleanExtra("is_reminder", false)
            
            if (isReminder) {
                // Esta es la notificación de reenvío (30 minutos después)
                showReminderNotification(context)
            } else {
                // Esta es la notificación original
                showNotification(context)
                // Programar notificación de reenvío para 30 minutos después
                scheduleReminderNotification(context)
            }
        }
    }

    private fun showNotification(context: Context) {
        // Guardar timestamp de la notificación para verificar si se registró
        val prefs = context.getSharedPreferences("sleep_notifications", Context.MODE_PRIVATE)
        prefs.edit().putLong("last_sleep_notification_time", System.currentTimeMillis()).apply()
        
        // Crear canal de notificación si no existe
        createNotificationChannel(context)

        val notificationIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            putExtra("notification_type", "daily_sleep_registration")
        }

        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            notificationIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        // Obtener el icono de la aplicación para la notificación
        val smallIcon = context.applicationInfo.icon
        
        val notification = NotificationCompat.Builder(context, "daily_sleep_reminder")
            .setSmallIcon(smallIcon)
            .setContentTitle("🌙 Registro de Sueño Diario")
            .setContentText("¿Cuántas horas durmió el bebé anoche?")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_REMINDER)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .setVibrate(longArrayOf(0, 250, 250, 250))
            .setSound(android.provider.Settings.System.DEFAULT_NOTIFICATION_URI)
            .build()

        with(NotificationManagerCompat.from(context)) {
            notify(889, notification)
        }
    }
    
    private fun showReminderNotification(context: Context) {
        // Verificar si se registró el sueño antes de mostrar el reenvío
        val prefs = context.getSharedPreferences("sleep_notifications", Context.MODE_PRIVATE)
        val lastNotificationTime = prefs.getLong("last_sleep_notification_time", 0)
        
        // Leer timestamp del registro como string y convertir a long
        val lastRecordTimeStr = prefs.getString("last_sleep_record_time", "0")
        val lastRecordTime = lastRecordTimeStr?.toLongOrNull() ?: 0L
        
        // Si se registró después de la notificación, no mostrar reenvío
        if (lastRecordTime > lastNotificationTime) {
            return
        }
        
        // Crear canal de notificación si no existe
        createNotificationChannel(context)

        val notificationIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            putExtra("notification_type", "daily_sleep_registration")
        }

        val pendingIntent = PendingIntent.getActivity(
            context,
            8890, // ID diferente para el reenvío
            notificationIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val smallIcon = context.applicationInfo.icon
        
        val notification = NotificationCompat.Builder(context, "daily_sleep_reminder")
            .setSmallIcon(smallIcon)
            .setContentTitle("🌙 Recordatorio: Registro de Sueño")
            .setContentText("No olvides registrar las horas de sueño del bebé")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_REMINDER)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .setVibrate(longArrayOf(0, 250, 250, 250))
            .setSound(android.provider.Settings.System.DEFAULT_NOTIFICATION_URI)
            .build()

        with(NotificationManagerCompat.from(context)) {
            notify(8890, notification)
        }
    }
    
    private fun scheduleReminderNotification(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val reminderTime = System.currentTimeMillis() + (30 * 60 * 1000) // 30 minutos
        
        val intent = Intent(context, SleepNotificationReceiver::class.java).apply {
            action = "com.example.gilact3.SLEEP_NOTIFICATION"
            putExtra("is_reminder", true)
        }
        
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            8890,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                if (alarmManager.canScheduleExactAlarms()) {
                    alarmManager.setExactAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        reminderTime,
                        pendingIntent
                    )
                } else {
                    alarmManager.setAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        reminderTime,
                        pendingIntent
                    )
                }
            } else {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    reminderTime,
                    pendingIntent
                )
            }
        } else {
            alarmManager.set(AlarmManager.RTC_WAKEUP, reminderTime, pendingIntent)
        }
    }

    private fun createNotificationChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "daily_sleep_reminder",
                "Registro de Sueño Diario",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Notificación diaria para registrar las horas de sueño del bebé"
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 250, 250, 250)
                setSound(
                    android.provider.Settings.System.DEFAULT_NOTIFICATION_URI,
                    null
                )
            }

            val notificationManager =
                context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }
}

