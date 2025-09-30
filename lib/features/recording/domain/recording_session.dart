import 'package:equatable/equatable.dart';

class RecordingSession extends Equatable {
  const RecordingSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.duration,
    this.transcriptionStatus = RecordingTranscriptionStatus.notStarted,
    this.filePath,
  });

  final String id;
  final String title;
  final DateTime createdAt;
  final Duration duration;
  final RecordingTranscriptionStatus transcriptionStatus;
  final String? filePath;

  RecordingSession copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    Duration? duration,
    RecordingTranscriptionStatus? transcriptionStatus,
    String? filePath,
  }) {
    return RecordingSession(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      duration: duration ?? this.duration,
      transcriptionStatus:
          transcriptionStatus ?? this.transcriptionStatus,
      filePath: filePath ?? this.filePath,
    );
  }

  @override
  List<Object?> get props =>
      [id, title, createdAt, duration, transcriptionStatus, filePath];
}

enum RecordingTranscriptionStatus {
  notStarted,
  inProgress,
  completed,
  failed,
}
