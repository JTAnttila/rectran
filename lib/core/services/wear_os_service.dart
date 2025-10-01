import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Service to handle communication with Wear OS devices
/// Receives audio from watch, processes it, and sends responses back
class WearOSService {
  static const MethodChannel _channel = MethodChannel('com.jta.rectran/wear');
  static const MethodChannel _audioChannel = MethodChannel('com.jta.rectran/wear_audio');
  static bool _initialized = false;

  /// Callbacks for handling wear audio
  static Future<void> Function(String audioFilePath, String watchNodeId)? onWearAudioReceived;

  /// Initialize the Wear OS service
  static void initialize({
    required Future<void> Function(String audioFilePath, String watchNodeId) onAudioReceived,
  }) {
    if (_initialized) {
      debugPrint('WearOSService already initialized');
      return;
    }

    onWearAudioReceived = onAudioReceived;

    // Set up method call handlers
    _channel.setMethodCallHandler(_handleMethodCall);
    _audioChannel.setMethodCallHandler(_handleAudioMethodCall);
    _initialized = true;

    debugPrint('WearOSService initialized');
  }

  /// Handle audio method calls from Android native code
  static Future<dynamic> _handleAudioMethodCall(MethodCall call) async {
    debugPrint('WearOSService audio channel received call: ${call.method}');

    switch (call.method) {
      case 'onWearAudioReceived':
        final audioFilePath = call.arguments['audioPath'] as String?;
        final watchNodeId = call.arguments['watchId'] as String?;

        if (audioFilePath == null || watchNodeId == null) {
          throw PlatformException(
            code: 'INVALID_ARGS',
            message: 'audioPath and watchId are required',
          );
        }

        // Verify file exists
        final file = File(audioFilePath);
        if (!await file.exists()) {
          debugPrint('Audio file does not exist: $audioFilePath');
          throw PlatformException(
            code: 'FILE_NOT_FOUND',
            message: 'Audio file not found',
          );
        }

        debugPrint('Processing wear audio: $audioFilePath (${await file.length()} bytes)');

        // Call the callback
        if (onWearAudioReceived != null) {
          try {
            await onWearAudioReceived!(audioFilePath, watchNodeId);
            return true;
          } catch (e) {
            debugPrint('Error processing wear audio: $e');
            rethrow;
          }
        } else {
          debugPrint('No callback registered for wear audio');
          throw PlatformException(
            code: 'NO_HANDLER',
            message: 'No handler registered for wear audio',
          );
        }

      default:
        throw PlatformException(
          code: 'NOT_IMPLEMENTED',
          message: 'Method ${call.method} not implemented',
        );
    }
  }

  /// Handle method calls from Android native code (for wear control)
  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    debugPrint('WearOSService control channel received call: ${call.method}');

    // This channel is for control messages (not audio)
    throw PlatformException(
      code: 'NOT_IMPLEMENTED',
      message: 'Method ${call.method} not implemented on control channel',
    );
  }

  /// Send success notification to the watch
  static Future<void> sendSuccessToWatch({
    required String watchNodeId,
    String message = 'Transcription complete',
  }) async {
    try {
      await _channel.invokeMethod('sendSuccessToWatch', {
        'watchNodeId': watchNodeId,
        'message': message,
      });
      debugPrint('Success sent to watch: $message');
    } catch (e) {
      debugPrint('Failed to send success to watch: $e');
    }
  }

  /// Send error notification to the watch
  static Future<void> sendErrorToWatch({
    required String watchNodeId,
    required String error,
  }) async {
    try {
      await _channel.invokeMethod('sendErrorToWatch', {
        'watchNodeId': watchNodeId,
        'error': error,
      });
      debugPrint('Error sent to watch: $error');
    } catch (e) {
      debugPrint('Failed to send error to watch: $e');
    }
  }

  /// Cleanup the service
  static void dispose() {
    _channel.setMethodCallHandler(null);
    _audioChannel.setMethodCallHandler(null);
    onWearAudioReceived = null;
    _initialized = false;
    debugPrint('WearOSService disposed');
  }
}
