package com.gilact.app

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

class LactationNotificationReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == "com.gilact.app.LACTATION_NOTIFICATION") {
            val notificationId = intent.getIntExtra("notification_id", 1000)
            val title = intent.getStringExtra("title") ?: "🍼 Recordatorio de Lactancia"
            val body = intent.getStringExtra("body") ?: "Han pasado 2h desde la última toma"
            val isReminder = intent.getBooleanExtra("is_reminder", false)
            
            if (isReminder) {
                // Esta es la notificación de reenvío (30 minutos después)
                showReminderNotification(context, notificationId, title, body)
            } else {
                // Esta es la notificación original
                showNotification(context, notificationId, title, body)
                // Programar notificación de reenvío para 30 minutos después
                scheduleReminderNotification(context, notificationId, title, body)
            }
        }
    }

    private fun showNotification(
        context: Context,
        notificationId: Int,
        title: String,
        body: String
    ) {
        // Guardar timestamp de la notificación para verificar si se registró
        val prefs = context.getSharedPreferences("lactation_notifications", Context.MODE_PRIVATE)
        prefs.edit().putLong("last_lactation_notification_time_$notificationId", System.currentTimeMillis()).apply()
        
        // Crear canal de notificación si no existe
        createNotificationChannel(context)

        val notificationIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            putExtra("notification_type", "lactation_reminder")
        }

        val pendingIntent = PendingIntent.getActivity(
            context,
            notificationId,
            notificationIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        // Obtener el icono de la aplicación para la notificación
        val smallIcon = context.applicationInfo.icon

        val notification = NotificationCompat.Builder(context, "lactation_reminders")
            .setSmallIcon(smallIcon)
            .setContentTitle(title)
            .setContentText(body)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_REMINDER)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .setVibrate(longArrayOf(0, 250, 250, 250))
            .setSound(android.provider.Settings.System.DEFAULT_NOTIFICATION_URI)
            .build()

        with(NotificationManagerCompat.from(context)) {
            notify(notificationId, notification)
        }
    }
    
    private fun showReminderNotification(
        context: Context,
        notificationId: Int,
        title: String,
        body: String
    ) {
        // Verificar si se registró la lactancia antes de mostrar el reenvío
        val prefs = context.getSharedPreferences("lactation_notifications", Context.MODE_PRIVATE)
        val lastNotificationTime = prefs.getLong("last_lactation_notification_time_$notificationId", 0)
        
        // Leer timestamp del registro como string y convertir a long
        val lastRecordTimeStr = prefs.getString("last_lactation_record_time", "0")
        val lastRecordTime = lastRecordTimeStr?.toLongOrNull() ?: 0L
        
        // Si se registró después de la notificación, no mostrar reenvío
        if (lastRecordTime > lastNotificationTime) {
            return
        }
        
        // Crear canal de notificación si no existe
        createNotificationChannel(context)

        val reminderNotificationId = notificationId + 10000 // ID diferente para el reenvío
        
        val notificationIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            putExtra("notification_type", "lactation_reminder")
        }

        val pendingIntent = PendingIntent.getActivity(
            context,
            reminderNotificationId,
            notificationIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val smallIcon = context.applicationInfo.icon

        val notification = NotificationCompat.Builder(context, "lactation_reminders")
            .setSmallIcon(smallIcon)
            .setContentTitle("🍼 Recordatorio: $title")
            .setContentText("No olvides registrar la lactancia")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_REMINDER)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .setVibrate(longArrayOf(0, 250, 250, 250))
            .setSound(android.provider.Settings.System.DEFAULT_NOTIFICATION_URI)
            .build()

        with(NotificationManagerCompat.from(context)) {
            notify(reminderNotificationId, notification)
        }
    }
    
    private fun scheduleReminderNotification(
        context: Context,
        notificationId: Int,
        title: String,
        body: String
    ) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val reminderTime = System.currentTimeMillis() + (30 * 60 * 1000) // 30 minutos
        
        val intent = Intent(context, LactationNotificationReceiver::class.java).apply {
            action = "com.gilact.app.LACTATION_NOTIFICATION"
            putExtra("notification_id", notificationId)
            putExtra("title", title)
            putExtra("body", body)
            putExtra("is_reminder", true)
        }
        
        val reminderNotificationId = notificationId + 10000
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            reminderNotificationId,
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
                "lactation_reminders",
                "Recordatorios de Lactancia",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Notificaciones para recordar registrar la próxima toma de lactancia"
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
