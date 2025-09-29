import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:rectran/features/transcription/domain/transcription_entry.dart';

enum TranscriptionFilter {
  all,
  favorites,
  drafts,
  completed,
}

class TranscriptionController extends ChangeNotifier {
  TranscriptionController() {
    _seedMockData();
  }

  final List<TranscriptionEntry> _entries = <TranscriptionEntry>[];
  String _query = '';
  TranscriptionFilter _filter = TranscriptionFilter.all;
  String? _activeEntryId;

  List<TranscriptionEntry> get entries => List.unmodifiable(_entries);
  String get query => _query;
  TranscriptionFilter get filter => _filter;
  TranscriptionEntry? get activeEntry {
    if (_entries.isEmpty) {
      return null;
    }
    if (_activeEntryId == null) {
      return _entries.first;
    }
    try {
      return _entries.firstWhere((entry) => entry.id == _activeEntryId);
    } catch (_) {
      return _entries.first;
    }
  }

  Iterable<TranscriptionEntry> get filteredEntries => _entries.where((entry) {
        final matchesQuery = _query.isEmpty ||
            entry.title.toLowerCase().contains(_query.toLowerCase()) ||
            entry.transcript.toLowerCase().contains(_query.toLowerCase());
        final matchesFilter = switch (_filter) {
          TranscriptionFilter.all => true,
          TranscriptionFilter.favorites => entry.isFavorite,
          TranscriptionFilter.drafts => entry.status == TranscriptionStatus.draft,
          TranscriptionFilter.completed =>
            entry.status == TranscriptionStatus.completed,
        };
        return matchesQuery && matchesFilter;
      });

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void setFilter(TranscriptionFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  void toggleFavorite(String id) {
    final index = _entries.indexWhere((entry) => entry.id == id);
    if (index == -1) return;

    _entries[index] =
        _entries[index].copyWith(isFavorite: !_entries[index].isFavorite);
    notifyListeners();
  }

  void updateTranscript(String id, String transcript) {
    final index = _entries.indexWhere((entry) => entry.id == id);
    if (index == -1) return;

    _entries[index] = _entries[index].copyWith(
      transcript: transcript,
      status: TranscriptionStatus.completed,
    );
    notifyListeners();
  }

  void createDraftFromRecording({
    required String sessionId,
    required String title,
    required Duration duration,
    String language = 'English',
  }) {
    final entry = TranscriptionEntry(
      id: const Uuid().v4(),
      title: title,
      createdAt: DateTime.now(),
      language: language,
      status: TranscriptionStatus.draft,
      duration: duration,
      transcript: '',
      summary: 'Auto summaries will appear here once transcription finishes.',
      sourceSessionId: sessionId,
    );
    _entries.insert(0, entry);
    _activeEntryId = entry.id;
    notifyListeners();
  }

  void removeBySourceSessionId(String sessionId) {
    final initialLength = _entries.length;
    _entries.removeWhere((entry) => entry.sourceSessionId == sessionId);
    if (_entries.length == initialLength) {
      return;
    }
    if (_entries.isEmpty) {
      _activeEntryId = null;
    } else if (_activeEntryId != null &&
        !_entries.any((entry) => entry.id == _activeEntryId)) {
      _activeEntryId = _entries.first.id;
    }
    notifyListeners();
  }

  void setActiveEntry(String id) {
    _activeEntryId = id;
    notifyListeners();
  }

  void _seedMockData() {
    final now = DateTime.now();
    _entries.addAll([
      TranscriptionEntry(
        id: const Uuid().v4(),
        title: 'Client Interview',
        createdAt: now.subtract(const Duration(hours: 5)),
        language: 'English',
        status: TranscriptionStatus.completed,
        duration: const Duration(minutes: 28, seconds: 12),
        summary:
            'Discussion about project milestones, deliverables, and risks.',
        transcript:
            'Client: Great to connect today. Let’s align on the upcoming deliverables...\n\nYou: Absolutely, we have three main milestones...',
        isFavorite: true,
      ),
      TranscriptionEntry(
        id: const Uuid().v4(),
        title: 'Standup Notes',
        createdAt: now.subtract(const Duration(days: 1)),
        language: 'English',
        status: TranscriptionStatus.processing,
        duration: const Duration(minutes: 14, seconds: 48),
        summary: 'Daily sync waiting for AI transcription.',
      ),
      TranscriptionEntry(
        id: const Uuid().v4(),
        title: 'Lecture Highlights',
        createdAt: now.subtract(const Duration(days: 3)),
        language: 'Finnish',
        status: TranscriptionStatus.completed,
        duration: const Duration(minutes: 52, seconds: 5),
        summary:
            'Overview of signal processing fundamentals with key formulae.',
        transcript:
            'Professor: The Fourier transform allows us to observe signals in the frequency domain...\n\nNote: Remember to review the Nyquist theorem.',
      ),
    ]);
    _activeEntryId = _entries.first.id;
  }
}
