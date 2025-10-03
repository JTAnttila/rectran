import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rectran/features/transcription/application/transcription_controller.dart';
import 'package:rectran/features/transcription/presentation/widgets/transcription_detail_panel.dart';

class TranscriptionDetailScreen extends StatelessWidget {
  static const routeName = '/transcription-detail';

  const TranscriptionDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final entryId = args as String?;
    final controller = context.watch<TranscriptionController>();

    final entry = entryId != null
        ? controller.entries.firstWhereOrNull((element) => element.id == entryId) ??
          controller.activeEntry
        : controller.activeEntry;

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
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          children: [
            // Custom dark header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Text(
                      resolvedEntry.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      resolvedEntry.isFavorite ? Icons.star : Icons.star_border,
                      color: resolvedEntry.isFavorite ? const Color(0xFFFF4757) : Colors.white,
                    ),
                    onPressed: () {
                      // TODO: Toggle favorite
                    },
                  ),
                ],
              ),
            ),
            // Transcript content
            Expanded(
              child: TranscriptionDetailPanel(
                entry: resolvedEntry,
                onTranscriptChanged: (value) =>
                    controller.updateTranscript(resolvedEntry.id, value),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
