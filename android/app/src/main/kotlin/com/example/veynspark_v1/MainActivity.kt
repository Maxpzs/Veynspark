package com.example.veynspark_v1

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val haptics = GlynaHaptics(applicationContext)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "glyna/haptics")
            .setMethodCallHandler { call, result ->
                val moment = call.arguments as? String
                if (call.method == "play" && moment != null) {
                    haptics.play(moment)
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "glyna/lock")
            .setStreamHandler(GlynaLockStream(applicationContext))
    }
}
