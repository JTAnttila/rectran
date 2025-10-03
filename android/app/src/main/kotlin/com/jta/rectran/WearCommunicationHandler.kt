package com.jta.rectran

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.plugin.common.MethodChannel

object WearCommunicationHandler {
    private const val TAG = "WearCommunicationHandler"
    private const val CHANNEL = "com.jta.rectran/wear_audio"
    
    private var methodChannel: MethodChannel? = null
    private val mainHandler = Handler(Looper.getMainLooper())
    private var context: Context? = null

    fun initialize(context: Context) {
        this.context = context
        Log.d(TAG, "WearCommunicationHandler initialized")
    }

    fun setMethodChannel(channel: MethodChannel?) {
        mainHandler.post {
            methodChannel = channel
            Log.d(TAG, "Method channel set: ${channel != null}")
        }
    }

    fun sendAudioToFlutter(audioPath: String, watchId: String) {
        mainHandler.post {
            try {
                if (methodChannel == null) {
                    Log.w(TAG, "Method channel is null, cannot send audio")
                    return@post
                }

                val message = mapOf(
                    "audioPath" to audioPath,
                    "watchId" to watchId
                )

                methodChannel?.invokeMethod("onWearAudioReceived", message)
                Log.d(TAG, "Sent audio to Flutter: $audioPath (watch: $watchId)")
            } catch (e: Exception) {
                Log.e(TAG, "Error sending audio to Flutter", e)
            }
        }
    }

    fun sendMessageToFlutter(type: String, data: String) {
        mainHandler.post {
            try {
                if (methodChannel == null) {
                    Log.w(TAG, "Method channel is null, cannot send message")
                    return@post
                }

                // Match the Flutter service's expected format
                when (type) {
                    "wear_audio_received" -> {
                        val message = mapOf(
                            "audioPath" to data,
                            "watchId" to "unknown"  // Will be improved later
                        )
                        methodChannel?.invokeMethod("onWearAudioReceived", message)
                        Log.d(TAG, "Sent audio path to Flutter: $data")
                    }
                    else -> {
                        val message = mapOf(
                            "type" to type,
                            "data" to data
                        )
                        methodChannel?.invokeMethod("onWearMessage", message)
                        Log.d(TAG, "Sent message to Flutter: $type")
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error sending message to Flutter", e)
            }
        }
    }

    fun sendErrorToFlutter(errorMessage: String) {
        mainHandler.post {
            try {
                if (methodChannel == null) {
                    Log.w(TAG, "Method channel is null, cannot send error")
                    return@post
                }

                val message = mapOf(
                    "type" to "error",
                    "data" to errorMessage
                )

                methodChannel?.invokeMethod("onWearMessage", message)
                Log.d(TAG, "Sent error to Flutter: $errorMessage")
            } catch (e: Exception) {
                Log.e(TAG, "Error sending error to Flutter", e)
            }
        }
    }

    fun cleanup() {
        mainHandler.post {
            methodChannel = null
            context = null
            Log.d(TAG, "Cleaned up WearCommunicationHandler")
        }
    }
}