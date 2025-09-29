import 'package:flutter/material.dart';

import 'package:rectran/features/library/application/library_controller.dart';
import 'package:rectran/features/library/domain/library_filter.dart';

class LibraryFilterBar extends StatelessWidget {
  const LibraryFilterBar({
    required this.controller,
    super.key,
  });

  final LibraryController controller;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      children: LibraryFilter.values.map((filter) {
        final isSelected = controller.filter == filter;
        return ChoiceChip(
          label: Text(_labelFor(filter)),
          selected: isSelected,
          onSelected: (_) => controller.setFilter(filter),
        );
      }).toList(),
    );
  }

  String _labelFor(LibraryFilter filter) {
    return switch (filter) {
      LibraryFilter.all => 'All',
      LibraryFilter.favorites => 'Favorites',
      LibraryFilter.flagged => 'Flagged',
      LibraryFilter.needsReview => 'Needs review',
    };
  }
}
