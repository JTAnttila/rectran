import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rectran/features/library/application/library_controller.dart';
import 'package:rectran/features/library/presentation/widgets/library_filter_bar.dart';
import 'package:rectran/features/library/presentation/widgets/library_list_item.dart';
import 'package:rectran/features/library/presentation/widgets/library_sort_dropdown.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LibraryController>();
    final items = controller.filteredItems.toList();
    final colorScheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: const Text('Library'),
          floating: true,
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.filter_list_alt),
              tooltip: 'Advanced Filters',
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Organize and revisit your recordings',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Filter by favorites, flags, or transcription status.',
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
                    hintText: 'Search recordings…',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: LibraryFilterBar(controller: controller),
                    ),
                    const SizedBox(width: 16),
                    LibrarySortDropdown(controller: controller),
                  ],
                ),
                const SizedBox(height: 24),
                if (items.isEmpty)
                  _EmptyState(colorScheme: colorScheme)
                else
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return LibraryListItem(
                        item: item,
                        onFavoriteToggled: () =>
                            controller.toggleFavorite(item.session.id),
                        onFlaggedToggled: () =>
                            controller.toggleFlagged(item.session.id),
                      );
                    },
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemCount: items.length,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.colorScheme,
  });

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            Icons.folder_off_outlined,
            size: 64,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'Your library is empty',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Create recordings and completed transcriptions to see them listed here.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
