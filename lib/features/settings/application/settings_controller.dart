import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rectran/core/theme/app_theme.dart';
import 'package:rectran/features/recording/application/recording_controller.dart';

class AccentColorOption {
  const AccentColorOption({required this.label, required this.color});

  final String label;
  final Color color;
}

class SettingsController extends ChangeNotifier {
  SettingsController({
    required RecordingController recordingController,
  }) : _recordingController = recordingController {
    _recordingController.setHighQualityAudio(_highQualityAudio);
    _recordingController.setAutoCreateDrafts(_autoStartTranscription);
  }

  final RecordingController _recordingController;

  bool _highQualityAudio = true;
  bool _autoStartTranscription = true;
  bool _cloudBackupEnabled = true;
  bool _cloudBackupBusy = false;
  bool _useSystemTheme = true;
  ThemeMode _manualThemeMode = ThemeMode.dark;
  String _defaultLanguage = 'English (US)';
  Color _accentColor = AppTheme.defaultSeed;

  static const List<AccentColorOption> _accentPalette = [
    AccentColorOption(label: 'Deep Purple', color: Color(0xFF5B3B8C)),
    AccentColorOption(label: 'Ocean Blue', color: Color(0xFF1565C0)),
    AccentColorOption(label: 'Emerald', color: Color(0xFF2E7D32)),
    AccentColorOption(label: 'Sunset', color: Color(0xFFEF6C00)),
    AccentColorOption(label: 'Crimson', color: Color(0xFFC62828)),
    AccentColorOption(label: 'Rose', color: Color(0xFFAD1457)),
  ];

  static const List<String> _supportedLanguages = <String>[
    'English (US)',
    'Finnish',
    'Swedish',
    'German',
    'Spanish',
    'French',
  ];

  bool get highQualityAudio => _highQualityAudio;
  bool get autoStartTranscription => _autoStartTranscription;
  bool get cloudBackupEnabled => _cloudBackupEnabled;
  bool get cloudBackupBusy => _cloudBackupBusy;
  bool get useSystemTheme => _useSystemTheme;
  ThemeMode get manualThemeMode => _manualThemeMode;
  ThemeMode get themeMode =>
      _useSystemTheme ? ThemeMode.system : _manualThemeMode;
  String get defaultTranscriptionLanguage => _defaultLanguage;
  Color get accentColor => _accentColor;

  String get accentColorLabel => _accentPalette
      .firstWhere(
        (option) => option.color == _accentColor,
        orElse: () => AccentColorOption(label: 'Custom', color: _accentColor),
      )
      .label;

  List<AccentColorOption> get accentOptions =>
      List<AccentColorOption>.unmodifiable(_accentPalette);

  List<String> get supportedLanguages =>
      List<String>.unmodifiable(_supportedLanguages);

  Future<void> setHighQualityAudio(bool value) async {
    if (_highQualityAudio == value) {
      return;
    }
    _highQualityAudio = value;
    _recordingController.setHighQualityAudio(value);
    notifyListeners();
  }

  Future<void> setAutoStartTranscription(bool value) async {
    if (_autoStartTranscription == value) {
      return;
    }
    _autoStartTranscription = value;
    _recordingController.setAutoCreateDrafts(value);
    notifyListeners();
  }

  Future<void> setUseSystemTheme(bool value) async {
    if (_useSystemTheme == value) {
      return;
    }
    _useSystemTheme = value;
    notifyListeners();
  }

  Future<void> setManualThemeMode(ThemeMode value) async {
    if (_manualThemeMode == value) {
      return;
    }
    _manualThemeMode = value;
    if (!_useSystemTheme) {
      notifyListeners();
    }
  }

  Future<void> setAccentColor(Color value) async {
    if (_accentColor == value) {
      return;
    }
    _accentColor = value;
    notifyListeners();
  }

  Future<void> setDefaultLanguage(String value) async {
    if (_defaultLanguage == value) {
      return;
    }
    _defaultLanguage = value;
    notifyListeners();
  }

  Future<void> setCloudBackupEnabled(bool value) async {
    if (_cloudBackupEnabled == value) {
      return;
    }
    _cloudBackupBusy = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 600));

    _cloudBackupEnabled = value;
    _cloudBackupBusy = false;
    notifyListeners();
  }

  Future<void> triggerManualBackup() async {
    if (_cloudBackupBusy) {
      return;
    }
    _cloudBackupBusy = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(seconds: 1));

    _cloudBackupBusy = false;
    notifyListeners();
  }
}
