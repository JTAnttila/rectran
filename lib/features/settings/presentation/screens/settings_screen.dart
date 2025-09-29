import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';

  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
              value: true,
              onChanged: (_) {},
              title: const Text('High quality audio'),
              subtitle: const Text('Use lossless compression for recordings'),
            ),
            SwitchListTile.adaptive(
              value: false,
              onChanged: (_) {},
              title: const Text('Auto start transcription'),
              subtitle:
                  const Text('Send recordings for AI transcription automatically'),
            ),
            const Divider(),
            const _SectionHeader(label: 'Transcription'),
            ListTile(
              title: const Text('Default language'),
              subtitle: const Text('English (US)'),
              trailing: const Icon(Icons.keyboard_arrow_right),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Cloud backup'),
              subtitle: const Text('Sync recordings securely across devices'),
              trailing: Switch.adaptive(value: true, onChanged: (_) {}),
            ),
            const Divider(),
            const _SectionHeader(label: 'Appearance'),
            SwitchListTile.adaptive(
              value: MediaQuery.of(context).platformBrightness == Brightness.dark,
              onChanged: (_) {},
              title: const Text('Use system theme'),
            ),
            ListTile(
              title: const Text('Accent color'),
              subtitle: const Text('Deep Purple'),
              trailing: CircleAvatar(
                backgroundColor: colorScheme.primary,
                radius: 12,
              ),
              onTap: () {},
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
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}
