import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/state/app_scope.dart';
import '../../domain/game_types.dart';
import '../../shared/nova_scaffold.dart';
import 'game_board.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _dialogVisible = false;
  Timer? _challengeTimer;

  @override
  void initState() {
    super.initState();
    _challengeTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      AppScope.of(context).refreshChallengeStatus();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _challengeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final game = controller.game;
    if (game == null) {
      return NovaScaffold(
        title: 'Game',
        body: Center(
          child: FilledButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/modes'),
            child: const Text('Start a game'),
          ),
        ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_dialogVisible) return;
      if (game.status == GameStatus.won && !game.hasAcknowledgedWin) {
        _dialogVisible = true;
        _showWinDialog().whenComplete(() => _dialogVisible = false);
      } else if (game.status == GameStatus.lost) {
        _dialogVisible = true;
        _showLossDialog().whenComplete(() => _dialogVisible = false);
      }
    });

    return NovaScaffold(
      title: _label(game.config.mode),
      actions: [
        IconButton(
          tooltip: 'Hint',
          onPressed: () {
            final hint = controller.hint();
            final message = hint == null
                ? 'No valid move found.'
                : 'Try ${hint.name.toUpperCase()}.';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          },
          icon: const Icon(Icons.lightbulb_outline_rounded),
        ),
        IconButton(
          tooltip: 'Undo',
          onPressed: controller.canUndo ? controller.undo : null,
          icon: const Icon(Icons.undo_rounded),
        ),
        IconButton(
          tooltip: 'New game',
          onPressed: _restart,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
      body: Focus(
        autofocus: true,
        onKeyEvent: (_, event) {
          if (event is! KeyDownEvent) return KeyEventResult.ignored;
          final direction = switch (event.logicalKey) {
            LogicalKeyboardKey.arrowUp || LogicalKeyboardKey.keyW => Direction.up,
            LogicalKeyboardKey.arrowDown || LogicalKeyboardKey.keyS => Direction.down,
            LogicalKeyboardKey.arrowLeft || LogicalKeyboardKey.keyA => Direction.left,
            LogicalKeyboardKey.arrowRight || LogicalKeyboardKey.keyD => Direction.right,
            _ => null,
          };
          if (direction == null) return KeyEventResult.ignored;
          controller.move(direction);
          return KeyEventResult.handled;
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanEnd: (details) {
            final velocity = details.velocity.pixelsPerSecond;
            if (velocity.distance < 150) return;
            final direction = velocity.dx.abs() > velocity.dy.abs()
                ? (velocity.dx > 0 ? Direction.right : Direction.left)
                : (velocity.dy > 0 ? Direction.down : Direction.up);
            controller.move(direction);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _Metric('Score', game.score),
                    _Metric('Best', game.bestScore),
                    _Metric('Moves', game.moves),
                    _Metric('Highest', game.highestTile),
                    if (game.config.moveLimit case final limit?)
                      _Metric(
                        'Moves left',
                        (limit - game.moves).clamp(0, limit).toInt(),
                      ),
                    if (game.config.timeLimitSeconds case final limit?)
                      _Metric(
                        'Seconds left',
                        _secondsLeft(game.startedAt, limit),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: GameBoard(
                        board: game.board,
                        reducedMotion: controller.settings.reducedMotion,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Swipe, Arrow Keys, or W/A/S/D',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _secondsLeft(DateTime startedAt, int limit) {
    final elapsed = DateTime.now().difference(startedAt).inSeconds;
    return (limit - elapsed).clamp(0, limit).toInt();
  }

  Future<void> _restart() async {
    final controller = AppScope.of(context);
    final config = controller.game!.config;
    if (controller.settings.confirmRestart) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Start over?'),
          content: const Text('Your current board will be replaced.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Restart'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }
    await controller.newGame(config);
  }

  Future<void> _showWinDialog() async {
    final controller = AppScope.of(context);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Target reached!'),
        content: Text(
          'You reached ${controller.game?.highestTile}. Continue your Nova run?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/modes');
            },
            child: const Text('New game'),
          ),
          FilledButton(
            onPressed: () async {
              await controller.continueAfterWin();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Future<void> _showLossDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game over'),
        content: Text('Score: ${AppScope.of(context).game?.score ?? 0}'),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.popUntil(context, ModalRoute.withName('/')),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _restart();
            },
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }

  String _label(GameMode mode) => switch (mode) {
        GameMode.classic => 'Classic 4×4',
        GameMode.quick => 'Quick 3×3',
        GameMode.extended => 'Extended 5×5',
        GameMode.challenge => 'Challenge 6×6',
        GameMode.endless => 'Endless',
        GameMode.target => 'Target',
        GameMode.timeChallenge => 'Time Challenge',
        GameMode.moveLimit => 'Move Limit',
        GameMode.daily => 'Daily Challenge',
        GameMode.zen => 'Zen',
      };
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value);

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label $value',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelSmall),
              Text(
                '$value',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
