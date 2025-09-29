import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rectran/features/transcription/application/transcription_controller.dart';
import 'package:rectran/features/transcription/domain/transcription_entry.dart';
import 'package:rectran/features/transcription/presentation/widgets/transcription_detail_panel.dart';

class TranscriptionDetailScreen extends StatelessWidget {
  static const routeName = '/transcription-detail';

  const TranscriptionDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final entryId = args as String?;
    final controller = context.watch<TranscriptionController>();
    TranscriptionEntry? entry;
    if (entryId != null) {
      try {
        entry = controller.entries
            .firstWhere((element) => element.id == entryId);
      } catch (_) {
        entry = controller.activeEntry;
      }
    } else {
      entry = controller.activeEntry;
    }

    final resolvedEntry = entry;

    if (resolvedEntry == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Transcription')),
        body: const Center(
          child: Text('Transcription not found.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(resolvedEntry.title)),
      body: TranscriptionDetailPanel(
        entry: resolvedEntry,
        onTranscriptChanged: (value) =>
            controller.updateTranscript(resolvedEntry.id, value),
      ),
    );
  }
}
