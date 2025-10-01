package com.jta.rectranpackage com.jta.rectranpackage com.jta.rectran



import android.content.Intent

import android.os.Bundle

import android.util.Logimport android.content.Intentimport android.content.Intent

import androidx.annotation.NonNull

import com.google.android.gms.wearable.MessageClientimport android.os.Bundleimport android.os.Bundle

import com.google.android.gms.wearable.Wearable

import io.flutter.embedding.android.FlutterActivityimport android.util.Logimport android.util.Log

import io.flutter.embedding.engine.FlutterEngine

import io.flutter.plugin.common.MethodChannelimport androidx.annotation.NonNullimport androidx.annotation.NonNull

import kotlinx.coroutines.CoroutineScope

import kotlinx.coroutines.Dispatchersimport com.google.android.gms.wearable.MessageClientimport com.google.android.gms.wearable.MessageClient

import kotlinx.coroutines.SupervisorJob

import kotlinx.coroutines.cancelimport com.google.android.gms.wearable.Wearableimport com.google.android.gms.wearable.Wearable

import kotlinx.coroutines.launch

import kotlinx.coroutines.tasks.awaitimport io.flutter.embedding.android.FlutterActivityimport io.flutter.embedding.android.FlutterActivity



class MainActivity: FlutterActivity() {import io.flutter.embedding.engine.FlutterEngineimport io.flutter.embedding.engine.FlutterEngine

    companion object {

        private const val TAG = "RectranMainActivity"import io.flutter.plugin.common.MethodChannelimport io.flutter.plugin.common.MethodChannel

        private const val CHANNEL = "com.jta.rectran/wear"

        private const val MESSAGE_PATH_SUCCESS = "/rectran/transcription/success"import kotlinx.coroutines.CoroutineScopeimport kotlinx.coroutines.CoroutineScope

        private const val MESSAGE_PATH_ERROR = "/rectran/transcription/error"

    }import kotlinx.coroutines.Dispatchersimport kotlinx.coroutines.Dispatchers



    private val mainScope = CoroutineScope(SupervisorJob() + Dispatchers.Main)import kotlinx.coroutines.SupervisorJobimport kotlinx.coroutines.SupervisorJob

    private var methodChannel: MethodChannel? = null

import kotlinx.coroutines.cancelimport kotlinx.coroutines.cancel

