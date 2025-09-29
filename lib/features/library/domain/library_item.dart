import 'package:equatable/equatable.dart';

import 'package:rectran/features/recording/domain/recording_session.dart';

enum LibrarySort { newest, oldest, shortest, longest }

class LibraryItem extends Equatable {
  const LibraryItem({
    required this.session,
    this.isFavorite = false,
    this.isFlagged = false,
    this.tags = const <String>[],
  });

  final RecordingSession session;
  final bool isFavorite;
  final bool isFlagged;
  final List<String> tags;

  LibraryItem copyWith({
    RecordingSession? session,
    bool? isFavorite,
    bool? isFlagged,
    List<String>? tags,
  }) {
    return LibraryItem(
      session: session ?? this.session,
      isFavorite: isFavorite ?? this.isFavorite,
      isFlagged: isFlagged ?? this.isFlagged,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [session, isFavorite, isFlagged, tags];
}
