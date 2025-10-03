/// Base exception class for all app-specific exceptions
abstract class AppException implements Exception {
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException(this.message, [this.originalError, this.stackTrace]);

  @override
  String toString() => message;

  /// User-friendly error message that can be shown in the UI
  String get userMessage => message;
}

/// Exception thrown when API key is missing or invalid
class ApiKeyException extends AppException {
  const ApiKeyException([String? message, dynamic originalError, StackTrace? stackTrace])
      : super(
          message ?? 'API key not configured. Please add your API key in Settings.',
          originalError,
          stackTrace,
        );

  @override
  String get userMessage => 'API key not configured. Please add your API key in Settings.';
}

/// Exception thrown during audio transcription process
class TranscriptionException extends AppException {
  final String? audioFilePath;

  const TranscriptionException(
    super.message, [
    this.audioFilePath,
    super.originalError,
    super.stackTrace,
  ]);

  @override
  String get userMessage => 'Failed to transcribe audio: $message';
}

/// Exception thrown when API request fails
class ApiException extends AppException {
  final int? statusCode;
  final String? endpoint;

  const ApiException(
    String message, {
    this.statusCode,
    this.endpoint,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(message, originalError, stackTrace);

  @override
  String get userMessage {
    if (statusCode != null) {
      return 'API error ($statusCode): $message';
    }
    return 'API error: $message';
  }
}

/// Exception thrown during audio recording
class RecordingException extends AppException {
  const RecordingException(super.message, [super.originalError, super.stackTrace]);

  @override
  String get userMessage => 'Recording failed: $message';
}

/// Exception thrown during file operations
class FileStorageException extends AppException {
  final String? filePath;

  const FileStorageException(
    super.message, [
    this.filePath,
    super.originalError,
    super.stackTrace,
  ]);

  @override
  String get userMessage => 'File operation failed: $message';
}

/// Exception thrown during export operations
class ExportException extends AppException {
  final String? format;

  const ExportException(
    String message, {
    this.format,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(message, originalError, stackTrace);

  @override
  String get userMessage {
    if (format != null) {
      return 'Failed to export as $format: $message';
    }
    return 'Export failed: $message';
  }
}

/// Exception thrown when secure storage operations fail
class SecureStorageException extends AppException {
  const SecureStorageException(super.message, [super.originalError, super.stackTrace]);

  @override
  String get userMessage => 'Secure storage error: $message';
}

/// Exception thrown when audio playback fails
class AudioPlaybackException extends AppException {
  final String? audioPath;

  const AudioPlaybackException(
    super.message, [
    this.audioPath,
    super.originalError,
    super.stackTrace,
  ]);

  @override
  String get userMessage => 'Playback failed: $message';
}
