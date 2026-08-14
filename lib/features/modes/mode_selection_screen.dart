import 'package:flutter/material.dart';

import '../../app/state/app_scope.dart';
import '../../domain/game_types.dart';
import '../../shared/nova_scaffold.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  static const _targetOptions = [
    128,
    256,
    512,
    1024,
    2048,
    4096,
    8192,
    16384,
  ];

  @override
  Widget build(BuildContext context) {
    const modes = [
      (GameMode.classic, 'Classic 4×4', 'The familiar 2048 experience.'),
      (GameMode.quick, 'Quick 3×3', 'Compact and fast.'),
      (GameMode.extended, 'Extended 5×5', 'More room for long strategies.'),
      (GameMode.challenge, 'Challenge 6×6', 'A larger 4096 objective.'),
      (GameMode.endless, 'Endless', 'Continue beyond 2048.'),
      (GameMode.target, 'Target', 'Choose the tile you want to reach.'),
      (
        GameMode.timeChallenge,
        'Time Challenge',
        'Reach the target within three minutes.',
      ),
      (
        GameMode.moveLimit,
        'Move Limit',
        'Reach the target within 250 valid moves.',
      ),
      (
        GameMode.daily,
        'Daily Challenge',
        'A deterministic date-based challenge.',
      ),
      (GameMode.zen, 'Zen', 'Low-pressure endless play.'),
    ];
    return NovaScaffold(
      title: 'Choose a Mode',
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: modes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final mode = modes[index];
          return Card(
            child: ListTile(
              title: Text(mode.$2),
              subtitle: Text(mode.$3),
              trailing: const Icon(Icons.arrow_forward_rounded),
              onTap: () => _startMode(context, mode.$1),
            ),
          );
        },
      ),
    );
  }

  Future<void> _startMode(BuildContext context, GameMode mode) async {
    int? target;
    if (mode == GameMode.target) {
      target = await showDialog<int>(
        context: context,
        builder: (dialogContext) => SimpleDialog(
          title: const Text('Choose target tile'),
          children: [
            for (final value in _targetOptions)
              SimpleDialogOption(
                onPressed: () => Navigator.pop(dialogContext, value),
                child: Text('$value'),
              ),
          ],
        ),
      );
      if (target == null || !context.mounted) return;
    }

    await AppScope.of(context).newGame(
      GameConfig.preset(mode, target: target),
    );
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/game');
    }
  }
}
