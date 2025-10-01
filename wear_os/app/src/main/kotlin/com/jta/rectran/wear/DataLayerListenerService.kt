package com.jta.rectran.wear

import android.util.Log
import com.google.android.gms.wearable.MessageEvent
import com.google.android.gms.wearable.WearableListenerService

/**
 * Service that listens for messages from the phone
 */
class DataLayerListenerService : WearableListenerService() {
    
    companion object {
        private const val TAG = "DataLayerListener"
    }
    
    override fun onMessageReceived(messageEvent: MessageEvent) {
        Log.d(TAG, "Message received: ${messageEvent.path}")
        
        when {
            messageEvent.path.startsWith("/rectran/success") -> {
                // Phone confirmed successful transcription
                val message = String(messageEvent.data)
                Log.d(TAG, "Transcription success: $message")
                // Could trigger a notification or update UI
            }
            
            messageEvent.path.startsWith("/rectran/error") -> {
                // Phone reported an error
                val error = String(messageEvent.data)
                Log.e(TAG, "Transcription error: $error")
            }
            
            else -> {
                Log.d(TAG, "Unknown message path: ${messageEvent.path}")
            }
        }
    }
}
