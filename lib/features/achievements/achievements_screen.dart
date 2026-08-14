import 'package:flutter/material.dart';

import '../../app/state/app_scope.dart';
import '../../shared/nova_scaffold.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    return NovaScaffold(
      title: 'Achievements',
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: controller.achievements.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index == controller.achievements.length) {
            return OutlinedButton(
              onPressed: () => _reset(context),
              child: const Text('Reset achievements'),
            );
          }
          final item = controller.achievements[index];
          return Card(
            child: ListTile(
              leading: Icon(
                item.unlocked
                    ? Icons.emoji_events_rounded
                    : Icons.lock_outline_rounded,
              ),
              title: Text(item.title),
              subtitle: Text(item.description),
              trailing: item.unlocked
                  ? const Icon(Icons.check_circle_rounded)
                  : null,
            ),
          );
        },
      ),
    );
  }

  Future<void> _reset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset achievements?'),
        content: const Text('All local achievement unlocks will be cleared.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await AppScope.of(context).resetAchievements();
    }
  }
}
