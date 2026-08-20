import 'package:flutter/material.dart';

import '../../app/state/app_scope.dart';
import '../../core/localization/nova_localizations.dart';
import '../../data/custom_preset_store.dart';
import '../../domain/custom_game_preset.dart';
import '../../shared/game_replacement_guard.dart';
import '../../shared/nova_scaffold.dart';

enum _PresetAction { edit, duplicate, delete }

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
  final _scrollController = ScrollController();
  final _nameController = TextEditingController(text: 'My Custom Game');
  final _seedController = TextEditingController();

  CustomGameStyle _style = CustomGameStyle.target;
  int _size = 4;
  int _target = 2048;
  int _timeLimit = 180;
  int _moveLimit = 250;
  bool _loading = true;
  String? _editingOriginalName;
  List<CustomGamePreset> _presets = const [];

  bool get _isEditing => _editingOriginalName != null;

  @override
  void initState() {
    super.initState();
    _loadPresets();
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
      final originalName = _editingOriginalName?.toLowerCase();
      if (originalName != null &&
          _presets.any(
            (item) =>
                item.name.toLowerCase() == normalizedName &&
                item.name.toLowerCase() != originalName,
          )) {
        _showMessage(
          _text(
            'A preset with this name already exists.',
            'इस नाम का प्रीसेट पहले से मौजूद है।',
          ),
        );
        return;
      }

      final updated = <CustomGamePreset>[
        preset,
        ..._presets.where((item) {
          final itemName = item.name.toLowerCase();
          return itemName != normalizedName && itemName != originalName;
        }),
      ];
      await _store.save(updated);
      if (!mounted) return;
      final wasEditing = _isEditing;
      setState(() {
        _presets = updated.take(CustomPresetStore.maxPresets).toList();
        _editingOriginalName = null;
      });
      _showMessage(
        wasEditing
            ? _text('Preset updated.', 'प्रीसेट अपडेट हो गया।')
            : _text('Preset saved.', 'प्रीसेट सेव हो गया।'),
      );
    } on FormatException catch (error) {
      _showMessage(_friendlyError(error));
    }
  }

  void _editPreset(CustomGamePreset preset) {
    _populateForm(preset, name: preset.name, editingOriginalName: preset.name);
    _showMessage(_text('Preset loaded for editing.', 'प्रीसेट संपादन के लिए लोड हुआ।'));
  }

  void _duplicatePreset(CustomGamePreset preset) {
    _populateForm(
      preset,
      name: _nextCopyName(preset.name),
      editingOriginalName: null,
    );
    _showMessage(
      _text(
        'Preset copy loaded. Review it and save when ready.',
        'प्रीसेट कॉपी लोड हुई। जाँचकर तैयार होने पर सेव करें।',
      ),
    );
  }

  void _populateForm(
    CustomGamePreset preset, {
    required String name,
    required String? editingOriginalName,
  }) {
    FocusManager.instance.primaryFocus?.unfocus();
    _nameController.text = name;
    _seedController.text = preset.seed?.toString() ?? '';
    setState(() {
      _style = preset.style;
      _size = preset.size;
      _target = preset.target;
      _timeLimit = preset.timeLimitSeconds ?? 180;
      _moveLimit = preset.moveLimit ?? 250;
      _editingOriginalName = editingOriginalName;
    });
    _scrollToForm();
  }

  void _scrollToForm() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.jumpTo(_scrollController.position.minScrollExtent);
    });
  }

  void _cancelEdit() {
    FocusManager.instance.primaryFocus?.unfocus();
    _nameController.text = 'My Custom Game';
    _seedController.clear();
    setState(() {
      _style = CustomGameStyle.target;
      _size = 4;
      _target = 2048;
      _timeLimit = 180;
      _moveLimit = 250;
      _editingOriginalName = null;
    });
    _showMessage(_text('Edit cancelled.', 'संपादन रद्द हुआ।'));
  }

  String _nextCopyName(String sourceName) {
    final existingNames = _presets
        .map((preset) => preset.name.toLowerCase())
        .toSet();
    for (var index = 1; index <= CustomPresetStore.maxPresets + 2; index++) {
      final suffix = index == 1 ? ' copy' : ' copy $index';
      final maximumBaseLength = CustomGamePreset.maxNameLength - suffix.length;
      var base = sourceName;
      if (base.length > maximumBaseLength) {
        base = base.substring(0, maximumBaseLength);
      }
      base = base.trimRight();
      if (base.isEmpty) base = 'Preset';
      final candidate = '$base$suffix';
      if (!existingNames.contains(candidate.toLowerCase())) return candidate;
    }
    throw const FormatException('Unable to create unique preset copy name');
  }

  Future<void> _handlePresetAction(
    _PresetAction action,
    CustomGamePreset preset,
  ) async {
    switch (action) {
      case _PresetAction.edit:
        _editPreset(preset);
        break;
      case _PresetAction.duplicate:
        _duplicatePreset(preset);
        break;
      case _PresetAction.delete:
        await _confirmDeletePreset(preset);
        break;
    }
  }

  Future<void> _confirmDeletePreset(CustomGamePreset preset) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_text('Delete preset?', 'प्रीसेट हटाएँ?')),
        content: Text(
          _text(
            'Delete "${preset.name}"? This cannot be undone.',
            '"${preset.name}" हटाएँ? इसे वापस नहीं किया जा सकता।',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(_text('Cancel', 'रद्द करें')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(_text('Delete', 'हटाएँ')),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _deletePreset(preset);
    }
  }

  Future<void> _deletePreset(CustomGamePreset preset) async {
    final updated = _presets.where((item) => item.name != preset.name).toList();
    await _store.save(updated);
    if (!mounted) return;
    setState(() {
      _presets = updated;
      if (_editingOriginalName?.toLowerCase() == preset.name.toLowerCase()) {
        _editingOriginalName = null;
      }
    });
    _showMessage(_text('Preset deleted.', 'प्रीसेट हटा दिया गया।'));
  }

  Future<void> _startPreset(CustomGamePreset preset) async {
    if (!await confirmGameReplacement(context) || !mounted) return;
    await AppScope.of(context).newGame(preset.toGameConfig(), custom: true);
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
      'Unable to create unique preset copy name' => _text(
        'Unable to create another unique copy name.',
        'एक और अलग कॉपी नाम नहीं बनाया जा सका।',
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
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameController,
            maxLength: CustomGamePreset.maxNameLength,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: _text('Preset name', 'प्रीसेट नाम'),
              helperText: _isEditing
                  ? _text(
                      'Editing "${_editingOriginalName!}".',
                      '"${_editingOriginalName!}" का संपादन हो रहा है।',
                    )
                  : _text(
                      'Used only on this device.',
                      'केवल इस डिवाइस पर उपयोग होगा।',
                    ),
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<CustomGameStyle>(
            key: ValueKey('custom-style-${_style.name}'),
            initialValue: _style,
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
            key: ValueKey('custom-size-$_size'),
            initialValue: _size,
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
            key: ValueKey('custom-target-$_target'),
            initialValue: _target,
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
              key: ValueKey('custom-time-$_timeLimit'),
              initialValue: _timeLimit,
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
              key: ValueKey('custom-move-$_moveLimit'),
              initialValue: _moveLimit,
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
              labelText: _text(
                'Deterministic seed (optional)',
                'निर्धारक सीड (वैकल्पिक)',
              ),
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
                icon: Icon(
                  _isEditing
                      ? Icons.save_outlined
                      : Icons.bookmark_add_outlined,
                ),
                label: Text(
                  _isEditing
                      ? _text('Save changes', 'बदलाव सेव करें')
                      : _text('Save preset', 'प्रीसेट सेव करें'),
                ),
              ),
              if (_isEditing)
                TextButton.icon(
                  onPressed: _cancelEdit,
                  icon: const Icon(Icons.close_rounded),
                  label: Text(_text('Cancel edit', 'संपादन रद्द करें')),
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
                  trailing: PopupMenuButton<_PresetAction>(
                    tooltip: _text('Preset actions', 'प्रीसेट क्रियाएँ'),
                    onSelected: (action) => _handlePresetAction(action, preset),
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: _PresetAction.edit,
                        child: Row(
                          children: [
                            const Icon(Icons.edit_outlined),
                            const SizedBox(width: 12),
                            Text(_text('Edit preset', 'प्रीसेट संपादित करें')),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: _PresetAction.duplicate,
                        child: Row(
                          children: [
                            const Icon(Icons.copy_outlined),
                            const SizedBox(width: 12),
                            Text(_text('Duplicate preset', 'प्रीसेट कॉपी करें')),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: _PresetAction.delete,
                        child: Row(
                          children: [
                            const Icon(Icons.delete_outline_rounded),
                            const SizedBox(width: 12),
                            Text(_text('Delete preset', 'प्रीसेट हटाएँ')),
                          ],
                        ),
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
