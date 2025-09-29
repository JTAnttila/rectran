import 'package:flutter/material.dart';

import 'package:rectran/features/library/application/library_controller.dart';
import 'package:rectran/features/library/domain/library_item.dart';

class LibrarySortDropdown extends StatelessWidget {
  const LibrarySortDropdown({
    required this.controller,
    super.key,
  });

  final LibraryController controller;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<LibrarySort>(
        value: controller.sort,
        borderRadius: BorderRadius.circular(12),
        onChanged: (value) {
          if (value != null) {
            controller.setSort(value);
          }
        },
        items: LibrarySort.values
            .map(
              (sort) => DropdownMenuItem(
                value: sort,
                child: Text(_labelFor(sort)),
              ),
            )
            .toList(),
      ),
    );
  }

  String _labelFor(LibrarySort sort) {
    return switch (sort) {
      LibrarySort.newest => 'Newest',
      LibrarySort.oldest => 'Oldest',
      LibrarySort.shortest => 'Shortest',
      LibrarySort.longest => 'Longest',
    };
  }
}
