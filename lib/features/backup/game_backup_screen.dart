import 'package:flutter/material.dart';

import '../../app/state/app_scope.dart';
import '../../domain/game_backup.dart';
import '../../domain/game_state.dart';
import '../../shared/nova_scaffold.dart';
import '../../shared/text_clipboard.dart';

class GameBackupScreen extends StatelessWidget {
  const GameBackupScreen({
    this.clipboard = const SystemTextClipboard(),
    super.key,
  });

  final TextClipboard clipboard;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final current = controller.game;

    return NovaScaffold(
      title: 'Game Backup',
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Portable current-game backup',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Export copies one validated JSON backup to the clipboard. '
                    'It contains the current game only — never settings, lifetime '
                    'statistics, achievements, Daily history, or Undo history.',
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Imported backups are deliberately restored as unranked '
                    'sessions. You can keep playing them, but they cannot change '
                    'lifetime records, achievements, streaks, or Daily results.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (current != null)
            _CurrentGameCard(
              state: current,
              unranked: controller.currentGameIsUnranked,
            )
          else
            const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Text(
                  'No current game is available to export. You can still import '
                  'a valid 2048 Nova game backup from the clipboard.',
                ),
              ),
            ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: current == null
                    ? null
                    : () => _exportCurrentGame(context, current),
                icon: const Icon(Icons.copy_rounded),
                label: const Text('Copy game backup'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => _importFromClipboard(context),
                icon: const Icon(Icons.content_paste_rounded),
                label: const Text('Import from clipboard'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Import safety',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 8),
                  Text('• Backup format and version must match 2048 Nova.'),
                  Text('• Embedded game state is strictly validated.'),
                  Text('• Oversized or malformed text is rejected.'),
                  Text('• Import always requires an explicit confirmation.'),
                  Text('• The current game is replaced and Undo is cleared.'),
                  Text('• Imported sessions stay unranked after app restart.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportCurrentGame(
    BuildContext context,
    GameState current,
  ) async {
    final text = GameBackup.encode(current);
    await clipboard.writeText(text);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Current game backup copied to clipboard.')),
    );
  }

  Future<void> _importFromClipboard(BuildContext context) async {
    final raw = await clipboard.readText();
    if (!context.mounted) return;
    if (raw == null || raw.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Clipboard does not contain a game backup.'),
        ),
      );
      return;
    }

    final GameState restored;
    try {
      restored = GameBackup.decode(raw);
    } on FormatException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Backup rejected: ${error.message}')),
      );
      return;
    } on Object {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup rejected as invalid.')),
      );
      return;
    }

    final approved = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => _ImportPreviewDialog(state: restored),
        ) ??
        false;
    if (!approved || !context.mounted) return;

    await AppScope.of(context).importGameBackup(restored);
    if (!context.mounted) return;
    Navigator.pushNamed(context, '/game');
  }
}

class _CurrentGameCard extends StatelessWidget {
  const _CurrentGameCard({required this.state, required this.unranked});

  final GameState state;
  final bool unranked;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Wrap(
          spacing: 14,
          runSpacing: 10,
          children: [
            _Fact('Mode', _modeLabel(state)),
            _Fact('Board', '${state.config.size}×${state.config.size}'),
            _Fact('Score', '${state.score}'),
            _Fact('Moves', '${state.moves}'),
            _Fact('Highest', '${state.highestTile}'),
            _Fact('Status', state.status.name),
            _Fact('Ranking', unranked ? 'Unranked restored' : 'Local ranked'),
          ],
        ),
      ),
    );
  }
}

class _ImportPreviewDialog extends StatelessWidget {
  const _ImportPreviewDialog({required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Restore unranked backup?'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                _Fact('Mode', _modeLabel(state)),
                _Fact('Board', '${state.config.size}×${state.config.size}'),
                _Fact('Score', '${state.score}'),
                _Fact('Moves', '${state.moves}'),
                _Fact('Highest', '${state.highestTile}'),
                _Fact('Status', state.status.name),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'This replaces the current game and clears its Undo history. '
              'The restored game is permanently marked unranked for this '
              'session, including after restart. Lifetime statistics, '
              'achievements, settings, and Daily history are not imported or '
              'modified by the restored session.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Restore unranked backup'),
        ),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('$label: $value'));
  }
}

String _modeLabel(GameState state) {
  final name = state.config.mode.name;
  return '${name[0].toUpperCase()}${name.substring(1)}';
}
