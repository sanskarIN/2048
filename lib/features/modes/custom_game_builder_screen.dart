import 'package:flutter/material.dart';

import '../../app/state/app_scope.dart';
import '../../core/localization/nova_localizations.dart';
import '../../data/custom_preset_store.dart';
import '../../domain/custom_game_preset.dart';
import '../../shared/game_replacement_guard.dart';
import '../../shared/nova_scaffold.dart';

class CustomGameBuilderScreen extends StatefulWidget {
  const CustomGameBuilderScreen({super.key});

  @override
  State<CustomGameBuilderScreen> createState() =>
      _CustomGameBuilderScreenState();
}

class _CustomGameBuilderScreenState extends State<CustomGameBuilderScreen> {
  static const _boardSizes = [3, 4, 5, 6, 7, 8];
  static const _targets = [128, 256, 512, 1024, 2048, 4096, 8192, 16384];
  static const _timeLimits = [30, 60, 90, 120, 180, 300, 600];
  static const _moveLimits = [25, 50, 100, 150, 250, 500, 1000];

  final _store = CustomPresetStore();
  final _nameController = TextEditingController(text: 'My Custom Game');
  final _seedController = TextEditingController();

  CustomGameStyle _style = CustomGameStyle.target;
  int _size = 4;
  int _target = 2048;
  int _timeLimit = 180;
  int _moveLimit = 250;
  bool _loading = true;
  List<CustomGamePreset> _presets = const [];

  @override
  void initState() {
    super.initState();
    _loadPresets();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _seedController.dispose();
    super.dispose();
  }

  Future<void> _loadPresets() async {
    final presets = await _store.load();
    if (!mounted) return;
    setState(() {
      _presets = presets;
      _loading = false;
    });
  }

  CustomGamePreset _buildPreset() {
    final seedText = _seedController.text.trim();
    final seed = seedText.isEmpty ? null : int.tryParse(seedText);
    if (seedText.isNotEmpty && seed == null) {
      throw const FormatException('Invalid random seed');
    }
    return CustomGamePreset.create(
      name: _nameController.text,
      style: _style,
      size: _size,
      target: _target,
      moveLimit: _style == CustomGameStyle.moveLimit ? _moveLimit : null,
      timeLimitSeconds: _style == CustomGameStyle.timed ? _timeLimit : null,
      seed: seed,
    );
  }

  Future<void> _savePreset() async {
    try {
      final preset = _buildPreset();
      final normalizedName = preset.name.toLowerCase();
      final updated = <CustomGamePreset>[
        preset,
        ..._presets.where(
          (item) => item.name.toLowerCase() != normalizedName,
        ),
      ];
      await _store.save(updated);
      if (!mounted) return;
      setState(() => _presets = updated.take(CustomPresetStore.maxPresets).toList());
      _showMessage(
        _text('Preset saved.', 'प्रीसेट सेव हो गया।'),
      );
    } on FormatException catch (error) {
      _showMessage(_friendlyError(error));
    }
  }

  Future<void> _deletePreset(CustomGamePreset preset) async {
    final updated = _presets.where((item) => item.name != preset.name).toList();
    await _store.save(updated);
    if (!mounted) return;
    setState(() => _presets = updated);
    _showMessage(_text('Preset deleted.', 'प्रीसेट हटा दिया गया।'));
  }

  Future<void> _startPreset(CustomGamePreset preset) async {
    if (!await confirmGameReplacement(context) || !mounted) return;
    await AppScope.of(
      context,
    ).newGame(preset.toGameConfig(), custom: true);
    if (mounted) Navigator.pushReplacementNamed(context, '/game');
  }

  Future<void> _startCurrent() async {
    try {
      final preset = _buildPreset();
      await _startPreset(preset);
    } on FormatException catch (error) {
      _showMessage(_friendlyError(error));
    }
  }

