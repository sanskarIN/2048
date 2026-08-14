# Release Checklist

2048 Nova remains on the `0.9.0+1` release-candidate line. Automated checks below can verify repository behavior and build configuration; they do not replace physical-device, assistive-technology, clipboard/handler, signing, or store-distribution qualification.

## Automated release-candidate gate

Current objective evidence is recorded in `docs/VERIFICATION.md` and `what_changed.md`.

- [x] `dart format --output=none --set-exit-if-changed lib test`
- [x] `flutter analyze`
- [x] `flutter test --coverage`
- [x] `flutter build web --release`
- [x] Android release APK builds on the configured hosted runner
- [x] Linux release builds on the configured hosted runner
- [x] Windows release builds on the configured hosted runner
- [x] macOS release builds on the configured hosted runner
- [x] iOS release builds with `--no-codesign` on the configured hosted runner
- [x] Save-schema validation/migration and malformed-data recovery are regression tested
- [x] Daily Challenge persistence/history repair and replay-best preservation are regression tested
- [x] Undo lifetime-best and statistics-reset/Undo boundaries are regression tested
- [x] Board-size and positional tile accessibility semantics are regression tested
- [x] Terminal dialogs, replacement guards, keyboard shortcuts, and restored timed-game status are regression tested
- [x] External destination URI policy is regression tested
- [x] Auto Play deterministic reset and matching-seed sequence behavior are regression tested
- [x] Auto Play single-step, speed selection, start/pause, and stopped-background-timer behavior are regression tested
- [x] Auto Play player-data isolation is regression tested against player game state and lifetime statistics
- [x] Auto Play production code builds successfully in the configured Android/Linux/Windows/macOS/unsigned-iOS matrix
- [x] Replay timeline filters stale/future snapshots, orders retained moves, deduplicates move-number frames, and returns defensive unmodifiable copies
- [x] Replay widget coverage verifies first/next/latest navigation, timed playback, Pause, safe empty state, and live board/score/move/RNG immutability
- [x] Replay reuses the existing bounded Undo persistence rather than introducing a second unvalidated history format
- [x] Replay production code is included in the configured native build matrix recorded in `docs/VERIFICATION.md`
- [x] Challenge Code codec round-trips supported seeded configurations and reproduces the deterministic opening board/RNG state
- [x] Challenge Codes reject missing seed, Daily mode, malformed/oversized input, unsupported prefixes/shapes, invalid checksums, and unsafe seed bounds
- [x] Challenge Code UI regression coverage verifies deterministic generation/copy, Paste/Validate/preview/start, invalid-input preservation, and recoverable-game replacement cancellation
- [x] Challenge Codes add no cloud/account dependency or persistence key and never import board progress, scores, achievements, settings, Daily history, or Undo data
- [x] Daily Challenge remains excluded from arbitrary Challenge Code seed import
- [x] Game Backup envelope round trip and exclusion of settings/statistics/achievements/Daily/Undo are regression tested
- [x] Game Backup rejects malformed, unsupported-version, missing-game, invalid-timestamp, invalid-GameState, and oversized clipboard text
- [x] Game Backup UI verifies explicit restore confirmation, cancellation without replacement, clipboard export, and malformed-input rejection
- [x] Portable imports are persisted as unranked sessions and cannot mutate lifetime statistics, achievements, streaks, or Daily history
- [x] Imported historical `bestScore` cannot replace the device lifetime record
- [x] Imported terminal state cannot award a local ranked win
- [x] Corrupt/cleared current-game state removes the associated unranked marker
- [x] Normal new local game exits imported unranked policy
- [x] Permanent workflow directory is clean of temporary one-time patch/wiring workflows
- [x] Complete user, architecture, engine, mode, Challenge Code, persistence, backup, privacy, accessibility, development, platform, CI/CD, testing, FAQ, troubleshooting, security, contribution, support, and release documentation is present

The exact latest CI/native evidence for the Challenge Code production state is recorded in [`VERIFICATION.md`](VERIFICATION.md) after Phase 15 verification completes. If production code changes after that evidence, repeat the affected automated gate before release.

## Manual device and interaction qualification

Complete these before promoting to `1.0.0`:

