import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rectran/features/transcription/application/transcription_controller.dart';
import 'package:rectran/features/transcription/presentation/screens/transcription_detail_screen.dart';

class TranscriptionScreen extends StatelessWidget {
  const TranscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TranscriptionController>();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: _TranscriptionList(controller: controller),
      ),
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

    return CustomScrollView(
      slivers: [
        // Title
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Text(
              'Transcripts',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        
        // Search bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: TextField(
              onChanged: controller.setQuery,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search transcripts...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.4)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ),
        
        // Transcriptions list
        if (entries.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.article_outlined,
                    size: 64,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No transcripts yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      'Record audio to create AI-powered transcripts',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final entry = entries[index];
                return _TranscriptListItem(
                  entry: entry,
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      TranscriptionDetailScreen.routeName,
                      arguments: entry.id,
                    );
                  },
                  onDelete: () {
                    // TODO: Implement delete functionality in controller
                    // controller.deleteEntry(entry.id);
                  },
                );
              },
              childCount: entries.length,
            ),
          ),
      ],
    );
  }
}

class _TranscriptListItem extends StatelessWidget {
  const _TranscriptListItem({
    required this.entry,
    required this.onTap,
    required this.onDelete,
  });

  final dynamic entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final title = entry.title ?? 'Untitled';
    final preview = entry.transcript?.isEmpty ?? true 
        ? 'No transcript available' 
        : entry.transcript.substring(0, entry.transcript.length > 80 ? 80 : entry.transcript.length);

    return InkWell(
      onTap: onTap,
      onLongPress: () => _showDeleteDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (entry.isFavorite == true)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.star,
                      color: Color(0xFFFF4757),
                      size: 16,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              preview,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.5),
                letterSpacing: 0.1,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          title: const Text(
            'Delete Recording',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'This will permanently delete the audio file and transcript. This action cannot be undone.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFFF4757),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      onDelete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Recording deleted'),
          backgroundColor: const Color(0xFF2A2A2A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
