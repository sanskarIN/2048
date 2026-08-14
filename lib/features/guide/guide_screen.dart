import 'package:flutter/material.dart';

import '../../core/localization/nova_localizations.dart';
import '../../shared/nova_scaffold.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const sections = [
      (
        'Objective',
        'Slide tiles to combine equal numbers. Build larger powers of two and reach the target without filling the board.',
      ),
      (
        'Controls',
        'Swipe on touch devices. On desktop and web use Arrow Keys or W/A/S/D. H requests a hint, U performs Undo, P or Escape opens Pause, and R starts the restart flow.',
      ),
      (
        'Merging',
        'Each tile can merge at most once in a single move. A new 2 or 4 appears only after a move changes the board.',
      ),
      (
        'Scoring',
        'When two equal tiles merge, the value of the new tile is added to your score. Best score is stored locally.',
      ),
      (
        'Strategy',
        'Keep your highest tiles organized, preserve empty cells, avoid random swipes, use corners intelligently, and plan several moves ahead.',
      ),
      (
        'Modes',
        'Classic 4×4, Quick 3×3, Extended 5×5, Challenge 6×6, Endless, Target, Time Challenge, Move Limit, Daily Challenge, and Zen are available.',
      ),
      (
        'Undo and hints',
        'Undo restores the previous board snapshot including deterministic random state. Hints evaluate legal moves using empty-space, merge, corner, monotonicity, and smoothness heuristics. A normal hint suggests one move and never moves tiles automatically.',
      ),
      (
        'Challenge Codes',
        'Home can open Challenge Codes to create or open an offline shared deterministic challenge. A NOVA1 code contains only a supported game configuration and random seed, so the same code produces the same opening board and random state. It never contains board progress, score, lifetime statistics, achievements, Daily history, settings, or Undo snapshots. Codes are checksummed for accidental corruption, not signed or encrypted. Daily Challenge stays separate because it already uses the UTC date as its shared seed. Starting a valid code creates a fresh normal non-Daily game and uses the normal local statistics policy.',
      ),
      (
        'Game Backup',
        'Home can open Game Backup to copy one validated current-game JSON backup to the clipboard or restore a valid backup after an explicit confirmation. Portable backup excludes settings, lifetime statistics, achievements, Daily history, and old Undo history. Every imported game is deliberately marked unranked, stays unranked after restart, and cannot change lifetime records, achievements, streaks, or Daily results. Imported play can still save and create new Undo snapshots for that restored session.',
      ),
      (
        'Move Replay',
        'When a saved game exists, Home can open Move Replay. It is a read-only spectator view built from the current game and its retained Undo snapshots. You can scrub between frames, jump to the first or latest retained frame, step backward or forward, play/pause the timeline, and choose 1, 2, or 4 frames per second. Undo history is bounded, so very long games may replay only the most recent retained moves. Replay uses defensive copies and never changes the live board, score, RNG, statistics, achievements, or Daily history.',
      ),
      (
        'Auto Play / AI Demo',
        'Auto Play Demo is an optional local heuristic demonstration. It repeatedly applies the same deterministic solver used by Hint to a separate seeded Endless 4×4 sandbox. You can start, pause/resume, step one move at a time, choose the demonstration speed, or reset the seed. It is not machine learning and does not claim optimal play. Demo score and moves are never mixed with your saved game, lifetime statistics, achievements, or Daily Challenge history.',
      ),
      (
        'Daily Challenge',
        'The daily mode derives a deterministic seed from the UTC date, so the starting random sequence is repeatable for that day.',
      ),
      (
        'Accessibility',
        'Use system text scaling, keyboard controls, positional semantic tile labels, high contrast, and reduced motion. Tile values are always shown as text, not color alone. Challenge Codes use labeled form controls, selectable generated text, explicit validation feedback, and a decoded configuration preview.',
      ),
      (
        'Language',
        'Settings can follow the system language or explicitly use English or Hindi. Language choice is stored locally, works offline, and never sends text to a translation service.',
      ),
      (
        'Offline and privacy',
        'Core gameplay, Challenge Codes, Game Backup validation, Move Replay, Auto Play Demo, and language switching work without a project server. No account, analytics, advertising tracker, remote AI service, cloud synchronization, or online translation service is required. Clipboard text is read or written only after you choose the corresponding Challenge Code or Game Backup action.',
      ),
      (
        'FAQ',
        'You can continue after reaching the target, disable optional feedback in Settings, change language, reset project-owned local data, and report bugs through GitHub or the support email.',
      ),
    ];
    return NovaScaffold(
      title: l10n.text('How to Play'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final section in sections)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.text(section.$1),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(l10n.text(section.$2)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
