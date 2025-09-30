import 'package:flutter/material.dart';

import 'package:rectran/features/transcription/domain/transcription_entry.dart';

class TranscriptionDetailPanel extends StatefulWidget {
  const TranscriptionDetailPanel({
    required this.entry,
    this.onTranscriptChanged,
    super.key,
  });

  final TranscriptionEntry entry;
  final ValueChanged<String>? onTranscriptChanged;

  @override
  State<TranscriptionDetailPanel> createState() => _TranscriptionDetailPanelState();
}

class _TranscriptionDetailPanelState extends State<TranscriptionDetailPanel> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.entry.transcript);
  }

  @override
  void didUpdateWidget(covariant TranscriptionDetailPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry.id != widget.entry.id ||
        oldWidget.entry.transcript != widget.entry.transcript) {
      _controller.text = widget.entry.transcript;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.entry.title,
                  style: textTheme.headlineSmall,
                ),
              ),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.ios_share),
                label: const Text('Export'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: [
              Chip(
                label: Text(widget.entry.language),
                avatar: const Icon(Icons.language),
              ),
              Chip(
                label: Text(_statusLabel(widget.entry.status)),
                avatar: Icon(_statusIcon(widget.entry.status)),
              ),
              Chip(
                label: Text(_formatDuration(widget.entry.duration)),
                avatar: const Icon(Icons.timer_outlined),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.entry.summary != null)
            Card(
              elevation: 0,
              color: colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Summary',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      widget.entry.summary!,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text(
            'Transcript',
            style: textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.auto_fix_high_outlined),
                    label: const Text('Auto-clean suggestions'),
                  ),
                  const Divider(),
                  TextField(
                    controller: _controller,
                    minLines: 8,
                    maxLines: null,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Edit the transcript manually…',
                    ),
                    onChanged: widget.onTranscriptChanged,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(TranscriptionStatus status) {
    return switch (status) {
      TranscriptionStatus.draft => 'Draft',
      TranscriptionStatus.processing => 'Processing',
      TranscriptionStatus.completed => 'Completed',
      TranscriptionStatus.failed => 'Failed',
    };
  }

  IconData _statusIcon(TranscriptionStatus status) {
    return switch (status) {
      TranscriptionStatus.draft => Icons.edit_note,
      TranscriptionStatus.processing => Icons.timelapse,
      TranscriptionStatus.completed => Icons.check_circle,
      TranscriptionStatus.failed => Icons.error,
    };
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${duration.inHours > 0 ? '${duration.inHours.toString().padLeft(2, '0')}:' : ''}$minutes:$seconds';
  }
}
