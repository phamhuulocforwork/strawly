package com.example.strawly

import com.istornz.live_activities.LiveActivityManagerHolder
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        LiveActivityManagerHolder.instance = StrawlyLiveActivityManager(this)
        StrawlyLiveIslandService.start(this)
    }

    override fun onResume() {
        super.onResume()
        StrawlyLiveIslandService.start(this)
    }

    override fun onDestroy() {
        if (isFinishing) {
            StrawlyLiveIslandService.cancelIsland(this)
        }
        super.onDestroy()
    }
}
