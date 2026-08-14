import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/state/app_scope.dart';
import '../../domain/autoplay_session.dart';
import '../../domain/game_types.dart';
import '../../shared/nova_scaffold.dart';
import '../game/game_board.dart';

class SolverDemoScreen extends StatefulWidget {
  const SolverDemoScreen({super.key});

  @override
  State<SolverDemoScreen> createState() => _SolverDemoScreenState();
}

class _SolverDemoScreenState extends State<SolverDemoScreen> {
  static const _speeds = <Duration>[
    Duration(milliseconds: 1000),
    Duration(milliseconds: 500),
    Duration(milliseconds: 250),
  ];

  late AutoplaySession _session;
  Timer? _timer;
  Duration _interval = _speeds[1];
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _session = AutoplaySession();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleRunning() {
    if (_running) {
      _stopTimer();
      setState(() {});
      return;
    }
    if (_session.isComplete) return;

    _running = true;
    _timer = Timer.periodic(_interval, (_) => _performStep());
    setState(() {});
  }

  void _performStep() {
    if (!mounted || _session.isComplete) {
      _stopTimer();
      if (mounted) setState(() {});
      return;
    }

    final changed = _session.step();
    if (!changed || _session.isComplete) {
      _stopTimer();
    }
    setState(() {});
  }

  void _reset() {
    _stopTimer();
    _session.reset();
    setState(() {});
  }

  void _changeSpeed(Duration? value) {
    if (value == null || value == _interval) return;
    final wasRunning = _running;
    _stopTimer();
    _interval = value;
    if (wasRunning && !_session.isComplete) {
      _running = true;
      _timer = Timer.periodic(_interval, (_) => _performStep());
    }
    setState(() {});
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    _running = false;
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final game = _session.state;
    final direction = _session.lastDirection;
    final width = MediaQuery.sizeOf(context).width;
    final boardExtent = width.clamp(280.0, 520.0).toDouble();

    return NovaScaffold(
      title: 'Solver Demo',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Deterministic heuristic autoplay',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'This local demonstration uses the same read-only '
                          'heuristic as Hint. It runs in an isolated sandbox '
                          'and never changes your saved game, lifetime '
                          'statistics, achievements, or Daily Challenge history.',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _Metric(label: 'Score', value: '${game.score}'),
                    _Metric(label: 'Moves', value: '${game.moves}'),
                    _Metric(label: 'Highest', value: '${game.highestTile}'),
                    _Metric(
                      label: 'Last move',
                      value:
                          direction == null ? '—' : _directionName(direction),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Align(
                  child: SizedBox.square(
                    dimension: boardExtent,
                    child: GameBoard(
                      board: game.board,
                      reducedMotion: app.settings.reducedMotion,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Semantics(
                  container: true,
                  label: _session.isComplete
                      ? 'Solver demo complete'
                      : _running
                          ? 'Solver demo running'
                          : 'Solver demo paused',
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.center,
                    children: [
                      FilledButton.icon(
                        onPressed: _session.isComplete ? null : _toggleRunning,
                        icon: Icon(
                          _running
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                        ),
                        label: Text(_running ? 'Pause' : 'Autoplay'),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: _running || _session.isComplete
                            ? null
                            : _performStep,
                        icon: const Icon(Icons.skip_next_rounded),
                        label: const Text('Step'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _reset,
                        icon: const Icon(Icons.restart_alt_rounded),
                        label: const Text('Reset seed'),
                      ),
                      DropdownButton<Duration>(
                        value: _interval,
                        onChanged: _changeSpeed,
                        items: [
                          for (final speed in _speeds)
                            DropdownMenuItem(
                              value: speed,
                              child: Text(_speedLabel(speed)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  _session.isComplete
                      ? 'The sandbox has no legal move remaining. Reset the '
                          'seed to replay the same deterministic demonstration.'
                      : 'Seed: ${_session.seed} · Endless 4×4 sandbox · '
                          'recommendations do not consume the game RNG.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _directionName(Direction direction) {
    final value = direction.name;
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }

  static String _speedLabel(Duration duration) {
    if (duration.inMilliseconds == 1000) return '1 move / sec';
    return '${1000 ~/ duration.inMilliseconds} moves / sec';
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label $value',
      child: Chip(
        avatar: const Icon(Icons.auto_awesome_rounded, size: 18),
        label: Text('$label: $value'),
      ),
    );
  }
}
