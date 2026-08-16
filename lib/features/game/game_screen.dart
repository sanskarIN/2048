import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/state/app_scope.dart';
import '../../core/localization/nova_localizations.dart';
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final timed = AppScope.of(context).game?.config.timeLimitSeconds != null;
    if (timed && _challengeTimer == null) {
      _challengeTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        unawaited(AppScope.of(context).refreshChallengeStatus());
        setState(() {});
      });
    } else if (!timed && _challengeTimer != null) {
      _challengeTimer?.cancel();
      _challengeTimer = null;
    }
  }

  @override
  void dispose() {
    _challengeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final l10n = context.l10n;
    final game = controller.game;
    if (game == null) {
      return NovaScaffold(
        title: l10n.text('Game'),
        body: Center(
          child: FilledButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/modes'),
            child: Text(l10n.text('Start a game')),
          ),
        ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _dialogVisible) return;
      if (game.status == GameStatus.won && !game.hasAcknowledgedWin) {
        _dialogVisible = true;
        _showWinDialog().whenComplete(() => _dialogVisible = false);
      } else if (game.status == GameStatus.lost) {
        _dialogVisible = true;
        _showLossDialog().whenComplete(() => _dialogVisible = false);
      }
    });

    return NovaScaffold(
      title: l10n.text(_label(game.config.mode)),
      actions: [
        IconButton(
          tooltip: l10n.text('Hint'),
          onPressed: _showHint,
          icon: const Icon(Icons.lightbulb_outline_rounded),
        ),
        IconButton(
          tooltip: l10n.text('Undo'),
          onPressed: controller.canUndo ? controller.undo : null,
          icon: const Icon(Icons.undo_rounded),
        ),
        IconButton(
          tooltip: l10n.text('Pause'),
          onPressed: _showPauseMenu,
          icon: const Icon(Icons.pause_rounded),
        ),
        IconButton(
          tooltip: l10n.text('New game'),
          onPressed: _restart,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
      body: Focus(
        autofocus: true,
        onKeyEvent: (_, event) => _handleKeyEvent(event),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanEnd: (details) {
            final velocity = details.velocity.pixelsPerSecond;
            if (velocity.distance < 150) return;
            final direction = velocity.dx.abs() > velocity.dy.abs()
                ? (velocity.dx > 0 ? Direction.right : Direction.left)
                : (velocity.dy > 0 ? Direction.down : Direction.up);
            unawaited(_performMove(direction));
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
                    _Metric(l10n.text('Score'), game.score),
                    _Metric(l10n.text('Best'), game.bestScore),
                    _Metric(l10n.text('Moves'), game.moves),
                    _Metric(l10n.text('Highest'), game.highestTile),
                    if (game.config.moveLimit case final limit?)
                      _Metric(
                        l10n.text('Moves left'),
                        (limit - game.moves).clamp(0, limit).toInt(),
                      ),
                    if (game.config.timeLimitSeconds case final limit?)
                      _Metric(
                        l10n.text('Seconds left'),
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
                Text(
                  l10n.text(
                    'Move: Swipe / Arrows / W A S D  •  H Hint  •  U Undo  •  P or Esc Pause  •  R Restart',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  KeyEventResult _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent || _dialogVisible) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    final direction = _directionForKey(key);
    if (direction != null) {
      unawaited(_performMove(direction));
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.keyH) {
      _showHint();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.keyU) {
      final controller = AppScope.of(context);
      if (controller.canUndo) unawaited(controller.undo());
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.keyP || key == LogicalKeyboardKey.escape) {
      unawaited(_showPauseMenu());
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.keyR) {
      unawaited(_restart());
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Direction? _directionForKey(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.arrowUp || key == LogicalKeyboardKey.keyW) {
      return Direction.up;
    }
    if (key == LogicalKeyboardKey.arrowDown || key == LogicalKeyboardKey.keyS) {
      return Direction.down;
    }
    if (key == LogicalKeyboardKey.arrowLeft || key == LogicalKeyboardKey.keyA) {
      return Direction.left;
    }
    if (key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.keyD) {
      return Direction.right;
    }
    return null;
  }

  void _showHint() {
    if (_dialogVisible) return;
    final hint = AppScope.of(context).hint();
    final l10n = context.l10n;
    final message = hint == null
        ? l10n.text('No valid move found.')
        : l10n.isHindi
        ? '${l10n.directionName(hint)} की ओर प्रयास करें।'
        : 'Try ${l10n.directionName(hint).toUpperCase()}.';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _performMove(Direction direction) async {
    if (!mounted || _dialogVisible) return;
    final controller = AppScope.of(context);
    final outcome = await controller.move(direction);
    if (!mounted || outcome == null || !outcome.changed) return;

    if (controller.settings.hapticsEnabled) {
      if (outcome.merges > 0) {
        await HapticFeedback.mediumImpact();
      } else {
        await HapticFeedback.selectionClick();
      }
    }
    if (controller.settings.soundEnabled) {
      await SystemSound.play(SystemSoundType.click);
    }
  }

  int _secondsLeft(DateTime startedAt, int limit) {
    final elapsed = DateTime.now().difference(startedAt).inSeconds;
    return (limit - elapsed).clamp(0, limit).toInt();
  }

  Future<void> _showPauseMenu() async {
    if (_dialogVisible) return;
    _dialogVisible = true;
    final l10n = context.l10n;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.text('Paused')),
        content: Text(l10n.text('Your current game is saved locally.')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.text('Resume')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pushNamed(context, '/settings');
            },
            child: Text(l10n.text('Settings')),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              );
            },
            child: Text(l10n.text('Home')),
          ),
        ],
      ),
    );
    _dialogVisible = false;
  }

  Future<void> _restart() async {
    final controller = AppScope.of(context);
    final l10n = context.l10n;
    final config = controller.game!.config;
    if (controller.settings.confirmRestart) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.text('Start over?')),
          content: Text(l10n.text('Your current board will be replaced.')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.text('Cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.text('Restart')),
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
    final l10n = context.l10n;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text(l10n.text('Target reached!')),
          content: Text(
            l10n.isHindi
                ? 'आप ${controller.game?.highestTile} तक पहुँच गए। अपना नोवा रन जारी रखें?'
                : 'You reached ${controller.game?.highestTile}. Continue your Nova run?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pushReplacementNamed(context, '/modes');
              },
              child: Text(l10n.text('New game')),
            ),
            FilledButton(
              onPressed: () async {
                await controller.continueAfterWin();
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: Text(l10n.text('Continue')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLossDialog() async {
    final l10n = context.l10n;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text(l10n.text('Game over')),
          content: Text(l10n.score(AppScope.of(context).game?.score ?? 0)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (route) => false,
                );
              },
              child: Text(l10n.text('Home')),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                unawaited(_restart());
              },
              child: Text(l10n.text('Restart')),
            ),
          ],
        ),
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
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
