import 'dart:io';

class AudioChunkingService {
  // Gemini API can handle up to ~25MB files
  // For M4A at 256kbps, that's roughly 13 minutes
  // We'll use 10 minutes as safe threshold
  static const int maxDurationSeconds = 600; // 10 minutes

  Future<int> getAudioDurationFromFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      return 0;
    }

    // Estimate duration based on file size and bitrate
    // For M4A at 256kbps (32KB/s) or 128kbps (16KB/s)
    final fileSize = await file.length();

    // Use conservative estimate: assume 20KB/s average bitrate
    final estimatedSeconds = (fileSize / 20000).round();
    return estimatedSeconds;
  }

  bool shouldWarnLongFile(int durationSeconds) {
    return durationSeconds > maxDurationSeconds;
  }
}