import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rectran/core/utils/time_formatter.dart';
import 'package:rectran/features/library/domain/library_item.dart';
import 'package:rectran/features/library/application/audio_player_controller.dart';
import 'package:rectran/features/transcription/presentation/screens/transcription_detail_screen.dart';

class LibraryListItem extends StatelessWidget {
  const LibraryListItem({
    required this.item,
    required this.onFavoriteToggled,
    required this.onFlaggedToggled,
    super.key,
  });

  final LibraryItem item;
  final VoidCallback onFavoriteToggled;
  final VoidCallback onFlaggedToggled;

  @override
  Widget build(BuildContext context) {
    final session = item.session;
    final colorScheme = Theme.of(context).colorScheme;
    final audioPlayer = context.watch<AudioPlayerController>();
    final isPlaying = audioPlayer.isPlayingRecording(session.id);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      leading: CircleAvatar(
        backgroundColor: colorScheme.primaryContainer,
        child: session.filePath != null
            ? IconButton(
                onPressed: () {
                  audioPlayer.togglePlayPause(session.id, session.filePath!);
                },
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: colorScheme.onPrimaryContainer,
                ),
                padding: EdgeInsets.zero,
              )
            : Icon(
                Icons.music_note,
                color: colorScheme.onPrimaryContainer,
              ),
      ),
      title: Text(session.title),
      subtitle: Text(
        '${TimeFormatter.formatDuration(session.duration)} · ${_formatDate(session.createdAt)}',
      ),
      trailing: Wrap(
        spacing: 8,
        children: [
          IconButton(
            onPressed: onFlaggedToggled,
            icon: Icon(
              Icons.flag_outlined,
              color: item.isFlagged ? colorScheme.tertiary : null,
            ),
          ),
          IconButton(
            onPressed: onFavoriteToggled,
            icon: Icon(
              item.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: item.isFavorite ? colorScheme.primary : null,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(
                TranscriptionDetailScreen.routeName,
                arguments: session.id,
              );
            },
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
