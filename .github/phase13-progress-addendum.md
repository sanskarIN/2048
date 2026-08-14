

---

## 2026-08-14 — Phase 13 read-only Move Replay / move-history viewer

Phase 13 implements the source prompt's optional replay/move-history/spectator expansion while preserving the existing `0.9.0+1` release-candidate boundary. The design deliberately reuses the already-validated bounded Undo history instead of adding another persistence schema, and the replay viewer is read-only by construction.

### Replay domain architecture

Added `lib/domain/replay_timeline.dart`.

`ReplayTimeline.build()` receives the authoritative current game plus validated persisted Undo snapshots and creates a spectator timeline by:

1. requiring every retained snapshot to match the current session's start timestamp and complete configuration identity;
2. rejecting snapshots whose moves, merge count, or score represent progress beyond the current game;
3. collapsing duplicate move-number frames;
4. sorting retained frames by move count;
5. making a defensive copy of every retained `GameState`;
6. making the current game the authoritative final frame;
7. returning an unmodifiable list so viewer code cannot replace or append frames.

The timeline comparison includes mode, board size, target, move limit, time limit, seed, and session start time. This protects Replay from stale snapshots that belong to a previous game.

Replay introduces **no new persistence key or schema**. Its storage source remains the existing bounded Undo history plus current game. Because Undo history is intentionally bounded, a very long game's replay may begin at the earliest still-retained snapshot rather than move zero. The UI explicitly discloses this instead of implying a complete lifetime history.

### Replay user experience

Added `lib/features/replay/replay_screen.dart` and route `/replay`.

Home now shows **Move Replay** whenever a saved game exists, including a terminal/lost saved game. This does not change the existing Continue rule: Continue remains hidden for a lost game.

The Replay screen provides:

- title `Move Replay`;
- explicit `Read-only spectator replay` explanation;
- retained Frame, Move, Score, and Highest metrics;
- the same responsive/accessibility-aware `GameBoard` renderer used by gameplay;
- first retained frame navigation;
- previous frame navigation;
- next frame navigation;
- latest/current frame navigation;
- slider scrubbing across retained frames;
- `Play Replay` / `Pause Replay`;
- 1, 2, or 4 frames per second playback choices;
- frame status and merge count;
- safe empty state when the route is opened without a current game;
- safe load-error state with Retry;
- bounded-history explanation when the earliest retained move is later than move zero;
- timer cancellation on Pause, end-of-timeline, and widget disposal.

Playback/scrubbing operate only on defensive frame copies. The screen never calls `AppController.move`, `AppController.undo`, player save mutation, statistics mutation, achievement mutation, or Daily history mutation.

### Replay automated coverage

Added `test/replay_timeline_test.dart` covering:

- active-session filtering;
- stale-session rejection;
- future move/merge/score rejection;
- chronological ordering;
- duplicate move-number collapse;
- current frame authority;
- defensive copied boards/state;
- unmodifiable returned frame list.

Added `test/replay_screen_test.dart` covering:

- Home navigation into Move Replay;
- first/next/latest frame navigation;
- live game board remaining unchanged while replay frames are viewed;
- live game score remaining unchanged;
- live game move count remaining unchanged;
- live RNG state remaining unchanged;
- timed playback advancing frames;
- Pause stopping later timer ticks;
- safe empty route behavior when no current game exists.

The total automated suite increased from 86 to **92 tests**.

### Transparent intermediate Replay CI failure

CI run `31779369661` passed formatting and static analysis but completed the test step with:

```text
90 tests passed
2 tests failed
```

Both failures were in Replay widget tests. The tests attempted to tap `Next frame` and `Play Replay` while those controls were below Flutter's default 800×600 widget-test viewport. The production Replay body is intentionally scrollable, so the taps missed their targets rather than exposing a production Replay logic failure.

Commit:

`501b2a512c2f185461129f2e294504e43e883d59` — `test: scroll replay controls before widget taps`

changed the tests to scroll the controls into view before tapping them. The final 92-test gate then passed. This real intermediate failure remains documented instead of being hidden behind the later successful run.

### Phase 13 formatting work