- [ ] Verify core moves, scoring, spawning, win/continue, and no-double-merge behavior through real interaction
- [ ] Verify save/resume across app termination and relaunch on representative devices
- [ ] Verify Undo through long sessions and after challenge transitions
- [ ] Verify Time Challenge and Move Limit behavior on representative devices
- [ ] Verify Daily Challenge across UTC date boundaries where practical
- [ ] Verify statistics and achievements during representative full-game sessions
- [ ] Verify light/dark/system themes, all palettes, and high-contrast switching
- [ ] Verify reduced-motion and platform animation-reduction behavior
- [ ] Verify touch/swipe controls on representative Android and iOS devices
- [ ] Verify keyboard focus, Arrow/WASD controls, H/U/P/Escape/R shortcuts, and window resizing on desktop/web
- [ ] Verify Challenge Codes generate/copy correctly on representative Android, iOS, Web, Windows, macOS, and Linux clipboard environments where supported
- [ ] Verify manual entry and Paste/Validate of a valid Challenge Code on representative platforms
- [ ] Verify invalid prefix, checksum corruption, empty clipboard, and oversized Challenge Code input fail without replacing the current game
- [ ] Verify the decoded Challenge Code preview accurately shows mode, board, target, limits, and seed
- [ ] Verify recoverable-game replacement confirmation from Challenge Codes preserves the current game when cancelled
- [ ] Verify two independent sessions using the same code start on exactly the same board/RNG state
- [ ] Verify the same valid move sequence keeps two same-code sessions deterministic and different moves are allowed to diverge
- [ ] Verify Target Challenge Codes for each supported target choice and at least one Time Challenge, Move Limit, Quick, Extended, Challenge, Endless, and Zen code
- [ ] Confirm Daily Challenge cannot be encoded/opened as an arbitrary Challenge Code and normal date-derived Daily behavior remains unchanged
- [ ] Confirm a Challenge Code starts a fresh normal non-Daily game rather than restoring sender progress
- [ ] Verify Move Replay appears for saved/terminal games as intended and does not replace the normal Continue rule
- [ ] Verify Move Replay first/previous/next/latest controls, slider scrub, Play/Pause, all speed options, bounded-history disclosure, and final-frame behavior on representative real platforms
- [ ] Navigate away from Move Replay while playing and verify no user-visible/background timer behavior remains
- [ ] Compare the live saved game before/after replay viewing and confirm board, score, moves, RNG, statistics, achievements, and Daily history remain unchanged
- [ ] Verify Auto Play Demo navigation, single-step, start/pause/resume, all speed options, deterministic reset, and terminal-state behavior on representative real platforms
- [ ] Navigate away from Auto Play while running and verify no user-visible/background timer behavior remains
- [ ] Confirm Auto Play demo metrics are clearly distinguishable from player scores/statistics during real interaction
- [ ] Verify Game Backup copy produces usable clipboard text on representative Android, iOS, Web, Windows, macOS, and Linux environments where supported
- [ ] Verify valid Game Backup import preview, Cancel, and Restore Unranked Backup using real platform clipboard handlers
- [ ] Verify invalid/empty/oversized backup input displays understandable failure behavior without replacing the current game
- [ ] Verify imported session remains visibly **Continue Unranked Backup** after app termination/relaunch
- [ ] Verify imported-session Undo works for moves made after import while lifetime records remain unchanged
- [ ] Verify imported Classic, Daily, Target, Time Challenge, and Move Limit states reconcile correctly with current engine terminal rules
- [ ] Confirm a portable Daily-configured import cannot create/update trusted Daily history
- [ ] Confirm starting a normal local new game after import restores ordinary ranked/local statistics policy
- [ ] Verify BMC, GitHub, LinkedIn, business/support email, and bug-report destinations using real platform handlers
- [ ] Verify responsive layout at representative small-phone, large-phone, tablet, landscape, desktop, and browser widths
- [ ] Verify native splash/icon presentation on representative targets
- [ ] Verify optional sound/haptic settings on platforms that support the corresponding feedback

## Accessibility qualification

- [ ] Verify board and tile announcements with TalkBack
- [ ] Verify board and tile announcements with VoiceOver
- [ ] Verify a representative desktop/browser screen reader
- [ ] Verify visible focus order and focus recovery around dialogs/navigation
- [ ] Verify Challenge Codes mode/target selection, Generate, selectable code text, Copy, multiline input, Paste, Validate, preview, errors, Start, and replacement confirmation with representative screen readers
- [ ] Verify long Challenge Code text remains selectable/editable/readable with large text and keyboard-only navigation
- [ ] Verify Challenge Code clipboard success/failure and validation feedback are announced understandably without relying on color
- [ ] Verify Move Replay read-only explanation, frame/move metrics, semantic board, slider, first/previous/next/latest controls, Play/Pause, and speed selector with representative screen readers
- [ ] Verify replay playback can be paused immediately and does not create uncontrollable repeated announcements
- [ ] Verify Auto Play controls, demo-state label, board semantics, speed selector, and demo metrics with representative screen readers
- [ ] Verify Game Backup Copy/Import controls, validation messages, candidate preview, Cancel, and Restore Unranked Backup dialog with TalkBack/VoiceOver/desktop screen reader
- [ ] Verify imported/unranked continuation status is understandable without color alone
- [ ] Verify large system text scaling without clipped primary controls, including Challenge Codes, Replay, Auto Play, and Game Backup confirmation screens
- [ ] Verify high contrast and non-color tile-value identification
- [ ] Verify reduced-motion behavior on Replay and Auto Play boards
- [ ] Verify timed challenge updates do not create disruptive repeated announcements

## Distribution and project hygiene

- [ ] Configure real Android distribution signing for the intended store/channel
- [ ] Configure Apple signing/provisioning for real iOS distribution
- [ ] Produce and inspect final store/package artifacts
- [ ] Confirm store privacy/data-safety metadata matches the offline-first implementation, explicit Challenge Code/Game Backup clipboard behavior, persistent local unranked marker, read-only local Replay behavior, and in-memory-only Auto Play sandbox
- [ ] Prepare final screenshots/listing text where required
- [ ] Recheck README, documentation index, CHANGELOG, ROADMAP, version, release notes, `docs/VERIFICATION.md`, and `what_changed.md`
- [ ] Confirm no credentials/private signing material are committed
- [ ] Review dependency/update state deliberately; do not upgrade blindly immediately before release
- [ ] Document any remaining known limitations, including non-cryptographic Challenge Code checksums, same-code divergence after different move sequences, bounded Replay history, plain-JSON clipboard backup, imported-game unranked policy, and the heuristic rather than guaranteed-optimal Auto Play solver
- [ ] Promote version/tag to `1.0.0` only after the stable-release criteria are satisfied
