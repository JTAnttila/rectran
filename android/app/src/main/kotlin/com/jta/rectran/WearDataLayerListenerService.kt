package com.jta.rectranpackage com.jta.rectran



import android.app.NotificationChannelimport android.app.NotificationChannel

import android.app.NotificationManagerimport android.app.NotificationManager

import android.app.Serviceimport android.app.Service

import android.content.Contextimport android.content.Context

import android.os.Buildimport android.os.Build

import android.util.Logimport android.util.Log

import androidx.core.app.NotificationCompatimport androidx.core.app.NotificationCompat

import com.google.android.gms.wearable.MessageEventimport com.google.android.gms.wearable.MessageEvent

import com.google.android.gms.wearable.WearableListenerServiceimport com.google.android.gms.wearable.WearableListenerService

import kotlinx.coroutines.CoroutineScopeimport kotlinx.coroutines.CoroutineScope

import kotlinx.coroutines.Dispatchersimport kotlinx.coroutines.Dispatchers

import kotlinx.coroutines.SupervisorJobimport kotlinx.coroutines.SupervisorJob

import kotlinx.coroutines.cancelimport kotlinx.coroutines.cancel

import kotlinx.coroutines.delayimport kotlinx.coroutines.delay

import kotlinx.coroutines.launchimport kotlinx.coroutines.launch

import org.json.JSONObjectimport org.json.JSONObject

import java.io.Fileimport java.io.File

import java.io.FileOutputStreamimport java.io.FileOutputStream



class WearDataLayerListenerService : WearableListenerService() {class WearDataLayerListenerService : WearableListenerService() {

    companion object {    

        private const val TAG = "WearListenerService"    companion object {

        private const val MESSAGE_PATH_AUDIO_METADATA = "/rectran/audio/metadata"        private const val TAG = "WearListenerService"

        private const val MESSAGE_PATH_AUDIO_CHUNK = "/rectran/audio/chunk"        private const val MESSAGE_PATH_AUDIO_METADATA = "/rectran/audio/metadata"

        private const val NOTIFICATION_ID = 1        private const val MESSAGE_PATH_AUDIO_CHUNK = "/rectran/audio/chunk"

    }        private const val NOTIFICATION_ID = 1

        private const val CHANNEL_ID = "wear_audio_transfer"

    private val serviceScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)        private const val CHANNEL_NAME = "Wear Audio Transfer"

    private var currentFile: File? = null    }

    private var fileOutputStream: FileOutputStream? = null

    private var expectedChunks = 0    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

    private var receivedChunks = 0    private var fileOutputStream: FileOutputStream? = null

    private var currentWatchNodeId: String? = null    private var currentFile: File? = null

    private var expectedChunks = 0

