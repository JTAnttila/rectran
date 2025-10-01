# Changelog

## [Unreleased] - 2025-10-01

### Added
- **Wear OS Support**: Complete Wear OS companion app for Samsung Galaxy Watch 4+
  - Local audio recording with MediaRecorder (AAC, 128kbps, 44.1kHz)
  - Bluetooth data transfer via Wear OS Data Layer API
  - Jetpack Compose UI with Material Design for Wear OS
  - Foreground service for reliable recording
  - Real-time connection status indicator
  - Success animation feedback

- **Reliability Features for Long Recordings**:
  - Automatic retry mechanism (up to 3 attempts with exponential backoff)
  - Real-time transfer progress display with chunk counting
  - Pre-recording battery check (warns if below 15%)
  - Pre-recording storage check (warns if less than 50MB available)
  - File backup system - recordings preserved on watch after successful transfer
  - Warning dialog system for user notifications

- **Phone-Watch Communication**:
  - WearDataLayerListenerService for receiving audio from watch
  - Chunked file transfer protocol (100KB chunks with 4-byte index prefix)
  - WearCommunicationHandler for Flutter integration
  - WearOSService in Flutter for handling watch audio
  - Automatic transcription trigger upon audio receipt

- **Development Tools**:
  - PowerShell script for testing Wear OS integration
  - Comprehensive documentation in `.instructions/` folder
  - Pairing and installation guides

### Changed
- Updated package structure to use lowercase `com.jta.rectran` consistently
- Unified signing keys between phone and watch apps for Data Layer communication
- Enhanced main Flutter app to handle Wear OS audio automatically

### Fixed
- Resolved package name case sensitivity issues (JTA → jta)
- Fixed duplicate message processing bug in WearDataLayerListenerService
- Corrected channel and method name mismatches between native and Flutter
- Fixed argument name inconsistencies (audioFilePath → audioPath, watchNodeId → watchId)
- Resolved audio file corruption issues during transfer

### Technical Details
- Minimum SDK: Android 11 (API 30) for Wear OS
- Target devices: Samsung Galaxy Watch 4 and newer (Wear OS 3.0+)
- Build system: Gradle 8.9, AGP 8.7.0, Kotlin 2.0.21
- UI framework: Jetpack Compose for Wear OS 1.3.0
- Communication: Google Play Services Wearable 18.1.0

### Known Limitations
- Requires Bluetooth connection between watch and phone
- Both devices must have the respective apps installed
- Watch app requires microphone permission
- Estimated transfer time for 30-minute recording: 25-40 seconds (~29MB)
