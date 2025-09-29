import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:rectran/features/recording/domain/recording_session.dart';
import 'package:rectran/features/recording/domain/recording_status.dart';

class RecordingController extends ChangeNotifier {
  RecordingController({
    this.onSessionSaved,
    this.onDraftCreated,
  });

  RecordingStatus _status = RecordingStatus.idle;
  Duration _elapsed = Duration.zero;
  Timer? _ticker;
  final List<RecordingSession> _sessions = <RecordingSession>[];
  String? _errorMessage;

  final void Function(RecordingSession session)? onSessionSaved;
  final void Function(String title, Duration duration)? onDraftCreated;

  RecordingStatus get status => _status;
  Duration get elapsed => _elapsed;
  bool get isRecording => _status == RecordingStatus.recording;
  bool get isPaused => _status == RecordingStatus.paused;
  bool get isProcessing => _status == RecordingStatus.processing;
  String? get errorMessage => _errorMessage;
  List<RecordingSession> get sessions => List.unmodifiable(_sessions);

  void toggleRecording() {
    switch (_status) {
      case RecordingStatus.idle:
      case RecordingStatus.paused:
        _startRecording();
      case RecordingStatus.recording:
        pauseRecording();
      case RecordingStatus.processing:
      case RecordingStatus.error:
        break;
    }
  }

  void _startRecording() {
    _status = RecordingStatus.recording;
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsed += const Duration(seconds: 1);
      notifyListeners();
    });
    notifyListeners();
  }

  void pauseRecording() {
    if (_status != RecordingStatus.recording) {
      return;
    }
    _status = RecordingStatus.paused;
    _ticker?.cancel();
    notifyListeners();
  }

  Future<void> stopRecording() async {
    if (_status == RecordingStatus.idle) {
      return;
    }
    _status = RecordingStatus.processing;
    _ticker?.cancel();
    notifyListeners();

    await Future<void>.delayed(const Duration(seconds: 2));
    final session = RecordingSession(
      id: const Uuid().v4(),
      title: _generateTitle(),
      createdAt: DateTime.now(),
      duration: _elapsed,
      transcriptionStatus: RecordingTranscriptionStatus.inProgress,
    );
    _sessions.insert(0, session);

    onSessionSaved?.call(session);
    onDraftCreated?.call(session.title, session.duration);

    _status = RecordingStatus.idle;
    _elapsed = Duration.zero;
    notifyListeners();
  }

  void resetError() {
    _errorMessage = null;
    notifyListeners();
  }

  void setError(String message) {
    _errorMessage = message;
    _status = RecordingStatus.error;
    _ticker?.cancel();
    notifyListeners();
  }

  void clearHistory() {
    _sessions.clear();
    notifyListeners();
  }

  String _generateTitle() {
    final now = DateTime.now();
    return 'Recording ${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
