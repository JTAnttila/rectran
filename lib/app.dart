import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:rectran/core/theme/app_theme.dart';
import 'package:rectran/features/settings/application/settings_controller.dart';
import 'package:rectran/features/settings/presentation/screens/settings_screen.dart';
import 'package:rectran/features/shared/presentation/widgets/main_shell.dart';
import 'package:rectran/features/transcription/presentation/screens/transcription_detail_screen.dart';

class RectranApp extends StatelessWidget {
  const RectranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsController>(
      builder: (context, settingsController, _) {
        final accent = settingsController.accentColor;

        return MaterialApp(
          title: 'Rectran',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(seed: accent),
          darkTheme: AppTheme.dark(seed: accent),
          themeMode: settingsController.themeMode,
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
      },
    );
  }
}