    override fun onCreate() {    private var receivedChunks = 0

        super.onCreate()    private var currentWatchNodeId: String? = null

        Log.d(TAG, "WearDataLayerListenerService created")

        createNotificationChannel()    override fun onCreate() {

        startForeground(NOTIFICATION_ID, createNotification("Waiting for watch..."))        super.onCreate()

    }        Log.d(TAG, "WearDataLayerListenerService created")

        

    override fun onMessageReceived(messageEvent: MessageEvent) {        createNotificationChannel()

        Log.d(TAG, "Message received: ${messageEvent.path} from ${messageEvent.sourceNodeId}")        val notification = createNotification("Waiting for watch...")

                startForeground(NOTIFICATION_ID, notification)

        when (messageEvent.path) {    }

            MESSAGE_PATH_AUDIO_METADATA -> {

                handleAudioMetadata(messageEvent)    override fun onMessageReceived(messageEvent: MessageEvent) {

            }        super.onMessageReceived(messageEvent)

            MESSAGE_PATH_AUDIO_CHUNK -> {        

                handleAudioChunk(messageEvent)        Log.d(TAG, "Message received: ${messageEvent.path} from ${messageEvent.sourceNodeId}")

            }        

        }        when (messageEvent.path) {

    }            MESSAGE_PATH_AUDIO_METADATA -> {

                handleAudioMetadata(messageEvent)

    private fun handleAudioMetadata(messageEvent: MessageEvent) {            }

        try {            MESSAGE_PATH_AUDIO_CHUNK -> {

            val jsonString = String(messageEvent.data)                handleAudioChunk(messageEvent)

            val metadata = JSONObject(jsonString)            }

                    }

            Log.d(TAG, "Metadata received: $jsonString")    }

            

            val filename = metadata.getString("filename")    private fun handleAudioMetadata(messageEvent: MessageEvent) {

            val size = metadata.getLong("size")        try {

            val chunks = metadata.getInt("chunks")            val metadataString = String(messageEvent.data, Charsets.UTF_8)

                        Log.d(TAG, "Metadata received: $metadataString")

            currentWatchNodeId = messageEvent.sourceNodeId            

            expectedChunks = chunks            val json = JSONObject(metadataString)

            receivedChunks = 0            val fileName = json.getString("filename")

                        val fileSize = json.getLong("size")

            // Create directory for wear audio files            val totalChunks = json.getInt("chunks")

            val audioDir = File(filesDir, "wear_audio")            val timestamp = json.getLong("timestamp")

            if (!audioDir.exists()) {            

                audioDir.mkdirs()            currentWatchNodeId = messageEvent.sourceNodeId

            }            

                        // Create file in app's files directory

            currentFile = File(audioDir, filename)            val audioDir = File(filesDir, "wear_audio")

            fileOutputStream = FileOutputStream(currentFile)            if (!audioDir.exists()) {

                            audioDir.mkdirs()

            Log.d(TAG, "Prepared to receive $chunks chunks for file: $filename ($size bytes)")            }

                        

            val notification = createNotification("Receiving audio... 0%")            currentFile = File(audioDir, fileName)

            startForeground(NOTIFICATION_ID, notification)            fileOutputStream = FileOutputStream(currentFile)

                        expectedChunks = totalChunks

        } catch (e: Exception) {            receivedChunks = 0

            Log.e(TAG, "Error handling metadata", e)            

            cleanup()            Log.d(TAG, "Prepared to receive $totalChunks chunks for file: $fileName (${fileSize} bytes)")

        }            

    }            val notification = createNotification("Receiving audio... 0%")

            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

    private fun handleAudioChunk(messageEvent: MessageEvent) {            notificationManager.notify(NOTIFICATION_ID, notification)

        try {            

            val data = messageEvent.data        } catch (e: Exception) {

                        Log.e(TAG, "Error handling metadata", e)

            // First 4 bytes are the chunk index            cleanup()

            if (data.size <= 4) {            stopServiceAfterError("Metadata error: ${e.message}")

                Log.e(TAG, "Invalid chunk data size: ${data.size}")        }

                return    }

            }

                private fun handleAudioChunk(messageEvent: MessageEvent) {

            // Skip the 4-byte index prefix and write the rest        try {

            val audioData = data.copyOfRange(4, data.size)            val chunkData = messageEvent.data

            fileOutputStream?.write(audioData)            

            fileOutputStream?.flush()            // First 4 bytes are the chunk index

                        val actualData = chunkData.copyOfRange(4, chunkData.size)

            receivedChunks++            

            val progress = (receivedChunks * 100) / expectedChunks            fileOutputStream?.write(actualData)

                        fileOutputStream?.flush()

            Log.d(TAG, "Chunk received: $receivedChunks/$expectedChunks ($progress%)")            

                        receivedChunks++

            val notification = createNotification("Receiving audio... $progress%")            

            startForeground(NOTIFICATION_ID, notification)            val percentage = (receivedChunks * 100) / expectedChunks

                        Log.d(TAG, "Chunk received: $receivedChunks/$expectedChunks ($percentage%)")

            if (receivedChunks >= expectedChunks) {            

                Log.d(TAG, "All chunks received: $receivedChunks/$expectedChunks")            val notification = createNotification("Receiving audio... $percentage%")

                finishReceiving()            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

            }            notificationManager.notify(NOTIFICATION_ID, notification)

                        

        } catch (e: Exception) {            if (receivedChunks >= expectedChunks) {

            Log.e(TAG, "Error handling chunk", e)                Log.d(TAG, "All chunks received: $receivedChunks/$expectedChunks")

            cleanup()                finishReceiving()

        }            }

    }            

        } catch (e: Exception) {

    private fun finishReceiving() {            Log.e(TAG, "Error handling chunk", e)

        try {            cleanup()

            fileOutputStream?.close()            stopServiceAfterError("Chunk error: ${e.message}")

            fileOutputStream = null        }

                }

            val audioPath = currentFile?.absolutePath

            val watchId = currentWatchNodeId    private fun finishReceiving() {

                    try {

            if (audioPath != null && watchId != null) {            fileOutputStream?.flush()

                Log.d(TAG, "Audio file complete: $audioPath")            fileOutputStream?.close()

                            fileOutputStream = null

                serviceScope.launch {            

                    try {            val audioFile = currentFile

                        WearCommunicationHandler.processWearAudio(            val watchId = currentWatchNodeId

                            this@WearDataLayerListenerService,            

                            audioPath,            if (audioFile != null && watchId != null) {

                            watchId                Log.d(TAG, "Audio file complete: ${audioFile.absolutePath}")

                        )                

                                        // Notify Flutter

                        // Give Flutter time to receive the message                scope.launch {

                        delay(1000)                    try {

                                                WearCommunicationHandler.processWearAudio(

                        // Stop foreground service and dismiss notification                            applicationContext,

                        stopForeground(true)                            audioFile.absolutePath,

                        stopSelf()                            watchId

                                                )

                    } catch (e: Exception) {                        

                        Log.e(TAG, "Error processing audio file: $audioPath", e)                        // Give Flutter time to receive the message

                        Log.e(TAG, "Processing error: ${e.message}")                        delay(1000)

                    }                        

                }                        // Stop the foreground service and dismiss notification

            }                        stopForeground(true)

                                    stopSelf()

        } catch (e: Exception) {                        

            Log.e(TAG, "Error finishing transfer", e)                    } catch (e: Exception) {

        } finally {                        Log.e(TAG, "Error processing audio file: ${audioFile.absolutePath}", e)

            cleanup()                        stopServiceAfterError("Processing error: ${e.message}")

        }                    }

    }                }

            } else {

    private fun cleanup() {                Log.e(TAG, "Missing audioFile or watchId after transfer")

        try {                stopServiceAfterError("Missing file or watch ID")

            fileOutputStream?.close()            }

        } catch (e: Exception) {            

            Log.e(TAG, "Error closing file", e)            cleanup()

        }            

                } catch (e: Exception) {

        fileOutputStream = null            Log.e(TAG, "Error finishing receive", e)

        currentFile = null            cleanup()

        expectedChunks = 0            stopServiceAfterError("Finish error: ${e.message}")

        receivedChunks = 0        }

