import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/state/app_scope.dart';
import '../../core/localization/nova_localizations.dart';
import '../../data/local_store.dart';
import '../../domain/game_state.dart';
import '../../domain/replay_timeline.dart';
import '../../shared/nova_scaffold.dart';
import '../game/game_board.dart';

class ReplayScreen extends StatefulWidget {
  const ReplayScreen({super.key});

  @override
  State<ReplayScreen> createState() => _ReplayScreenState();
}

class _ReplayScreenState extends State<ReplayScreen> {
  static const _speeds = <Duration>[
    Duration(milliseconds: 1000),
    Duration(milliseconds: 500),
    Duration(milliseconds: 250),
  ];

  List<GameState>? _frames;
  Object? _loadError;
  Timer? _timer;
  Duration _interval = _speeds[1];
  int _index = 0;
  bool _running = false;
  bool _loadStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadStarted) return;
    _loadStarted = true;
    unawaited(_loadReplay());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadReplay() async {
    final current = AppScope.of(context).game?.copy();
    if (current == null) {
      if (!mounted) return;
      setState(() => _frames = const []);
      return;
    }

    try {
      final history = await LocalStore().loadUndoHistory();
      final frames = ReplayTimeline.build(current: current, history: history);
      if (!mounted) return;
      setState(() {
        _frames = frames;
        _index = 0;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _loadError = error);
    }
  }

  void _togglePlayback() {
    final frames = _frames;
    if (frames == null || frames.length < 2) return;
    if (_running) {
      _stopPlayback();
      setState(() {});
      return;
    }
    if (_index >= frames.length - 1) {
      _index = 0;
    }
    _running = true;
    _timer = Timer.periodic(_interval, (_) => _advance());
    setState(() {});
  }

  void _advance() {
    final frames = _frames;
    if (!mounted || frames == null || frames.isEmpty) {
      _stopPlayback();
      return;
    }
    if (_index >= frames.length - 1) {
      _stopPlayback();
      if (mounted) setState(() {});
      return;
    }
    setState(() {
      _index += 1;
      if (_index >= frames.length - 1) {
        _stopPlayback();
      }
    });
  }

  void _moveTo(int index) {
    final frames = _frames;
    if (frames == null || frames.isEmpty) return;
    _stopPlayback();
    setState(() => _index = index.clamp(0, frames.length - 1).toInt());
  }

  void _changeSpeed(Duration? value) {
    if (value == null || value == _interval) return;
    final wasRunning = _running;
    _stopPlayback();
    _interval = value;
    if (wasRunning && _frames != null && _index < _frames!.length - 1) {
      _running = true;
      _timer = Timer.periodic(_interval, (_) => _advance());
    }
    setState(() {});
  }

  void _stopPlayback() {
    _timer?.cancel();
    _timer = null;
    _running = false;
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final frames = _frames;

    return NovaScaffold(
      title: context.l10n.text('Move Replay'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loadError != null
            ? _ErrorState(onRetry: _retry)
            : frames == null
                ? const Center(child: CircularProgressIndicator())
                : frames.isEmpty
                    ? _EmptyState(
                        onStart: () => Navigator.pushNamed(context, '/modes'),
                      )
                    : _ReplayBody(
                        frames: frames,
                        index: _index,
                        running: _running,
                        interval: _interval,
                        reducedMotion: controller.settings.reducedMotion,
                        onTogglePlayback: _togglePlayback,
                        onPrevious:
                            _index > 0 ? () => _moveTo(_index - 1) : null,
                        onNext: _index < frames.length - 1
                            ? () => _moveTo(_index + 1)
                            : null,
                        onFirst: _index > 0 ? () => _moveTo(0) : null,
                        onLatest: _index < frames.length - 1
                            ? () => _moveTo(frames.length - 1)
                            : null,
                        onSliderChanged: (value) => _moveTo(value.round()),
                        onSpeedChanged: _changeSpeed,
                      ),
      ),
    );
  }

  void _retry() {
    _stopPlayback();
    setState(() {
      _loadError = null;
      _frames = null;
    });
    unawaited(_loadReplay());
  }
}

class _ReplayBody extends StatelessWidget {
  const _ReplayBody({
    required this.frames,
    required this.index,
    required this.running,
    required this.interval,
    required this.reducedMotion,
    required this.onTogglePlayback,
    required this.onPrevious,
    required this.onNext,
    required this.onFirst,
    required this.onLatest,
    required this.onSliderChanged,
    required this.onSpeedChanged,
  });

