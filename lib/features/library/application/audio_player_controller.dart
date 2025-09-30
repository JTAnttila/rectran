import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioPlayerController extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  String? _currentPlayingId;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  AudioPlayerController() {
    _player.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });

    _player.onPositionChanged.listen((position) {
      _position = position;
      notifyListeners();
    });

    _player.onDurationChanged.listen((duration) {
      _duration = duration;
      notifyListeners();
    });

    _player.onPlayerComplete.listen((_) {
      _isPlaying = false;
      _position = Duration.zero;
      _currentPlayingId = null;
      notifyListeners();
    });
  }

  String? get currentPlayingId => _currentPlayingId;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;

  bool isPlayingRecording(String recordingId) {
    return _currentPlayingId == recordingId && _isPlaying;
  }

  Future<void> togglePlayPause(String recordingId, String filePath) async {
    if (_currentPlayingId == recordingId) {
      if (_isPlaying) {
        await _player.pause();
      } else {
        await _player.resume();
      }
    } else {
      await _player.stop();
      _currentPlayingId = recordingId;
      await _player.play(DeviceFileSource(filePath));
    }
  }

  Future<void> stop() async {
    await _player.stop();
    _currentPlayingId = null;
    _position = Duration.zero;
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}