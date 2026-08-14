# Accessibility

Accessibility is part of the 2048 Nova definition of done.

## Implemented foundations

- The game board exposes its dimensions through a dedicated semantic container node.
- Every tile exposes a distinct semantic node with row and column position plus its exact value; empty cells are identified as empty.
- Visual tile text is excluded from duplicate semantics so assistive technology receives one intentional positional/value announcement per cell rather than a merged or repeated label.
- Tile values are rendered as text, so gameplay never relies on color alone.
- Arrow Keys and W/A/S/D provide keyboard gameplay controls.
- H opens a Hint, U performs Undo when available, P/Escape opens Pause, and R starts the restart flow on keyboard platforms.
- The Game screen visibly lists its keyboard shortcuts.
- Interactive toolbar controls use tooltips and semantic labels where additional context is useful.
- Terminal win/loss dialogs require an explicit action and cannot be accidentally dismissed by tapping outside or using route-back.
- Recoverable-game replacement uses an explicit confirmation dialog rather than silently discarding the saved board.
- Challenge Codes use standard labeled form controls, selectable generated code text, explicit validation feedback, a decoded configuration preview, and the same recoverable-game replacement confirmation used by normal new-game flows.
- Game Backup uses visible descriptive buttons and a non-dismissible restore confirmation that explains the unranked policy before replacement.
- Home distinguishes imported sessions with **Continue Unranked Backup** rather than presenting imported data as ordinary ranked progress.
- Move Replay reuses the accessible game-board renderer, labels the replay-frame slider, exposes tooltips for first/previous/next/latest controls, and keeps playback read-only.
- Auto Play Demo reuses the accessible game-board renderer and exposes running/paused/completed semantic state.
- Buy Me a Coffee is explicitly labeled as optional support.
- Material 3 controls provide keyboard/focus behavior on supported desktop and Web targets.
- High-contrast mode increases generated color-scheme contrast.
- Reduced-motion disables tile transition durations.
- The implementation also respects the platform `disableAnimations` preference.
- Layouts use responsive constraints rather than a single fixed phone size.
- Text remains under Flutter's normal system text-scaling behavior.
- Large tile values use fitted/responsive text rather than silent truncation.
- Sound and haptic feedback can be disabled independently.

## Board semantics

The board renderer communicates structure separately from visual decoration:

- one semantic node identifies the board size;
- each cell has a row/column position;
- non-empty cells include the exact tile value;
- empty cells are explicitly identified as empty;
- visual tile-number text is excluded from producing a second duplicate semantics announcement.

This supports users who cannot rely on the visual grid or tile colors alone.

## Keyboard accessibility

The primary game can be played without a pointer:

| Key | Action |
| --- | --- |
| Arrow keys | Move tiles |
| W/A/S/D | Move tiles |
| H | Hint |
| U | Undo |
| P / Escape | Pause |
| R | Restart flow |

Keyboard behavior still requires real-platform focus qualification because automated widget tests cannot reproduce every browser/window-manager/screen-reader focus interaction.

## Motion and feedback

Reduced Motion removes nonessential tile transition duration. The game also respects the platform's disabled-animation signal where implemented.

Sound and haptics are optional and independently disableable. Gameplay state is never communicated only through those feedback channels.

## Challenge Codes accessibility

The Challenge Codes screen uses standard Material controls for:

- mode selection;
- Target tile selection when relevant;
- generating a fresh deterministic code;
- selectable generated code text;
- copying a generated code;
- multiline manual input;
- explicit Paste and Validate actions;
- decoded mode/board/target/limit/seed preview;
- starting a validated challenge.

Validation success/failure is visible as text rather than color alone. A valid code does not replace a recoverable game until the normal explicit replacement dialog is confirmed.

Manual qualification still needs to verify long `NOVA1...` text selection/reading behavior, multiline input editing, keyboard focus order, validation announcements, clipboard success/failure behavior, large-text wrapping, and the replacement dialog on TalkBack, VoiceOver, Narrator, and representative browser screen readers.

## Game Backup accessibility

The Backup screen uses standard Material controls for:

- Copy game backup;
- Import from clipboard;
- cancel restore;
- confirm **Restore unranked backup**.

A valid import is previewed before replacement. The dialog is intentionally not dismissible by tapping outside, reducing accidental data replacement and making the required decision explicit.

The text explains that imported games are unranked and do not update lifetime records. The Home continuation label also preserves that distinction after navigation/restart.

Manual qualification still needs to verify clipboard action announcements, long validation-error text, confirmation focus order, and large-text layout with real assistive technology.

## Move Replay accessibility

Move Replay:

- identifies itself as read-only;
- reuses the semantic game board;
- exposes frame/move/score/highest metrics;
- labels first/previous/next/latest controls;
- labels the frame slider;
- provides Play/Pause;
- exposes playback speed choices.

