import 'package:flutter/material.dart';

import '../../shared/nova_scaffold.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        'Auto Play / AI Demo',
        'Auto Play Demo is an optional local heuristic demonstration. It repeatedly applies the same deterministic solver used by Hint to a separate seeded Endless 4×4 sandbox. You can start, pause/resume, step one move at a time, choose the demonstration speed, or reset the seed. It is not machine learning and does not claim optimal play. Demo score and moves are never mixed with your saved game, lifetime statistics, achievements, or Daily Challenge history.',
      ),
      (
        'Daily Challenge',
        'The daily mode derives a deterministic seed from the UTC date, so the starting random sequence is repeatable for that day.',
      ),
      (
        'Accessibility',
        'Use system text scaling, keyboard controls, positional semantic tile labels, high contrast, and reduced motion. Tile values are always shown as text, not color alone.',
      ),
      (
        'Offline and privacy',
        'Core gameplay and Auto Play Demo work offline. No account, analytics, advertising tracker, or cloud synchronization is required.',
      ),
      (
        'FAQ',
        'You can continue after reaching the target, disable optional feedback in Settings, and report bugs through GitHub or the support email.',
      ),
    ];
    return NovaScaffold(
      title: 'How to Play',
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
                      section.$1,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(section.$2),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
