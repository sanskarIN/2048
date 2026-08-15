import 'package:flutter/material.dart';

import '../../app/state/app_scope.dart';
import '../../core/localization/nova_localizations.dart';
import '../../core/theme/nova_theme.dart';
import '../../shared/nova_scaffold.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final settings = controller.settings;
    final l10n = context.l10n;
    return NovaScaffold(
      title: l10n.text('Settings'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.text('Appearance'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<AppLanguage>(
            initialValue: settings.language,
            decoration: InputDecoration(labelText: l10n.text('Language')),
            items: AppLanguage.values
                .map(
                  (language) => DropdownMenuItem(
                    value: language,
                    child: Text(
                      language == AppLanguage.hindi
                          ? language.label
                          : l10n.text(language.label),
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                controller.updateSettings(
                  (settings) => settings.language = value,
                );
              }
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<ThemeMode>(
            initialValue: settings.themeMode,
            decoration: InputDecoration(labelText: l10n.text('Brightness')),
            items: ThemeMode.values
                .map(
                  (mode) => DropdownMenuItem(
                    value: mode,
                    child: Text(
                      l10n.text(switch (mode) {
                        ThemeMode.system => 'System',
                        ThemeMode.light => 'Light',
                        ThemeMode.dark => 'Dark',
                      }),
                    ),
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
            decoration: InputDecoration(labelText: l10n.text('Color theme')),
            items: NovaPalette.values
                .map(
                  (palette) => DropdownMenuItem(
                    value: palette,
                    child: Text(l10n.text(palette.label)),
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
            title: Text(l10n.text('High contrast')),
            value: settings.highContrast,
            onChanged: (value) => controller.updateSettings(
              (settings) => settings.highContrast = value,
            ),
          ),
          SwitchListTile(
            title: Text(l10n.text('Reduced motion')),
            value: settings.reducedMotion,
            onChanged: (value) => controller.updateSettings(
              (settings) => settings.reducedMotion = value,
            ),
          ),
          const Divider(height: 32),
          Text(
            l10n.text('Audio & haptics'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SwitchListTile(
            title: Text(l10n.text('Sound')),
            subtitle: Text(
              l10n.text('Enable lightweight game and UI feedback.'),
            ),
            value: settings.soundEnabled,
            onChanged: (value) => controller.updateSettings(
              (settings) => settings.soundEnabled = value,
            ),
          ),
          SwitchListTile(
            title: Text(l10n.text('Haptics')),
            subtitle: Text(l10n.text('Used only on supported platforms.')),
            value: settings.hapticsEnabled,
            onChanged: (value) => controller.updateSettings(
              (settings) => settings.hapticsEnabled = value,
            ),
          ),
          const Divider(height: 32),
          Text(
            l10n.text('Gameplay'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SwitchListTile(
            title: Text(l10n.text('Confirm restart')),
            value: settings.confirmRestart,
            onChanged: (value) => controller.updateSettings(
              (settings) => settings.confirmRestart = value,
            ),
          ),
          const Divider(height: 32),
          Text(
            l10n.text('Data'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          ListTile(
            leading: const Icon(Icons.restart_alt_rounded),
            title: Text(l10n.text('Reset current game')),
            subtitle: Text(
              l10n.text('Remove the saved board and undo history.'),
            ),
            enabled: controller.hasGame,
            onTap: controller.hasGame
                ? () => _confirmAction(
                      context,
                      title: l10n.text('Reset current game?'),
                      message: l10n.text(
                        'Your saved board and undo history will be removed.',
                      ),
                      action: controller.clearCurrentGame,
                    )
                : null,
          ),
          ListTile(
            leading: const Icon(Icons.insights_rounded),
            title: Text(l10n.text('Reset statistics')),
            subtitle: Text(
              l10n.text(
                controller.hasGame
                    ? 'Clear historical statistics while keeping the active game as the current session.'
                    : 'Clear all locally stored statistics.',
              ),
            ),
            onTap: () => _confirmAction(
              context,
              title: l10n.text('Reset statistics?'),
              message: l10n.text(
                controller.hasGame
                    ? 'Historical statistics will be cleared. The active game remains counted as the current session so future win-rate data stays valid.'
                    : 'All locally stored statistics will be cleared.',
              ),
              action: controller.resetStats,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.emoji_events_outlined),
            title: Text(l10n.text('Reset achievements')),
            onTap: () => _confirmAction(
              context,
              title: l10n.text('Reset achievements?'),
              message: l10n.text(
                'All local achievement unlock dates will be cleared.',
              ),
              action: controller.resetAchievements,
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.delete_forever_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              l10n.text('Clear all local data'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            subtitle: Text(
              l10n.text(
                'Reset game, settings, statistics, achievements, and daily history.',
              ),
            ),
            onTap: () => _confirmAction(
              context,
              title: l10n.text('Clear all local data?'),
              message: l10n.text(
                'This removes all 2048 Nova data stored on this device and cannot be undone.',
              ),
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
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.text('Cancel')),
          ),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: Theme.of(dialogContext).colorScheme.error,
                    foregroundColor:
                        Theme.of(dialogContext).colorScheme.onError,
                  )
                : null,
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.text(destructive ? 'Clear all' : 'Reset')),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await action();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.text('Local data updated.'))),
    );
  }
}