The permanent Format Dart workflow produced formatting commits during the early Replay source/test sequence:

- `4f86cb5e363f76e936e7d2db5198d0fe40790772` — `style: format Dart sources and tests`
- `33e7f59c1ddc4326ec07545937a3412a2796e107` — `style: format Dart sources and tests`

The final quality gate independently confirmed that all 55 Dart source/test files were formatter-clean with 0 changes required.

### Final Phase 13 quality verification

```text
Workflow: CI
Run: 31779838751
Verified commit: 278ba039d0b7b59ce54c72c5ed0fcd0401ba537a
Flutter: 3.47.0 stable
Dart: 3.13.0
Formatting: PASS — 55 files checked, 0 changed
Static analysis: PASS — No issues found
Automated tests: PASS — 92/92
Web release build: PASS — build/web
WASM dry run: PASS
Overall CI job: SUCCESS
```

The Web build emitted the existing informational CupertinoIcons font lookup warning while still producing `build/web` successfully. The project does not directly reference `CupertinoIcons`.

The dependency resolver also continued to report newer versions outside the current constraints (`flutter_lints` 6.0.0, `lints` 6.1.0, `material_color_utilities` 0.13.1, and `test_api` 0.7.13). They were not blindly upgraded during Replay hardening because the verified release-candidate dependency state remains stable and Dependabot review is separate from feature implementation.

### Final Phase 13 native release-build verification

The final Replay production/UI state requiring native compilation was:

`4f3cc6f55ae6b2f50b4758db22569b7ec48ddafd` — `docs: explain read-only move replay in game guide`

Although that commit message is documentation-oriented, the guide lives under `lib/` and is compiled into the application; it also contains all preceding Replay production code.

Native matrix:

```text
Workflow: Platform Builds
Run: 31779566057
Verified production commit: 4f3cc6f55ae6b2f50b4758db22569b7ec48ddafd
```

Results:

- Linux release: **SUCCESS**
- Windows release: **SUCCESS**
- Android release APK: **SUCCESS**
- macOS release: **SUCCESS**
- iOS release without signing: **SUCCESS**

The Apple build remains intentionally unsigned. Real signing/provisioning credentials are not committed to the repository.

### Phase 13 documentation updated

Updated:

- `README.md` — Move Replay feature, read-only/bounded-history behavior, architecture, privacy, and accessibility wording;
- `lib/features/guide/guide_screen.dart` — Move Replay usage, controls, bounded-history disclosure, and immutability guarantee;
- `docs/ARCHITECTURE.md` — Replay domain, feature, persistence, and session boundaries;
- `docs/TESTING.md` — Replay domain/widget coverage, transparent intermediate failure, final 92-test evidence, and native matrix;
- `docs/ACCESSIBILITY.md` — Replay board/slider/control/manual screen-reader qualification;
- `docs/PRIVACY.md` — Replay defensive-copy/local-only behavior and Auto Play sandbox privacy boundary;
- `docs/RELEASE_CHECKLIST.md` — Replay automated/manual/accessibility qualification items;
- `docs/VERIFICATION.md` — current Phase 13 quality/native evidence and historical progression;
- `CHANGELOG.md` — release-facing Replay feature, fixes, and objective verification evidence;
- `ROADMAP.md` — bounded read-only Move Replay marked implemented; full-session export/import remains later optional work.

### Meaningful Phase 13 commit trail

Key commits include:

