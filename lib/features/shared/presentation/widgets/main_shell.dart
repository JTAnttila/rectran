import 'package:flutter/material.dart';

import 'package:rectran/features/library/presentation/screens/library_screen.dart';
import 'package:rectran/features/recording/presentation/screens/recording_screen.dart';
import 'package:rectran/features/settings/presentation/screens/settings_screen.dart';
import 'package:rectran/features/transcription/presentation/screens/transcription_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  final PageStorageBucket _bucket = PageStorageBucket();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = const [
      RecordingScreen(key: PageStorageKey('recording')),
      TranscriptionScreen(key: PageStorageKey('transcription')),
      LibraryScreen(key: PageStorageKey('library')),
      SettingsScreen(key: PageStorageKey('settings')),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: PageStorage(
          bucket: _bucket,
          child: IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (value) {
          if (value == _currentIndex) return;
          setState(() => _currentIndex = value);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.mic_none),
            selectedIcon: Icon(Icons.mic, color: colorScheme.primary),
            label: 'Record',
          ),
          NavigationDestination(
            icon: const Icon(Icons.article_outlined),
            selectedIcon: Icon(Icons.article, color: colorScheme.primary),
            label: 'Transcripts',
          ),
          NavigationDestination(
            icon: const Icon(Icons.library_music_outlined),
            selectedIcon:
                Icon(Icons.library_music, color: colorScheme.primary),
            label: 'Library',
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: colorScheme.primary),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
