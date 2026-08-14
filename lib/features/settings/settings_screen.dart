import 'package:flutter/material.dart';

import '../../app/state/app_scope.dart';
import '../../shared/nova_scaffold.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final settings = controller.settings;
    return NovaScaffold(
      title: 'Settings',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<ThemeMode>(
            initialValue: settings.themeMode,
            decoration: const InputDecoration(labelText: 'Theme'),
            items: ThemeMode.values
                .map(
                  (mode) => DropdownMenuItem(
                    value: mode,
                    child: Text(mode.name),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                controller.updateSettings(
                  (settings) => settings.themeMode = value,
                );
              }
            },
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('High contrast'),
            value: settings.highContrast,
            onChanged: (value) => controller.updateSettings(
              (settings) => settings.highContrast = value,
            ),
          ),
          SwitchListTile(
            title: const Text('Reduced motion'),
            value: settings.reducedMotion,
            onChanged: (value) => controller.updateSettings(
              (settings) => settings.reducedMotion = value,
            ),
          ),
          SwitchListTile(
            title: const Text('Sound'),
            subtitle: const Text('Enable lightweight game and UI feedback.'),
            value: settings.soundEnabled,
            onChanged: (value) => controller.updateSettings(
              (settings) => settings.soundEnabled = value,
            ),
          ),
          SwitchListTile(
            title: const Text('Haptics'),
            subtitle: const Text('Used only on supported platforms.'),
            value: settings.hapticsEnabled,
            onChanged: (value) => controller.updateSettings(
              (settings) => settings.hapticsEnabled = value,
            ),
          ),
          SwitchListTile(
            title: const Text('Confirm restart'),
            value: settings.confirmRestart,
            onChanged: (value) => controller.updateSettings(
              (settings) => settings.confirmRestart = value,
            ),
          ),
        ],
      ),
    );
  }
}