- `8499b1498d696240447fa06002414d75b1a0d22f` — `feat: add read-only replay timeline builder`
- `6285eb415516dcfc0c419e464e1863ef209b086b` — `test: cover replay timeline filtering and immutability`
- `4f86cb5e363f76e936e7d2db5198d0fe40790772` — `style: format Dart sources and tests`
- `fc83fe07c924710e3087e60da783565f89f1003e` — `feat: add read-only move history replay screen`
- `bfc9358b96790aa47caa422a152983642f5c63ea` — `feat: register move replay route`
- `7afeedfdbd5d9e4de2b11576b33bccc3cc8d1f77` — `feat: surface read-only replay for saved games`
- `33e7f59c1ddc4326ec07545937a3412a2796e107` — `style: format Dart sources and tests`
- `6f845c6deb222ff6f86dda4c42291204e84a425f` — `fix: keep replay frame index strongly typed`
- `26316479c1762086a6c3787302f282dc833e2ea7` — `test: cover read-only replay controls and game isolation`
- `0f761c0531cd47faaccb779c420e32aef33ead93` — `test: keep replay fixture shifts strongly typed`
- `7d4ffc376d6a10e4829a6b02c862f2ca533b0f98` — `test: navigate replay route through navigator state`
- `501b2a512c2f185461129f2e294504e43e883d59` — `test: scroll replay controls before widget taps`
- `4f3cc6f55ae6b2f50b4758db22569b7ec48ddafd` — `docs: explain read-only move replay in game guide`
- `385538c838fb1b60a247c600ceb6c2434cc8737b` — `docs: record read-only replay architecture boundary`
- `6d10635453da3d82671283acc434b07ca30fb417` — `docs: mark read-only move replay implemented`
- `05a9563fac3d84ca497c65995bbc711286647a18` — `docs: document read-only move replay feature`
- `1b9c3612bb1438971febaccc9a5d07f86d8d5b3d` — `docs: add replay accessibility qualification`
- `aac83f90d635e8056cc21ceca50189ad2daeb391` — `docs: add read-only replay regression strategy`
- `278ba039d0b7b59ce54c72c5ed0fcd0401ba537a` — `docs: add move replay release qualification checks`
- `ff3cde390b88f4d0a1bc2d2a7d0a7c6e56eecd97` — `docs: clarify replay and auto play local data boundaries`
- `9ff2be684df1c166156f58ac0a07ee70ff446d0e` — `docs: record final replay quality gate`
- `096368e2f6048fe3ec8df917ad59e5676804f26c` — `docs: advance verification manifest through move replay phase`
- `b1970f2e378a6edeaef0fbe4ce160d40af928b42` — `docs: record read-only move replay and verification`

The repository continues to use meaningful small Conventional Commits; no-op commit spam was not used merely to inflate commit count.

### Updated release-candidate state after Phase 13

```text
Project: 2048 Nova
Version: 0.9.0+1
Phase: 13 — read-only Move Replay implemented

Core engine: implemented and hardened
Save/resume + deterministic Undo: implemented and hardened
Daily Challenge: implemented and hardened
Statistics/achievements: implemented
Accessibility foundations: implemented and expanded
Heuristic Hint: implemented and deterministic
Auto Play Demo: implemented, isolated, and verified
Move Replay: implemented, read-only, bounded, and verified
Formatter: PASS
Analyzer: PASS
Automated tests: 92/92 PASS
Web release build: PASS
Configured native release builds: PASS
```

### Remaining manual boundaries before stable `1.0.0`

Phase 13 does not remove the existing manual stable-release qualification. Remaining work includes:

- physical Android/iOS gameplay, lifecycle, background/foreground, termination, and save-resume checks;
- real-platform Move Replay slider/first/previous/next/latest/play/pause/speed behavior;
- Replay navigation-away timer cleanup and comparison of saved state before/after real interaction;
- Replay bounded-history wording and layout on long retained timelines;
- Replay control/slider/board semantics with VoiceOver, TalkBack, and representative desktop/browser screen readers;
- real-platform Auto Play timer/start/pause/resume/speed/reset/navigation-away behavior;
- representative touch, orientation, keyboard, focus, large-text, high-contrast, and reduced-motion checks;
- long-session Undo, Daily, timed, move-limit, target-win/continue, and restart testing;
- real external browser/email handlers;
- native splash/icon visual review;
- Android distribution signing;
- Apple signing/provisioning;
- final package/store privacy/data-safety/listing/screenshot review.

### Next safe optional expansion

The remaining source-listed optional expansion areas include validated save export/import, shareable seeded challenge codes, localization readiness, advanced solver benchmarking behind the existing isolated Auto Play boundary, golden/visual-regression matrices, and additional PWA/desktop convenience work. Any next phase must remain isolated, tested, and truthful about manual/device boundaries.
