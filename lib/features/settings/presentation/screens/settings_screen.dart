import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rectran/core/config/ai_model.dart';
import 'package:rectran/features/settings/application/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';

  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsController>(
      builder: (context, controller, _) {
        return CustomScrollView(
          slivers: [
            const SliverAppBar(
              title: Text('Settings'),
              floating: true,
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                const _SectionHeader(label: 'Recording'),
                SwitchListTile.adaptive(
                  value: controller.highQualityAudio,
                  onChanged: (value) => controller.setHighQualityAudio(value),
                  title: const Text('High quality audio'),
                  subtitle:
                      const Text('Use lossless compression for recordings'),
                ),
                SwitchListTile.adaptive(
                  value: controller.autoStartTranscription,
                  onChanged: (value) =>
                      controller.setAutoStartTranscription(value),
                  title: const Text('Auto start transcription'),
                  subtitle: const Text(
                    'Send recordings for AI transcription automatically',
                  ),
                ),
                const Divider(),
                const _SectionHeader(label: 'Transcription'),
                ListTile(
                  title: const Text('AI Model'),
                  subtitle: Text(controller.selectedAIModel.displayName),
                  trailing: const Icon(Icons.keyboard_arrow_right),
                  onTap: () => _showAIModelPicker(context, controller),
                ),
                ListTile(
                  title: const Text('Default language'),
                  subtitle: Text(controller.defaultTranscriptionLanguage),
                  trailing: const Icon(Icons.keyboard_arrow_right),
                  onTap: () => _showLanguagePicker(context, controller),
                ),
                SwitchListTile.adaptive(
                  value: controller.cloudBackupEnabled,
                  onChanged: controller.cloudBackupBusy
                      ? null
                      : (value) => controller.setCloudBackupEnabled(value),
                  title: const Text('Cloud backup'),
                  subtitle: Text(
                    controller.cloudBackupBusy
                        ? 'Updating cloud backup settings...'
                        : 'Sync recordings securely across devices',
                  ),
                  secondary: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: controller.cloudBackupBusy
                        ? const SizedBox(
                            key: ValueKey('backup-progress'),
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(
                            Icons.cloud_outlined,
                            key: ValueKey('backup-icon'),
                          ),
                  ),
                ),
                ListTile(
                  title: const Text('Manual backup'),
                  subtitle: const Text('Trigger an immediate sync now'),
                  enabled: controller.cloudBackupEnabled &&
                      !controller.cloudBackupBusy,
                  onTap: controller.cloudBackupEnabled &&
                          !controller.cloudBackupBusy
                      ? () => controller.triggerManualBackup()
                      : null,
                  trailing: controller.cloudBackupBusy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : FilledButton.tonal(
                          onPressed: controller.cloudBackupEnabled
                              ? () => controller.triggerManualBackup()
                              : null,
                          child: const Text('Sync now'),
                        ),
                ),
                const Divider(),
                const _SectionHeader(label: 'Appearance'),
                SwitchListTile.adaptive(
                  value: controller.useSystemTheme,
                  onChanged: (value) => controller.setUseSystemTheme(value),
                  title: const Text('Use system theme'),
                ),
                if (!controller.useSystemTheme) ...[
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.light,
                    groupValue: controller.manualThemeMode,
                    onChanged: (value) {
                      if (value != null) {
                        controller.setManualThemeMode(value);
                      }
                    },
                    title: const Text('Light theme'),
                  ),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.dark,
                    groupValue: controller.manualThemeMode,
                    onChanged: (value) {
                      if (value != null) {
                        controller.setManualThemeMode(value);
                      }
                    },
                    title: const Text('Dark theme'),
                  ),
                ],
                ListTile(
                  title: const Text('Accent color'),
                  subtitle: Text(controller.accentColorLabel),
                  trailing: CircleAvatar(
                    backgroundColor: controller.accentColor,
                    radius: 12,
                  ),
                  onTap: () => _showAccentPicker(context, controller),
                ),
                const Divider(),
                const _SectionHeader(label: 'About'),
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Version'),
                  subtitle: Text('0.1.0'),
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Privacy Policy'),
                  onTap: () {},
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ],
        );
      },
    );
  }

  static Future<void> _showAccentPicker(
    BuildContext context,
    SettingsController controller,
  ) async {
    final selected = await showModalBottomSheet<Color>(
      context: context,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              ...controller.accentOptions.map(
                (option) => ListTile(
                  leading: CircleAvatar(backgroundColor: option.color),
                  title: Text(option.label),
          trailing: option.color == controller.accentColor
                      ? Icon(
                          Icons.check,
              color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop(option.color);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      await controller.setAccentColor(selected);
    }
  }

  static Future<void> _showAIModelPicker(
    BuildContext context,
    SettingsController controller,
  ) async {
    final selected = await showModalBottomSheet<AIModel>(
      context: context,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: AIModel.values.map((model) {
              return RadioListTile<AIModel>(
                title: Text(model.displayName),
                subtitle: Text(model.modelId),
                value: model,
                groupValue: controller.selectedAIModel,
                onChanged: (value) {
                  Navigator.of(bottomSheetContext).pop(value);
                },
              );
            }).toList(),
          ),
        );
      },
    );

    if (selected != null) {
      await controller.setSelectedAIModel(selected);
    }
  }

  static Future<void> _showLanguagePicker(
    BuildContext context,
    SettingsController controller,
  ) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: controller.supportedLanguages.map((language) {
              return RadioListTile<String>(
                title: Text(language),
                value: language,
                groupValue: controller.defaultTranscriptionLanguage,
                onChanged: (value) {
                  Navigator.of(bottomSheetContext).pop(value);
                },
              );
            }).toList(),
          ),
        );
      },
    );

    if (selected != null) {
      await controller.setDefaultLanguage(selected);
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}
