import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:rectran/features/recording/domain/recording_session.dart';
import 'package:rectran/features/library/domain/library_filter.dart';
import 'package:rectran/features/library/domain/library_item.dart';

class LibraryController extends ChangeNotifier {
  LibraryController() {
    _seedMockData();
  }

  final List<LibraryItem> _items = <LibraryItem>[];
  LibraryFilter _filter = LibraryFilter.all;
  LibrarySort _sort = LibrarySort.newest;
  String _query = '';

  List<LibraryItem> get items => List.unmodifiable(_items);
  LibraryFilter get filter => _filter;
  LibrarySort get sort => _sort;
  String get query => _query;

  Iterable<LibraryItem> get filteredItems {
    final filtered = _items.where((item) {
      final matchesQuery = _query.isEmpty ||
          item.session.title.toLowerCase().contains(_query.toLowerCase());
      final matchesFilter = switch (_filter) {
        LibraryFilter.all => true,
        LibraryFilter.favorites => item.isFavorite,
        LibraryFilter.flagged => item.isFlagged,
        LibraryFilter.needsReview => item.session.transcriptionStatus ==
            RecordingTranscriptionStatus.failed,
      };
      return matchesQuery && matchesFilter;
    }).toList();

    filtered.sort((a, b) {
      return switch (_sort) {
        LibrarySort.newest => b.session.createdAt.compareTo(a.session.createdAt),
        LibrarySort.oldest => a.session.createdAt.compareTo(b.session.createdAt),
        LibrarySort.shortest =>
          a.session.duration.compareTo(b.session.duration),
        LibrarySort.longest =>
          b.session.duration.compareTo(a.session.duration),
      };
    });
    return filtered;
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void setFilter(LibraryFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  void setSort(LibrarySort sort) {
    _sort = sort;
    notifyListeners();
  }

  void toggleFavorite(String id) {
    final index = _items.indexWhere((item) => item.session.id == id);
    if (index == -1) return;
    _items[index] = _items[index].copyWith(
      isFavorite: !_items[index].isFavorite,
    );
    notifyListeners();
  }

  void toggleFlagged(String id) {
    final index = _items.indexWhere((item) => item.session.id == id);
    if (index == -1) return;
    _items[index] = _items[index].copyWith(
      isFlagged: !_items[index].isFlagged,
    );
    notifyListeners();
  }

  void addSession(RecordingSession session) {
    _items.insert(0, LibraryItem(session: session));
    notifyListeners();
  }

  void removeSession(String sessionId) {
    final initialLength = _items.length;
    _items.removeWhere((item) => item.session.id == sessionId);
    if (_items.length != initialLength) {
      notifyListeners();
    }
  }

  void _seedMockData() {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, MMM d');
    _items.addAll([
      LibraryItem(
        session: RecordingSession(
          id: const Uuid().v4(),
          title: 'Design Workshop Recap',
          createdAt: now.subtract(const Duration(hours: 2)),
          duration: const Duration(minutes: 42, seconds: 16),
          transcriptionStatus: RecordingTranscriptionStatus.completed,
        ),
        isFavorite: true,
        tags: const ['Workshop', 'Design'],
      ),
      LibraryItem(
        session: RecordingSession(
          id: const Uuid().v4(),
          title: 'Daily Journal - ${formatter.format(now)}',
          createdAt: now.subtract(const Duration(days: 1)),
          duration: const Duration(minutes: 12, seconds: 4),
          transcriptionStatus: RecordingTranscriptionStatus.inProgress,
        ),
        isFlagged: true,
        tags: const ['Personal'],
      ),
      LibraryItem(
        session: RecordingSession(
          id: const Uuid().v4(),
          title: 'Product Sprint Planning',
          createdAt: now.subtract(const Duration(days: 4)),
          duration: const Duration(minutes: 55, seconds: 40),
          transcriptionStatus: RecordingTranscriptionStatus.failed,
        ),
        tags: const ['Sprint', 'Planning'],
      ),
    ]);
  }
}
