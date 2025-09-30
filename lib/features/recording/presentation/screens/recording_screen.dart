import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rectran/core/utils/time_formatter.dart';
import 'package:rectran/features/library/application/library_controller.dart';
import 'package:rectran/features/recording/application/recording_controller.dart';
import 'package:rectran/features/recording/domain/recording_session.dart';
import 'package:rectran/features/recording/domain/recording_status.dart';
import 'package:rectran/features/recording/presentation/widgets/record_action_buttons.dart';
import 'package:rectran/features/recording/presentation/widgets/record_status_chip.dart';
import 'package:rectran/features/recording/presentation/widgets/record_timer_display.dart';
import 'package:rectran/features/recording/presentation/widgets/waveform_placeholder.dart';
import 'package:rectran/features/settings/presentation/screens/settings_screen.dart';
import 'package:rectran/features/transcription/application/transcription_controller.dart';
import 'package:rectran/features/transcription/presentation/screens/transcription_detail_screen.dart';

class RecordingScreen extends StatelessWidget {
  const RecordingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RecordingController>();
    final colorScheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: const Text('Voice Recorder'),
          floating: true,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(SettingsScreen.routeName);
              },
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Settings',
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    child: Column(
                      children: [
                        WaveformPlaceholder(
                          isActive: controller.status == RecordingStatus.recording,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(height: 24),
                        RecordTimerDisplay(duration: controller.elapsed),
                        const SizedBox(height: 8),
                        RecordStatusChip(status: controller.status),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                RecordActionButtons(controller: controller),
                if (controller.sessions.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Recent Sessions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final session = controller.sessions[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colorScheme.primaryContainer,
                          child: Icon(
                            Icons.graphic_eq,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        title: Text(session.title),
                        subtitle: Text(
                          '${TimeFormatter.formatDuration(session.duration)} · ${_formatDate(session.createdAt)}',
                        ),
                        trailing: _TranscriptionStatus(status: session.transcriptionStatus),
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            TranscriptionDetailScreen.routeName,
                            arguments: session.id,
                          );
                        },
                        onLongPress: () => _confirmDeletion(context, session),
                      );
                    },
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemCount: controller.sessions.length,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

Future<void> _confirmDeletion(
  BuildContext context,
  RecordingSession session,
) async {
  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Delete recording?'),
        content: Text(
          'Deleting "${session.title}" will remove the audio and any related transcripts. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor:
                  Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );

  if (!context.mounted) {
    return;
  }

  if (shouldDelete != true) {
    return;
  }

  final recordingController = context.read<RecordingController>();
  final libraryController = context.read<LibraryController>();
  final transcriptionController = context.read<TranscriptionController>();

  final deleted = recordingController.deleteSession(session.id);
  if (deleted) {
    libraryController.removeSession(session.id);
    transcriptionController.removeBySourceSessionId(session.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Recording "${session.title}" deleted.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _TranscriptionStatus extends StatelessWidget {
  const _TranscriptionStatus({
    required this.status,
  });

  final RecordingTranscriptionStatus status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final (background, foreground, label) = switch (status) {
      RecordingTranscriptionStatus.notStarted => (
        colorScheme.surfaceContainerHighest,
        colorScheme.onSurface,
        'Pending',
      ),
      RecordingTranscriptionStatus.inProgress => (
        colorScheme.primaryContainer,
        colorScheme.onPrimaryContainer,
        'Processing',
      ),
      RecordingTranscriptionStatus.completed => (
        colorScheme.secondaryContainer,
        colorScheme.onSecondaryContainer,
        'Completed',
      ),
      RecordingTranscriptionStatus.failed => (
        colorScheme.errorContainer,
        colorScheme.onErrorContainer,
        'Failed',
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: textTheme.labelMedium?.copyWith(color: foreground),
      ),
    );
  }
}