Automatic replay changes must remain immediately pausable and should not cause disruptive repeated screen-reader announcements on real platforms.

## Auto Play Demo accessibility

Auto Play Demo explicitly identifies itself as a deterministic heuristic demonstration and as separate from player records. It reuses the semantic board and provides visible/semantic control state for Auto Play/Pause, Step, Reset, and speed selection.

Because automatic movement can update the board repeatedly, real screen-reader qualification must check that users retain control and can stop automatic changes quickly.

## Automated accessibility regression coverage

`test/game_board_accessibility_test.dart` verifies:

- the board exposes its configured dimensions as its own semantic node;
- a non-empty tile exposes a separate row, column, and value label;
- an empty tile exposes a separate row, column, and empty-state label;
- the board hierarchy remains discoverable without relying on visual tile text semantics.

Challenge Code widget tests exercise generated-code Copy, clipboard Paste, validation feedback, decoded preview, starting a deterministic code, invalid-input preservation, and replacement cancellation through the actual screen/state boundary.

Replay/widget tests additionally verify that timeline controls can be reached in a constrained test viewport after scrolling and that Replay uses the same semantic board instead of introducing a second inaccessible renderer.

Backup widget tests verify primary export/import controls, explicit restore confirmation, cancellation, and invalid-input flow while exercising the same application routing/state layer used by the UI.

Additional widget tests cover terminal-dialog protection, recoverable-game replacement confirmation, Home state behavior, keyboard shortcuts, Auto Play controls, Challenge Code navigation, and primary navigation. Automated semantics tests are useful regression checks but are not equivalent to real assistive-technology testing.

## Manual release checks

Before a stable release, verify:

1. Navigate primary screens using keyboard only.
2. Play a full game with Arrow Keys and W/A/S/D.
3. Exercise H, U, P/Escape, and R shortcuts and confirm focus returns sensibly.
4. Confirm visible focus indicators on interactive controls.
5. Inspect board-size, row/column tile, metric, toolbar, support, and dialog semantics with a screen reader.
6. Confirm each board cell is announced once with its intended positional/value state rather than duplicated visual text.
7. Confirm terminal win/loss dialogs communicate state and actions clearly.
8. Open Challenge Codes and verify mode/target dropdowns, Generate, selectable code, Copy, multiline code field, Paste, Validate, decoded preview, validation errors, Start, and replacement confirmation with keyboard and representative screen readers.
9. Verify Challenge Code clipboard actions and long-code reading/editing remain understandable at large text sizes and across representative mobile/desktop/browser clipboard implementations.
10. Open Game Backup and verify Copy, Import, invalid-input messaging, preview information, Cancel, and Restore Unranked Backup focus/announcement behavior.
11. Verify imported-session labeling remains understandable on Home and does not rely on color alone.
12. Open Move Replay and verify the read-only explanation, current frame/move metrics, board cells, slider, first/previous/next/latest controls, Play/Pause, and speed selector have understandable focus/announcement behavior.
13. During Replay playback, confirm frame changes do not create disruptive or uncontrollable repeated announcements; Pause must stop further automatic frame changes.
14. Open Auto Play Demo and verify demo-state labels, controls, speed selection, board semantics, and demo-only metrics with representative assistive technology.
15. Test both light and dark modes with high contrast on and off.
16. Test large system text scaling without clipped primary actions, Challenge Code controls, Backup dialog/actions, Replay controls, demo controls, or unreadable board labels.
17. Test reduced motion and platform animation reduction across normal play, Replay, and Auto Play Demo.
18. Verify values remain understandable without distinguishing colors.
19. Check portrait, landscape, narrow desktop, and wide desktop layouts.
20. Verify destructive/replacement actions remain clearly labeled and require confirmation where data is recoverable.
21. Verify timed-challenge countdown changes do not create disruptive repeated announcements in the chosen assistive technology.
22. Verify clipboard success/failure/error messages for both Challenge Codes and Game Backup are understandable with TalkBack, VoiceOver, and at least one desktop/browser screen reader.

## Known scope

Automated tests can cover semantics and interaction regressions, but they do not replace VoiceOver, TalkBack, Narrator, browser screen-reader, switch-control, keyboard-only, or other assistive-technology testing on representative real target platforms.

Stable release notes must distinguish automated verification from manual screen-reader/device verification. Current remaining manual qualification is tracked in [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md).

## Localized accessibility semantics

English and Hindi use the same accessibility structure. In Hindi mode the game-board container and positional tile/empty-cell semantics are localized, including row, column, and tile value. Standard Material controls receive the selected locale through Flutter's official localization delegates.

Automated widget/semantics tests verify representative Hindi Home/Settings text and board labels. They do **not** prove final real assistive-technology quality. Stable release still requires Hindi checks with TalkBack, VoiceOver, representative desktop/browser screen readers, large text, narrow layouts, focus traversal, and language switching on real platforms.
