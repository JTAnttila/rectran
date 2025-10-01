# Wear OS Development Scripts

This directory contains helper scripts for Wear OS development.

## Main Script: `adb-wear.ps1`

A comprehensive ADB helper for Wear OS development.

### Commands

```powershell
# Show help
.\adb-wear.ps1

# List connected devices
.\adb-wear.ps1 devices

# Connect to watch via Wi-Fi (get IP from watch Settings > Developer options > Wireless debugging)
.\adb-wear.ps1 connect 192.168.1.100:5555

# Build, install and launch
.\gradlew.bat assembleDebug
.\adb-wear.ps1 install

# Watch live logs
.\adb-wear.ps1 logs

# Uninstall app
.\adb-wear.ps1 uninstall

# Run custom shell command
.\adb-wear.ps1 shell pm list packages
```

---

## Additional Scripts

### `scripts/build-and-install.ps1` / `.sh`
Builds and installs the watch app in one command.

**Usage**:
```powershell
.\scripts\build-and-install.ps1
```

### `scripts/clean-build.ps1` / `.sh`
Cleans build artifacts and rebuilds from scratch.

**Usage**:
```powershell
.\scripts\clean-build.ps1
```

### `scripts/watch-logs.ps1` / `.sh`
Monitors app logs in real-time with color coding.

**Usage**:
```powershell
.\scripts\watch-logs.ps1
```

---

## Device Connection

### USB Connection (Recommended for first setup)
1. Enable Developer options on watch
2. Enable ADB debugging
3. Connect watch to computer via USB cable
4. Run `adb devices` to verify connection

### Wi-Fi Connection (Convenient for testing)
1. Connect watch and computer to same Wi-Fi network
2. On watch: Settings > Developer options > Wireless debugging
3. Note the IP address and port (e.g., 192.168.1.100:5555)
4. Run: `.\adb-wear.ps1 connect 192.168.1.100:5555`
5. Accept the connection on watch
6. Verify: `.\adb-wear.ps1 devices`

**Tip**: Once connected via Wi-Fi, you can disconnect the USB cable.

---

## Troubleshooting

### Watch not detected
```powershell
# Restart ADB server
adb kill-server
adb start-server

# Check devices
adb devices
```

### Installation fails
```powershell
# Uninstall old version first
.\adb-wear.ps1 uninstall

# Then reinstall
.\adb-wear.ps1 install
```

### Can't connect via Wi-Fi
- Ensure both devices are on same network
- Try disabling and re-enabling Wireless debugging on watch
- Try rebooting the watch
- Check if firewall is blocking ADB port 5555

### Build fails
```powershell
# Clean and rebuild
.\scripts\clean-build.ps1
```

---

## Development Workflow

**Typical workflow**:
1. Make code changes
2. Build: `.\gradlew.bat assembleDebug`
3. Install: `.\adb-wear.ps1 install`
4. Test on watch
5. Check logs: `.\adb-wear.ps1 logs`
6. Repeat

**Quick iteration**:
```powershell
# One-liner: build + install + launch logs
.\gradlew.bat assembleDebug; .\adb-wear.ps1 install; .\adb-wear.ps1 logs
```

---

## Platform Notes

- **Windows**: Use `.ps1` (PowerShell) scripts
- **Linux/Mac**: Use `.sh` (Bash) scripts

All scripts have equivalent functionality across platforms.
