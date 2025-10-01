# Rectran Wear OS - Quick Test Script

Write-Host "🎙️ Rectran Wear OS Integration Test" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Check if in correct directory
if (!(Test-Path "pubspec.yaml")) {
    Write-Host "❌ Error: Please run this from the Rectran root directory" -ForegroundColor Red
    exit 1
}

Write-Host "📋 Step 1: Building Phone App" -ForegroundColor Yellow
Write-Host "Running: flutter build apk --debug" -ForegroundColor Gray
flutter build apk --debug

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Phone app build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Phone app built successfully!" -ForegroundColor Green
Write-Host ""

Write-Host "📋 Step 2: Checking connected devices" -ForegroundColor Yellow
$ADB = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
& $ADB devices

Write-Host ""
Write-Host "📋 Step 3: Installing Phone App" -ForegroundColor Yellow
Write-Host "Looking for phone device..." -ForegroundColor Gray

$devices = & $ADB devices | Select-String "device$" | Select-String -NotMatch "List of devices"
$phoneDevice = $null

foreach ($device in $devices) {
    $deviceId = ($device -split "\s+")[0]
    # Check if it's not a watch (watches have adb-* prefix)
    if ($deviceId -notlike "adb-*") {
        $phoneDevice = $deviceId
        break
    }
}

if ($phoneDevice) {
    Write-Host "Found phone: $phoneDevice" -ForegroundColor Green
    Write-Host "Installing..." -ForegroundColor Gray
    & $ADB -s $phoneDevice install -r build\app\outputs\flutter-apk\app-debug.apk
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Phone app installed successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ Installation failed!" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "⚠️  No phone device found. Connect your phone via USB." -ForegroundColor Yellow
    Write-Host "You can install manually later with:" -ForegroundColor Gray
    Write-Host "  adb install build\app\outputs\flutter-apk\app-debug.apk" -ForegroundColor Gray
}

Write-Host ""
Write-Host "📋 Step 4: Watch App Status" -ForegroundColor Yellow
Set-Location wear_os

$watchDevice = & $ADB devices | Select-String "device$" | Select-String "adb-" | Select-Object -First 1
if ($watchDevice) {
    $watchId = ($watchDevice -split "\s+")[0]
    Write-Host "✅ Watch connected: $watchId" -ForegroundColor Green
    
    # Check if watch app is installed
    $watchApp = & $ADB -s $watchId shell pm list packages | Select-String "com.jta.rectran.wear"
    if ($watchApp) {
        Write-Host "✅ Watch app already installed" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Watch app not installed" -ForegroundColor Yellow
        Write-Host "Install with: .\adb-wear.ps1 install" -ForegroundColor Gray
    }
} else {
    Write-Host "⚠️  No watch connected" -ForegroundColor Yellow
    Write-Host "Connect with: .\adb-wear.ps1 connect <IP>:<PORT>" -ForegroundColor Gray
}

Set-Location ..

Write-Host ""
Write-Host "🎉 Setup Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📱 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Open Rectran app on your phone"
Write-Host "2. Configure Gemini API key in Settings (if not done)"
Write-Host "3. Enable 'Auto-start transcription' in Settings"
Write-Host "4. Open Rectran Wear app on your watch"
Write-Host "5. Make a test recording on the watch"
Write-Host "6. Check your phone's Library and Transcription tabs"
Write-Host ""
Write-Host "🐛 Debug:" -ForegroundColor Cyan
Write-Host "Phone logs: adb logcat | findstr `"WearDataListener WearCommHandler WearOSService`"" -ForegroundColor Gray
Write-Host "Watch logs: cd wear_os; .\adb-wear.ps1 logs" -ForegroundColor Gray
Write-Host ""
