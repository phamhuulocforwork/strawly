package com.example.strawly

import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.IBinder

/** Cancels the Super Island notification when the user swipes Strawly from Recents. */
class StrawlyLiveIslandService : Service() {
    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_NOT_STICKY
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        cancelIsland(this)
        stopSelf()
        super.onTaskRemoved(rootIntent)
    }

    companion object {
        fun start(context: Context) {
            try {
                context.startService(Intent(context, StrawlyLiveIslandService::class.java))
            } catch (_: IllegalStateException) {
                // App is backgrounded; Recents swipe is handled if the service is already running.
            }
        }

        fun cancelIsland(context: Context) {
            val manager = context.getSystemService(NotificationManager::class.java) ?: return
            manager.activeNotifications
                .filter { notification ->
                    notification.notification.channelId == "Live Activities" ||
                        notification.tag == "strawly-cycle"
                }
                .forEach { notification ->
                    manager.cancel(notification.tag, notification.id)
                }
        }
    }
}
