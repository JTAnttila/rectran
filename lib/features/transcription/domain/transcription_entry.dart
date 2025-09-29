import 'package:equatable/equatable.dart';

enum TranscriptionStatus {
  draft,
  processing,
  completed,
  failed,
}

class TranscriptionEntry extends Equatable {
  const TranscriptionEntry({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.language,
    required this.status,
    required this.duration,
    this.summary,
    this.transcript = '',
    this.isFavorite = false,
  });

  final String id;
  final String title;
  final DateTime createdAt;
  final String language;
  final TranscriptionStatus status;
  final Duration duration;
  final String? summary;
  final String transcript;
  final bool isFavorite;

  TranscriptionEntry copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    String? language,
    TranscriptionStatus? status,
    Duration? duration,
    String? summary,
    String? transcript,
    bool? isFavorite,
  }) {
    return TranscriptionEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      language: language ?? this.language,
      status: status ?? this.status,
      duration: duration ?? this.duration,
      summary: summary ?? this.summary,
      transcript: transcript ?? this.transcript,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        createdAt,
        language,
        status,
        duration,
        summary,
        transcript,
        isFavorite,
      ];
}
