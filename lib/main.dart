import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rectran/app.dart';
import 'package:rectran/features/library/application/library_controller.dart';
import 'package:rectran/features/recording/application/recording_controller.dart';
import 'package:rectran/features/transcription/application/transcription_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppBootstrap());
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late final LibraryController _libraryController;
  late final TranscriptionController _transcriptionController;
  late final RecordingController _recordingController;

  @override
  void initState() {
    super.initState();
    _libraryController = LibraryController();
    _transcriptionController = TranscriptionController();
    _recordingController = RecordingController(
      onSessionSaved: _libraryController.addSession,
      onDraftCreated: (title, duration) {
        _transcriptionController.createDraftFromRecording(
          title: title,
          duration: duration,
        );
      },
    );
  }

  @override
  void dispose() {
    _recordingController.dispose();
    _transcriptionController.dispose();
    _libraryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<RecordingController>.value(
          value: _recordingController,
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