        currentWatchNodeId = null    }

    }

    private fun stopServiceAfterError(errorMessage: String) {

    private fun createNotificationChannel() {        Log.e(TAG, errorMessage)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {        val notification = createNotification("Error: $errorMessage")

            val channel = NotificationChannel(        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

                "wear_transfer",        notificationManager.notify(NOTIFICATION_ID, notification)

                "Wear Audio Transfer",        

                NotificationManager.IMPORTANCE_LOW        scope.launch {

            ).apply {            delay(3000)

                description = "Shows progress of audio file transfers from watch"            stopForeground(true)

                setShowBadge(false)            stopSelf()

            }        }

                }

            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

            notificationManager.createNotificationChannel(channel)    private fun cleanup() {

        }        try {

    }            fileOutputStream?.close()

        } catch (e: Exception) {

    private fun createNotification(message: String): android.app.Notification {            Log.e(TAG, "Error closing file output stream", e)

        return NotificationCompat.Builder(this, "wear_transfer")        }

            .setContentTitle("Rectran Watch")        fileOutputStream = null

            .setContentText(message)        currentFile = null

            .setSmallIcon(android.R.drawable.stat_sys_download)        expectedChunks = 0

            .setPriority(NotificationCompat.PRIORITY_LOW)        receivedChunks = 0

            .setOngoing(false)        currentWatchNodeId = null

            .build()    }

    }

    private fun createNotificationChannel() {

    override fun onDestroy() {        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {

        Log.d(TAG, "WearDataLayerListenerService destroyed")            val channel = NotificationChannel(

        serviceScope.cancel()                CHANNEL_ID,

        cleanup()                CHANNEL_NAME,

        super.onDestroy()                NotificationManager.IMPORTANCE_LOW

    }            ).apply {

}                description = "Notifications for audio transfer from watch"

                setShowBadge(false)
            }
            
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(message: String): android.app.Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Rectran Watch")
            .setContentText(message)
            .setSmallIcon(android.R.drawable.stat_sys_upload)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(false)
            .build()
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "WearDataLayerListenerService destroyed")
        scope.cancel()
        cleanup()
    }
}