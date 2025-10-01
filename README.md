# 🎙️ Rectran - Voice Recording & Transcription App

<div align="center">

**A modern Flutter mobile application for voice recording with AI-powered transcription**

[![Flutter](https://img.shields.io/badge/Flutter-3.4+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.4+-0175C2?logo=dart)](https://dart.dev)
[![Material Design 3](https://img.shields.io/badge/Material%20Design-3-757575?logo=material-design)](https://m3.material.io)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

[Features](#-features) • [Quick Start](#-quick-start) • [Architecture](#-architecture) • [API Setup](#-api-setup) • [Contributing](#-contributing)

</div>

---

## 📋 Overview

**Rectran** (Record & Transcribe) is a cross-platform mobile application that combines high-quality audio recording with AI-powered transcription using Google's Gemini API. Built with Flutter and following Material Design 3 principles, it provides a clean, intuitive interface for capturing, transcribing, organizing, and exporting voice recordings.

### Why Rectran?

- 🎯 **Simple & Intuitive** - Clean Material Design 3 interface
- 🤖 **AI-Powered** - Leverages Google Gemini for accurate transcriptions
- 📱 **Cross-Platform** - Works on Android and iOS
- ⌚ **Wear OS Support** - Record directly from your smartwatch (Wear OS 3.0+)
- 🔄 **Seamless Integration** - Watch recordings automatically transcribe on phone
- 🎨 **Modern Design** - Beautiful adaptive UI with theme support
- 📦 **Lightweight** - Optimized for minimal app size
- 🔒 **Privacy-First** - Local storage with optional export

---

## ✨ Features

### 🎤 Recording

- High-quality audio recording with real-time timer
- Visual recording status indicators
- Pause and resume functionality
- Automatic file management
- Support for multiple audio formats
- **⌚ Wear OS app** - Record on smartwatch, transcribe on phone

### 📝 Transcription

- AI-powered transcription using Google Gemini
- Multiple AI model support (Gemini 1.5 Flash, Pro)
- Real-time transcription status tracking
- View detailed transcripts with timestamps
- Edit and manage transcriptions

### 📚 Library

- Organized library of all recordings
- Search and filter capabilities
- Sort by date, duration, or name
- Audio playback controls
- Session management

### 📤 Export & Share

- Export transcripts as TXT, JSON, Markdown, or **PDF**
- Export summaries in multiple formats
- Share recordings and transcripts
- Professional PDF documents with formatting

### ⌚ Wear OS Integration

- **Universal Wear OS Support** - Works with Galaxy Watch, Pixel Watch, TicWatch, and more!
- **No Samsung SDK Required** - Uses standard Wear OS Data Layer API
- **Seamless Sync** - Automatically transfers recordings to phone via Bluetooth
- **Success Notifications** - Visual confirmation when transcription completes
- **Battery Efficient** - Optimized for watch battery life
- **Simple Interface** - Large, easy-to-use buttons designed for watch screens

👉 **[Get started with Wear OS →](wear_os/QUICKSTART.md)**

### ⚙️ Settings

- **In-app API key management** - No need to download project first!
- Secure encrypted storage for API keys
- AI model selection (Gemini 2.5 Flash, 1.5 Flash, 1.5 Pro)
- Theme selection (Light/Dark/System)
- Language preferences
- Storage management

---

## 🚀 Quick Start

### 📱 Phone App

### Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (≥3.4.0) - [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Dart SDK** (≥3.4.0) - Included with Flutter
- **Android Studio** or **Xcode** - For platform-specific development
- **Google Gemini API Key** - [Get API Key](https://aistudio.google.com/app/apikey)

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/yourusername/rectran.git
   cd rectran
   ```
2. **Install dependencies**

   ```bash
   flutter pub get
   ```
3. **Run the app**

   ```bash
   # Run on connected device/emulator
   flutter run

   # Run in release mode for better performance
   flutter run --release
   ```
4. **Configure API Key (First-Time Setup)**

   When you first launch the app:

   - Go to **Settings** tab
   - Tap on **"Gemini API Key"**
   - Enter your Google Gemini API key ([Get one here](https://aistudio.google.com/app/apikey))
   - Your key is securely encrypted and stored on your device

   ✅ **No `.env` file needed!** - Everything is managed in-app

### Building for Production

#### Android APK

```bash
flutter build apk --release --split-per-abi
```

#### Android App Bundle (Recommended for Play Store)

```bash
flutter build appbundle --release
```

#### iOS

```bash
flutter build ios --release
```

### ⌚ Wear OS App (Optional)

Want to record from your Wear OS watch? Check out the companion app:

**Quick Setup (No Samsung SDK required!):**
1. Enable developer mode on watch
2. Build and install: See [wear_os/QUICKSTART.md](wear_os/QUICKSTART.md)
3. Start recording from your wrist! 🎙️

**Compatible Devices:**
- ✅ Samsung Galaxy Watch 4, 5, 6
- ✅ Google Pixel Watch, Pixel Watch 2
- ✅ TicWatch Pro series
- ✅ Any Wear OS 3.0+ watch

**Documentation:**
- 📖 [Full README](wear_os/README.md) - Complete feature documentation
- 🚀 [Quick Start](wear_os/QUICKSTART.md) - Get running in 10 minutes
- 🔗 Phone Integration - Coming soon
- 🏗️ Architecture - Coming soon

---

## 🏗️ Architecture

Rectran follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/                      # Core functionality
│   ├── config/               # App configuration
│   │   └── ai_model.dart     # AI model definitions
│   ├── services/             # Business services
│   │   ├── audio_recording_service.dart
│   │   ├── gemini_service.dart
│   │   └── export_service.dart
│   ├── theme/                # App theming
│   │   └── app_theme.dart
│   └── utils/                # Utility functions
│       └── time_formatter.dart
│
├── features/                  # Feature modules
│   ├── recording/            # Recording feature
│   │   ├── domain/          # Business logic & entities
│   │   ├── application/     # State management
│   │   └── presentation/    # UI components
│   │
│   ├── transcription/        # Transcription feature
│   │   ├── domain/
│   │   ├── application/
│   │   └── presentation/
│   │
│   ├── library/              # Library feature
│   │   ├── domain/
│   │   ├── application/
│   │   └── presentation/
│   │
│   ├── settings/             # Settings feature
│   │   ├── application/
│   │   └── presentation/
│   │
│   └── shared/               # Shared UI components
│       └── presentation/
│
├── app.dart                   # App widget
└── main.dart                  # Entry point
```

### Key Architectural Patterns

- **Feature-First Organization** - Features are self-contained modules
- **Clean Architecture Layers**:
  - `domain/` - Business entities and logic (no framework dependencies)
  - `application/` - State management and use cases
  - `presentation/` - UI components and screens
- **Provider for State Management** - Simple, effective state management
- **Service Layer** - Encapsulated external dependencies

---

## 🔧 Configuration

### API Setup

#### Getting a Gemini API Key

1. Visit [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy the key and add it to your `.env` file

#### Configuring AI Models

Edit `lib/core/config/ai_model.dart` to customize available models:

```dart
enum AiModel {
  gemini15Flash(
    id: 'gemini-1.5-flash',
    displayName: 'Gemini 1.5 Flash',
    description: 'Fast and efficient',
  ),
  gemini15Pro(
    id: 'gemini-1.5-pro',
    displayName: 'Gemini 1.5 Pro',
    description: 'Most capable model',
  ),
}
```

### App Configuration

#### Changing App Name & Bundle ID

1. **Android**: Edit `android/app/build.gradle.kts`

   ```kotlin
   android {
       namespace = "com.yourcompany.rectran"
       defaultConfig {
           applicationId = "com.yourcompany.rectran"
       }
   }
   ```
2. **iOS**: Edit `ios/Runner/Info.plist`

   ```xml
   <key>CFBundleDisplayName</key>
   <string>Your App Name</string>
   ```
3. **Flutter**: Edit `pubspec.yaml`

   ```yaml
   name: rectran
   description: Your app description
   version: 1.0.0+1
   ```

---

## 📦 Dependencies

### Core Dependencies

| Package       | Version | Purpose              |
| ------------- | ------- | -------------------- |
| `flutter`   | SDK     | Framework            |
| `provider`  | ^6.1.2  | State management     |
| `equatable` | ^2.0.5  | Value equality       |
| `intl`      | ^0.19.0 | Internationalization |

### Feature Dependencies

| Package            | Version | Purpose               |
| ------------------ | ------- | --------------------- |
| `audioplayers`   | ^6.1.0  | Audio playback        |
| `record`         | 5.1.0   | Audio recording       |
| `http`           | ^1.2.2  | HTTP client           |
| `flutter_dotenv` | ^5.2.1  | Environment variables |
| `path_provider`  | ^2.1.5  | File system paths     |
| `share_plus`     | ^12.0.0 | Sharing functionality |
| `uuid`           | ^4.5.0  | Unique ID generation  |

---

## 🧪 Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart
```

### Test Structure

```
test/
├── unit/                 # Unit tests
├── widget/              # Widget tests
├── integration/         # Integration tests
└── test_helpers/        # Test utilities
```

---

## 🎨 Customization

### Theming

The app uses Material Design 3 with custom color schemes. Edit `lib/core/theme/app_theme.dart`:

```dart
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );

  // Customize your theme here
}
```

### Adding New Features

1. Create a new feature directory under `lib/features/`
2. Follow the existing structure:
   ```
   your_feature/
   ├── domain/
   ├── application/
   └── presentation/
   ```
3. Register providers in `main.dart` if needed
4. Add navigation routes if required

---

## 🐛 Troubleshooting

### Common Issues

#### "Gemini API key not found"

- Ensure `.env` file exists in project root
- Verify `GEMINI_API_KEY` is set correctly
- Restart the app after adding `.env`

#### Recording permission denied

- Grant microphone permissions in device settings
- For Android: Add permissions to `AndroidManifest.xml`
- For iOS: Add permissions to `Info.plist`

#### Build errors

```bash
# Clean build cache
flutter clean

# Get dependencies
flutter pub get

# Rebuild
flutter run
```

---

## 📊 Performance Optimization

### App Size Optimization

The app is optimized for minimal size:

- ✅ Split APKs per ABI (reduces size by ~75%)
- ✅ No unnecessary dependencies
- ✅ Optimized assets and resources
- ✅ ProGuard/R8 enabled in release builds

Current size: **~50MB per architecture** (down from 200MB universal APK)

### Build Optimization Tips

1. **Use split APKs for distribution**:

   ```bash
   flutter build apk --release --split-per-abi
   ```
2. **Enable code shrinking** (already configured):

   - ProGuard rules in `android/app/proguard-rules.pro`
   - Automatic in release builds
3. **Analyze app size**:

   ```bash
   flutter build apk --analyze-size
   ```

---

## ⌚ Wear OS Integration

Rectran includes a companion Wear OS app that allows you to record audio directly on your smartwatch!

### Features

- 🎙️ **Record on Watch** - Capture audio using your Wear OS smartwatch
- 📤 **Auto-Transfer** - Recordings automatically sent to your phone
- 🤖 **Auto-Transcribe** - Phone transcribes using Gemini AI
- ✅ **Instant Feedback** - Get success notifications on your watch

### Compatibility

- **Wear OS 3.0+** (Samsung Galaxy Watch 4, Watch 5, Watch 6, Pixel Watch, etc.)
- Works with any Wear OS device paired with your Android phone
- No Samsung-specific dependencies required

### Quick Start

1. **Build & Install Watch App:**
   ```powershell
   cd wear_os
   .\gradlew.bat assembleDebug
   .\adb-wear.ps1 connect <WATCH_IP>:5555
   .\adb-wear.ps1 install
   ```

2. **Test Integration:**
   ```powershell
   cd ..
   .\test-wear-integration.ps1
   ```

3. **Use It:**
   - Open Rectran Wear on your watch
   - Tap record, speak, then stop
   - Recording automatically transfers to phone
   - Check phone app for transcription!

### Documentation

For detailed setup, troubleshooting, and architecture:
- 📖 [Wear OS Integration Guide](WEAR_OS_INTEGRATION.md)
- 🚀 [Watch App Quick Start](wear_os/QUICKSTART.md)
- 📋 [Installation Guide](wear_os/INSTALL_GUIDE.md)

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

### Development Workflow

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Make your changes**
4. **Run tests**
   ```bash
   flutter test
   flutter analyze
   ```
5. **Commit your changes**
   ```bash
   git commit -m "feat: add amazing feature"
   ```
6. **Push to your fork**
   ```bash
   git push origin feature/amazing-feature
   ```
7. **Open a Pull Request**

### Coding Standards

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Write tests for new features
- Keep commits atomic and well-described

### Commit Message Convention

We follow [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting, etc.)
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev) - UI framework
- [Google Gemini](https://ai.google.dev) - AI transcription
- [Material Design 3](https://m3.material.io) - Design system
- All open-source contributors

---


**Made with ❤️ using Flutter**

[⬆ Back to Top](#️-rectran---voice-recording--transcription-app)

</div>
