import 'package:flutter/material.dart';

import 'package:rectran/features/library/domain/library_item.dart';
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

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      leading: CircleAvatar(
        backgroundColor: colorScheme.primaryContainer,
        child: Icon(
          Icons.play_arrow,
          color: colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(session.title),
      subtitle: Text(
        '${_formatDuration(session.duration)} · ${_formatDate(session.createdAt)}',
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

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${duration.inHours > 0 ? '${duration.inHours.toString().padLeft(2, '0')}:' : ''}$minutes:$seconds';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
