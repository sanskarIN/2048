import 'package:flutter/material.dart';

import '../../app/state/app_scope.dart';
import '../../core/localization/nova_localizations.dart';
import '../../shared/nova_scaffold.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final l10n = context.l10n;
    return NovaScaffold(
      title: l10n.text('Achievements'),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: controller.achievements.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index == controller.achievements.length) {
            return OutlinedButton(
              onPressed: () => _reset(context),
              child: Text(l10n.text('Reset achievements')),
            );
          }
          final item = controller.achievements[index];
          final progress = controller.achievementProgress(item);
          final fraction = (progress / item.threshold).clamp(0, 1).toDouble();
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    item.unlocked
                        ? Icons.emoji_events_rounded
                        : Icons.lock_outline_rounded,
                    size: 30,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.achievementTitle(item.id, item.title),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            if (item.unlocked)
                              const Icon(Icons.check_circle_rounded, size: 20),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.achievementDescription(
                            item.id,
                            item.description,
                          ),
                        ),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(value: fraction),
                        const SizedBox(height: 5),
                        Text(
                          item.unlocked
                              ? l10n.isHindi
                                    ? '${l10n.text('Unlocked')} ${_date(item.unlockedAt!)}'
                                    : 'Unlocked ${_date(item.unlockedAt!)}'
                              : '$progress / ${item.threshold}',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static String _date(DateTime value) {
    final date = value.toLocal();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  Future<void> _reset(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.text('Reset achievements?')),
        content: Text(
          l10n.text('All local achievement unlocks will be cleared.'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.text('Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.text('Reset')),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await AppScope.of(context).resetAchievements();
    }
  }
}
