package com.example.background_service_app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.os.*
import androidx.core.app.NotificationCompat

class KeepAppOnService : Service() {
    override fun onBind(intent: Intent): IBinder? {
        return null
    }

    private fun buildNotificationBadge() {
        val stop = "stop"
        val flag =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE else PendingIntent.FLAG_UPDATE_CURRENT
        val broadcastIntent =
            PendingIntent.getBroadcast(
                this, 0, Intent(stop), flag
            )

        val builder = NotificationCompat.Builder(this, "ee2fe36d4e0f04404109ad5e45bbe2ed")
            .setContentTitle("Battery Alarm")
            .setContentText("Battery tracking is working")
            .setOngoing(true)
            .setContentIntent(broadcastIntent)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "ee2fe36d4e0f04404109ad5e45bbe2ed", "Battery Alarm",
                NotificationManager.IMPORTANCE_DEFAULT
            )
            channel.setShowBadge(false)
            channel.description = "Listening to battery values"
            channel.setSound(null, null)
            val manager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(channel)
        }
        startForeground(1, builder.build())
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        buildNotificationBadge()
        return START_STICKY
    }
}