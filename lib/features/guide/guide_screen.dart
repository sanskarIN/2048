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
        'Swipe on touch devices. On desktop and web use Arrow Keys or W/A/S/D. Use the toolbar for undo, hint, and restart.',
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
        'Undo restores the previous board snapshot including deterministic random state. Hints choose a valid direction using a lightweight heuristic.',
      ),
      (
        'Daily Challenge',
        'The daily mode derives a deterministic seed from the UTC date, so the starting random sequence is repeatable for that day.',
      ),
      (
        'Accessibility',
        'Use system text scaling, keyboard controls, semantic tile labels, high contrast, and reduced motion. Tile values are always shown as text, not color alone.',
      ),
      (
        'Offline and privacy',
        'Core gameplay works offline. No account, analytics, advertising tracker, or cloud synchronization is required.',
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
