import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:rectran/core/theme/app_theme.dart';
import 'package:rectran/features/settings/presentation/screens/settings_screen.dart';
import 'package:rectran/features/shared/presentation/widgets/main_shell.dart';
import 'package:rectran/features/transcription/presentation/screens/transcription_detail_screen.dart';

class RectranApp extends StatelessWidget {
  const RectranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rectran',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
      ],
      home: const MainShell(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case SettingsScreen.routeName:
            return MaterialPageRoute<void>(
              builder: (_) => const SettingsScreen(),
              settings: settings,
            );
          case TranscriptionDetailScreen.routeName:
            return MaterialPageRoute<void>(
              builder: (_) => const TranscriptionDetailScreen(),
              settings: settings,
            );
        }
        return null;
      },
    );
  }
}
