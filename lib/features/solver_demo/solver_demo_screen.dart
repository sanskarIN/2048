import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/state/app_scope.dart';
import '../../core/localization/nova_localizations.dart';
import '../../domain/autoplay_session.dart';
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

  void _changeStrategy(AutoplayStrategy? value) {
    if (value == null || value == _session.strategy) return;
    _stopTimer();
    _session.setStrategy(value);
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
    final l10n = context.l10n;
    final game = _session.state;
    final direction = _session.lastDirection;
    final width = MediaQuery.sizeOf(context).width;
    final boardExtent = width.clamp(280.0, 520.0).toDouble();

    return NovaScaffold(
      title: l10n.text('Auto Play Demo'),
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
                          l10n.text('Deterministic local solver demonstration'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.text(
                            'Choose the fast heuristic or a bounded expectimax search. Both run only inside this isolated deterministic sandbox, never change your saved game, statistics, achievements, or Daily history, and never consume the live game RNG. Normal Hint remains the fast heuristic and is not replaced by expectimax.',
                          ),
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
                    _Metric(
                      label: l10n.text('Demo score'),
                      value: '${game.score}',
                    ),
                    _Metric(
                      label: l10n.text('Demo moves'),
                      value: '${game.moves}',
                    ),
                    _Metric(
                      label: l10n.text('Highest'),
                      value: '${game.highestTile}',
                    ),
                    _Metric(
                      label: l10n.text('Last move'),
                      value: direction == null
                          ? '—'
                          : l10n.directionName(direction),
                    ),
                    _Metric(
                      label: l10n.text('Strategy'),
                      value: _strategyLabel(_session.strategy, l10n),
                    ),
                    _Metric(
                      label: l10n.text('Search nodes'),
                      value:
                          _session.strategy == AutoplayStrategy.expectimax &&
                              _session.lastDecisionNodes > 0
                          ? '${_session.lastDecisionNodes}'
                          : '—',
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
                  label: l10n.text(
                    _session.isComplete
                        ? 'Auto Play demo complete'
                        : _running
                        ? 'Auto Play demo running'
                        : 'Auto Play demo paused',
                  ),
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
                        label: Text(
                          l10n.text(_running ? 'Pause' : 'Auto Play'),
                        ),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: _running || _session.isComplete
                            ? null
                            : _performStep,
                        icon: const Icon(Icons.skip_next_rounded),
                        label: Text(l10n.text('Step')),
                      ),
                      OutlinedButton.icon(
                        onPressed: _reset,
                        icon: const Icon(Icons.restart_alt_rounded),
                        label: Text(l10n.text('Reset seed')),
                      ),
                      DropdownButton<AutoplayStrategy>(
                        value: _session.strategy,
                        onChanged: _changeStrategy,
                        items: [
                          for (final strategy in AutoplayStrategy.values)
                            DropdownMenuItem(
                              value: strategy,
                              child: Text(_strategyLabel(strategy, l10n)),
                            ),
                        ],
                      ),
                      DropdownButton<Duration>(
                        value: _interval,
                        onChanged: _changeSpeed,
                        items: [
                          for (final speed in _speeds)
                            DropdownMenuItem(
                              value: speed,
                              child: Text(_speedLabel(speed, l10n)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  _session.isComplete
                      ? l10n.text(
                          'The sandbox has no legal move remaining. Reset the seed to replay the same deterministic demonstration.',
                        )
                      : l10n.isHindi
                      ? 'सीड: ${_session.seed} · एंडलेस 4×4 सैंडबॉक्स · ${_strategyLabel(_session.strategy, l10n)} · रणनीति बदलने पर सैंडबॉक्स रुकता है लेकिन बोर्ड या RNG रीसेट नहीं होता।'
                      : 'Seed: ${_session.seed} · Endless 4×4 sandbox · ${_strategyLabel(_session.strategy, l10n)} · changing strategy pauses the sandbox without resetting its board or RNG.',
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

  static String _strategyLabel(
    AutoplayStrategy strategy,
    NovaLocalizations l10n,
  ) {
    return l10n.text(switch (strategy) {
      AutoplayStrategy.heuristic => 'Heuristic',
      AutoplayStrategy.expectimax => 'Expectimax',
    });
  }

  static String _speedLabel(Duration duration, NovaLocalizations l10n) {
    final count = duration.inMilliseconds == 1000
        ? 1
        : 1000 ~/ duration.inMilliseconds;
    return l10n.isHindi
        ? '$count चाल / सेकंड'
        : '$count move${count == 1 ? '' : 's'} / sec';
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
