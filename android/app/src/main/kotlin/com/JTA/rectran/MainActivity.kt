package com.jta.rectran

import android.content.Intent
import android.util.Log
import com.google.android.gms.wearable.Wearable
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await

class MainActivity : FlutterActivity() {

    companion object {
        private const val TAG = "MainActivity"
        private const val CHANNEL = "com.jta.rectran/wear"
        private const val MESSAGE_PATH_SUCCESS = "/rectran/transcription/success"
        private const val MESSAGE_PATH_ERROR = "/rectran/transcription/error"
    }

    private val mainScope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Start the Wear Data Layer listener service
        try {
            val serviceIntent = Intent(this, WearDataLayerListenerService::class.java)
            startService(serviceIntent)
            Log.d(TAG, "Started WearDataLayerListenerService")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start WearDataLayerListenerService", e)
        }

        // Initialize Wear communication handler
        WearCommunicationHandler.initialize(flutterEngine)

        // Set up method channel for bidirectional communication
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel!!.setMethodCallHandler { call, result ->
            when (call.method) {
                "sendSuccessToWatch" -> {
                    val watchNodeId = call.argument<String>("watchNodeId")
                    val message = call.argument<String>("message") ?: "Transcription complete"

                    if (watchNodeId != null) {
                        sendMessageToWatch(watchNodeId, MESSAGE_PATH_SUCCESS, message)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGS", "watchNodeId is required", null)
                    }
                }
                "sendErrorToWatch" -> {
                    val watchNodeId = call.argument<String>("watchNodeId")
                    val error = call.argument<String>("error") ?: "Unknown error"

                    if (watchNodeId != null) {
                        sendMessageToWatch(watchNodeId, MESSAGE_PATH_ERROR, error)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGS", "watchNodeId is required", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        Log.d(TAG, "Flutter engine configured with Wear OS support")
    }

    private fun sendMessageToWatch(nodeId: String, path: String, message: String) {
        mainScope.launch {
            try {
                val messageClient = Wearable.getMessageClient(applicationContext)
                val data = """{"message": ""}""".toByteArray()

                messageClient.sendMessage(nodeId, path, data).await()
                Log.d(TAG, "Message sent to watch:  - ")

            } catch (e: Exception) {
                Log.e(TAG, "Failed to send message to watch", e)
            }
        }
    }

    override fun onDestroy() {
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
        mainScope.cancel()
        super.onDestroy()
    }
}
