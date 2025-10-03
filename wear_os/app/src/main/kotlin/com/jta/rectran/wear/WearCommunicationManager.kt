package com.jta.rectran.wear

import android.content.Context
import android.util.Log
import com.google.android.gms.tasks.Tasks
import com.google.android.gms.wearable.*
import kotlinx.coroutines.*
import org.json.JSONObject
import java.io.File

/**
 * Manages communication between watch and phone using Wear OS Data Layer API
 */
object WearCommunicationManager {
    private const val TAG = "WearCommManager"
    private const val MESSAGE_PATH = "/rectran/audio"
    private const val CHUNK_SIZE = 100 * 1024 // 100KB chunks (smaller for message API)
    private const val MAX_RETRY_ATTEMPTS = 3
    
    // Callback for transfer progress
    var onTransferProgress: ((current: Int, total: Int) -> Unit)? = null
    
    private lateinit var dataClient: DataClient
    private lateinit var messageClient: MessageClient
    private lateinit var nodeClient: NodeClient
    
    fun initialize(context: Context) {
        dataClient = Wearable.getDataClient(context)
        messageClient = Wearable.getMessageClient(context)
        nodeClient = Wearable.getNodeClient(context)
        Log.d(TAG, "Wear OS Data Layer initialized")
    }
    
    /**
     * Check if phone is connected
     */
    suspend fun isPhoneConnected(): Boolean = withContext(Dispatchers.IO) {
        try {
            val nodes = Tasks.await(nodeClient.connectedNodes)
            val connected = nodes.isNotEmpty()
            Log.d(TAG, "Phone connected: $connected, nodes: ${nodes.size}")
            connected
        } catch (e: Exception) {
            Log.e(TAG, "Error checking connection", e)
            false
        }
    }
    
    /**
     * Send audio file to phone using Data Layer API with retry
     */
    suspend fun sendAudioFile(context: Context, file: File): Boolean = withContext(Dispatchers.IO) {
        var attempt = 0
        var lastError: Exception? = null
        
        while (attempt < MAX_RETRY_ATTEMPTS) {
            attempt++
            try {
                Log.d(TAG, "Transfer attempt $attempt/$MAX_RETRY_ATTEMPTS")
                val success = sendAudioFileInternal(context, file)
                if (success) {
                    return@withContext true
                }
            } catch (e: Exception) {
                lastError = e
                Log.e(TAG, "Attempt $attempt failed", e)
                if (attempt < MAX_RETRY_ATTEMPTS) {
                    kotlinx.coroutines.delay(1000L * attempt) // Exponential backoff
                }
            }
        }
        
        Log.e(TAG, "All transfer attempts failed", lastError)
        return@withContext false
    }
    
    /**
     * Internal method to send audio file (single attempt)
     */
    private suspend fun sendAudioFileInternal(context: Context, file: File): Boolean = withContext(Dispatchers.IO) {
        try {
            if (!file.exists() || file.length() == 0L) {
                Log.e(TAG, "File does not exist or is empty")
                return@withContext false
            }
            
            // Get connected nodes (phones)
            val nodes = Tasks.await(nodeClient.connectedNodes)
            if (nodes.isEmpty()) {
                Log.e(TAG, "No connected nodes found")
                return@withContext false
            }
            
            val phoneNode = nodes.first()
            Log.d(TAG, "Sending file to node: ${phoneNode.displayName} (${phoneNode.id})")
            
            // Read file
            val fileBytes = file.readBytes()
            val totalChunks = (fileBytes.size + CHUNK_SIZE - 1) / CHUNK_SIZE
            
            Log.d(TAG, "File: ${file.name}, Size: ${fileBytes.size} bytes, Chunks: $totalChunks")
            
            // Send metadata first
            val metadata = """
                {
                    "type": "audio_start",
                    "filename": "${file.name}",
                    "size": ${fileBytes.size},
                    "chunks": $totalChunks,
                    "timestamp": ${System.currentTimeMillis()}
                }
            """.trimIndent()
            
            // Send metadata with correct message path format (matching phone app's expected format exactly)
            val metadataJson = JSONObject().apply {
                put("fileName", file.name)  // Phone expects "fileName" (camelCase)
                put("totalChunks", totalChunks)
                put("fileSize", fileBytes.size)
                put("timestamp", System.currentTimeMillis())
            }
            
            Log.d(TAG, "Sending metadata JSON: ${metadataJson.toString()}")
            
            Tasks.await(
                messageClient.sendMessage(
                    phoneNode.id,
                    "/rectran/audio/metadata",
                    metadataJson.toString().toByteArray(Charsets.UTF_8)
                )
            )
            
            Log.d(TAG, "Metadata sent to /rectran/audio/metadata")
            
            // Send file in chunks
            var offset = 0
            var chunkIndex = 0
            
            while (offset < fileBytes.size) {
                val chunkSize = minOf(CHUNK_SIZE, fileBytes.size - offset)
                val chunk = fileBytes.copyOfRange(offset, offset + chunkSize)
                
                // Encode chunk as JSON with base64 data (matching phone app's expectation)
                val chunkJson = JSONObject().apply {
                    put("chunkIndex", chunkIndex)
                    put("data", android.util.Base64.encodeToString(chunk, android.util.Base64.NO_WRAP))
                    put("size", chunk.size)
                }
                
                Tasks.await(
                    messageClient.sendMessage(
                        phoneNode.id,
                        "/rectran/audio/chunk",
                        chunkJson.toString().toByteArray(Charsets.UTF_8)
                    )
                )
                
                offset += chunkSize
                chunkIndex++
                
                // Report progress
                onTransferProgress?.invoke(chunkIndex, totalChunks)
                
                Log.d(TAG, "Sent chunk $chunkIndex/$totalChunks (${chunk.size} bytes)")
                
                // Small delay to avoid overwhelming the phone
                delay(10)
            }
            
            // Send completion message (phone app doesn't require this, but good for logging)
            Log.d(TAG, "All chunks sent. Total: $totalChunks")
            
            // Give phone time to process final chunks
            delay(500)
            
            Log.d(TAG, "File transfer completed successfully")
            true
            
        } catch (e: Exception) {
            Log.e(TAG, "Error sending file", e)
            false
        }
    }
    
    /**
     * Send a simple status message to phone
     */
    suspend fun sendMessage(message: String): Boolean = withContext(Dispatchers.IO) {
        try {
            val nodes = Tasks.await(nodeClient.connectedNodes)
            if (nodes.isEmpty()) {
                Log.e(TAG, "No connected nodes")
                return@withContext false
            }
            
            val phoneNode = nodes.first()
            Tasks.await(
                messageClient.sendMessage(
                    phoneNode.id,
                    "$MESSAGE_PATH/status",
                    message.toByteArray()
                )
            )
            
            Log.d(TAG, "Message sent: $message")
            true
        } catch (e: Exception) {
            Log.e(TAG, "Error sending message", e)
            false
        }
    }
}
