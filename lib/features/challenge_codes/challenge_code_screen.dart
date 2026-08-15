import 'package:flutter/material.dart';

import '../../app/state/app_scope.dart';
import '../../core/localization/nova_localizations.dart';
import '../../domain/challenge_code.dart';
import '../../domain/game_types.dart';
import '../../shared/game_replacement_guard.dart';
import '../../shared/nova_scaffold.dart';
import '../../shared/text_clipboard.dart';

import 'challenge_code_qr.dart';

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
  static const _targetOptions = [128, 256, 512, 1024, 2048, 4096, 8192, 16384];

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
    final l10n = context.l10n;
    return NovaScaffold(
      title: l10n.text('Challenge Codes'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _InfoCard(
            icon: Icons.hub_outlined,
            title: l10n.text('Same seed, same opening'),
            body: l10n.text(
              'Challenge codes share only a validated game configuration and deterministic seed. They do not contain board progress, scores, statistics, achievements, Daily history, or Undo data.',
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
                    l10n.text('Create a challenge'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<GameMode>(
                    initialValue: _mode,
                    decoration: InputDecoration(
                      labelText: l10n.text('Game mode'),
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      for (final mode in ChallengeCode.supportedModes)
                        DropdownMenuItem(
                          value: mode,
                          child: Text(l10n.text(_modeLabel(mode))),
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
                      decoration: InputDecoration(
                        labelText: l10n.text('Target tile'),
                        border: const OutlineInputBorder(),
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
                    label: Text(l10n.text('Generate new seeded code')),
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
                    const SizedBox(height: 12),
                    Text(
                      l10n.text('Scan to share'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ChallengeCodeQr(
                      code: _generatedCode!,
                      semanticsLabel: l10n.text(
                        'QR code containing this challenge code',
                      ),
                      errorLabel: l10n.text('Unable to render QR code.'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.text(
                        'The QR code contains the same plain NOVA1 text shown above. It does not add identity, authentication, or cloud transfer.',
                      ),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _copyGeneratedCode,
                      icon: const Icon(Icons.copy_rounded),
                      label: Text(l10n.text('Copy challenge code')),
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
                    l10n.text('Open a challenge'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.text(
                      'Paste a NOVA1 code or enter it manually. A checksum catches accidental corruption before any game is replaced.',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _inputController,
                    minLines: 3,
                    maxLines: 6,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: InputDecoration(
                      labelText: l10n.text('Challenge code'),
                      alignLabelWithHint: true,
                      border: const OutlineInputBorder(),
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
                        label: Text(l10n.text('Paste code')),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: _validateInput,
                        icon: const Icon(Icons.verified_outlined),
                        label: Text(l10n.text('Validate code')),
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
                      label: Text(l10n.text('Start this challenge')),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _InfoCard(
            icon: Icons.calendar_today_outlined,
            title: l10n.text('Daily Challenge stays separate'),
            body: l10n.text(
              'Daily Challenge already uses the UTC date as its shared seed and keeps dedicated history. Challenge codes intentionally cannot encode Daily mode.',
            ),
          ),
          const SizedBox(height: 12),
          _InfoCard(
            icon: Icons.shield_outlined,
            title: l10n.text('No account or cloud required'),
            body: l10n.text(
              'Codes are plain offline text. The checksum is for typo/corruption detection, not identity or authentication. Starting a valid code creates a fresh local game and counts like any other new non-Daily game.',
            ),
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
      SnackBar(
        content: Text(context.l10n.text('Challenge code copied to clipboard.')),
      ),
    );
  }

  Future<void> _pasteCode() async {
    final text = await widget.clipboard.readText();
    if (!mounted) return;
    if (text == null || text.trim().isEmpty) {
      setState(() {
        _preview = null;
        _validationMessage = context.l10n.text(
          'Clipboard does not contain a challenge code.',
        );
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
        _validationMessage = context.l10n.text('Valid challenge code.');
      });
    } on FormatException catch (error) {
      setState(() {
        _preview = null;
        _validationMessage = context.l10n.text(error.message.toString());
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
    final l10n = context.l10n;
    final entries = <(String, String)>[
      (
        l10n.text('Mode'),
        l10n.text(_ChallengeCodeScreenState._modeLabel(config.mode)),
      ),
      (l10n.text('Board'), '${config.size}×${config.size}'),
      (l10n.text('Target'), '${config.target}'),
      if (config.moveLimit != null)
        (l10n.text('Move limit'), '${config.moveLimit}'),
      if (config.timeLimitSeconds != null)
        (
          l10n.text('Time limit'),
          l10n.isHindi
              ? '${config.timeLimitSeconds} सेकंड'
              : '${config.timeLimitSeconds} seconds',
        ),
      (l10n.text('Seed'), '${config.seed}'),
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
