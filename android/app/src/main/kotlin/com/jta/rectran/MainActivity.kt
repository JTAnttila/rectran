package com.jta.rectran

import android.content.Intent
import android.os.Bundle
import android.util.Log
import androidx.annotation.NonNull
import com.google.android.gms.wearable.MessageClient
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
        private const val AUDIO_CHANNEL = "com.jta.rectran/wear_audio"
        private const val WEAR_MESSAGE_PATH = "/rectran/message"
    }

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
    private lateinit var messageClient: MessageClient
    private var methodChannel: MethodChannel? = null
    private var audioMethodChannel: MethodChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d(TAG, "MainActivity created")
        messageClient = Wearable.getMessageClient(this)
        WearCommunicationHandler.initialize(this)
        val serviceIntent = Intent(this, WearDataLayerListenerService::class.java)
        startService(serviceIntent)
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Set up control channel for wear messages
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "sendMessageToWear" -> {
                    val message = call.argument<String>("message")
                    if (message != null) {
                        sendMessageToWear(message, result)
                    } else {
                        result.error("INVALID_ARGUMENT", "Message cannot be null", null)
                    }
                }
                "checkWearConnection" -> {
                    checkWearConnection(result)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        // Set up audio channel for wear audio transfer
        audioMethodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, AUDIO_CHANNEL)
        WearCommunicationHandler.setMethodChannel(audioMethodChannel)
        
        Log.d(TAG, "Flutter engine configured with method channels")
    }

    private fun sendMessageToWear(message: String, result: MethodChannel.Result) {
        scope.launch {
            try {
                val nodeClient = Wearable.getNodeClient(this@MainActivity)
                val nodes = nodeClient.connectedNodes.await()
                if (nodes.isEmpty()) {
                    result.error("NO_WATCH", "No connected Wear OS device found", null)
                    return@launch
                }
                var sentToAny = false
                for (node in nodes) {
                    try {
                        messageClient.sendMessage(node.id, WEAR_MESSAGE_PATH, message.toByteArray(Charsets.UTF_8)).await()
                        Log.d(TAG, "Message sent to ${node.displayName}: $message")
                        sentToAny = true
                    } catch (e: Exception) {
                        Log.e(TAG, "Failed to send message to ${node.displayName}", e)
                    }
                }
                if (sentToAny) {
                    result.success("Message sent to watch")
                } else {
                    result.error("SEND_FAILED", "Failed to send message to any watch", null)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error sending message to wear", e)
                result.error("ERROR", "Failed to send message: ${e.message}", null)
            }
        }
    }

    private fun checkWearConnection(result: MethodChannel.Result) {
        scope.launch {
            try {
                val nodeClient = Wearable.getNodeClient(this@MainActivity)
                val nodes = nodeClient.connectedNodes.await()
                if (nodes.isEmpty()) {
                    result.success(mapOf("connected" to false, "message" to "No Wear OS device connected"))
                } else {
                    val nodeNames = nodes.map { it.displayName }
                    result.success(mapOf("connected" to true, "devices" to nodeNames, "message" to "Connected to ${nodes.size} device(s)"))
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error checking wear connection", e)
                result.error("ERROR", "Failed to check connection: ${e.message}", null)
            }
        }
    }

    override fun onDestroy() {
        Log.d(TAG, "MainActivity being destroyed")
        scope.cancel()
        WearCommunicationHandler.cleanup()
        super.onDestroy()
    }
}