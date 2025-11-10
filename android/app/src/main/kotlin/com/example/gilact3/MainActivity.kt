package com.example.gilact

import android.os.Build
import android.view.WindowManager
import android.view.View
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "screen_recording_prevention"
    private val EVENT_CHANNEL = "screen_recording_prevention_events"
    private var isSecureFlagEnabled = false
    private var eventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Configurar MethodChannel para comandos
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "enableSecureFlag" -> {
                    enableSecureFlag()
                    result.success(true)
                }
                "disableSecureFlag" -> {
                    disableSecureFlag()
                    result.success(true)
                }
                "isScreenRecordingActive" -> {
                    val isRecording = isScreenRecordingActive()
                    result.success(isRecording)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        // Configurar EventChannel para eventos de broadcast
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            }
        )
    }

    private fun enableSecureFlag() {
        runOnUiThread {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB) {
                window.setFlags(
                    WindowManager.LayoutParams.FLAG_SECURE,
                    WindowManager.LayoutParams.FLAG_SECURE
                )
                isSecureFlagEnabled = true
            }
        }
    }

    private fun disableSecureFlag() {
        runOnUiThread {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB) {
                window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                isSecureFlagEnabled = false
            }
        }
    }

    private fun isScreenRecordingActive(): Boolean {
        // Nota: Android no proporciona una API pública confiable para detectar
        // si se está grabando la pantalla. FLAG_SECURE previene la grabación,
        // pero no podemos detectarla directamente.
        // Esta función se mantiene para compatibilidad futura.
        return false
    }

    override fun onResume() {
        super.onResume()
        // Re-aplicar FLAG_SECURE si estaba activo antes de pausar
        if (isSecureFlagEnabled) {
            enableSecureFlag()
        }
    }
}
