package com.jta.rectran.wear

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.media.MediaRecorder
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import kotlinx.coroutines.launch
import java.io.File
import java.io.IOException

class RecordingService : Service() {
    
    private var mediaRecorder: MediaRecorder? = null
    private var recordingFile: File? = null
    private var startTime: Long = 0
    
    companion object {
        private const val TAG = "RecordingService"
        const val ACTION_START_RECORDING = "com.jta.rectran.wear.START_RECORDING"
        const val ACTION_STOP_RECORDING = "com.jta.rectran.wear.STOP_RECORDING"
        private const val NOTIFICATION_ID = 1001
        private const val CHANNEL_ID = "recording_channel"
    }
    
    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START_RECORDING -> {
                startRecording()
            }
            ACTION_STOP_RECORDING -> {
                stopRecording()
                stopSelf()
            }
        }
        return START_NOT_STICKY
    }
    
    private fun startRecording() {
        try {
            // Create recording file
            val recordingsDir = File(getExternalFilesDir(null), "recordings")
            if (!recordingsDir.exists()) {
                recordingsDir.mkdirs()
            }
            
            val timestamp = System.currentTimeMillis()
            recordingFile = File(recordingsDir, "recording_$timestamp.m4a")
            
            // Setup MediaRecorder
            mediaRecorder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                MediaRecorder(this)
            } else {
                @Suppress("DEPRECATION")
                MediaRecorder()
            }
            
            mediaRecorder?.apply {
                setAudioSource(MediaRecorder.AudioSource.MIC)
                setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
                setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
                setAudioEncodingBitRate(128000)
                setAudioSamplingRate(44100)
                setOutputFile(recordingFile?.absolutePath)
                prepare()
                start()
            }
            
            startTime = System.currentTimeMillis()
            startForeground(NOTIFICATION_ID, createNotification())
            
            Log.d(TAG, "Recording started: ${recordingFile?.name}")
            
        } catch (e: IOException) {
            Log.e(TAG, "Failed to start recording", e)
            stopSelf()
        } catch (e: Exception) {
            Log.e(TAG, "Unexpected error starting recording", e)
            stopSelf()
        }
    }
    
    private fun stopRecording() {
        try {
            mediaRecorder?.apply {
                stop()
                release()
            }
            mediaRecorder = null
            
            val duration = System.currentTimeMillis() - startTime
            Log.d(TAG, "Recording stopped. Duration: ${duration}ms")
            
            // Send file to phone (keep file as backup even after successful send)
            recordingFile?.let { file ->
                if (file.exists() && file.length() > 0) {
                    // Send asynchronously using coroutine
                    kotlinx.coroutines.MainScope().launch {
                        val sent = WearCommunicationManager.sendAudioFile(this@RecordingService, file)
                        if (sent) {
                            Log.d(TAG, "Audio file sent to phone successfully")
                            Log.d(TAG, "File backed up on watch at: ${file.absolutePath}")
                            // Note: File is kept as backup. Old files will be cleaned up automatically
                            // by Android when storage gets low, or user can manually delete in Files app
                        } else {
                            Log.e(TAG, "Failed to send audio file to phone - file remains on watch as backup")
                        }
                    }
                } else {
                    Log.e(TAG, "Recording file is empty or doesn't exist")
                }
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping recording", e)
        }
    }
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Recording",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Recording audio on watch"
            }
            
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }
    
    private fun createNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Recording Audio")
            .setContentText("Recording in progress...")
            .setSmallIcon(android.R.drawable.ic_btn_speak_now)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }
    
    override fun onBind(intent: Intent?): IBinder? = null
    
    override fun onDestroy() {
        mediaRecorder?.release()
        mediaRecorder = null
        super.onDestroy()
    }
}
