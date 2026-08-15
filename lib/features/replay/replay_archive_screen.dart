import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/state/app_scope.dart';
import '../../core/localization/nova_localizations.dart';
import '../../domain/game_state.dart';
import '../../domain/replay_archive.dart';
import '../../shared/nova_scaffold.dart';
import '../../shared/text_clipboard.dart';
import '../game/game_board.dart';

class ReplayArchiveScreen extends StatefulWidget {
  const ReplayArchiveScreen({
    this.clipboard = const SystemTextClipboard(),
    super.key,
  });

  final TextClipboard clipboard;

  @override
  State<ReplayArchiveScreen> createState() => _ReplayArchiveScreenState();
}

class _ReplayArchiveScreenState extends State<ReplayArchiveScreen> {
  static const _speeds = <Duration>[
    Duration(milliseconds: 1000),
    Duration(milliseconds: 500),
    Duration(milliseconds: 250),
  ];

  Timer? _timer;
  List<GameState> _frames = const [];
  ReplayCapture? _loadedCapture;
  bool _showingImported = false;
  bool _initialized = false;
  int _index = 0;
  bool _running = false;
  Duration _interval = _speeds[1];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _loadCurrentCapture();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _loadCurrentCapture() {
    final capture = AppScope.of(context).replayCapture;
    _stopPlayback();
    setState(() {
      _showingImported = false;
      _loadedCapture = capture;
      _frames = _framesFor(capture);
      _index = 0;
    });
  }

  List<GameState> _framesFor(ReplayCapture? capture) {
    if (capture == null || !capture.isFullSessionExportable) return const [];
    try {
      return ReplayArchivePlayer.build(capture);
    } on Object {
      return const [];
    }
  }

