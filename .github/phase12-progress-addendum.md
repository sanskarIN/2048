

---

## 2026-08-14 — Phase 12 optional Auto Play / AI Demonstration

Phase 12 continues the source prompt's optional-expansion track without changing the release-candidate version from `0.9.0+1`. The implementation follows the specification's explicit Auto Play / AI Demonstration requirements: clear labeling, pause/resume, speed selection, separation from personal statistics/achievements, and algorithm documentation.

### Source requirement implemented

The project master prompt requires an optional demonstration mode that can play automatically using a heuristic or expectimax-style solver while:

- clearly labeling the feature as Auto Play or AI Demo;
- allowing pause/resume;
- allowing speed selection;
- keeping demonstration results separate from legitimate personal statistics/achievements;
- documenting the algorithm in the guide;
- keeping optional advanced work isolated so it does not destabilize the core project.

Phase 12 implements the heuristic form using the already-tested deterministic Hint solver. It does **not** present the feature as machine learning or guaranteed-optimal play.

### Architecture

Added `lib/domain/autoplay_session.dart`.

`AutoplaySession`:

- owns its own `GameConfig`, `GameEngine`, and `GameState`;
- defaults to deterministic seed `2048` and a 4×4 Endless sandbox;
- requests the existing deterministic `GameEngine.hint()` recommendation;
- applies the recommendation only to its own sandbox state;
- tracks its own last direction;
- recreates the seeded engine/state on Reset;
- does not import or depend on `AppController`, SharedPreferences, Flutter UI, analytics, network services, or cloud services.

This creates an explicit boundary between:

- **Hint** — suggestion-only behavior on the player's current game; and
- **Auto Play Demo** — automatic movement only inside an isolated in-memory demonstration session.

The demo has no local-storage key. Closing the screen discards its sandbox state.

### Auto Play user experience

Added `lib/features/solver_demo/solver_demo_screen.dart` and registered route `/solver-demo`.

Home now contains a clearly labeled **Auto Play Demo** entry.

The screen provides:

- title `Auto Play Demo`;
- heading `Deterministic heuristic AI demonstration`;
- explicit explanation that the feature is local heuristic automation rather than machine learning or guaranteed optimal play;
- explicit explanation that it never modifies the player's saved game, lifetime statistics, achievements, or Daily Challenge history;
- demo-only metrics: Demo score, Demo moves, Highest, Last move;
- `Auto Play` / `Pause` control;
- one-move `Step` control;
- `Reset seed` control;
- speed choices of 1, 2, or 4 moves per second;
- periodic autoplay timer that stops on Pause, terminal state, reset, or widget disposal;
- responsive reuse of the accessible `GameBoard` renderer;
- reduced-motion behavior inherited from application settings;
- semantic running/paused/completed state labels.

Changing speed while Auto Play is active safely cancels and recreates the periodic timer at the chosen interval.

### Player-data isolation

The demo intentionally never calls:

- `AppController.newGame()`;
- `AppController.move()`;
- `LocalStore.saveGame()`;
- lifetime-statistics mutation paths;
- achievement unlock paths;
- Daily Challenge history update paths.

The normal player controller may still be read for appearance/reduced-motion settings, but the demonstration game itself is not stored in or written through the player controller.

### Automated tests added

Added `test/autoplay_session_test.dart` covering:

- deterministic reset to the original starting board and RNG state;
- matching seeded sessions producing matching direction, board, score, move-count, and RNG sequences;
- alternate sandbox board size support;
- session behavior remaining outside application persistence/statistics orchestration.

Added `test/solver_demo_screen_test.dart` covering:

- Home navigation into Auto Play Demo;
- clear AI-demonstration labeling;
- single-step execution;
- seed reset;
- player `gamesPlayed`, `totalMoves`, and lifetime `bestScore` remaining unchanged;
- player `AppController.game` remaining null during demo-only operation;
- speed selection from 2 moves/sec to 4 moves/sec;
- Auto Play start;
- Pause availability;
- Pause preventing later timer ticks from advancing the sandbox.

The total automated suite increased from 81 to **86 tests**.

### Documentation updated

Updated:

- `README.md` — Auto Play feature, controls, architecture, privacy/isolation, and no external AI dependency;
- `lib/features/guide/guide_screen.dart` — Auto Play / AI Demo explanation and algorithm boundary;
- `docs/HINT_SOLVER.md` — `AutoplaySession` architecture, controls, determinism, isolation, and tests;
- `docs/ARCHITECTURE.md` — Auto Play domain/feature/persistence boundaries;
- `docs/TESTING.md` — Auto Play domain/widget regression coverage and current 86-test evidence;
- `CHANGELOG.md` — release-facing Auto Play feature and Phase 12 verification evidence;
- `docs/VERIFICATION.md` — current Phase 12 quality/native evidence;
- `docs/RELEASE_CHECKLIST.md` — automated Auto Play checks and remaining real-platform/manual qualification;
- `ROADMAP.md` — heuristic Auto Play marked complete while advanced expectimax/benchmark work remains optional.

### Meaningful Phase 12 commit trail

Key commits include:

