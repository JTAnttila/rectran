import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rectran/features/transcription/application/transcription_controller.dart';
import 'package:rectran/features/transcription/presentation/widgets/transcription_detail_panel.dart';
import 'package:rectran/features/transcription/presentation/widgets/transcription_filter_bar.dart';
import 'package:rectran/features/transcription/presentation/widgets/transcription_list_item.dart';

class TranscriptionScreen extends StatelessWidget {
  const TranscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TranscriptionController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 860;
        final list = _TranscriptionList(controller: controller);
        final detail = _ActiveTranscriptionDetail(controller: controller);

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: list),
              const VerticalDivider(width: 1),
              Expanded(flex: 3, child: detail),
            ],
          );
        }

        return CustomScrollView(
          slivers: [
            const SliverAppBar(
              title: Text('Transcriptions'),
              floating: true,
            ),
            SliverToBoxAdapter(child: list),
            SliverToBoxAdapter(child: detail),
          ],
        );
      },
    );
  }
}

class _TranscriptionList extends StatelessWidget {
  const _TranscriptionList({
    required this.controller,
  });

  final TranscriptionController controller;

  @override
  Widget build(BuildContext context) {
    final entries = controller.filteredEntries.toList();
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Manage your AI transcripts',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Search, edit, and share your transcriptions quickly.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              TextField(
                onChanged: controller.setQuery,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search by title, keyword, or speaker',
                ),
              ),
              const SizedBox(height: 16),
              TranscriptionFilterBar(controller: controller),
            ],
          ),
        ),
        if (entries.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: Column(
              children: [
                Icon(
                  Icons.library_music_outlined,
                  size: 64,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'No transcriptions yet',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Record audio to automatically populate this space with AI-generated transcripts.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return TranscriptionListItem(
                entry: entry,
                isActive: entry.id == controller.activeEntry?.id,
                onTap: () => controller.setActiveEntry(entry.id),
                onFavoriteToggled: () => controller.toggleFavorite(entry.id),
              );
            },
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemCount: entries.length,
          ),
        const SizedBox(height: 48),
      ],
    );
  }
}

class _ActiveTranscriptionDetail extends StatelessWidget {
  const _ActiveTranscriptionDetail({
    required this.controller,
  });

  final TranscriptionController controller;

  @override
  Widget build(BuildContext context) {
    final entry = controller.activeEntry;
    if (entry == null) {
      return const SizedBox.shrink();
    }

    return TranscriptionDetailPanel(
      entry: entry,
      onTranscriptChanged: (value) =>
          controller.updateTranscript(entry.id, value),
    );
  }
}
