import 'package:flutter/material.dart';

import '../../app/state/app_scope.dart';
import '../../domain/challenge_code.dart';
import '../../domain/game_types.dart';
import '../../shared/game_replacement_guard.dart';
import '../../shared/nova_scaffold.dart';
import '../../shared/text_clipboard.dart';

class ChallengeCodeScreen extends StatefulWidget {
  const ChallengeCodeScreen({
    super.key,
    this.clipboard = const SystemTextClipboard(),
    this.seedFactory,
  });

  final TextClipboard clipboard;
  final int Function()? seedFactory;

  @override
  State<ChallengeCodeScreen> createState() => _ChallengeCodeScreenState();
}

class _ChallengeCodeScreenState extends State<ChallengeCodeScreen> {
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

  final TextEditingController _inputController = TextEditingController();
  GameMode _mode = GameMode.classic;
  int _target = 4096;
  String? _generatedCode;
  GameConfig? _preview;
  String? _validationMessage;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NovaScaffold(
      title: 'Challenge Codes',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _InfoCard(
            icon: Icons.hub_outlined,
            title: 'Same seed, same opening',
            body:
                'Challenge codes share only a validated game configuration and deterministic seed. They do not contain board progress, scores, statistics, achievements, Daily history, or Undo data.',
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Create a challenge',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<GameMode>(
                    initialValue: _mode,
                    decoration: const InputDecoration(
                      labelText: 'Game mode',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final mode in ChallengeCode.supportedModes)
                        DropdownMenuItem(
                          value: mode,
                          child: Text(_modeLabel(mode)),
                        ),
                    ],
                    onChanged: (mode) {
                      if (mode == null) return;
                      setState(() {
                        _mode = mode;
                        _generatedCode = null;
                      });
                    },
                  ),
                  if (_mode == GameMode.target) ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: _target,
                      decoration: const InputDecoration(
                        labelText: 'Target tile',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        for (final target in _targetOptions)
                          DropdownMenuItem(
                            value: target,
                            child: Text('$target'),
                          ),
                      ],
                      onChanged: (target) {
                        if (target == null) return;
                        setState(() {
                          _target = target;
                          _generatedCode = null;
                        });
                      },
                    ),
                  ],
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _generateCode,
                    icon: const Icon(Icons.casino_outlined),
                    label: const Text('Generate new seeded code'),
                  ),
                  if (_generatedCode != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SelectableText(
                        _generatedCode!,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _copyGeneratedCode,
                      icon: const Icon(Icons.copy_rounded),
                      label: const Text('Copy challenge code'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Open a challenge',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Paste a NOVA1 code or enter it manually. A checksum catches accidental corruption before any game is replaced.',
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _inputController,
                    minLines: 3,
                    maxLines: 6,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: const InputDecoration(
                      labelText: 'Challenge code',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) {
                      setState(() {
                        _preview = null;
                        _validationMessage = null;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _pasteCode,
                        icon: const Icon(Icons.content_paste_rounded),
                        label: const Text('Paste code'),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: _validateInput,
                        icon: const Icon(Icons.verified_outlined),
                        label: const Text('Validate code'),
                      ),
                    ],
                  ),
                  if (_validationMessage != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _validationMessage!,
                      style: TextStyle(
                        color: _preview == null
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                  if (_preview != null) ...[
                    const SizedBox(height: 12),
                    _ConfigPreview(config: _preview!),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _startChallenge,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Start this challenge'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const _InfoCard(
            icon: Icons.calendar_today_outlined,
            title: 'Daily Challenge stays separate',
            body:
                'Daily Challenge already uses the UTC date as its shared seed and keeps dedicated history. Challenge codes intentionally cannot encode Daily mode.',
          ),
          const SizedBox(height: 12),
          const _InfoCard(
            icon: Icons.shield_outlined,
            title: 'No account or cloud required',
            body:
                'Codes are plain offline text. The checksum is for typo/corruption detection, not identity or authentication. Starting a valid code creates a fresh local game and counts like any other new non-Daily game.',
          ),
        ],
      ),
    );
  }

  void _generateCode() {
    final preset = GameConfig.preset(
      _mode,
      target: _mode == GameMode.target ? _target : null,
    );
    final seed = _nextSeed();
    final config = ChallengeCode.withSeed(preset, seed);
    setState(() {
      _generatedCode = ChallengeCode.encode(config);
    });
  }

  Future<void> _copyGeneratedCode() async {
    final code = _generatedCode;
    if (code == null) return;
    await widget.clipboard.writeText(code);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Challenge code copied to clipboard.')),
    );
  }

  Future<void> _pasteCode() async {
    final text = await widget.clipboard.readText();
    if (!mounted) return;
    if (text == null || text.trim().isEmpty) {
      setState(() {
        _preview = null;
        _validationMessage = 'Clipboard does not contain a challenge code.';
      });
      return;
    }
    _inputController.text = text.trim();
    _validateInput();
  }

  void _validateInput() {
    try {
      final config = ChallengeCode.decode(_inputController.text);
      setState(() {
        _preview = config;
        _validationMessage = 'Valid challenge code.';
      });
    } on FormatException catch (error) {
      setState(() {
        _preview = null;
        _validationMessage = error.message;
      });
    }
  }

  Future<void> _startChallenge() async {
    final config = _preview;
    if (config == null) return;
    if (!await confirmGameReplacement(context) || !mounted) return;

    await AppScope.of(context).newGame(config);
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/game');
    }
  }

  int _nextSeed() {
    final factory = widget.seedFactory;
    if (factory != null) return factory();
    return DateTime.now().microsecondsSinceEpoch & 0x7fffffff;
  }

  static String _modeLabel(GameMode mode) => switch (mode) {
        GameMode.classic => 'Classic 4×4',
        GameMode.quick => 'Quick 3×3',
        GameMode.extended => 'Extended 5×5',
        GameMode.challenge => 'Challenge 6×6',
        GameMode.endless => 'Endless',
        GameMode.target => 'Target',
        GameMode.timeChallenge => 'Time Challenge',
        GameMode.moveLimit => 'Move Limit',
        GameMode.zen => 'Zen',
        GameMode.daily => 'Daily Challenge',
      };
}

class _ConfigPreview extends StatelessWidget {
  const _ConfigPreview({required this.config});

  final GameConfig config;

  @override
  Widget build(BuildContext context) {
    final entries = <(String, String)>[
      ('Mode', _ChallengeCodeScreenState._modeLabel(config.mode)),
      ('Board', '${config.size}×${config.size}'),
      ('Target', '${config.target}'),
      if (config.moveLimit != null) ('Move limit', '${config.moveLimit}'),
      if (config.timeLimitSeconds != null)
        ('Time limit', '${config.timeLimitSeconds} seconds'),
      ('Seed', '${config.seed}'),
    ];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          for (final entry in entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Expanded(child: Text(entry.$1)),
                  Text(
                    entry.$2,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
