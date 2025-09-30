import 'package:flutter/material.dart';

import 'package:rectran/core/services/export_service.dart';
import 'package:rectran/core/utils/time_formatter.dart';
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
  final ExportService _exportService = ExportService();

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
                onPressed: () => _showExportOptions(context),
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
                label: Text(TimeFormatter.formatDuration(widget.entry.duration)),
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

  void _showExportOptions(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Export Options',
                style: textTheme.titleLarge,
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.article_outlined),
              title: const Text('Export as Text'),
              subtitle: const Text('Transcript and summary as .txt'),
              onTap: () => _exportAsText(context),
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Export as Markdown'),
              subtitle: const Text('Formatted transcript and summary as .md'),
              onTap: () => _exportAsMarkdown(context),
            ),
            ListTile(
              leading: const Icon(Icons.data_object),
              title: const Text('Export as JSON'),
              subtitle: const Text('Structured data as .json'),
              onTap: () => _exportAsJson(context),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Export as PDF'),
              subtitle: const Text('Formatted document as .pdf'),
              onTap: () => _exportAsPdf(context),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('Export transcript only'),
              onTap: () => _exportTranscriptOnly(context),
            ),
            ListTile(
              leading: const Icon(Icons.auto_awesome),
              title: const Text('Export summary only'),
              onTap: () => _exportSummaryOnly(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _exportAsText(BuildContext context) async {
    Navigator.pop(context);
    try {
      await _exportService.exportAsText(
        transcript: widget.entry.transcript,
        summary: widget.entry.summary ?? 'No summary available',
        createdAt: widget.entry.createdAt,
        title: widget.entry.title,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _exportAsMarkdown(BuildContext context) async {
    Navigator.pop(context);
    try {
      await _exportService.exportAsMarkdown(
        transcript: widget.entry.transcript,
        summary: widget.entry.summary ?? 'No summary available',
        createdAt: widget.entry.createdAt,
        title: widget.entry.title,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _exportAsJson(BuildContext context) async {
    Navigator.pop(context);
    try {
      await _exportService.exportAsJson(
        transcript: widget.entry.transcript,
        summary: widget.entry.summary ?? 'No summary available',
        createdAt: widget.entry.createdAt,
        title: widget.entry.title,
        additionalData: {
          'language': widget.entry.language,
          'duration': widget.entry.duration.inSeconds,
          'status': widget.entry.status.name,
        },
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _exportAsPdf(BuildContext context) async {
    Navigator.pop(context);
    try {
      await _exportService.exportAsPdf(
        transcript: widget.entry.transcript,
        summary: widget.entry.summary ?? 'No summary available',
        createdAt: widget.entry.createdAt,
        title: widget.entry.title,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _exportTranscriptOnly(BuildContext context) async {
    Navigator.pop(context);
    try {
      await _exportService.exportTranscriptOnly(
        transcript: widget.entry.transcript,
        createdAt: widget.entry.createdAt,
        title: widget.entry.title,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _exportSummaryOnly(BuildContext context) async {
    Navigator.pop(context);
    if (widget.entry.summary == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No summary available to export')),
      );
      return;
    }
    try {
      await _exportService.exportSummaryOnly(
        summary: widget.entry.summary!,
        createdAt: widget.entry.createdAt,
        title: widget.entry.title,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }
}