  final List<GameState> frames;
  final int index;
  final bool running;
  final Duration interval;
  final bool reducedMotion;
  final VoidCallback onTogglePlayback;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onFirst;
  final VoidCallback? onLatest;
  final ValueChanged<double> onSliderChanged;
  final ValueChanged<Duration?> onSpeedChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final frame = frames[index];
    final width = MediaQuery.sizeOf(context).width;
    final boardExtent = width.clamp(280.0, 520.0).toDouble();
    final retainedStart = frames.first.moves;
    final replayDescription = retainedStart == 0
        ? l10n.text('Replay includes the retained start of this game.')
        : l10n.isHindi
            ? 'अनडू हिस्ट्री सीमित है, इसलिए यह रिप्ले चाल $retainedStart से शुरू होता है और सबसे हाल की सुरक्षित टाइमलाइन दिखाता है।'
            : 'Undo history is bounded, so this replay begins at move $retainedStart and shows the most recent retained timeline.';

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.text('Read-only spectator replay'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.text(
                          'Replay is built from the same persisted Undo snapshots used by the current game. Viewing, scrubbing, or playing the timeline never changes the live board, score, RNG, statistics, achievements, or Daily history.',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        replayDescription,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _Metric(l10n.text('Frame'), index + 1,
                      suffix: ' / ${frames.length}'),
                  _Metric(l10n.text('Move'), frame.moves),
                  _Metric(l10n.text('Score'), frame.score),
                  _Metric(l10n.text('Highest'), frame.highestTile),
                ],
              ),
              const SizedBox(height: 14),
              Align(
                child: SizedBox.square(
                  dimension: boardExtent,
                  child: GameBoard(
                    board: frame.board,
                    reducedMotion: reducedMotion,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (frames.length > 1)
                Semantics(
                  label: l10n.isHindi
                      ? 'रिप्ले फ्रेम ${index + 1}, कुल ${frames.length}'
                      : 'Replay frame ${index + 1} of ${frames.length}',
                  child: Slider(
                    value: index.toDouble(),
                    min: 0,
                    max: (frames.length - 1).toDouble(),
                    divisions: frames.length - 1,
                    label: l10n.isHindi
                        ? 'चाल ${frame.moves}'
                        : 'Move ${frame.moves}',
                    onChanged: onSliderChanged,
                  ),
                ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  IconButton(
                    tooltip: l10n.text('First retained frame'),
                    onPressed: onFirst,
                    icon: const Icon(Icons.first_page_rounded),
                  ),
                  IconButton(
                    tooltip: l10n.text('Previous frame'),
                    onPressed: onPrevious,
                    icon: const Icon(Icons.skip_previous_rounded),
                  ),
                  FilledButton.icon(
                    onPressed: frames.length > 1 ? onTogglePlayback : null,
                    icon: Icon(
                      running ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    ),
                    label: Text(
                      l10n.text(running ? 'Pause Replay' : 'Play Replay'),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.text('Next frame'),
                    onPressed: onNext,
                    icon: const Icon(Icons.skip_next_rounded),
                  ),
                  IconButton(
                    tooltip: l10n.text('Latest frame'),
                    onPressed: onLatest,
                    icon: const Icon(Icons.last_page_rounded),
                  ),
                  DropdownButton<Duration>(
                    value: interval,
                    onChanged: onSpeedChanged,
                    items: [
                      for (final speed in _ReplayScreenState._speeds)
                        DropdownMenuItem(
                          value: speed,
                          child: Text(_speedLabel(speed, l10n)),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                l10n.isHindi
                    ? 'फ्रेम स्थिति: ${l10n.text(frame.status.name)} · मर्ज: ${frame.totalMerges}'
                    : 'Frame status: ${frame.status.name} · Merges: ${frame.totalMerges}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _speedLabel(Duration duration, NovaLocalizations l10n) {
    final count =
        duration.inMilliseconds == 1000 ? 1 : 1000 ~/ duration.inMilliseconds;
    return l10n.isHindi
        ? '$count फ्रेम / सेकंड'
        : '$count frame${count == 1 ? '' : 's'} / sec';
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value, {this.suffix = ''});

  final String label;
  final int value;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('$label: $value$suffix'));
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.movie_filter_outlined, size: 56),
          const SizedBox(height: 12),
          Text(
            l10n.text('No game replay is available yet.'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onStart,
            child: Text(l10n.text('Start a game')),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 56),
          const SizedBox(height: 12),
          Text(l10n.text('Replay history could not be loaded safely.')),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: Text(l10n.text('Retry'))),
        ],
      ),
    );
  }
}