  Future<void> _copyCurrentArchive() async {
    final capture = AppScope.of(context).replayCapture;
    if (capture == null || !capture.isFullSessionExportable) return;
    final text = ReplayArchive.encode(capture);
    await widget.clipboard.writeText(text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.l10n.text('Full-session replay copied to clipboard.'),
        ),
      ),
    );
  }

  Future<void> _importFromClipboard() async {
    final raw = await widget.clipboard.readText();
    if (!mounted) return;
    if (raw == null || raw.trim().isEmpty) {
      _showMessage(
        context.l10n.text('Clipboard does not contain a replay archive.'),
      );
      return;
    }
    _openArchive(raw);
  }

  Future<void> _enterArchiveManually() async {
    final controller = TextEditingController();
    final raw = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.text('Open replay archive text')),
        content: SizedBox(
          width: 620,
          child: TextField(
            controller: controller,
            minLines: 8,
            maxLines: 14,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              hintText: context.l10n.text(
                'Paste a 2048 Nova full-session replay JSON archive.',
              ),
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.l10n.text('Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: Text(context.l10n.text('Open Replay')),
          ),
        ],
      ),
    );
    controller.dispose();
    if (!mounted || raw == null) return;
    _openArchive(raw);
  }

  void _openArchive(String raw) {
    try {
      final capture = ReplayArchive.decode(raw);
      final frames = ReplayArchivePlayer.build(capture);
      _stopPlayback();
      setState(() {
        _loadedCapture = capture;
        _frames = frames;
        _index = 0;
        _showingImported = true;
      });
      _showMessage(
        context.l10n.text(
          'Replay archive opened in spectator mode. Your current game was not changed.',
        ),
      );
    } on FormatException catch (error) {
      _showMessage(
        context.l10n.isHindi
            ? 'रिप्ले अस्वीकार किया गया: ${context.l10n.text(error.message.toString())}'
            : 'Replay rejected: ${error.message}',
      );
    } on Object {
      _showMessage(context.l10n.text('Replay archive was rejected as invalid.'));
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _togglePlayback() {
    if (_frames.length < 2) return;
    if (_running) {
      _stopPlayback();
      setState(() {});
      return;
    }
    if (_index >= _frames.length - 1) _index = 0;
    _running = true;
    _timer = Timer.periodic(_interval, (_) => _advance());
    setState(() {});
  }

  void _advance() {
    if (!mounted || _frames.isEmpty || _index >= _frames.length - 1) {
      _stopPlayback();
      if (mounted) setState(() {});
      return;
    }
    setState(() {
      _index += 1;
      if (_index >= _frames.length - 1) _stopPlayback();
    });
  }

  void _moveTo(int index) {
    if (_frames.isEmpty) return;
    _stopPlayback();
    setState(() => _index = index.clamp(0, _frames.length - 1).toInt());
  }

  void _changeSpeed(Duration? value) {
    if (value == null || value == _interval) return;
    final wasRunning = _running;
    _stopPlayback();
    _interval = value;
    if (wasRunning && _index < _frames.length - 1) {
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
    final l10n = context.l10n;
    final currentCapture = AppScope.of(context).replayCapture;
    final currentExportable =
        currentCapture != null && currentCapture.isFullSessionExportable;

    return NovaScaffold(
      title: l10n.text('Full Replay Archive'),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _InfoCard(capture: currentCapture),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: currentExportable ? _copyCurrentArchive : null,
                icon: const Icon(Icons.copy_all_rounded),
                label: Text(l10n.text('Copy full replay')),
              ),
              FilledButton.tonalIcon(
                onPressed: _importFromClipboard,
                icon: const Icon(Icons.content_paste_rounded),
                label: Text(l10n.text('Open from clipboard')),
              ),
              OutlinedButton.icon(
                onPressed: _enterArchiveManually,
                icon: const Icon(Icons.text_snippet_outlined),
                label: Text(l10n.text('Enter replay text')),
              ),
              if (_showingImported)
                OutlinedButton.icon(
                  onPressed: _loadCurrentCapture,
                  icon: const Icon(Icons.restore_rounded),
                  label: Text(l10n.text('Return to current replay')),
                ),
            ],
          ),
          const SizedBox(height: 18),
          if (_frames.isEmpty)
            _NoReplayCard(showingImported: _showingImported)
          else
            _ReplayViewer(
              frames: _frames,
              index: _index,
              running: _running,
              interval: _interval,
              imported: _showingImported,
              reducedMotion: AppScope.of(context).settings.reducedMotion,
              onTogglePlayback: _togglePlayback,
              onFirst: _index > 0 ? () => _moveTo(0) : null,
              onPrevious: _index > 0 ? () => _moveTo(_index - 1) : null,
              onNext: _index < _frames.length - 1
                  ? () => _moveTo(_index + 1)
                  : null,
              onLatest: _index < _frames.length - 1
                  ? () => _moveTo(_frames.length - 1)
                  : null,
              onSliderChanged: (value) => _moveTo(value.round()),
              onSpeedChanged: _changeSpeed,
            ),
          if (_loadedCapture != null) ...[
            const SizedBox(height: 12),
            Text(
              l10n.isHindi
                  ? 'रिकॉर्ड किए गए इवेंट: ${_loadedCapture!.events.length} / ${ReplayCapture.maxEvents}'
                  : 'Recorded events: ${_loadedCapture!.events.length} / ${ReplayCapture.maxEvents}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.capture});

  final ReplayCapture? capture;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = capture == null
        ? l10n.text('No full-session capture yet')
        : capture!.overflowed
            ? l10n.text('Replay capture reached its safety limit')
            : capture!.startsAtSessionStart
                ? l10n.text('Complete full-session capture available')
                : l10n.text('Current replay began after the session started');

    final description = capture == null
        ? l10n.text(
            'Start a new game to record a portable full-session spectator replay.',
          )
        : capture!.overflowed
            ? l10n.text(
                'This replay exceeded the 4,096-event safety limit, so export is disabled rather than silently producing an incomplete archive.',
              )
            : capture!.startsAtSessionStart
                ? l10n.text(
                    'The archive stores a validated starting state plus deterministic replay actions. Exported or imported replay data is spectator-only and cannot change player records.',
                  )
                : l10n.text(
                    'Legacy or restored progress does not contain the earlier actions needed for a true full-session archive. Start a new game to create a complete portable replay.',
                  );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 8),
            Text(
              l10n.text(
                'Opening an archive never replaces the live game, imports statistics, or creates trusted progress.',
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoReplayCard extends StatelessWidget {
  const _NoReplayCard({required this.showingImported});

  final bool showingImported;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            const Icon(Icons.movie_creation_outlined, size: 52),
            const SizedBox(height: 10),
            Text(
              context.l10n.text(
                showingImported
                    ? 'No imported replay frames are available.'
                    : 'A complete current full-session replay is not available.',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReplayViewer extends StatelessWidget {
  const _ReplayViewer({
    required this.frames,
    required this.index,
    required this.running,
    required this.interval,
    required this.imported,
    required this.reducedMotion,
    required this.onTogglePlayback,
    required this.onFirst,
    required this.onPrevious,
    required this.onNext,
    required this.onLatest,
    required this.onSliderChanged,
    required this.onSpeedChanged,
  });

  final List<GameState> frames;
  final int index;
  final bool running;
  final Duration interval;
  final bool imported;
  final bool reducedMotion;
  final VoidCallback onTogglePlayback;
  final VoidCallback? onFirst;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onLatest;
  final ValueChanged<double> onSliderChanged;
  final ValueChanged<Duration?> onSpeedChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final frame = frames[index];
    final width = MediaQuery.sizeOf(context).width;
    final boardExtent = width.clamp(280.0, 520.0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Text(
              l10n.text(
                imported
                    ? 'Imported spectator replay — live player state is untouched.'
                    : 'Current full-session spectator replay',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            Chip(label: Text('${l10n.text('Frame')}: ${index + 1} / ${frames.length}')),
            Chip(label: Text('${l10n.text('Move')}: ${frame.moves}')),
            Chip(label: Text('${l10n.text('Score')}: ${frame.score}')),
            Chip(label: Text('${l10n.text('Highest')}: ${frame.highestTile}')),
          ],
        ),
        const SizedBox(height: 12),
        Align(
          child: SizedBox.square(
            dimension: boardExtent,
            child: GameBoard(
              board: frame.board,
              reducedMotion: reducedMotion,
            ),
          ),
        ),
        if (frames.length > 1) ...[
          const SizedBox(height: 12),
          Semantics(
            label: l10n.isHindi
                ? 'पूर्ण रिप्ले फ्रेम ${index + 1}, कुल ${frames.length}'
                : 'Full replay frame ${index + 1} of ${frames.length}',
            child: Slider(
              value: index.toDouble(),
              min: 0,
              max: (frames.length - 1).toDouble(),
              divisions: frames.length - 1,
              label: '${l10n.text('Move')} ${frame.moves}',
              onChanged: onSliderChanged,
            ),
          ),
        ],
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
              icon: Icon(running ? Icons.pause_rounded : Icons.play_arrow_rounded),
              label: Text(l10n.text(running ? 'Pause Replay' : 'Play Replay')),
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
                for (final speed in _ReplayArchiveScreenState._speeds)
                  DropdownMenuItem(
                    value: speed,
                    child: Text(_speedLabel(speed, l10n)),
                  ),
              ],
            ),
          ],
        ),
      ],
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
