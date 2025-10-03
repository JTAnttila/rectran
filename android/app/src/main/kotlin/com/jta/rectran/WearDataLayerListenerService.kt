package com.jta.rectran

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import com.google.android.gms.wearable.MessageEvent
import com.google.android.gms.wearable.WearableListenerService
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import org.json.JSONObject
import java.io.File
import java.io.FileOutputStream

class WearDataLayerListenerService : WearableListenerService() {

    companion object {
        private const val TAG = "WearListenerService"
        private const val MESSAGE_PATH_AUDIO_METADATA = "/rectran/audio/metadata"
        private const val MESSAGE_PATH_AUDIO_CHUNK = "/rectran/audio/chunk"
        private const val NOTIFICATION_ID = 1
        private const val CHANNEL_ID = "wear_audio_transfer"
        private const val CHANNEL_NAME = "Wear Audio Transfer"
    }

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
    private var fileOutputStream: FileOutputStream? = null
    private var currentFile: File? = null
    private var expectedChunks = 0
    private var receivedChunks = 0
    private var currentWatchNodeId: String? = null

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "WearDataLayerListenerService created")
        createNotificationChannel()
        val notification = createNotification("Waiting for watch...")
        startForeground(NOTIFICATION_ID, notification)
    }

    override fun onMessageReceived(messageEvent: MessageEvent) {
        super.onMessageReceived(messageEvent)
        Log.d(TAG, "Message received: ${messageEvent.path} from ${messageEvent.sourceNodeId}")

        when (messageEvent.path) {
            MESSAGE_PATH_AUDIO_METADATA -> {
                handleAudioMetadata(messageEvent)
            }
            MESSAGE_PATH_AUDIO_CHUNK -> {
                handleAudioChunk(messageEvent)
            }
            else -> {
                Log.w(TAG, "Unknown message path: ${messageEvent.path}")
            }
        }
    }

    private fun handleAudioMetadata(messageEvent: MessageEvent) {
        scope.launch {
            try {
                Log.d(TAG, "Handling audio metadata")
                val dataString = String(messageEvent.data, Charsets.UTF_8)
                val metadata = JSONObject(dataString)
                
                val fileName = metadata.getString("fileName")
                val totalChunks = metadata.getInt("totalChunks")
                
                Log.d(TAG, "Audio metadata: fileName=$fileName, totalChunks=$totalChunks")
                
                cleanup()
                
                val audioDir = File(filesDir, "wear_audio")
                if (!audioDir.exists()) {
                    audioDir.mkdirs()
                }
                
                currentFile = File(audioDir, fileName)
                fileOutputStream = FileOutputStream(currentFile!!)
                expectedChunks = totalChunks
                receivedChunks = 0
                currentWatchNodeId = messageEvent.sourceNodeId
                
                Log.d(TAG, "Ready to receive $expectedChunks chunks for ${currentFile?.name}")
                
                val notification = createNotification("Receiving audio from watch...")
                startForeground(NOTIFICATION_ID, notification)
                
            } catch (e: Exception) {
                Log.e(TAG, "Error handling audio metadata", e)
                cleanup()
                stopServiceAfterError("Failed to process metadata: ${e.message}")
            }
        }
    }

    private fun handleAudioChunk(messageEvent: MessageEvent) {
        scope.launch {
            try {
                if (fileOutputStream == null) {
                    Log.w(TAG, "Received chunk but no active transfer")
                    return@launch
                }
                
                if (messageEvent.sourceNodeId != currentWatchNodeId) {
                    Log.w(TAG, "Received chunk from different watch node, ignoring")
                    return@launch
                }
                
                val dataString = String(messageEvent.data, Charsets.UTF_8)
                val chunkData = JSONObject(dataString)
                val chunkIndex = chunkData.getInt("chunkIndex")
                val data = android.util.Base64.decode(
                    chunkData.getString("data"),
                    android.util.Base64.DEFAULT
                )
                
                fileOutputStream?.write(data)
                fileOutputStream?.flush()
                receivedChunks++
                
                Log.d(TAG, "Received chunk $receivedChunks/$expectedChunks (${data.size} bytes)")
                
                val progress = (receivedChunks * 100) / expectedChunks
                val notification = createNotification("Receiving audio: $progress%")
                startForeground(NOTIFICATION_ID, notification)
                
                if (receivedChunks >= expectedChunks) {
                    Log.d(TAG, "All chunks received, finishing transfer")
                    finishReceiving()
                    
                    val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                    notificationManager.cancel(NOTIFICATION_ID)
                    
                    processWearAudio(currentFile?.absolutePath ?: "")
                }
                
            } catch (e: Exception) {
                Log.e(TAG, "Error handling audio chunk: ${e.message}", e)
                cleanup()
                stopServiceAfterError("Failed to receive chunk: ${e.message}")
            }
        }
    }

    private fun finishReceiving() {
        try {
            fileOutputStream?.close()
            Log.d(TAG, "Audio file saved: ${currentFile?.absolutePath}")
        } catch (e: Exception) {
            Log.e(TAG, "Error closing file: ${e.message}", e)
        }
    }

    private fun cleanup() {
        Log.d(TAG, "Cleaning up resources")
        try {
            fileOutputStream?.close()
        } catch (e: Exception) {
            // Ignore
        } finally {
            fileOutputStream = null
            currentFile = null
            expectedChunks = 0
            receivedChunks = 0
            currentWatchNodeId = null
        }
    }

    private fun stopServiceAfterError(message: String) {
        Log.e(TAG, "Stopping service after error: $message")
        
        scope.launch {
            try {
                val notification = createNotification(message)
                startForeground(NOTIFICATION_ID, notification)
                
                delay(3000)
                
                stopForeground(Service.STOP_FOREGROUND_REMOVE)
                stopSelf()
            } catch (e: Exception) {
                Log.e(TAG, "Error during service shutdown: ${e.message}")
                stopSelf()
            }
        }
    }

    private fun processWearAudio(audioPath: String) {
        try {
            val watchId = currentWatchNodeId ?: "unknown"
            Log.d(TAG, "Processing audio from watch $watchId: $audioPath")
            
            // Update notification to show completion (not ongoing so it can be dismissed)
            val completionNotification = createNotification("Audio received successfully!", ongoing = false)
            startForeground(NOTIFICATION_ID, completionNotification)
            
            // Send to Flutter
            WearCommunicationHandler.sendAudioToFlutter(audioPath, watchId)
            Log.d(TAG, "Sent audio file to Flutter: $audioPath")
            
            // Dismiss notification and stop service after a short delay
            scope.launch {
                delay(1500)
                
                Log.d(TAG, "Stopping foreground service and dismissing notification")
                stopForeground(Service.STOP_FOREGROUND_REMOVE)
                stopSelf()
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error processing wear audio", e)
            Log.e(TAG, "Stack trace:", e)
            stopServiceAfterError("Failed to process audio: ${e.message}")
        } finally {
            cleanup()
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Log.d(TAG, "Creating notification channel: $CHANNEL_ID")
            
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Notifications for audio transfer from Wear OS"
                setShowBadge(false)
            }
            
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(message: String, ongoing: Boolean = true) =
        NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Rectran")
            .setContentText(message)
            .setSmallIcon(android.R.drawable.stat_sys_upload)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(ongoing)
            .setAutoCancel(!ongoing)
            .build()

    override fun onDestroy() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            Log.d(TAG, "Service being destroyed")
            scope.cancel()
            cleanup()
        }
        super.onDestroy()
    }
}