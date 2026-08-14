import 'package:flutter/material.dart';

import '../../app/state/app_scope.dart';
import '../../domain/game_types.dart';
import '../../shared/nova_scaffold.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const modes = [
      (GameMode.classic, 'Classic 4×4', 'The familiar 2048 experience.'),
      (GameMode.quick, 'Quick 3×3', 'Compact and fast.'),
      (GameMode.extended, 'Extended 5×5', 'More room for long strategies.'),
      (GameMode.challenge, 'Challenge 6×6', 'A larger 4096 objective.'),
      (GameMode.endless, 'Endless', 'Continue beyond 2048.'),
      (GameMode.target, 'Target 4096', 'Aim for a higher milestone.'),
      (GameMode.timeChallenge, 'Time Challenge', 'Three-minute challenge rules.'),
      (GameMode.moveLimit, 'Move Limit', 'Reach the target within 250 moves.'),
      (GameMode.daily, 'Daily Challenge', 'Deterministic date-based seed.'),
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
              onTap: () async {
                await AppScope.of(context).newGame(GameConfig.preset(mode.$1));
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/game');
                }
              },
            ),
          );
        },
      ),
    );
  }
}
