import 'package:flutter/material.dart';

import '../../app/state/app_scope.dart';
import '../../core/localization/nova_localizations.dart';
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
    final l10n = context.l10n;

    return NovaScaffold(
      title: l10n.text('Game Backup'),
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
                    l10n.text('Portable current-game backup'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.text(
                      'Export copies one validated JSON backup to the clipboard. It contains the current game only — never settings, lifetime statistics, achievements, Daily history, or Undo history.',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.text(
                      'Imported backups are deliberately restored as unranked sessions. You can keep playing them, but they cannot change lifetime records, achievements, streaks, or Daily results.',
                    ),
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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Text(
                  l10n.text(
                    'No current game is available to export. You can still import a valid 2048 Nova game backup from the clipboard.',
                  ),
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
                label: Text(l10n.text('Copy game backup')),
              ),
              FilledButton.tonalIcon(
                onPressed: () => _importFromClipboard(context),
                icon: const Icon(Icons.content_paste_rounded),
                label: Text(l10n.text('Import from clipboard')),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.text('Import safety'),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.text(
                      '• Backup format and version must match 2048 Nova.')),
                  Text(l10n
                      .text('• Embedded game state is strictly validated.')),
                  Text(l10n.text('• Oversized or malformed text is rejected.')),
                  Text(l10n.text(
                      '• Import always requires an explicit confirmation.')),
                  Text(l10n.text(
                      '• The current game is replaced and Undo is cleared.')),
                  Text(l10n.text(
                      '• Imported sessions stay unranked after app restart.')),
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
      SnackBar(
        content: Text(
          context.l10n.text('Current game backup copied to clipboard.'),
        ),
      ),
    );
  }

  Future<void> _importFromClipboard(BuildContext context) async {
    final l10n = context.l10n;
    final raw = await clipboard.readText();
    if (!context.mounted) return;
    if (raw == null || raw.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.text('Clipboard does not contain a game backup.')),
        ),
      );
      return;
    }

    final GameState restored;
    try {
      restored = GameBackup.decode(raw);
    } on FormatException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.isHindi
                ? 'बैकअप अस्वीकार किया गया: ${l10n.text(error.message.toString())}'
                : 'Backup rejected: ${error.message}',
          ),
        ),
      );
      return;
    } on Object {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.text('Backup rejected as invalid.'))),
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
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Wrap(
          spacing: 14,
          runSpacing: 10,
          children: [
            _Fact(l10n.text('Mode'), l10n.modeName(state.config.mode)),
            _Fact(l10n.text('Board'),
                '${state.config.size}×${state.config.size}'),
            _Fact(l10n.text('Score'), '${state.score}'),
            _Fact(l10n.text('Moves'), '${state.moves}'),
            _Fact(l10n.text('Highest'), '${state.highestTile}'),
            _Fact(l10n.text('Status'), l10n.text(_statusLabel(state))),
            _Fact(
              l10n.text('Ranking'),
              l10n.text(unranked ? 'Unranked restored' : 'Local ranked'),
            ),
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
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.text('Restore unranked backup?')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                _Fact(l10n.text('Mode'), l10n.modeName(state.config.mode)),
                _Fact(l10n.text('Board'),
                    '${state.config.size}×${state.config.size}'),
                _Fact(l10n.text('Score'), '${state.score}'),
                _Fact(l10n.text('Moves'), '${state.moves}'),
                _Fact(l10n.text('Highest'), '${state.highestTile}'),
                _Fact(l10n.text('Status'), l10n.text(_statusLabel(state))),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.text(
                'This replaces the current game and clears its Undo history. The restored game is permanently marked unranked for this session, including after restart. Lifetime statistics, achievements, settings, and Daily history are not imported or modified by the restored session.',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.text('Cancel')),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.text('Restore unranked backup')),
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

String _statusLabel(GameState state) => switch (state.status) {
      GameStatus.playing => 'Playing',
      GameStatus.won => 'Won',
      GameStatus.lost => 'Lost',
    };
