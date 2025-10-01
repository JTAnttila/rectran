# Build and Install Script for Rectran Wear OS (PowerShell)
# Builds the debug APK and installs it on connected watch

Write-Host "🔨 Building Rectran Wear OS..." -ForegroundColor Cyan
& .\gradlew.bat assembleDebug

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "📱 Finding connected watch..." -ForegroundColor Cyan
$devices = adb devices | Select-String "device$"
$watchId = ($devices[0] -split "\s+")[0]

if (-not $watchId) {
    Write-Host "❌ No watch found. Please connect your watch via ADB." -ForegroundColor Red
    exit 1
}

Write-Host "📲 Installing on watch: $watchId" -ForegroundColor Cyan
adb -s $watchId install -r app\build\outputs\apk\debug\app-debug.apk

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Installation complete!" -ForegroundColor Green
    Write-Host "📱 Launch 'Rectran' on your watch to test." -ForegroundColor Yellow
} else {
    Write-Host "❌ Installation failed!" -ForegroundColor Red
    exit 1
}
