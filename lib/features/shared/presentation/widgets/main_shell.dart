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
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: PageStorage(
        bucket: _bucket,
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: _MinimalistBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) return;
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}

class _MinimalistBottomNav extends StatelessWidget {
  const _MinimalistBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFF242424),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.fiber_manual_record,
              label: 'Record',
              isSelected: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _NavItem(
              icon: Icons.article_outlined,
              label: 'Transcripts',
              isSelected: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            _NavItem(
              icon: Icons.folder_outlined,
              label: 'Library',
              isSelected: currentIndex == 2,
              onTap: () => onTap(2),
            ),
            _NavItem(
              icon: Icons.settings_outlined,
              label: 'Settings',
              isSelected: currentIndex == 3,
              onTap: () => onTap(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? const Color(0xFFFF4757) 
                  : Colors.white.withOpacity(0.4),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected 
                    ? const Color(0xFFFF4757) 
                    : Colors.white.withOpacity(0.4),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
