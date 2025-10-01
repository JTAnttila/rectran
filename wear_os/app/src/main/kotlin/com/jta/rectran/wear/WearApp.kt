package com.jta.rectran.wear

import android.app.Application

class WearApp : Application() {
    override fun onCreate() {
        super.onCreate()
        // Initialize Wear OS Communication
        WearCommunicationManager.initialize(this)
    }
}
