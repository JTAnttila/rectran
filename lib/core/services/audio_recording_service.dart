import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AudioRecordingService {
  final AudioRecorder _recorder = AudioRecorder();
  String? _currentRecordingPath;

  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  Future<String?> startRecording({bool highQuality = true}) async {
    if (!await hasPermission()) {
      return null;
    }

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'recording_$timestamp.m4a';
    final filePath = '${directory.path}/$fileName';

    final config = RecordConfig(
      encoder: AudioEncoder.aacLc,
      bitRate: highQuality ? 256000 : 128000,
      sampleRate: highQuality ? 48000 : 44100,
      numChannels: 1,
    );

    await _recorder.start(config, path: filePath);
    _currentRecordingPath = filePath;
    return filePath;
  }

  Future<void> pauseRecording() async {
    await _recorder.pause();
  }

  Future<void> resumeRecording() async {
    await _recorder.resume();
  }

  Future<String?> stopRecording() async {
    final path = await _recorder.stop();
    _currentRecordingPath = null;
    return path;
  }

  Future<void> cancelRecording() async {
    await _recorder.cancel();
    if (_currentRecordingPath != null) {
      final file = File(_currentRecordingPath!);
      if (await file.exists()) {
        await file.delete();
      }
      _currentRecordingPath = null;
    }
  }

  Future<bool> isRecording() async {
    return await _recorder.isRecording();
  }

  String? get currentRecordingPath => _currentRecordingPath;

  void dispose() {
    _recorder.dispose();
  }
}