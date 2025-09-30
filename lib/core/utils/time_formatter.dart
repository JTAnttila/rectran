/// Utility class for formatting time-related values consistently across the app.
class TimeFormatter {
  TimeFormatter._();

  /// Formats a [Duration] into a human-readable string in the format HH:MM:SS or MM:SS.
  ///
  /// If the duration is less than 1 hour, the hours component is omitted.
  ///
  /// Example:
  /// ```dart
  /// TimeFormatter.formatDuration(Duration(seconds: 65)); // Returns "01:05"
  /// TimeFormatter.formatDuration(Duration(hours: 1, minutes: 30, seconds: 45)); // Returns "01:30:45"
  /// ```
  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${duration.inHours > 0 ? '${duration.inHours.toString().padLeft(2, '0')}:' : ''}$minutes:$seconds';
  }
}