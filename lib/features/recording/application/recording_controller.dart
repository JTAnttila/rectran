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
  bool _highQualityAudio = true;
  bool _autoCreateDrafts = true;

  final void Function(RecordingSession session)? onSessionSaved;
  final void Function(String sessionId, String title, Duration duration)?
      onDraftCreated;

  RecordingStatus get status => _status;
  Duration get elapsed => _elapsed;
  bool get isRecording => _status == RecordingStatus.recording;
  bool get isPaused => _status == RecordingStatus.paused;
  bool get isProcessing => _status == RecordingStatus.processing;
  bool get highQualityAudio => _highQualityAudio;
  bool get autoCreateDrafts => _autoCreateDrafts;
  String? get errorMessage => _errorMessage;
  List<RecordingSession> get sessions => List.unmodifiable(_sessions);

  void setHighQualityAudio(bool value) {
    if (_highQualityAudio == value) {
      return;
    }
    _highQualityAudio = value;
    notifyListeners();
  }

  void setAutoCreateDrafts(bool value) {
    _autoCreateDrafts = value;
  }

  void toggleRecording() {
    switch (_status) {
      case RecordingStatus.idle:
      case RecordingStatus.paused:
        _startRecording();
        break;
      case RecordingStatus.recording:
        pauseRecording();
        break;
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

    final processingDelay = _highQualityAudio
        ? const Duration(seconds: 3)
        : const Duration(seconds: 1);
    await Future<void>.delayed(processingDelay);

    final session = RecordingSession(
      id: const Uuid().v4(),
      title: _generateTitle(),
      createdAt: DateTime.now(),
      duration: _elapsed,
      transcriptionStatus: RecordingTranscriptionStatus.inProgress,
    );
    _sessions.insert(0, session);
    onSessionSaved?.call(session);

    _status = RecordingStatus.idle;
    _elapsed = Duration.zero;
    notifyListeners();

    if (_autoCreateDrafts) {
      onDraftCreated?.call(session.id, session.title, session.duration);
    }
  }

  bool deleteSession(String sessionId) {
    final initialLength = _sessions.length;
    _sessions.removeWhere((session) => session.id == sessionId);
    if (_sessions.length != initialLength) {
      notifyListeners();
      return true;
    }
    return false;
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
    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return 'Recording $date $time';
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
