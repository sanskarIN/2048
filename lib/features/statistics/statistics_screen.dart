import 'package:flutter/material.dart';

import '../../app/state/app_scope.dart';
import '../../shared/nova_scaffold.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = AppScope.of(context).stats;
    final values = [
      ('Games played', '${stats.gamesPlayed}'),
      ('Games won', '${stats.gamesWon}'),
      ('Win rate', '${(stats.winRate * 100).toStringAsFixed(1)}%'),
      ('Best score', '${stats.bestScore}'),
      ('Highest tile', '${stats.highestTile}'),
      ('Total moves', '${stats.totalMoves}'),
      ('Total merges', '${stats.totalMerges}'),
      ('Current streak', '${stats.currentStreak}'),
      ('Best streak', '${stats.bestStreak}'),
    ];
    return NovaScaffold(
      title: 'Statistics',
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: values.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index == values.length) {
            return OutlinedButton.icon(
              onPressed: () => _reset(context),
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Reset statistics'),
            );
          }
          return Card(
            child: ListTile(
              title: Text(values[index].$1),
              trailing: Text(values[index].$2),
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
        title: const Text('Reset statistics?'),
        content: const Text('This cannot be undone.'),
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
      await AppScope.of(context).resetStats();
    }
  }
}
