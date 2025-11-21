package com.example.gilact3

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

class SleepNotificationReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == "com.example.gilact3.SLEEP_NOTIFICATION") {
            showNotification(context)
        }
    }

    private fun showNotification(context: Context) {
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
        // Android convertirá automáticamente el icono a monocromático para el icono pequeño
        // Usar el icono de la app definido en el manifest
        val smallIcon = context.applicationInfo.icon
        
        val notification = NotificationCompat.Builder(context, "daily_sleep_reminder")
            .setSmallIcon(smallIcon) // Usar icono de la app
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

