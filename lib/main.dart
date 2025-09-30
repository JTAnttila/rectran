import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:rectran/app.dart';
import 'package:rectran/features/library/application/audio_player_controller.dart';
import 'package:rectran/features/library/application/library_controller.dart';
import 'package:rectran/features/recording/application/recording_controller.dart';
import 'package:rectran/features/settings/application/settings_controller.dart';
import 'package:rectran/features/transcription/application/transcription_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
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
          final entry = _transcriptionController.entries.firstWhere(
            (e) => e.sourceSessionId == session.id,
          );

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
      },
    );

    // Initialize settings controller with recording controller
    _settingsController = SettingsController(
      recordingController: _recordingController,
    );
  }

  @override
  void dispose() {
    _settingsController.dispose();
    _recordingController.dispose();
    _transcriptionController.dispose();
    _libraryController.dispose();
    _audioPlayerController.dispose();
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
