import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rectran/features/recording/application/recording_controller.dart';
import 'package:rectran/features/recording/domain/recording_session.dart';
import 'package:rectran/features/recording/domain/recording_status.dart';
import 'package:rectran/features/recording/presentation/widgets/record_action_buttons.dart';
import 'package:rectran/features/recording/presentation/widgets/record_status_chip.dart';
import 'package:rectran/features/recording/presentation/widgets/record_timer_display.dart';
import 'package:rectran/features/recording/presentation/widgets/waveform_placeholder.dart';
import 'package:rectran/features/settings/presentation/screens/settings_screen.dart';
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
                          '${_formatDuration(session.duration)} · ${_formatDate(session.createdAt)}',
                        ),
                        trailing: _TranscriptionStatus(status: session.transcriptionStatus),
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            TranscriptionDetailScreen.routeName,
                            arguments: session.id,
                          );
                        },
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

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${duration.inHours > 0 ? '${duration.inHours.toString().padLeft(2, '0')}:' : ''}$minutes:$seconds';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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
