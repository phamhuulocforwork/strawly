package com.example.strawly

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.content.res.Configuration
import android.os.Build
import android.os.Bundle
import android.util.TypedValue
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Locale

/**
 * Renders one entry of the day-by-day timeline written by [CycleWidgetSync].
 * The provider recomputes which entry applies on every update, so the day
 * count rolls over after midnight without the app being opened.
 */
abstract class CycleWidgetProvider : HomeWidgetProvider() {

    protected open val layoutRes: Int = R.layout.cycle_widget_bar
    protected open val statBarCount: Int = 0
    protected open val showDate: Boolean = false
    protected open val showCalendar: Boolean = false

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle,
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        onUpdate(
            context,
            appWidgetManager,
            intArrayOf(appWidgetId),
            HomeWidgetPlugin.getData(context),
        )
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val timeline = loadTimeline(widgetData)
        val today = todayStartMillis()
        val todayIndex = timeline.indexOfFirst { it.getLong("d") == today }
            .takeIf { it >= 0 }
            ?: timeline.indexOfLast { it.getLong("d") <= today }.takeIf { it >= 0 }
            ?: 0
        val todayEntry = timeline.getOrNull(todayIndex)
            ?.takeIf { today - it.getLong("d") <= STALE_AFTER_MILLIS }

