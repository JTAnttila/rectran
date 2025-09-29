import 'package:flutter/material.dart';

import 'package:rectran/features/recording/domain/recording_status.dart';

class RecordStatusChip extends StatelessWidget {
  const RecordStatusChip({
    required this.status,
    super.key,
  });

  final RecordingStatus status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final (background, foreground, label) = switch (status) {
      RecordingStatus.idle => (
        colorScheme.surfaceContainerHighest,
        colorScheme.onSurface,
        'Ready to record',
      ),
      RecordingStatus.recording => (
        colorScheme.errorContainer,
        colorScheme.onErrorContainer,
        'Recording',
      ),
      RecordingStatus.paused => (
        colorScheme.secondaryContainer,
        colorScheme.onSecondaryContainer,
        'Paused',
      ),
      RecordingStatus.processing => (
        colorScheme.primaryContainer,
        colorScheme.onPrimaryContainer,
        'Saving…',
      ),
      RecordingStatus.error => (
        colorScheme.error,
        colorScheme.onError,
        'Error',
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: textTheme.labelLarge?.copyWith(color: foreground),
      ),
    );
  }
}
