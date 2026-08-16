import 'package:flutter/material.dart';

import '../../core/localization/nova_localizations.dart';
import '../../core/theme/nova_theme.dart';

class GameBoard extends StatelessWidget {
  const GameBoard({
    required this.board,
    required this.reducedMotion,
    super.key,
  });

  final List<List<int>> board;
  final bool reducedMotion;

  @override
  Widget build(BuildContext context) {
    final size = board.length;
    final l10n = context.l10n;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: l10n.isHindi
          ? '$size बाय $size गेम बोर्ड'
          : '$size by $size game board',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final extent = constraints.maxWidth < constraints.maxHeight
              ? constraints.maxWidth
              : constraints.maxHeight;
          final gap = size >= 6 ? 5.0 : 8.0;
          final cell = (extent - gap * (size + 1)) / size;
          return SizedBox.square(
            dimension: extent,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Stack(
                children: [
                  for (var row = 0; row < size; row++)
                    for (var col = 0; col < size; col++)
                      Positioned(
                        left: gap + col * (cell + gap),
                        top: gap + row * (cell + gap),
                        width: cell,
                        height: cell,
                        child: _Tile(
                          row: row,
                          col: col,
                          value: board[row][col],
                          reducedMotion: reducedMotion,
                        ),
                      ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.row,
    required this.col,
    required this.value,
    required this.reducedMotion,
  });

  final int row;
  final int col;
  final int value;
  final bool reducedMotion;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final digits = value == 0 ? 1 : value.toString().length;
    final fontSize = digits <= 4
        ? 28.0
        : digits <= 6
        ? 22.0
        : 16.0;
    final systemReducedMotion = MediaQuery.disableAnimationsOf(context);
    final animationDuration = reducedMotion || systemReducedMotion
        ? Duration.zero
        : const Duration(milliseconds: 140);
    final position = l10n.isHindi
        ? 'पंक्ति ${row + 1}, कॉलम ${col + 1}'
        : 'Row ${row + 1}, column ${col + 1}';
    final semanticLabel = value == 0
        ? l10n.isHindi
              ? '$position, खाली'
              : '$position, empty'
        : l10n.isHindi
        ? '$position, टाइल $value'
        : '$position, tile $value';
    return Semantics(
      container: true,
      excludeSemantics: true,
      label: semanticLabel,
      child: AnimatedContainer(
        duration: animationDuration,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: NovaTheme.tileColor(scheme, value),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: AnimatedSwitcher(
          duration: animationDuration,
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            );
          },
          child: value == 0
              ? const SizedBox.shrink(key: ValueKey(0))
              : FittedBox(
                  key: ValueKey(value),
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      '$value',
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
