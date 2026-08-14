import 'package:flutter/material.dart';

import '../app/state/app_scope.dart';
import '../domain/game_types.dart';

Future<bool> confirmGameReplacement(BuildContext context) async {
  final current = AppScope.of(context).game;
  if (current == null || current.status == GameStatus.lost) return true;

  final confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Replace current game?'),
      content: const Text(
        'Your current game can still be continued. Starting another game will replace its saved board and undo history.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Keep current game'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Start new game'),
        ),
      ],
    ),
  );
  return confirmed == true;
}
