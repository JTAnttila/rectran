import 'package:flutter/material.dart';

import 'package:rectran/features/transcription/domain/transcription_entry.dart';

class TranscriptionListItem extends StatelessWidget {
  const TranscriptionListItem({
    required this.entry,
    required this.isActive,
    required this.onTap,
    required this.onFavoriteToggled,
    super.key,
  });

  final TranscriptionEntry entry;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color:
          isActive ? colorScheme.primaryContainer.withValues(alpha: 0.4) : null,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(
            _iconFor(entry.status),
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(entry.title),
        subtitle: Text(
          '${entry.language} • ${_formatDuration(entry.duration)}'
          '\n${_statusLabel(entry.status)}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        isThreeLine: true,
        trailing: IconButton(
          onPressed: onFavoriteToggled,
          icon: Icon(
            entry.isFavorite ? Icons.favorite : Icons.favorite_outline,
            color: entry.isFavorite ? colorScheme.primary : null,
          ),
        ),
      ),
    );
  }

  IconData _iconFor(TranscriptionStatus status) {
    return switch (status) {
      TranscriptionStatus.draft => Icons.edit_note,
      TranscriptionStatus.processing => Icons.timelapse,
      TranscriptionStatus.completed => Icons.check_circle,
      TranscriptionStatus.failed => Icons.error,
    };
  }

  String _statusLabel(TranscriptionStatus status) {
    return switch (status) {
      TranscriptionStatus.draft => 'Draft pending transcription',
      TranscriptionStatus.processing => 'Processing with AI',
      TranscriptionStatus.completed => 'Completed and ready',
      TranscriptionStatus.failed => 'Failed to transcribe',
    };
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${duration.inHours > 0 ? '${duration.inHours.toString().padLeft(2, '0')}:' : ''}$minutes:$seconds';
  }
}
