import 'package:flutter/material.dart';

import '../../app/state/app_scope.dart';
import '../../core/localization/nova_localizations.dart';
import '../../shared/nova_scaffold.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stats = AppScope.of(context).stats;
    final averageMoves =
        stats.gamesPlayed == 0 ? 0.0 : stats.totalMoves / stats.gamesPlayed;
    final averageMerges =
        stats.gamesPlayed == 0 ? 0.0 : stats.totalMerges / stats.gamesPlayed;
    final values = [
      ('Games played', '${stats.gamesPlayed}'),
      ('Games won', '${stats.gamesWon}'),
      ('Win rate', '${(stats.winRate * 100).toStringAsFixed(1)}%'),
      ('Best score', '${stats.bestScore}'),
      ('Highest tile', '${stats.highestTile}'),
      ('Total moves', '${stats.totalMoves}'),
      ('Total merges', '${stats.totalMerges}'),
      ('Average moves / game', averageMoves.toStringAsFixed(1)),
      ('Average merges / game', averageMerges.toStringAsFixed(1)),
      ('Current win streak', '${stats.currentStreak}'),
      ('Best win streak', '${stats.bestStreak}'),
    ];
    return NovaScaffold(
      title: l10n.text('Statistics'),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: values.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index == values.length) {
            return OutlinedButton.icon(
              onPressed: () => _reset(context),
              icon: const Icon(Icons.delete_outline_rounded),
              label: Text(l10n.text('Reset statistics')),
            );
          }
          return Card(
            child: ListTile(
              title: Text(l10n.text(values[index].$1)),
              trailing: Text(values[index].$2),
            ),
          );
        },
      ),
    );
  }

  Future<void> _reset(BuildContext context) async {
    final controller = AppScope.of(context);
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.text('Reset statistics?')),
        content: Text(
          l10n.text(
            controller.hasGame
                ? 'Historical statistics will be cleared. The active game remains counted as the current session so future win-rate data stays valid.'
                : 'All locally stored statistics will be cleared. This cannot be undone.',
          ),
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
      await controller.resetStats();
    }
  }
}
