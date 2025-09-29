import 'package:equatable/equatable.dart';

class RecordingSession extends Equatable {
  const RecordingSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.duration,
    this.transcriptionStatus = RecordingTranscriptionStatus.notStarted,
  });

  final String id;
  final String title;
  final DateTime createdAt;
  final Duration duration;
  final RecordingTranscriptionStatus transcriptionStatus;

  RecordingSession copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    Duration? duration,
    RecordingTranscriptionStatus? transcriptionStatus,
  }) {
    return RecordingSession(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      duration: duration ?? this.duration,
      transcriptionStatus:
          transcriptionStatus ?? this.transcriptionStatus,
    );
  }

  @override
  List<Object> get props =>
      [id, title, createdAt, duration, transcriptionStatus];
}

enum RecordingTranscriptionStatus {
  notStarted,
  inProgress,
  completed,
  failed,
}