        for (appWidgetId in appWidgetIds) {
            val (layout, barCount) = resolveLayout(context, appWidgetManager, appWidgetId)
            val views = RemoteViews(context.packageName, layout)
            bindToday(views, context, todayEntry)
            if (barCount > 0) {
                bindStats(views, context, widgetData, barCount)
            }
            if (showCalendar) {
                bindCalendar(views, context, widgetData)
            }
            tuneWidgetSize(views, appWidgetManager, appWidgetId)
            val clickTarget = if (showCalendar) R.id.widget_slot else R.id.widget_root
            views.setOnClickPendingIntent(clickTarget, openAppIntent(context))
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    protected open fun resolveLayout(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
    ): Pair<Int, Int> = layoutRes to statBarCount

    protected open fun tuneWidgetSize(
        views: RemoteViews,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
    ) {}

    private fun bindToday(
        views: RemoteViews,
        context: Context,
        entry: JSONObject?,
    ) {
        val phaseKey = entry?.optString("k") ?: "none"
        val phaseLabel = entry?.optString("l") ?: ""
        views.setImageViewResource(R.id.widget_sticker, stickerRes(phaseKey))
        views.setTextViewText(R.id.widget_phase_label, phaseLabel)
        views.setTextViewText(
            R.id.widget_digit,
            entry?.optString("n")?.takeIf { it.isNotEmpty() } ?: "—",
        )
        views.setTextColor(
            R.id.widget_digit,
            phaseColor(context, phaseKey),
        )
        bindPhaseChrome(views, context, phaseKey, phaseLabel)
        if (showDate) {
            views.setTextViewText(
                R.id.widget_date,
                formatTodayDate(entry?.optLong("d")),
            )
        }
    }

    private fun bindPhaseChrome(
        views: RemoteViews,
        context: Context,
        phaseKey: String,
        phaseLabel: String,
    ) {
        val hasPhase = phaseKey != "none" && phaseLabel.isNotEmpty()
        views.setInt(R.id.widget_root, "setBackgroundResource", washRes(phaseKey))
        if (hasPhase) {
            views.setViewVisibility(R.id.widget_phase_label, View.VISIBLE)
            views.setInt(R.id.widget_phase_label, "setBackgroundResource", badgeRes(phaseKey))
            views.setTextColor(
                R.id.widget_phase_label,
                themedColor(context, R.color.widget_badge_text),
            )
        } else {
            views.setViewVisibility(R.id.widget_phase_label, View.GONE)
        }
        if (showDate) {
            if (hasPhase) {
                views.setViewVisibility(R.id.widget_sticker_pip, View.VISIBLE)
                views.setImageViewResource(R.id.widget_sticker_pip, dotRes(phaseKey))
            } else {
                views.setViewVisibility(R.id.widget_sticker_pip, View.GONE)
            }
        }
    }

    private fun bindStats(
        views: RemoteViews,
        context: Context,
        widgetData: SharedPreferences,
        barCount: Int,
    ) {
        val stats = loadStats(widgetData)
        if (stats == null) {
            clearStats(views, barCount)
            return
        }
        views.setTextViewText(
            R.id.widget_stat_avg,
            stats.optString("avgLabel", ""),
        )
        val lengths = stats.optJSONArray("lengths") ?: JSONArray()
        if (lengths.length() == 0) {
            clearStats(views, barCount)
            return
        }
        val values = buildList {
            for (index in 0 until lengths.length()) {
                add(lengths.getInt(index))
            }
        }
        val min = values.minOrNull() ?: 0
        val max = values.maxOrNull() ?: 0
        val visibleCount = lengths.length().coerceAtMost(barCount)
        val startIndex = (lengths.length() - visibleCount).coerceAtLeast(0)

        for (index in STAT_BAR_IDS.indices) {
            val barId = STAT_BAR_IDS[index]
            if (index >= visibleCount) {
                views.setViewVisibility(barId, View.GONE)
                continue
            }
            val length = lengths.getInt(startIndex + index)
            views.setViewVisibility(barId, View.VISIBLE)
            views.setInt(barId, "setBackgroundResource", statBarDrawable(length, min, max))
        }
    }

    private fun clearStats(views: RemoteViews, barCount: Int) {
        views.setTextViewText(R.id.widget_stat_avg, "")
        for (index in 0 until barCount.coerceAtMost(STAT_BAR_IDS.size)) {
            views.setViewVisibility(STAT_BAR_IDS[index], View.GONE)
        }
    }

    private fun loadStats(widgetData: SharedPreferences): JSONObject? {
        return runCatching {
            val raw = widgetData.getString(STATS_KEY, null) ?: return null
            JSONObject(raw)
        }.getOrNull()
    }

    private fun statBarDrawable(length: Int, min: Int, max: Int): Int {
        if (max <= min) return R.drawable.stat_bar_h14
        val ratio = (length - min).toFloat() / (max - min).toFloat()
        return when {
            ratio < 0.2f -> R.drawable.stat_bar_h6
            ratio < 0.4f -> R.drawable.stat_bar_h10
            ratio < 0.6f -> R.drawable.stat_bar_h14
            ratio < 0.8f -> R.drawable.stat_bar_h18
            else -> R.drawable.stat_bar_h22
        }
    }

    private fun bindCalendar(
        views: RemoteViews,
        context: Context,
        widgetData: SharedPreferences,
    ) {
        runCatching {
            val calendar = loadCalendar(widgetData)
            if (calendar == null) {
                clearCalendar(views)
                return
            }
            bindCalendarHeader(views, context, calendar.optJSONObject("h"))

            val month = selectMonth(calendar) ?: run {
                clearCalendar(views)
                return
            }

            val weekdays = calendar.optJSONArray("w") ?: JSONArray()
            for (index in CAL_WEEKDAY_IDS.indices) {
                val label = if (index < weekdays.length()) {
                    weekdays.optString(index)
                } else {
                    ""
                }
                views.setTextViewText(CAL_WEEKDAY_IDS[index], label)
            }

            val offset = month.optInt("o", 0)
            val days = month.optJSONArray("days") ?: JSONArray()
            val todayCal = Calendar.getInstance()
            val todayYear = todayCal.get(Calendar.YEAR)
            val todayMonth = todayCal.get(Calendar.MONTH) + 1
            val todayDay = todayCal.get(Calendar.DAY_OF_MONTH)

            for (cellIndex in CAL_CELL_IDS.indices) {
                val cellId = CAL_CELL_IDS[cellIndex]
                if (cellIndex < offset || cellIndex >= offset + days.length()) {
                    clearCalendarCell(views, cellId)
                    continue
                }
                val day = days.getJSONObject(cellIndex - offset)
                val dayNumber = day.getInt("n")
                val kind = day.optString("k", "none")
                val peak = day.optInt("p", 0) == 1
                val isToday = month.getInt("y") == todayYear &&
                    month.getInt("m") == todayMonth &&
                    dayNumber == todayDay
                views.setTextViewText(cellId, dayNumber.toString())
                val background = if (isToday) {
                    todayDrawable(kind)
                } else {
                    calDayDrawable(kind)
                }
                views.setInt(cellId, "setBackgroundResource", background)
                val textColor = when {
                    peak || isToday -> themedColor(context, R.color.phase_period)
                    kind == "fertile" -> themedColor(context, R.color.cal_day_fertile_text)
                    else -> themedColor(context, R.color.widget_text)
                }
                views.setTextColor(cellId, textColor)
            }
        }
    }

    private fun bindCalendarHeader(
        views: RemoteViews,
        context: Context,
        header: JSONObject?,
    ) {
        if (header == null) {
            views.setTextViewText(R.id.widget_phase_title, "")
            views.setViewVisibility(R.id.widget_phase_label, View.GONE)
            views.setTextViewText(R.id.widget_digit, "—")
            views.setViewVisibility(R.id.widget_digit, View.GONE)
            return
        }

        val phaseKey = header.optString("k", "none")
        val phaseLabel = header.optString("l", "")
        views.setTextViewText(R.id.widget_phase_title, header.optString("t", ""))
        views.setTextViewText(R.id.widget_digit, header.optString("n", "—"))
        views.setViewVisibility(R.id.widget_digit, View.VISIBLE)
        views.setInt(R.id.widget_digit, "setBackgroundResource", badgeRes(phaseKey))
        views.setTextColor(
            R.id.widget_digit,
            themedColor(context, R.color.widget_badge_text),
        )

        val hasPhase = phaseKey != "none" && phaseLabel.isNotEmpty()
        if (hasPhase) {
            views.setTextViewText(R.id.widget_phase_label, phaseLabel)
            views.setViewVisibility(R.id.widget_phase_label, View.VISIBLE)
            views.setInt(R.id.widget_phase_label, "setBackgroundResource", badgeRes(phaseKey))
            views.setTextColor(
                R.id.widget_phase_label,
                themedColor(context, R.color.widget_badge_text),
            )
        } else {
            views.setViewVisibility(R.id.widget_phase_label, View.GONE)
        }
    }

    private fun clearCalendar(views: RemoteViews) {
        views.setTextViewText(R.id.widget_phase_title, "")
        views.setViewVisibility(R.id.widget_phase_label, View.GONE)
        views.setTextViewText(R.id.widget_digit, "—")
        views.setViewVisibility(R.id.widget_digit, View.GONE)
        for (weekdayId in CAL_WEEKDAY_IDS) {
            views.setTextViewText(weekdayId, "")
        }
        for (cellId in CAL_CELL_IDS) {
            clearCalendarCell(views, cellId)
        }
    }

    private fun clearCalendarCell(views: RemoteViews, cellId: Int) {
        views.setTextViewText(cellId, "")
        views.setInt(cellId, "setBackgroundResource", R.drawable.cal_day_none)
    }

    private fun loadTimeline(widgetData: SharedPreferences): List<JSONObject> {
        return runCatching {
            val raw = widgetData.getString(TIMELINE_KEY, null) ?: return emptyList()
            val entries = JSONArray(raw)
            buildList {
                for (index in 0 until entries.length()) {
                    add(entries.getJSONObject(index))
                }
            }
        }.getOrDefault(emptyList())
    }

    private fun loadCalendar(widgetData: SharedPreferences): JSONObject? {
        return runCatching {
            val raw = widgetData.getString(CALENDAR_KEY, null) ?: return null
            JSONObject(raw)
        }.getOrNull()
    }

    private fun selectMonth(calendar: JSONObject): JSONObject? {
        val months = calendar.optJSONArray("months") ?: return null
        if (months.length() == 0) return null
        val today = Calendar.getInstance()
        val year = today.get(Calendar.YEAR)
        val month = today.get(Calendar.MONTH) + 1
        for (index in 0 until months.length()) {
            val entry = months.getJSONObject(index)
            if (entry.getInt("y") == year && entry.getInt("m") == month) {
                return entry
            }
        }
        return months.getJSONObject(0)
    }

    private fun calDayDrawable(kind: String): Int = when (kind) {
        "period" -> R.drawable.cal_day_period
        "fertile" -> R.drawable.cal_day_fertile
        "predicted" -> R.drawable.cal_day_predicted
        else -> R.drawable.cal_day_none
    }

    private fun todayDrawable(kind: String): Int = when (kind) {
        "period" -> R.drawable.cal_day_today_period
        "fertile" -> R.drawable.cal_day_today_fertile
        "predicted" -> R.drawable.cal_day_today_predicted
        else -> R.drawable.cal_day_today
    }

    private fun todayStartMillis(): Long {
        val calendar = Calendar.getInstance()
        calendar.set(Calendar.HOUR_OF_DAY, 0)
        calendar.set(Calendar.MINUTE, 0)
        calendar.set(Calendar.SECOND, 0)
        calendar.set(Calendar.MILLISECOND, 0)
        return calendar.timeInMillis
    }

    private fun formatTodayDate(millis: Long?): String {
        if (millis == null) return ""
        return SimpleDateFormat("MMM d", Locale.getDefault()).format(millis)
    }

    private fun themedContext(context: Context): Context {
        val nightMode = context.resources.configuration.uiMode and
            Configuration.UI_MODE_NIGHT_MASK == Configuration.UI_MODE_NIGHT_YES
        return context.createConfigurationContext(
            Configuration(context.resources.configuration).apply {
                uiMode = if (nightMode) {
                    Configuration.UI_MODE_NIGHT_YES
                } else {
                    Configuration.UI_MODE_NIGHT_NO
                }
            },
        )
    }

    private fun themedColor(context: Context, colorRes: Int): Int {
        return themedContext(context).getColor(colorRes)
    }

    private fun phaseColor(context: Context, phaseKey: String): Int {
        val colorRes = when (phaseKey) {
            "period" -> R.color.phase_period
            "fertile" -> R.color.phase_fertile
            "luteal" -> R.color.phase_luteal
            else -> R.color.phase_follicular
        }
        return themedColor(context, colorRes)
    }

    private fun washRes(phaseKey: String): Int = when (phaseKey) {
        "period" -> R.drawable.widget_background_period
        "fertile" -> R.drawable.widget_background_fertile
        "luteal" -> R.drawable.widget_background_luteal
        "follicular" -> R.drawable.widget_background_follicular
        else -> R.drawable.widget_background_none
    }

    private fun badgeRes(phaseKey: String): Int = when (phaseKey) {
        "period" -> R.drawable.badge_period
        "fertile" -> R.drawable.badge_fertile
        "luteal" -> R.drawable.badge_luteal
        else -> R.drawable.badge_follicular
    }

    private fun stickerRes(phaseKey: String): Int = when (phaseKey) {
        "period" -> R.drawable.sticker_period
        "fertile" -> R.drawable.sticker_fertile
        "luteal" -> R.drawable.sticker_luteal
        else -> R.drawable.sticker_follicular
    }

    private fun dotRes(phaseKey: String): Int = when (phaseKey) {
        "period" -> R.drawable.dot_period
        "fertile" -> R.drawable.dot_fertile
        "luteal" -> R.drawable.dot_luteal
        else -> R.drawable.dot_follicular
    }

    private fun openAppIntent(context: Context): PendingIntent {
        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        return PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    protected companion object {
        const val TIMELINE_KEY = "widget_timeline"
        const val CALENDAR_KEY = "widget_calendar"
        const val STATS_KEY = "widget_stats"

        // ponytail: hide phase once the timeline is older than this many days
        // (app not opened for > horizonDays). Bump if widgets must always show.
        private const val STALE_AFTER_MILLIS = 3L * 24 * 60 * 60 * 1000

        private val STAT_BAR_IDS = intArrayOf(
            R.id.stat_bar_0, R.id.stat_bar_1, R.id.stat_bar_2, R.id.stat_bar_3,
            R.id.stat_bar_4, R.id.stat_bar_5, R.id.stat_bar_6,
        )

        private val CAL_CELL_IDS = intArrayOf(
            R.id.cal_cell_0, R.id.cal_cell_1, R.id.cal_cell_2, R.id.cal_cell_3,
            R.id.cal_cell_4, R.id.cal_cell_5, R.id.cal_cell_6, R.id.cal_cell_7,
            R.id.cal_cell_8, R.id.cal_cell_9, R.id.cal_cell_10, R.id.cal_cell_11,
            R.id.cal_cell_12, R.id.cal_cell_13, R.id.cal_cell_14, R.id.cal_cell_15,
            R.id.cal_cell_16, R.id.cal_cell_17, R.id.cal_cell_18, R.id.cal_cell_19,
            R.id.cal_cell_20, R.id.cal_cell_21, R.id.cal_cell_22, R.id.cal_cell_23,
            R.id.cal_cell_24, R.id.cal_cell_25, R.id.cal_cell_26, R.id.cal_cell_27,
            R.id.cal_cell_28, R.id.cal_cell_29, R.id.cal_cell_30, R.id.cal_cell_31,
            R.id.cal_cell_32, R.id.cal_cell_33, R.id.cal_cell_34, R.id.cal_cell_35,
            R.id.cal_cell_36, R.id.cal_cell_37, R.id.cal_cell_38, R.id.cal_cell_39,
            R.id.cal_cell_40, R.id.cal_cell_41,
        )

        private val CAL_WEEKDAY_IDS = intArrayOf(
            R.id.cal_wd_0, R.id.cal_wd_1, R.id.cal_wd_2, R.id.cal_wd_3,
            R.id.cal_wd_4, R.id.cal_wd_5, R.id.cal_wd_6,
        )

        internal val CAL_ROW_IDS = intArrayOf(
            R.id.cal_row_0, R.id.cal_row_1, R.id.cal_row_2, R.id.cal_row_3,
            R.id.cal_row_4, R.id.cal_row_5,
        )

        internal const val CALENDAR_HORIZONTAL_PADDING_DP = 16

        internal fun calendarCellHeightDp(widgetWidth: Int): Float {
            return ((widgetWidth - CALENDAR_HORIZONTAL_PADDING_DP) / 7f)
                .coerceAtLeast(10f)
        }
    }
}

class CycleWidgetBarProvider : CycleWidgetProvider() {
    override fun resolveLayout(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
    ): Pair<Int, Int> {
        val options = appWidgetManager.getAppWidgetOptions(appWidgetId)
        val minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 110)
        return when {
            minWidth < 180 -> R.layout.cycle_widget_compact to 0
            minWidth < 220 -> R.layout.cycle_widget_bar to 0
            minWidth < 300 -> R.layout.cycle_widget_wide to 4
            else -> R.layout.cycle_widget_wide to 7
        }
    }
}

class CycleWidget2x2Provider : CycleWidgetProvider() {
    override val layoutRes: Int = R.layout.cycle_widget_square
    override val showDate: Boolean = true
}

class CycleWidget2x3Provider : CycleWidgetProvider() {
    override val layoutRes: Int = R.layout.cycle_widget_tall
    override val showCalendar: Boolean = true

    override fun tuneWidgetSize(
        views: RemoteViews,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
    ) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return

        val options = appWidgetManager.getAppWidgetOptions(appWidgetId)
        val width = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 110)
        val height = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 110)
        val cellHeight = calendarCellHeightDp(width)

        for (rowId in CAL_ROW_IDS) {
            views.setViewLayoutHeight(
                rowId,
                cellHeight,
                TypedValue.COMPLEX_UNIT_DIP,
            )
        }

        if (height <= width) return

        // MIUI 2x2 cells are often taller than wide — snap card height toward width.
        val targetHeight = (width * 1.05f).toInt().coerceAtMost(height)
        views.setViewLayoutHeight(
            R.id.widget_root,
            targetHeight.toFloat(),
            TypedValue.COMPLEX_UNIT_DIP,
        )
        if (height > targetHeight) {
            val topMargin = (height - targetHeight) / 2f
            views.setViewLayoutMargin(
                R.id.widget_root,
                RemoteViews.MARGIN_TOP,
                topMargin,
                TypedValue.COMPLEX_UNIT_DIP,
            )
        }
    }
}
