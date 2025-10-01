# Watch Logs Script for Rectran Wear OS (PowerShell)
# Monitors logcat for Rectran-related logs

Write-Host "👀 Watching Rectran logs... (Ctrl+C to stop)" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray

adb logcat | Select-String -Pattern "Rectran|SAP|MediaRecorder|AudioReceiver"
