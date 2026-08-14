# Accessibility

Accessibility is part of the 2048 Nova definition of done.

## Implemented foundations

- The game board exposes its dimensions through a dedicated semantic container node.
- Every tile exposes a distinct semantic node with row and column position plus its exact value; empty cells are identified as empty.
- Visual tile text is excluded from duplicate semantics so assistive technology receives one intentional positional/value announcement per cell rather than a merged or repeated label.
- Tile values are rendered as text, so gameplay never relies on color alone.
- Arrow Keys and W/A/S/D provide keyboard gameplay controls.
- H opens a hint, U performs Undo when available, P/Escape opens Pause, and R starts the restart flow on keyboard platforms.
- The Game screen visibly lists its keyboard shortcuts.
- Interactive toolbar controls use tooltips and semantic labels where additional context is useful.
- Terminal win/loss dialogs require an explicit action and cannot be accidentally dismissed by tapping outside or using route-back.
- Recoverable-game replacement uses an explicit confirmation dialog rather than silently discarding the saved board.
- Buy Me a Coffee is explicitly labeled as optional support.
- Material 3 controls provide keyboard/focus behavior on supported desktop and web targets.
- High-contrast mode increases generated color-scheme contrast.
- Reduced-motion disables tile transition durations.
- The implementation also respects the platform `disableAnimations` preference.
- Layouts use responsive constraints rather than a single fixed phone size.
- Text remains under Flutter's normal system text-scaling behavior.
- Large tile values use fitted/responsive text rather than silent truncation.
- Sound and haptic feedback can be disabled independently.

## Automated accessibility regression coverage

`test/game_board_accessibility_test.dart` verifies:

- the board exposes its configured dimensions as its own semantic node;
- a non-empty tile exposes a separate row, column, and value label;
- an empty tile exposes a separate row, column, and empty-state label;
- the board hierarchy remains discoverable without relying on visual tile text semantics.

Additional widget tests cover terminal-dialog protection, recoverable-game replacement confirmation, Home state behavior, keyboard shortcuts, and primary navigation. Automated semantics tests are useful regression checks but are not equivalent to real assistive-technology testing.

## Manual release checks

Before a stable release, verify:

1. Navigate primary screens using keyboard only.
2. Play a full game with Arrow Keys and W/A/S/D.
3. Exercise H, U, P/Escape, and R shortcuts and confirm focus returns sensibly.
4. Confirm visible focus indicators on interactive controls.
5. Inspect board-size, row/column tile, metric, toolbar, support, and dialog semantics with a screen reader.
6. Confirm each board cell is announced once with its intended positional/value state rather than duplicated visual text.
7. Confirm terminal win/loss dialogs communicate state and actions clearly.
8. Test both light and dark modes with high contrast on and off.
9. Test large system text scaling without clipped primary actions or unreadable board labels.
10. Test reduced motion and platform animation reduction.
11. Verify values remain understandable without distinguishing colors.
12. Check portrait, landscape, narrow desktop, and wide desktop layouts.
13. Verify destructive/replacement actions remain clearly labeled and require confirmation where data is recoverable.
14. Verify timed-challenge countdown changes do not create disruptive repeated announcements in the chosen assistive technology.

## Known scope

Automated tests can cover semantics and interaction regressions, but they do not replace VoiceOver, TalkBack, Narrator, browser screen-reader, switch-control, or other assistive-technology testing on representative real target platforms. Stable release notes must distinguish automated verification from manual screen-reader/device verification.
