import 'package:flutter/material.dart';

import '../../app/state/app_scope.dart';
import '../../core/theme/nova_theme.dart';
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
          Text('Appearance', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          DropdownButtonFormField<ThemeMode>(
            initialValue: settings.themeMode,
            decoration: const InputDecoration(labelText: 'Brightness'),
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
          DropdownButtonFormField<NovaPalette>(
            initialValue: settings.palette,
            decoration: const InputDecoration(labelText: 'Color theme'),
            items: NovaPalette.values
                .map(
                  (palette) => DropdownMenuItem(
                    value: palette,
                    child: Text(palette.label),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                controller.updateSettings(
                  (settings) => settings.palette = value,
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
          const Divider(height: 32),
          Text(
            'Audio & haptics',
            style: Theme.of(context).textTheme.titleMedium,
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
          const Divider(height: 32),
          Text('Gameplay', style: Theme.of(context).textTheme.titleMedium),
          SwitchListTile(
            title: const Text('Confirm restart'),
            value: settings.confirmRestart,
            onChanged: (value) => controller.updateSettings(
              (settings) => settings.confirmRestart = value,
            ),
          ),
          const Divider(height: 32),
          Text('Data', style: Theme.of(context).textTheme.titleMedium),
          ListTile(
            leading: const Icon(Icons.restart_alt_rounded),
            title: const Text('Reset current game'),
            subtitle: const Text('Remove the saved board and undo history.'),
            enabled: controller.hasGame,
            onTap: controller.hasGame
                ? () => _confirmAction(
                      context,
                      title: 'Reset current game?',
                      message: 'Your saved board and undo history will be removed.',
                      action: controller.clearCurrentGame,
                    )
                : null,
          ),
          ListTile(
            leading: const Icon(Icons.insights_rounded),
            title: const Text('Reset statistics'),
            onTap: () => _confirmAction(
              context,
              title: 'Reset statistics?',
              message: 'All locally stored statistics will be cleared.',
              action: controller.resetStats,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.emoji_events_outlined),
            title: const Text('Reset achievements'),
            onTap: () => _confirmAction(
              context,
              title: 'Reset achievements?',
              message: 'All local achievement unlock dates will be cleared.',
              action: controller.resetAchievements,
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.delete_forever_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              'Clear all local data',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            subtitle: const Text(
              'Reset game, settings, statistics, achievements, and daily history.',
            ),
            onTap: () => _confirmAction(
              context,
              title: 'Clear all local data?',
              message:
                  'This removes all 2048 Nova data stored on this device and cannot be undone.',
              action: controller.clearAllData,
              destructive: true,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAction(
    BuildContext context, {
    required String title,
    required String message,
    required Future<void> Function() action,
    bool destructive = false,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: Theme.of(dialogContext).colorScheme.error,
                    foregroundColor: Theme.of(dialogContext).colorScheme.onError,
                  )
                : null,
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(destructive ? 'Clear all' : 'Reset'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await action();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Local data updated.')),
    );
  }
}
