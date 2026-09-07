package com.example.strawly

import android.app.Notification
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.drawable.Icon
import android.os.Build
import android.widget.RemoteViews
import com.istornz.live_activities.LiveActivityManager
import java.text.DateFormat
import java.util.Date
import java.util.Locale

class StrawlyLiveActivityManager(context: Context) : LiveActivityManager(context) {
    private val appContext: Context = context.applicationContext
    private val pendingIntent = PendingIntent.getActivity(
        appContext,
        200,
        Intent(appContext, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
        },
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
    )
    private val remoteViews = RemoteViews(
        appContext.packageName,
        R.layout.live_activity,
    )

    private fun intFrom(data: Map<String, Any>, key: String, fallback: Int): Int {
        return when (val value = data[key]) {
            is Int -> value
            is Long -> value.toInt()
            else -> fallback
        }
    }

    private fun longFrom(data: Map<String, Any>, key: String): Long {
        return when (val value = data[key]) {
            is Long -> value
            is Int -> value.toLong()
            else -> 0L
        }
    }

    private fun progressPercent(periodDay: Int, periodDuration: Int, daysUntil: Int): Int {
        if (periodDay > 0 && periodDuration > 0) {
            return ((periodDay * 100) / periodDuration).coerceIn(1, 100)
        }
        if (daysUntil in 0..100) {
            return (100 - daysUntil).coerceIn(1, 99)
        }
        return 50
    }

    private fun stickerRes(phaseKey: String): Int {
        return when (phaseKey) {
            "period" -> R.drawable.sticker_period
            "fertile" -> R.drawable.sticker_fertile
            "luteal" -> R.drawable.sticker_luteal
            else -> R.drawable.sticker_follicular
        }
    }

    private fun stickerBitmap(phaseKey: String, sizePx: Int): Bitmap {
        val original = BitmapFactory.decodeResource(appContext.resources, stickerRes(phaseKey))
        if (original.width == sizePx && original.height == sizePx) return original
        val scaled = Bitmap.createScaledBitmap(original, sizePx, sizePx, true)
        if (scaled !== original) original.recycle()
        return scaled
    }

    private fun updateRemoteViews(
        compactDigit: String,
        phaseLabel: String,
        predictedDateMs: Long,
        phaseKey: String,
    ) {
        remoteViews.setImageViewBitmap(R.id.sticker, stickerBitmap(phaseKey, 120))
        remoteViews.setTextViewText(R.id.compact_digit, compactDigit)
        remoteViews.setTextViewText(R.id.phase_label, phaseLabel)

        val predictedText = if (predictedDateMs > 0L) {
            val formatter = DateFormat.getDateInstance(DateFormat.MEDIUM, Locale.getDefault())
            formatter.format(Date(predictedDateMs))
        } else {
            ""
        }
        remoteViews.setTextViewText(R.id.predicted_date, predictedText)
    }

    override suspend fun buildNotification(
        notification: Notification.Builder,
        event: String,
        data: Map<String, Any>,
    ): Notification {
        val compactDigit = data["compactDigit"] as? String ?: "—"
        val phaseLabel = data["phaseLabel"] as? String ?: ""
        val phaseKey = data["phaseKey"] as? String ?: "none"
        val predictedDateMs = longFrom(data, "predictedDateMs")
        val periodDay = intFrom(data, "periodDay", -1)
        val periodDuration = intFrom(data, "periodDuration", 5)
        val daysUntil = intFrom(data, "daysUntil", -999)
        val progress = progressPercent(periodDay, periodDuration, daysUntil)
        val sticker = Icon.createWithBitmap(stickerBitmap(phaseKey, 192))
        val strawberry = Icon.createWithResource(appContext, R.drawable.ic_strawberry)

        notification
            .setSmallIcon(sticker)
            .setLargeIcon(sticker)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setContentTitle("Strawly")
            .setContentText(if (phaseLabel.isEmpty()) compactDigit else "$phaseLabel  $compactDigit")
            .setContentIntent(pendingIntent)
            .setCategory(Notification.CATEGORY_PROGRESS)
            .setVisibility(Notification.VISIBILITY_PUBLIC)

        StrawlyLiveIslandService.start(appContext)

        if (Build.VERSION.SDK_INT >= 36) {
            val style = Notification.ProgressStyle()
                .setStyledByProgress(true)
                .setProgress(progress)
                .setProgressStartIcon(strawberry)
                .setProgressTrackerIcon(strawberry)
                .addProgressSegment(
                    Notification.ProgressStyle.Segment(100).setColor(0xFFC44B6A.toInt()),
                )
            notification.setStyle(style)
            notification.setShortCriticalText(compactDigit)
            notification.extras.putBoolean("android.requestPromotedOngoing", true)
        } else {
            updateRemoteViews(compactDigit, phaseLabel, predictedDateMs, phaseKey)
            notification
                .setStyle(Notification.DecoratedCustomViewStyle())
                .setCustomContentView(remoteViews)
                .setCustomBigContentView(remoteViews)
        }

        return notification.build()
    }
}
