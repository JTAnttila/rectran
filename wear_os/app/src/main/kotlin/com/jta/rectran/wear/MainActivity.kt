package com.jta.rectran.wear

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.core.content.ContextCompat
import androidx.wear.compose.material.*
import com.jta.rectran.wear.ui.theme.RectranWatchTheme
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity() {
    
    private var isRecording by mutableStateOf(false)
    private var showSuccessAnimation by mutableStateOf(false)
    private var connectionStatus by mutableStateOf(ConnectionStatus.CHECKING)
    private var transferProgress by mutableStateOf<Pair<Int, Int>?>(null) // current/total chunks
    private var showWarning by mutableStateOf<String?>(null)
    
    enum class ConnectionStatus {
        CHECKING,
        CONNECTED,
        DISCONNECTED
    }
    
    companion object {
        private const val TAG = "MainActivity"
    }
    
    private val permissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { permissions ->
        val allGranted = permissions.entries.all { it.value }
        if (allGranted) {
            Log.d(TAG, "All permissions granted")
        } else {
            Log.w(TAG, "Some permissions denied")
        }
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        checkPermissions()
        checkConnectionStatus()
        
        // Set up transfer progress callback
        WearCommunicationManager.onTransferProgress = { current, total ->
            kotlinx.coroutines.MainScope().launch {
                transferProgress = Pair(current, total)
            }
        }
        
        setContent {
            RectranWatchTheme {
                MainScreen(
                    isRecording = isRecording,
                    showSuccess = showSuccessAnimation,
                    connectionStatus = connectionStatus,
                    transferProgress = transferProgress,
                    warningMessage = showWarning,
                    onRecordClick = { handleRecordClick() },
                    onDismissWarning = { showWarning = null }
                )
            }
        }
    }
    
    private fun checkPermissions() {
        val permissions = arrayOf(
            Manifest.permission.RECORD_AUDIO,
            Manifest.permission.BLUETOOTH,
            Manifest.permission.BLUETOOTH_CONNECT
        )
        
        val notGranted = permissions.filter {
            ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }
        
        if (notGranted.isNotEmpty()) {
            permissionLauncher.launch(notGranted.toTypedArray())
        }
    }
    
    private fun checkConnectionStatus() {
        // Check connection in background
        kotlinx.coroutines.MainScope().launch {
            connectionStatus = if (WearCommunicationManager.isPhoneConnected()) {
                ConnectionStatus.CONNECTED
            } else {
                ConnectionStatus.DISCONNECTED
            }
        }
    }
    
    private fun handleRecordClick() {
        if (isRecording) {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private fun startRecording() {
        // Check battery and storage before recording
        if (!checkPreRecordingConditions()) {
            return
        }
        
        val intent = Intent(this, RecordingService::class.java).apply {
            action = RecordingService.ACTION_START_RECORDING
        }
        startForegroundService(intent)
        isRecording = true
        Log.d(TAG, "Started recording")
    }
    
    private fun checkPreRecordingConditions(): Boolean {
        // Check battery level
        val batteryManager = getSystemService(BATTERY_SERVICE) as android.os.BatteryManager
        val batteryLevel = batteryManager.getIntProperty(android.os.BatteryManager.BATTERY_PROPERTY_CAPACITY)
        
        if (batteryLevel < 15) {
            showWarning = "Low battery ($batteryLevel%). Charge your watch for long recordings."
            return false
        }
        
        // Check available storage
        val recordingsDir = getExternalFilesDir(null)
        if (recordingsDir != null) {
            val freeSpace = recordingsDir.freeSpace / (1024 * 1024) // MB
            if (freeSpace < 50) { // Less than 50MB
                showWarning = "Low storage (${freeSpace}MB free). Free up space for recordings."
                return false
            }
        }
        
        return true
    }
    
    private fun stopRecording() {
        val intent = Intent(this, RecordingService::class.java).apply {
            action = RecordingService.ACTION_STOP_RECORDING
        }
        startService(intent)
        isRecording = false
        
        // Show success animation (will be replaced by transfer progress)
        showSuccessAnimation = true
        
        // Hide after transfer completes or timeout
        kotlinx.coroutines.MainScope().launch {
            delay(5000) // Give time for transfer to start
            if (transferProgress == null) {
                showSuccessAnimation = false
            } else {
                // Wait for transfer to complete
                while (transferProgress != null) {
                    delay(500)
                }
                delay(2000)
                showSuccessAnimation = false
            }
        }
        
        Log.d(TAG, "Stopped recording")
    }
    
    override fun onPause() {
        super.onPause()
        // Clean up callback when not visible to save battery
        WearCommunicationManager.onTransferProgress = null
    }
    
    override fun onResume() {
        super.onResume()
        // Restore callback when visible
        WearCommunicationManager.onTransferProgress = { current, total ->
            kotlinx.coroutines.MainScope().launch {
                transferProgress = Pair(current, total)
            }
        }
        // Refresh connection status
        checkConnectionStatus()
    }
    
    override fun onDestroy() {
        super.onDestroy()
        WearCommunicationManager.onTransferProgress = null
    }
}

@Composable
fun MainScreen(
    isRecording: Boolean,
    showSuccess: Boolean,
    connectionStatus: MainActivity.ConnectionStatus,
    transferProgress: Pair<Int, Int>?,
    warningMessage: String?,
    onRecordClick: () -> Unit,
    onDismissWarning: () -> Unit
) {
    Scaffold(
        timeText = {
            TimeText()
        }
    ) {
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(MaterialTheme.colors.background),
            contentAlignment = Alignment.Center
        ) {
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                // Connection Status Indicator
                ConnectionIndicator(connectionStatus)
                
                Spacer(modifier = Modifier.height(8.dp))
                
                // Record Button
                RecordButton(
                    isRecording = isRecording,
                    onClick = onRecordClick,
                    enabled = connectionStatus == MainActivity.ConnectionStatus.CONNECTED
                )
                
                Spacer(modifier = Modifier.height(8.dp))
                
                // Status Text with Transfer Progress
                if (transferProgress != null) {
                    val (current, total) = transferProgress
                    val percentage = (current * 100) / total
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text(
                            text = "Sending...",
                            style = MaterialTheme.typography.body2,
                            color = Color(0xFF2196F3)
                        )
                        Text(
                            text = "$current/$total ($percentage%)",
                            style = MaterialTheme.typography.caption3,
                            color = Color(0xFF2196F3)
                        )
                    }
                } else {
                    Text(
                        text = when {
                            showSuccess -> "Sent!"
                            isRecording -> "Recording..."
                            connectionStatus == MainActivity.ConnectionStatus.DISCONNECTED -> 
                                "No phone connected"
                            else -> "Ready"
                        },
                        style = MaterialTheme.typography.body2,
                        textAlign = TextAlign.Center,
                        color = when {
                            showSuccess -> Color(0xFF4CAF50)
                            connectionStatus == MainActivity.ConnectionStatus.DISCONNECTED -> 
                                Color(0xFFFF9800)
                            else -> MaterialTheme.colors.onBackground
                        }
                    )
                }
            }
            
            // Success Animation Overlay
            AnimatedVisibility(
                visible = showSuccess && transferProgress == null,
                enter = scaleIn() + fadeIn(),
                exit = scaleOut() + fadeOut()
            ) {
                SuccessAnimation()
            }
            
            // Warning Dialog
            if (warningMessage != null) {
                androidx.compose.ui.window.Dialog(
                    onDismissRequest = onDismissWarning
                ) {
                    Card(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(16.dp),
                        onClick = onDismissWarning
                    ) {
                        Column(
                            modifier = Modifier.padding(16.dp),
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.spacedBy(12.dp)
                        ) {
                            Text(
                                text = "⚠️ Warning",
                                style = MaterialTheme.typography.title3,
                                color = Color(0xFFFFB74D)
                            )
                            Text(
                                text = warningMessage,
                                style = MaterialTheme.typography.body2,
                                textAlign = TextAlign.Center
                            )
                            Button(onClick = onDismissWarning) {
                                Text("OK")
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun ConnectionIndicator(status: MainActivity.ConnectionStatus) {
    Row(
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        val color = when (status) {
            MainActivity.ConnectionStatus.CONNECTED -> Color(0xFF4CAF50)
            MainActivity.ConnectionStatus.DISCONNECTED -> Color(0xFFFF5252)
            MainActivity.ConnectionStatus.CHECKING -> Color(0xFFFFB74D)
        }
        
        Box(
            modifier = Modifier
                .size(8.dp)
                .background(color, androidx.compose.foundation.shape.CircleShape)
        )
        
        Text(
            text = when (status) {
                MainActivity.ConnectionStatus.CONNECTED -> "Connected"
                MainActivity.ConnectionStatus.DISCONNECTED -> "Disconnected"
                MainActivity.ConnectionStatus.CHECKING -> "Checking..."
            },
            style = MaterialTheme.typography.caption3,
            color = color
        )
    }
}

@Composable
fun RecordButton(
    isRecording: Boolean,
    onClick: () -> Unit,
    enabled: Boolean
) {
    val infiniteTransition = rememberInfiniteTransition(label = "recording")
    val scale by infiniteTransition.animateFloat(
        initialValue = 1f,
        targetValue = 1.1f,
        animationSpec = infiniteRepeatable(
            animation = tween(500, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "scale"
    )
    
    Button(
        onClick = onClick,
        modifier = Modifier
            .size(if (isRecording) 80.dp * scale else 80.dp)
            .padding(8.dp),
        enabled = enabled,
        colors = ButtonDefaults.buttonColors(
            backgroundColor = if (isRecording) Color(0xFFFF5252) else MaterialTheme.colors.primary,
            disabledBackgroundColor = Color.Gray
        )
    ) {
        Icon(
            painter = androidx.compose.ui.res.painterResource(
                if (isRecording) android.R.drawable.ic_media_pause 
                else android.R.drawable.ic_btn_speak_now
            ),
            contentDescription = if (isRecording) "Stop Recording" else "Start Recording",
            modifier = Modifier.size(32.dp),
            tint = Color.White
        )
    }
}

@Composable
fun SuccessAnimation() {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Black.copy(alpha = 0.7f)),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Icon(
                painter = androidx.compose.ui.res.painterResource(android.R.drawable.checkbox_on_background),
                contentDescription = "Success",
                modifier = Modifier.size(64.dp),
                tint = Color(0xFF4CAF50)
            )
            
            Text(
                text = "Audio Sent to Phone",
                style = MaterialTheme.typography.title3,
                color = Color.White,
                textAlign = TextAlign.Center
            )
        }
    }
}
