package com.jta.rectranpackage com.jta.rectran



import android.content.Contextimport android.content.Context

import android.os.Handlerimport android.os.Handler

import android.os.Looperimport android.os.Looper

import android.util.Logimport android.util.Log

import io.flutter.embedding.engine.FlutterEngineimport io.flutter.embedding.engine.FlutterEngine

import io.flutter.plugin.common.MethodChannelimport io.flutter.plugin.common.MethodChannel



object WearCommunicationHandler {object WearCommunicationHandler {

    private const val TAG = "WearCommunicationHandler"    private const val TAG = "WearCommunicationHandler"

    private const val CHANNEL = "com.jta.rectran/wear_audio"    private const val CHANNEL = "com.jta.rectran/wear_audio"

    private var methodChannel: MethodChannel? = null    private var methodChannel: MethodChannel? = null

    private val mainHandler = Handler(Looper.getMainLooper())    private val mainHandler = Handler(Looper.getMainLooper())



    fun initialize(flutterEngine: FlutterEngine) {    fun initialize(flutterEngine: FlutterEngine) {

        methodChannel = MethodChannel(        methodChannel = MethodChannel(

            flutterEngine.dartExecutor.binaryMessenger,            flutterEngine.dartExecutor.binaryMessenger,

            CHANNEL            CHANNEL

        )        )

        Log.d(TAG, "WearCommunicationHandler initialized")        Log.d(TAG, "WearCommunicationHandler initialized")

    }    }



    fun processWearAudio(context: Context, audioPath: String, watchId: String) {    fun processWearAudio(context: Context, audioPath: String, watchId: String) {

        Log.d(TAG, "Processing wear audio: $audioPath from watch: $watchId")        Log.d(TAG, "Processing wear audio: $audioPath from watch: $watchId")

                

        // Flutter method channel calls must be on the main thread        // Flutter method channel calls must be on the main thread

        mainHandler.post {        mainHandler.post {

            methodChannel?.invokeMethod("onWearAudioReceived", mapOf(            methodChannel?.invokeMethod("onWearAudioReceived", mapOf(

                "audioPath" to audioPath,                "audioPath" to audioPath,

                "watchId" to watchId                "watchId" to watchId

            ))            ))

        }        }

    }    }

}}
