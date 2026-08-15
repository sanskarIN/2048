import 'package:flutter/material.dart';

import '../../app/state/app_controller.dart';
import '../../app/state/app_scope.dart';
import '../../core/localization/nova_localizations.dart';
import '../../domain/game_types.dart';
import '../../shared/nova_scaffold.dart';

/// Presents aggregate player statistics plus trusted local per-mode records.
///
/// This screen is intentionally read-only with respect to record ranking. The
/// [AppController] owns the trust policy and excludes imported unranked backup
/// progress before [ModeRecord] values reach this presentation layer.
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stats = AppScope.of(context).stats;
    final averageMoves = stats.gamesPlayed == 0
        ? 0.0
        : stats.totalMoves / stats.gamesPlayed;
    final averageMerges = stats.gamesPlayed == 0
        ? 0.0
        : stats.totalMerges / stats.gamesPlayed;
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
    final modeRecords = [
      for (final mode in GameMode.values)
        if (stats.existingRecordFor(mode)?.hasProgress ?? false)
          (mode, stats.existingRecordFor(mode)!),
    ];

    return NovaScaffold(
      title: l10n.text('Statistics'),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: values.length + modeRecords.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index < values.length) {
            return Card(
              child: ListTile(
                title: Text(l10n.text(values[index].$1)),
                trailing: Text(values[index].$2),
              ),
            );
          }

          final modeIndex = index - values.length;
          if (modeIndex < modeRecords.length) {
            final entry = modeRecords[modeIndex];
            return _ModeRecordCard(mode: entry.$1, record: entry.$2);
          }

          return OutlinedButton.icon(
            onPressed: () => _reset(context),
            icon: const Icon(Icons.delete_outline_rounded),
            label: Text(l10n.text('Reset statistics')),
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

/// Localized presentation for one already-sanitized mode record.
///
/// Configuration metadata belongs to the saved best score and is deliberately
/// shown as one subtitle so board size and target remain a single record context.
class _ModeRecordCard extends StatelessWidget {
  const _ModeRecordCard({required this.mode, required this.record});

  final GameMode mode;
  final ModeRecord record;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final metadata = <String>[
      if (record.bestScoreBoardSize != null)
        l10n.boardSize(record.bestScoreBoardSize!),
      if (record.bestScoreTarget != null)
        l10n.targetTile(record.bestScoreTarget!),
    ];

    return Card(
      child: ExpansionTile(
        title: Text(l10n.modeName(mode)),
        subtitle: metadata.isEmpty ? null : Text(metadata.join(' • ')),
        children: [
          ListTile(
            dense: true,
            title: Text(l10n.text('Best score')),
            trailing: Text('${record.bestScore}'),
          ),
          ListTile(
            dense: true,
            title: Text(l10n.text('Highest tile')),
            trailing: Text('${record.highestTile}'),
          ),
        ],
      ),
    );
  }
}
