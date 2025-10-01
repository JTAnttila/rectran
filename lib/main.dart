import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:rectran/app.dart';
import 'package:rectran/core/services/wear_os_service.dart';
import 'package:rectran/features/library/application/audio_player_controller.dart';
import 'package:rectran/features/library/application/library_controller.dart';
import 'package:rectran/features/recording/application/recording_controller.dart';
import 'package:rectran/features/recording/domain/recording_session.dart';
import 'package:rectran/features/settings/application/settings_controller.dart';
import 'package:rectran/features/transcription/application/transcription_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppBootstrap());
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late final AudioPlayerController _audioPlayerController;
  late final LibraryController _libraryController;
  late final TranscriptionController _transcriptionController;
  late final RecordingController _recordingController;
  late final SettingsController _settingsController;

  @override
  void initState() {
    super.initState();
    _audioPlayerController = AudioPlayerController();
    _libraryController = LibraryController();
    _transcriptionController = TranscriptionController();

    // Initialize recording controller first (will be linked with settings later)
    _recordingController = RecordingController(
      onSessionSaved: (session) {
        _libraryController.addSession(session);

        // Trigger transcription if auto-start is enabled
        if (_settingsController.autoStartTranscription && session.filePath != null) {
          // Create draft entry first
          _transcriptionController.createDraftFromRecording(
            sessionId: session.id,
            title: session.title,
            duration: session.duration,
            language: _settingsController.defaultTranscriptionLanguage,
          );

          // Find the created entry and start transcription
          final entry = _transcriptionController.entries.firstWhereOrNull(
            (e) => e.sourceSessionId == session.id,
          );

          if (entry != null) {
            _transcriptionController.startTranscription(
              entryId: entry.id,
              audioFilePath: session.filePath!,
              modelId: _settingsController.selectedAIModel.modelId,
              language: _settingsController.defaultTranscriptionLanguage,
              onStatusChanged: (sessionId, status) {
                _recordingController.updateSessionTranscriptionStatus(
                  sessionId,
                  status,
                );
              },
            );
          }
        }
      },
    );

    // Initialize settings controller with recording controller
    _settingsController = SettingsController(
      recordingController: _recordingController,
    );
    
    // Initialize Wear OS service to receive audio from watch
    _initializeWearOSService();
  }
  
  void _initializeWearOSService() {
    // Only initialize on Android
    if (!Platform.isAndroid) return;
    
    WearOSService.initialize(
      onAudioReceived: (audioFilePath, watchNodeId) async {
        debugPrint('📱 Received audio from watch: $audioFilePath');
        
        try {
          // Create a recording session for the watch audio
          final duration = Duration.zero; // We don't know the exact duration from watch
          
          final session = RecordingSession(
            id: const Uuid().v4(),
            title: 'Watch Recording ${DateTime.now().toString().substring(0, 16)}',
            filePath: audioFilePath,
            createdAt: DateTime.now(),
            duration: duration,
            transcriptionStatus: RecordingTranscriptionStatus.notStarted,
          );
          
          // Add to library
          _libraryController.addSession(session);
          
          // Create transcription entry
          _transcriptionController.createDraftFromRecording(
            sessionId: session.id,
            title: session.title,
            duration: duration,
            language: _settingsController.defaultTranscriptionLanguage,
          );
          
          // Find the created entry
          final entry = _transcriptionController.entries.firstWhereOrNull(
            (e) => e.sourceSessionId == session.id,
          );
          
          if (entry != null) {
            // Start transcription
            await _transcriptionController.startTranscription(
              entryId: entry.id,
              audioFilePath: audioFilePath,
              modelId: _settingsController.selectedAIModel.modelId,
              language: _settingsController.defaultTranscriptionLanguage,
              onStatusChanged: (sessionId, status) {
                _recordingController.updateSessionTranscriptionStatus(
                  sessionId,
                  status,
                );
                
                // Send status to watch
                if (status == RecordingTranscriptionStatus.completed) {
                  WearOSService.sendSuccessToWatch(
                    watchNodeId: watchNodeId,
                    message: 'Transcription complete!',
                  );
                } else if (status == RecordingTranscriptionStatus.failed) {
                  WearOSService.sendErrorToWatch(
                    watchNodeId: watchNodeId,
                    error: 'Transcription failed',
                  );
                }
              },
            );
            
            debugPrint('✅ Watch audio processed successfully');
          } else {
            throw Exception('Failed to create transcription entry');
          }
        } catch (e) {
          debugPrint('❌ Error processing watch audio: $e');
          await WearOSService.sendErrorToWatch(
            watchNodeId: watchNodeId,
            error: 'Failed to process audio: $e',
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _settingsController.dispose();
    _recordingController.dispose();
    _transcriptionController.dispose();
    _libraryController.dispose();
    _audioPlayerController.dispose();
    WearOSService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AudioPlayerController>.value(
          value: _audioPlayerController,
        ),
        ChangeNotifierProvider<RecordingController>.value(
          value: _recordingController,
        ),
        ChangeNotifierProvider<SettingsController>.value(
          value: _settingsController,
        ),
        ChangeNotifierProvider<TranscriptionController>.value(
          value: _transcriptionController,
        ),
        ChangeNotifierProvider<LibraryController>.value(
          value: _libraryController,
        ),
      ],
      child: const RectranApp(),
    );
  }
}
