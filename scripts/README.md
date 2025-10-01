# Development Scripts

This directory contains PowerShell scripts for development and testing.

## Available Scripts

### `test-wear-integration.ps1`
**Purpose**: End-to-end integration test for Wear OS functionality

**Usage**:
```powershell
.\scripts\test-wear-integration.ps1
```

**What it does**:
1. Builds the phone app (Flutter)
2. Detects connected phone and watch devices
3. Installs the phone app
4. Checks watch app status
5. Provides next steps and debugging commands

**Requirements**:
- Flutter SDK
- Android SDK with ADB
- Phone connected via USB (for installation)
- Optional: Watch connected via ADB over Wi-Fi

---

## Wear OS Specific Scripts

For Wear OS development, see `wear_os/scripts/` and `wear_os/adb-wear.ps1`

### Quick Commands

```powershell
# Build and install watch app
cd wear_os
.\adb-wear.ps1 install

# Watch logs
.\adb-wear.ps1 logs

# Connect to watch via Wi-Fi
.\adb-wear.ps1 connect <IP>:5555

# Full test (phone + watch)
cd ..
.\scripts\test-wear-integration.ps1
```

---

## Notes

- All scripts assume you're running from the project root unless otherwise specified
- ADB path is auto-detected from `%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe`
- For Linux/Mac users, equivalent `.sh` scripts are available in `wear_os/scripts/`
