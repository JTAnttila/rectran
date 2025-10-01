# Wear OS ADB Helper Script
# This script provides easy access to ADB commands for Wear OS development

$ADB = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"

function Show-Help {
    Write-Host "Wear OS ADB Commands:" -ForegroundColor Green
    Write-Host "  .\adb-wear.ps1 devices          - List connected devices"
    Write-Host "  .\adb-wear.ps1 connect <IP>     - Connect to watch via Wi-Fi (e.g., 192.168.1.100:5555)"
    Write-Host "  .\adb-wear.ps1 disconnect       - Disconnect from watch"
    Write-Host "  .\adb-wear.ps1 install          - Install the debug APK"
    Write-Host "  .\adb-wear.ps1 uninstall        - Uninstall the app"
    Write-Host "  .\adb-wear.ps1 logs             - Show app logs"
    Write-Host "  .\adb-wear.ps1 shell <command>  - Run shell command on device"
    Write-Host ""
}

if (-not (Test-Path $ADB)) {
    Write-Host "Error: ADB not found at $ADB" -ForegroundColor Red
    exit 1
}

$command = $args[0]

switch ($command) {
    "devices" {
        & $ADB devices
    }
    "connect" {
        if ($args.Count -lt 2) {
            Write-Host "Usage: .\adb-wear.ps1 connect <IP:PORT>" -ForegroundColor Yellow
            Write-Host "Example: .\adb-wear.ps1 connect 192.168.1.100:5555" -ForegroundColor Yellow
        } else {
            & $ADB connect $args[1]
        }
    }
    "disconnect" {
        & $ADB disconnect
    }
    "install" {
        $apk = "app\build\outputs\apk\debug\app-debug.apk"
        if (Test-Path $apk) {
            Write-Host "Installing $apk..." -ForegroundColor Green
            
            # Check if there are multiple devices
            $devices = & $ADB devices | Select-String "device$" | Select-String -NotMatch "List of devices"
            if ($devices.Count -gt 1) {
                Write-Host "Multiple devices found. Please specify which device:" -ForegroundColor Yellow
                & $ADB devices
                Write-Host ""
                Write-Host "Use: .\adb-wear.ps1 install-to <device_id>" -ForegroundColor Yellow
            } else {
                & $ADB install -r $apk
            }
        } else {
            Write-Host "Error: APK not found at $apk" -ForegroundColor Red
            Write-Host "Run: .\gradlew.bat assembleDebug" -ForegroundColor Yellow
        }
    }
    "install-to" {
        if ($args.Count -lt 2) {
            Write-Host "Usage: .\adb-wear.ps1 install-to <device_id>" -ForegroundColor Yellow
            & $ADB devices
        } else {
            $apk = "app\build\outputs\apk\debug\app-debug.apk"
            if (Test-Path $apk) {
                Write-Host "Installing $apk to $($args[1])..." -ForegroundColor Green
                & $ADB -s $args[1] install -r $apk
            } else {
                Write-Host "Error: APK not found at $apk" -ForegroundColor Red
            }
        }
    }
    "uninstall" {
        & $ADB uninstall com.jta.rectran.wear
    }
    "logs" {
        Write-Host "Showing logs for Rectran (Ctrl+C to stop)..." -ForegroundColor Green
        & $ADB logcat -s "RectranWear:*" "RecordingService:*" "WearCommunicationManager:*"
    }
    "shell" {
        $shellCmd = $args[1..($args.Count-1)]
        & $ADB shell $shellCmd
    }
    default {
        Show-Help
    }
}
