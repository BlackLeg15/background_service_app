package com.example.background_service_app

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val methodChannel = "com.example.background_service_app/keep_app_on"

    private fun initService() {
        startService(Intent(this, KeepAppOnService::class.java))
    }

    private fun stopService() {
        stopService(Intent(this, KeepAppOnService::class.java))
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            methodChannel
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "initService" -> {
                    try {
                        initService()
                        result.success(null)
                    } catch (e: Error) {
                        result.error("START", "Couldn't start the battery service", e.message)
                    }
                }
                "stopService" -> {
                    try {
                        stopService()
                        result.success(null)
                    } catch (e: Error) {
                        result.error("STOP", "Couldn't stop the battery service", e.message)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}