- `5bda247947bd6c2582acc0e681be3ae3ef5849a4` — `feat: add isolated deterministic autoplay session`
- `ed57608b1d5f16caf9119e841fdf566891559674` — `test: cover deterministic autoplay session isolation`
- `aac49bd890e7ab0d0bb06120622c2eb0b49bfba4` — `feat: add isolated solver autoplay demo screen`
- `59da74daf76eada3f8021f128c5a50a35e6ad054` — `fix: keep solver demo board extent strongly typed`
- `a03edb96065c6e9b183a23a257482b46a76260a0` — `feat: register solver demo route`
- `ac794af068ef2529d949482f25be346a0254c2ec` — `feat: surface solver demo from home`
- `92feaf2ccbcefee1d35170c6f2d17508c2c0430c` — `test: cover solver demo controls and player data isolation`
- `2d16065c8a74963da491d3098bb72c82a96efc06` — `test: read solver metrics from rendered text widgets`
- `d28041eda59e02edb7fdb93a5d1ce0f76170336d` — `feat: label solver sandbox as auto play demo`
- `e2301c8a60f67548911c36d71edd70217a7ad9fd` — `feat: label sandbox entry as auto play demo`
- `b9905d49b7af6705c4aa00590bbe67f2a9a50022` — `test: align auto play demo labels with specification`
- `d91ea1d5daa8b3f1704df142e3302df2d5080758` — `test: verify auto play speed selection and pause behavior`
- `759cefc23bdc0a3a0ebb723a6992ee0a09a0394a` — `docs: explain solver demo inside the game guide`
- `a1cc17836834750c542c69ffdf3c5e582d4e43ab` — `docs: align guide with auto play demo naming`
- `9389a18a07fbbdecdafde0ebbc2335feb1ea7e39` — `docs: document solver autoplay architecture`
- `c8982c81035936c6e1c81a3c7fe28ad220a9eb64` — `docs: record solver demo isolation boundary`
- `73865d7ef881e9693c3e3a220a606b5ab74b40c7` — `docs: document isolated auto play demo`
- `1d98042558ab7ffe40c9da4ad42dbbf8263dcaf6` — `docs: mark heuristic auto play demo complete`
- `5120cb24c2071b86e44674351dcdf29296b41503` — `style: format Dart sources and tests`
- `5bd36e800d40725980b3a09ec6a94bfb055ee89a` — `docs: add auto play regression coverage`
- `7dd9b35fb5e7d0eff134bdb0fe15b21a6c576ff4` — `docs: record isolated auto play demonstration`
- `269a216aa35ab00ea2018053c63b97c2b0100a82` — `docs: advance verification manifest through auto play phase`
- `865c250ee1bb5fda9e518c6e17eae693e977372a` — `docs: add auto play release qualification checks`

### Transparent intermediate formatting failure

CI run `31778424231` failed at the formatting verification step after the Auto Play source/test files contained Dart-format differences. Static analysis, tests, and Web build were skipped by that run because formatting is intentionally the first gate.

The permanent `Format Dart` workflow run `31778424259` succeeded and produced commit:

`5120cb24c2071b86e44674351dcdf29296b41503` — `style: format Dart sources and tests`

No behavior was hidden or bypassed. The final quality run below verified the formatted state independently.

### Final Phase 12 quality verification

```text
Workflow: CI
Run: 31778558429
Verified commit: 1d98042558ab7ffe40c9da4ad42dbbf8263dcaf6
Flutter: 3.47.0 stable
Dart: 3.13.0
Formatting: PASS — 51 files checked, 0 changed
Static analysis: PASS — No issues found
Automated tests: PASS — 86/86
Web release build: PASS — build/web
WASM dry run: PASS
Overall CI job: SUCCESS
```

The Web build emitted the existing informational CupertinoIcons font lookup warning while still producing `build/web` successfully. The project does not directly reference `CupertinoIcons`.

### Final Phase 12 native build verification

```text
Workflow: Platform Builds
Run: 31778424208
Verified commit: a1cc17836834750c542c69ffdf3c5e582d4e43ab
```

Results:

- Linux release: **SUCCESS**
- Windows release: **SUCCESS**
- macOS release: **SUCCESS**
- iOS release without signing: **SUCCESS**
- Android release APK: **SUCCESS**

The native verified commit contains the Auto Play production code. Later Phase 12 commits changed tests, documentation, naming documentation, or Dart formatting without changing the underlying demo behavior.

The iOS build remains deliberately unsigned. Real Apple signing/provisioning is a manual distribution boundary.

### Phase 12 status

```text
Project: 2048 Nova
Version: 0.9.0+1
Phase: 12 — optional heuristic Auto Play / AI Demonstration implemented

Auto Play architecture: implemented
Auto Play clear labeling: implemented
Pause/resume: implemented
Single-step: implemented
Speed selection: implemented
Deterministic reset: implemented
Player-statistics separation: implemented and tested
Player-save separation: implemented and tested
Daily/achievement separation: architectural boundary documented
Guide/algorithm documentation: implemented
Formatter: PASS
Analyzer: PASS
Automated tests: 86/86 PASS
Web release: PASS
Configured native builds: PASS
```

### Remaining manual boundaries before stable 1.0.0

Phase 12 does not change the existing stable-release boundary. Manual qualification still includes:

- Auto Play navigation, timer start/pause/resume, speed changes, reset, navigation-away cleanup, responsive layout, and reduced-motion behavior on representative real platforms;
- Auto Play board/control/metric semantics with representative real screen readers;
- physical Android/iOS player gameplay and lifecycle/save-resume checks;
- representative touch/orientation/keyboard/focus/large-text/high-contrast/reduced-motion checks;
- long-session Undo, Daily, timed, move-limit, target-win/continue, and restart testing;
- real browser/email external handlers;
- native splash/icon review;
- Android distribution signing;
- Apple signing/provisioning;
- final package/store privacy/listing/screenshot review.

### Next safe optional expansion

The source prompt's remaining Phase 11+ options include replay/move history, export/import saves, shareable seeded challenges, localization readiness, advanced expectimax/benchmark work, and additional PWA/desktop improvements. Any such feature must continue to preserve the verified core, add focused tests, and remain truthful about manual release boundaries.
