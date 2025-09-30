/// Application-wide configuration constants
class AppConfig {
  // Prevent instantiation
  AppConfig._();

  // Application Identity
  static const String packageName = 'com.JTA.rectran';
  static const String appName = 'Rectran';
  static const String appTitle = 'Voice Recorder';

  // Author Information
  static const String authorName = 'Juuso Anttila';
  static const String authorEmail = 'juuso@anttila.io';
  static const String repository = 'https://github.com/JTAnttila/rectran';

  // API Configuration
  static const String defaultModelId = 'gemini-2.5-flash';

  // Recording Defaults
  static const String recordingTitlePrefix = 'Recording';
  static const int minSdkVersion = 23;

  // Storage Keys
  static const String selectedModelKey = 'selected_ai_model';
  static const String themeModeKey = 'theme_mode';
  static const String accentColorKey = 'accent_color';
  static const String autoStartTranscriptionKey = 'auto_start_transcription';
  static const String defaultLanguageKey = 'default_language';

  // Secure Storage Keys
  static const String apiKeyPrefix = 'api_key_';

  // Export Settings
  static const String exportFileExtensionText = 'txt';
  static const String exportFileExtensionPdf = 'pdf';
  static const String exportMimeTypeText = 'text/plain';
  static const String exportMimeTypePdf = 'application/pdf';

  // UI Constants
  static const int maxRecentSessionsDisplay = 50;
  static const Duration snackbarDuration = Duration(seconds: 3);

  // Date Format Patterns
  static const String dateFormatPattern = 'yyyy-MM-dd';
  static const String timeFormatPattern = 'HH:mm:ss';
  static const String dateTimeFormatPattern = 'yyyy-MM-dd HH:mm:ss';
}