    override fun onCreate(savedInstanceState: Bundle?) {

        super.onCreate(savedInstanceState)import kotlinx.coroutines.launchimport kotlinx.coroutines.launch

        

        val serviceIntent = Intent(this, WearDataLayerListenerService::class.java)import kotlinx.coroutines.tasks.awaitimport kotlinx.coroutines.tasks.await

        startService(serviceIntent)

    }



    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {class MainActivity: FlutterActivity() {class MainActivity: FlutterActivity() {

        super.configureFlutterEngine(flutterEngine)

            companion object {    companion object {

        WearCommunicationHandler.initialize(flutterEngine)

                private const val TAG = "RectranMainActivity"        private const val TAG = "RectranMainActivity"

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        methodChannel?.setMethodCallHandler { call, result ->        private const val CHANNEL = "com.jta.rectran/wear"        private const val CHANNEL = "com.jta.rectran/wear"

            when (call.method) {

                "sendSuccessToWatch" -> {        private const val MESSAGE_PATH_SUCCESS = "/rectran/transcription/success"        private const val MESSAGE_PATH_SUCCESS = "/rectran/transcription/success"

                    mainScope.launch {

                        try {        private const val MESSAGE_PATH_ERROR = "/rectran/transcription/error"        private const val MESSAGE_PATH_ERROR = "/rectran/transcription/error"

                            val watchNodeId = call.argument<String>("watchNodeId")

                            val message = call.argument<String>("message")    }    }

                            

                            if (watchNodeId == null || message == null) {

                                result.error("INVALID_ARGUMENTS", "Missing watchNodeId or message", null)

                                return@launch    private val mainScope = CoroutineScope(SupervisorJob() + Dispatchers.Main)    private val mainScope = CoroutineScope(SupervisorJob() + Dispatchers.Main)

                            }

                                private var methodChannel: MethodChannel? = null    private var methodChannel: MethodChannel? = null

                            val messageClient: MessageClient = Wearable.getMessageClient(applicationContext)

                            val data = message.toByteArray()

                            messageClient.sendMessage(watchNodeId, MESSAGE_PATH_SUCCESS, data).await()

                                override fun onCreate(savedInstanceState: Bundle?) {    override fun onCreate(savedInstanceState: Bundle?) {

                            result.success(null)

                            Log.d(TAG, "Success message sent to watch: $message")        super.onCreate(savedInstanceState)        super.onCreate(savedInstanceState)

                        } catch (e: Exception) {

                            Log.e(TAG, "Failed to send success message to watch", e)                

                            result.error("SEND_ERROR", e.message ?: "Unknown error", null)

                        }        val serviceIntent = Intent(this, WearDataLayerListenerService::class.java)        val serviceIntent = Intent(this, WearDataLayerListenerService::class.java)

                    }

                }        startService(serviceIntent)        startService(serviceIntent)

                "sendErrorToWatch" -> {

                    mainScope.launch {    }    }

                        try {

                            val watchNodeId = call.argument<String>("watchNodeId")

                            val message = call.argument<String>("message")

                                override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {

                            if (watchNodeId == null || message == null) {

                                result.error("INVALID_ARGUMENTS", "Missing watchNodeId or message", null)        super.configureFlutterEngine(flutterEngine)        super.configureFlutterEngine(flutterEngine)

                                return@launch

                            }                

                            

                            val messageClient: MessageClient = Wearable.getMessageClient(applicationContext)        WearCommunicationHandler.initialize(flutterEngine)        WearCommunicationHandler.initialize(flutterEngine)

                            val data = message.toByteArray()

                            messageClient.sendMessage(watchNodeId, MESSAGE_PATH_ERROR, data).await()                

                            

                            result.success(null)        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

                            Log.d(TAG, "Error message sent to watch: $message")

                        } catch (e: Exception) {        methodChannel?.setMethodCallHandler { call, result ->        methodChannel?.setMethodCallHandler { call, result ->

                            Log.e(TAG, "Failed to send error message to watch", e)

                            result.error("SEND_ERROR", e.message ?: "Unknown error", null)            when (call.method) {            when (call.method) {

                        }

                    }                "sendSuccessToWatch" -> {                "sendSuccessToWatch" -> {

                }

                else -> {                    mainScope.launch {                    mainScope.launch {

                    result.notImplemented()

                }                        try {                        try {

            }

        }                            val watchNodeId = call.argument<String>("watchNodeId")                            val watchNodeId = call.argument<String>("watchNodeId")

    }

                            val message = call.argument<String>("message")                            val message = call.argument<String>("message")

    override fun onDestroy() {

        methodChannel?.setMethodCallHandler(null)                                                        

        mainScope.cancel()

        super.onDestroy()                            if (watchNodeId == null || message == null) {                            if (watchNodeId == null || message == null) {

    }

}                                result.error("INVALID_ARGUMENTS", "Missing watchNodeId or message", null)                                result.error("INVALID_ARGUMENTS", "Missing watchNodeId or message", null)


                                return@launch                                return@launch

                            }                            }

                                                        

                            val messageClient: MessageClient = Wearable.getMessageClient(applicationContext)                            val messageClient: MessageClient = Wearable.getMessageClient(applicationContext)

                            val data = message.toByteArray()                            val data = message.toByteArray()

                            messageClient.sendMessage(watchNodeId, MESSAGE_PATH_SUCCESS, data).await()                            messageClient.sendMessage(watchNodeId, MESSAGE_PATH_SUCCESS, data).await()

                                                        

                            result.success(null)                            result.success(null)

                            Log.d(TAG, "Success message sent to watch: $message")                            Log.d(TAG, "Success message sent to watch: $message")

                        } catch (e: Exception) {                        } catch (e: Exception) {

                            Log.e(TAG, "Failed to send success message to watch", e)                            Log.e(TAG, "Failed to send success message to watch", e)

                            result.error("SEND_ERROR", e.message ?: "Unknown error", null)                            result.error("SEND_ERROR", e.message ?: "Unknown error", null)

                        }                        }

                    }                    }

                }                }

                "sendErrorToWatch" -> {                "sendErrorToWatch" -> {

                    mainScope.launch {                    mainScope.launch {

                        try {                        try {

                            val watchNodeId = call.argument<String>("watchNodeId")                            val watchNodeId = call.argument<String>("watchNodeId")

                            val message = call.argument<String>("message")                            val message = call.argument<String>("message")

                                                        

                            if (watchNodeId == null || message == null) {                            if (watchNodeId == null || message == null) {

                                result.error("INVALID_ARGUMENTS", "Missing watchNodeId or message", null)                                result.error("INVALID_ARGUMENTS", "Missing watchNodeId or message", null)

                                return@launch                                return@launch

                            }                            }

                                                        

                            val messageClient: MessageClient = Wearable.getMessageClient(applicationContext)                            val messageClient: MessageClient = Wearable.getMessageClient(applicationContext)

                            val data = message.toByteArray()                            val data = message.toByteArray()

                            messageClient.sendMessage(watchNodeId, MESSAGE_PATH_ERROR, data).await()                            messageClient.sendMessage(watchNodeId, MESSAGE_PATH_ERROR, data).await()

                                                        

                            result.success(null)                            result.success(null)

                            Log.d(TAG, "Error message sent to watch: $message")                            Log.d(TAG, "Error message sent to watch: $message")

                        } catch (e: Exception) {                        } catch (e: Exception) {

                            Log.e(TAG, "Failed to send error message to watch", e)                            Log.e(TAG, "Failed to send error message to watch", e)

                            result.error("SEND_ERROR", e.message ?: "Unknown error", null)                            result.error("SEND_ERROR", e.message ?: "Unknown error", null)

                        }                        }

                    }                    }

                }                }

                else -> {                else -> {

                    result.notImplemented()                    result.notImplemented()

                }                }

            }            }

        }        }

    }    }



    override fun onDestroy() {    override fun onDestroy() {

        methodChannel?.setMethodCallHandler(null)        methodChannel?.setMethodCallHandler(null)

        mainScope.cancel()        mainScope.cancel()

        super.onDestroy()        super.onDestroy()

    }    }

}}
