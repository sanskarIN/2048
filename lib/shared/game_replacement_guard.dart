import 'package:flutter/material.dart';

import '../app/state/app_scope.dart';
import '../core/localization/nova_localizations.dart';
import '../domain/game_types.dart';

Future<bool> confirmGameReplacement(BuildContext context) async {
  final current = AppScope.of(context).game;
  if (current == null || current.status == GameStatus.lost) return true;
  final l10n = context.l10n;

  final confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.text('Replace current game?')),
      content: Text(
        l10n.text(
          'Your current game can still be continued. Starting another game will replace its saved board and undo history.',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(l10n.text('Keep current game')),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(l10n.text('Start new game')),
        ),
      ],
    ),
  );
  return confirmed == true;
}
