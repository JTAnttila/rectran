import 'package:flutter/material.dart';

import 'package:rectran/features/transcription/application/transcription_controller.dart';

class TranscriptionFilterBar extends StatelessWidget {
  const TranscriptionFilterBar({
    required this.controller,
    super.key,
  });

  final TranscriptionController controller;

  @override
  Widget build(BuildContext context) {
    final chipTheme = Theme.of(context).chipTheme;

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: TranscriptionFilter.values.map((filter) {
        final isSelected = controller.filter == filter;
        return FilterChip(
          label: Text(_labelFor(filter)),
          selected: isSelected,
          onSelected: (_) => controller.setFilter(filter),
          selectedColor: chipTheme.selectedColor,
        );
      }).toList(),
    );
  }

  String _labelFor(TranscriptionFilter filter) {
    return switch (filter) {
      TranscriptionFilter.all => 'All',
      TranscriptionFilter.favorites => 'Favorites',
      TranscriptionFilter.drafts => 'Drafts',
      TranscriptionFilter.completed => 'Completed',
    };
  }
}
