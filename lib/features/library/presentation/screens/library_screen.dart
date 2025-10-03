import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:rectran/features/library/application/library_controller.dart';
import 'package:rectran/features/transcription/presentation/screens/transcription_detail_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LibraryController>();
    final items = controller.filteredItems.toList();

    // Group items by month
    final groupedItems = <String, List<dynamic>>{};
    for (final item in items) {
      final monthKey = DateFormat('MMMM yyyy').format(item.session.createdAt);
      groupedItems.putIfAbsent(monthKey, () => []).add(item);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top bar with back button and search
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.white70),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        // Show search
                      },
                      icon: const Icon(Icons.search, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
            
            // Title
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Text(
                  'Recordings',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            
            // Recordings list grouped by month
            if (items.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_off_outlined,
                        size: 64,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No recordings yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.6),
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
                    final monthKey = groupedItems.keys.elementAt(index);
                    final monthItems = groupedItems[monthKey]!;
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Month header
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                          child: Text(
                            monthKey,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.5),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        // Month recordings
                        ...monthItems.map((item) => _RecordingListItem(
                          item: item,
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              TranscriptionDetailScreen.routeName,
                              arguments: item.session.id,
                            );
                          },
                          onDelete: () {
                            // TODO: Implement delete in controller
                            // controller.deleteRecording(item.session.id);
                          },
                        )),
                      ],
                    );
                  },
                  childCount: groupedItems.length,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RecordingListItem extends StatelessWidget {
  const _RecordingListItem({
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  final dynamic item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final session = item.session;
    final dateFormat = DateFormat('MMM d, h:mm a');
    final duration = _formatDuration(session.duration);

    return InkWell(
      onTap: onTap,
      onLongPress: () => _showDeleteDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            // Play button
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            
            // Title and date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateFormat.format(session.createdAt),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
            
            // Duration
            Text(
              duration,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.6),
                letterSpacing: 1,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
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
            'This will permanently delete the audio file. This action cannot be undone.',
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
