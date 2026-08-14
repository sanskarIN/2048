import 'package:flutter/material.dart';

import '../../app/state/app_scope.dart';
import '../../domain/daily_record.dart';
import '../../domain/game_types.dart';
import '../../shared/game_replacement_guard.dart';
import '../../shared/nova_scaffold.dart';

class DailyChallengeScreen extends StatelessWidget {
  const DailyChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final config = GameConfig.preset(GameMode.daily);
    final seed = config.seed!;
    final record = controller.dailyRecordFor(seed);
    final currentIsToday = controller.game?.config.mode == GameMode.daily &&
        controller.game?.config.seed == seed &&
        controller.game?.status != GameStatus.lost;

    return NovaScaffold(
      title: 'Daily Challenge',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatSeed(seed),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Today’s challenge uses a deterministic UTC date seed and works fully offline.',
                  ),
                  const SizedBox(height: 16),
                  if (record != null) ...[
                    Text('Best saved score: ${record.score}'),
                    Text('Highest tile: ${record.highestTile}'),
                    Text('Moves: ${record.moves}'),
                    Text(
                      record.won
                          ? 'Status: Target reached'
                          : record.completed
                              ? 'Status: Completed'
                              : 'Status: In progress',
                    ),
                    const SizedBox(height: 16),
                  ],
                  FilledButton.icon(
                    onPressed: () => _openToday(
                      context,
                      currentIsToday: currentIsToday,
                      config: config,
                      record: record,
                    ),
                    icon: Icon(
                      currentIsToday
                          ? Icons.play_arrow_rounded
                          : record?.completed == true
                              ? Icons.replay_rounded
                              : record == null
                                  ? Icons.calendar_today_rounded
                                  : Icons.restart_alt_rounded,
                    ),
                    label: Text(
                      currentIsToday
                          ? 'Continue today’s challenge'
                          : record?.completed == true
                              ? 'Replay today’s challenge'
                              : record == null
                                  ? 'Start today’s challenge'
                                  : 'Restart today’s challenge',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Recent history',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          if (controller.dailyHistory.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('No daily challenge history yet.'),
              ),
            )
          else
            for (final item in controller.dailyHistory.take(14))
              Card(
                child: ListTile(
                  leading: Icon(
                    item.won
                        ? Icons.emoji_events_rounded
                        : item.completed
                            ? Icons.check_circle_outline_rounded
                            : Icons.timelapse_rounded,
                  ),
                  title: Text(_formatSeed(item.seed)),
                  subtitle: Text(
                    'Score ${item.score} • Highest ${item.highestTile} • ${item.moves} moves',
                  ),
                  trailing: Text(
                    item.won
                        ? 'Won'
                        : item.completed
                            ? 'Done'
                            : 'Open',
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Future<void> _openToday(
    BuildContext context, {
    required bool currentIsToday,
    required GameConfig config,
    required DailyRecord? record,
  }) async {
    if (currentIsToday) {
      Navigator.pushNamed(context, '/game');
      return;
    }

    if (!await confirmGameReplacement(context) || !context.mounted) return;

    if (record != null) {
      final isReplay = record.completed;
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: Text(
            isReplay
                ? 'Replay today’s challenge?'
                : 'Restart today’s challenge?',
          ),
          content: Text(
            isReplay
                ? 'A fresh run will use the same daily seed. Your completed history remains recorded.'
                : 'Your current Daily Challenge board is not available. Starting again will reset today’s in-progress run.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(isReplay ? 'Replay' : 'Restart'),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;
    }

    await AppScope.of(context).newGame(config);
    if (!context.mounted) return;
    Navigator.pushNamed(context, '/game');
  }

  String _formatSeed(int seed) {
    final text = seed.toString().padLeft(8, '0');
    return '${text.substring(6, 8)}/${text.substring(4, 6)}/${text.substring(0, 4)}';
  }
}
