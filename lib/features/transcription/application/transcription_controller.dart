import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:rectran/core/services/gemini_service.dart';
import 'package:rectran/features/recording/domain/recording_session.dart';
import 'package:rectran/features/transcription/domain/transcription_entry.dart';

enum TranscriptionFilter {
  all,
  favorites,
  drafts,
  completed,
}

class TranscriptionController extends ChangeNotifier {
  TranscriptionController() {
    _geminiService = GeminiService();
  }

  late GeminiService _geminiService;
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
    return _entries.firstWhereOrNull((entry) => entry.id == _activeEntryId) ??
           _entries.firstOrNull;
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

  Future<void> startTranscription({
    required String entryId,
    required String audioFilePath,
    required String modelId,
    String? language,
    Function(String sessionId, RecordingTranscriptionStatus status)? onStatusChanged,
  }) async {
    final index = _entries.indexWhere((entry) => entry.id == entryId);
    if (index == -1) return;

    _entries[index] = _entries[index].copyWith(
      status: TranscriptionStatus.processing,
    );
    notifyListeners();

    // Notify processing started
    final sessionId = _entries[index].sourceSessionId;
    if (sessionId != null) {
      onStatusChanged?.call(sessionId, RecordingTranscriptionStatus.inProgress);
    }

    try {
      final transcription = await _geminiService.transcribeAudio(
        audioFilePath: audioFilePath,
        modelId: modelId,
        language: language,
      );

      final summary = await _geminiService.generateSummary(
        transcription: transcription,
        modelId: modelId,
      );

      _entries[index] = _entries[index].copyWith(
        transcript: transcription,
        summary: summary,
        status: TranscriptionStatus.completed,
      );
      notifyListeners();

      // Notify completed
      if (sessionId != null) {
        onStatusChanged?.call(sessionId, RecordingTranscriptionStatus.completed);
      }
    } catch (e) {
      _entries[index] = _entries[index].copyWith(
        status: TranscriptionStatus.failed,
        summary: 'Transcription failed: $e',
      );
      notifyListeners();

      // Notify failed
      if (sessionId != null) {
        onStatusChanged?.call(sessionId, RecordingTranscriptionStatus.failed);
      }
    }
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
}
