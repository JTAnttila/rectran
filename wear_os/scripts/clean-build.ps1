# Clean Build Script for Rectran Wear OS (PowerShell)
# Cleans the project and rebuilds from scratch

Write-Host "🧹 Cleaning project..." -ForegroundColor Cyan
& .\gradlew.bat clean

Write-Host "🗑️  Removing build caches..." -ForegroundColor Cyan
Remove-Item -Path ".gradle" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "app\build" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "build" -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "🔨 Building fresh..." -ForegroundColor Cyan
& .\gradlew.bat assembleDebug

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Clean build complete!" -ForegroundColor Green
} else {
    Write-Host "❌ Build failed!" -ForegroundColor Red
    exit 1
}