  String _friendlyError(FormatException error) {
    return switch (error.message) {
      'Invalid custom preset name' => _text(
        'Enter a preset name from 1 to 40 characters.',
        '1 से 40 अक्षरों का प्रीसेट नाम दर्ज करें।',
      ),
      'Invalid random seed' => _text(
        'Seed must be a whole number from 0 to 2147483647.',
        'सीड 0 से 2147483647 तक पूर्ण संख्या होना चाहिए।',
      ),
      _ => _text(
        'Check the custom game settings and try again.',
        'कस्टम गेम सेटिंग जाँचें और फिर प्रयास करें।',
      ),
    };
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _text(String english, String hindi) {
    return context.l10n.isHindi ? hindi : english;
  }

  String _styleName(CustomGameStyle style) {
    return switch (style) {
      CustomGameStyle.target => _text('Target', 'लक्ष्य'),
      CustomGameStyle.endless => _text('Endless', 'एंडलेस'),
      CustomGameStyle.timed => _text('Timed', 'समय सीमा'),
      CustomGameStyle.moveLimit => _text('Move Limit', 'चाल सीमा'),
    };
  }

  String _presetSummary(CustomGamePreset preset) {
    final parts = <String>[
      '${preset.size}×${preset.size}',
      _styleName(preset.style),
      '${_text('target', 'लक्ष्य')} ${preset.target}',
    ];
    if (preset.timeLimitSeconds != null) {
      parts.add('${preset.timeLimitSeconds}s');
    }
    if (preset.moveLimit != null) {
      parts.add('${preset.moveLimit} ${_text('moves', 'चालें')}');
    }
    if (preset.seed != null) {
      parts.add('${_text('seed', 'सीड')} ${preset.seed}');
    }
    return parts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    return NovaScaffold(
      title: _text('Custom Game Builder', 'कस्टम गेम बिल्डर'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameController,
            maxLength: CustomGamePreset.maxNameLength,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: _text('Preset name', 'प्रीसेट नाम'),
              helperText: _text(
                'Used only on this device.',
                'केवल इस डिवाइस पर उपयोग होगा।',
              ),
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<CustomGameStyle>(
            value: _style,
            decoration: InputDecoration(
              labelText: _text('Game style', 'गेम शैली'),
            ),
            items: [
              for (final style in CustomGameStyle.values)
                DropdownMenuItem(value: style, child: Text(_styleName(style))),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _style = value);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: _size,
            decoration: InputDecoration(
              labelText: _text('Board size', 'बोर्ड आकार'),
            ),
            items: [
              for (final size in _boardSizes)
                DropdownMenuItem(value: size, child: Text('$size × $size')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _size = value);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: _target,
            decoration: InputDecoration(
              labelText: _text('Target tile', 'लक्ष्य टाइल'),
            ),
            items: [
              for (final target in _targets)
                DropdownMenuItem(value: target, child: Text('$target')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _target = value);
            },
          ),
          if (_style == CustomGameStyle.timed) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _timeLimit,
              decoration: InputDecoration(
                labelText: _text('Time limit', 'समय सीमा'),
              ),
              items: [
                for (final seconds in _timeLimits)
                  DropdownMenuItem(
                    value: seconds,
                    child: Text('$seconds ${_text('seconds', 'सेकंड')}'),
                  ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _timeLimit = value);
              },
            ),
          ],
          if (_style == CustomGameStyle.moveLimit) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _moveLimit,
              decoration: InputDecoration(
                labelText: _text('Move limit', 'चाल सीमा'),
              ),
              items: [
                for (final moves in _moveLimits)
                  DropdownMenuItem(
                    value: moves,
                    child: Text('$moves ${_text('moves', 'चालें')}'),
                  ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _moveLimit = value);
              },
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _seedController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: _text('Deterministic seed (optional)', 'निर्धारक सीड (वैकल्पिक)'),
              helperText: _text(
                'Use the same seed and moves to reproduce tile spawns.',
                'उसी सीड और चालों से टाइल स्पॉन दोहराए जा सकते हैं।',
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: _startCurrent,
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(_text('Play now', 'अभी खेलें')),
              ),
              OutlinedButton.icon(
                onPressed: _savePreset,
                icon: const Icon(Icons.bookmark_add_outlined),
                label: Text(_text('Save preset', 'प्रीसेट सेव करें')),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            _text('Saved presets', 'सेव किए गए प्रीसेट'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_presets.isEmpty)
            Text(
              _text(
                'No custom presets yet. Save one above for quick access.',
                'अभी कोई कस्टम प्रीसेट नहीं है। तेज़ पहुँच के लिए ऊपर एक सेव करें।',
              ),
            )
          else
            for (final preset in _presets)
              Card(
                child: ListTile(
                  title: Text(preset.name),
                  subtitle: Text(_presetSummary(preset)),
                  onTap: () => _startPreset(preset),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: _text('Play preset', 'प्रीसेट खेलें'),
                        onPressed: () => _startPreset(preset),
                        icon: const Icon(Icons.play_arrow_rounded),
                      ),
                      IconButton(
                        tooltip: _text('Delete preset', 'प्रीसेट हटाएँ'),
                        onPressed: () => _deletePreset(preset),
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
