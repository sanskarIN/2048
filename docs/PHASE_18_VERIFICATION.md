# Phase 18 Verification — Bounded Expectimax and Solver Benchmarks

This file is the focused verification record for the Phase 18 advanced-solver release-candidate work. The canonical cross-phase record remains [`VERIFICATION.md`](VERIFICATION.md).

## Qualified scope

Phase 18 adds advanced automated solving only behind the existing isolated Auto Play Demo boundary:

- bounded deterministic `ExpectimaxSolver`;
- player/chance search using every empty-cell spawn position and the game probabilities: tile `2` at 90%, tile `4` at 10%;
- explicit default limits of depth 2 and 50,000 explored nodes;
- non-mutating hypothetical board search with no RNG consumption during evaluation;
- `AutoplayStrategy.heuristic` and `AutoplayStrategy.expectimax`;
- strategy switching that preserves sandbox board/score/moves/RNG while clearing only decision diagnostics;
- visible expectimax explored-node diagnostics;
- reusable deterministic `SolverBenchmark` library;
- `dart run tool/solver_benchmark.dart` CLI harness;
- English/Hindi strategy UI and updated in-app Guide/About copy;
- 17 focused regression additions over the Phase 17 total.

Normal player Hint remains the existing fast read-only heuristic and never invokes expectimax.

## Final maintained CI gate

The final test-only correction commit is:

```text
b114255b6f510f0e7ba8d0516e9a30eebf4451b8
fix: import solver demo language enum
```

Permanent CI evidence:

```text
Workflow: CI
Run: 31869835223
Job: 94976646621
Result: SUCCESS
Date: 2026-08-15
Runner: ubuntu-24.04
Flutter: 3.47.0 stable
Dart: 3.13.0
DevTools: 2.60.0
Dependency resolution: PASS
Dart formatting: PASS — 80 files, 0 changed
Flutter analyze: PASS — No issues found
Automated tests: PASS — 161/161
Flutter Web release build: PASS — build/web produced
Flutter Web WASM dry run: PASS
```

Phase 18 therefore moved the complete regression total from 144 to 161, exactly matching the 17 focused additions recorded for expectimax, strategy isolation, benchmark behavior, widget integration, and Hindi localization.

The Web compiler again emitted the existing non-fatal Cupertino icon-font availability warning while still producing `build/web`. It is recorded as a warning, not misrepresented as a build failure.

## Current runtime native matrix

The final runtime-source commit intentionally used to trigger the maintained native matrix is:

```text
e324882fc861e9e4221020aabb00515c7366a6f7
docs: clarify autoplay strategy isolation in source
```

The later `b114255...` commit changes only a test import, so the runtime application source verified by the native matrix is unchanged.

```text
Workflow: Platform Builds
Run: 31869794809
Result: SUCCESS

Linux release
  Job: 94976574317
  flutter build linux --release: PASS

Android release APK
  Job: 94976574376
  flutter build apk --release: PASS

Windows release
  Job: 94976574323
  flutter build windows --release: PASS

macOS and unsigned iOS release
  Job: 94976574495
  flutter build macos --release: PASS
  flutter build ios --release --no-codesign: PASS
```

This is the latest hosted multi-platform compilation evidence for 2048 Nova and supersedes the Phase 17 matrix as the current native-build record.

## Acceptance failures retained for auditability

### Attempt 1 — duplicate localization key and benchmark CLI lints

```text
Commit: 959f8a230484b0cbdf0e028eabbbe4847ef51d41
CI run: 31869526679
Formatting: PASS — 79 files, 0 changed
Static analysis: FAIL — 9 issues
Tests: skipped
Web build: skipped
```

Static analysis found:

- one duplicate constant-map key for the Hindi `Strategy` translation;
- eight `avoid_print` findings in `tool/solver_benchmark.dart`.

The CLI was corrected to use `dart:io` `stdout.writeln`; the duplicate Phase 18 `Strategy` entry was removed so the pre-existing `Strategy` → `रणनीति` mapping remains the single translation source.

### Attempt 2 — missing test import

The final runtime-source commit triggered a second maintained CI gate:

```text
Commit: e324882fc861e9e4221020aabb00515c7366a6f7
CI run: 31869794852
Job: 94976548162
Formatting: PASS — 80 files, 0 changed
Static analysis: FAIL — 1 issue
Tests: skipped
Web build: skipped
```

The only issue was `Undefined name 'AppLanguage'` in `test/solver_demo_localization_test.dart`, caused by a missing localization import in the new test harness. Production solver/runtime source was not implicated. Commit `b114255b6f510f0e7ba8d0516e9a30eebf4451b8` added the correct import, after which CI `31869835223` passed all 161 tests and Web/WASM verification.

## Focused regression additions

Phase 18 adds:

```text
test/expectimax_solver_test.dart          6 tests
test/autoplay_strategy_test.dart          5 tests
test/solver_benchmark_test.dart           3 tests
test/solver_demo_screen_test.dart         +1 test
test/localization_test.dart               +1 test
test/solver_demo_localization_test.dart    1 test
-------------------------------------------------
Total Phase 18 additions                  17 tests
```

Coverage verifies deterministic/legal search, terminal no-move handling, board immutability, node-budget enforcement, larger-board support, malformed-board rejection, strategy-switch state preservation, seeded expectimax reproducibility, bounded decision diagnostics, reset behavior, deterministic benchmark summaries, heuristic zero-search-node accounting, benchmark validation, trusted-state UI isolation, Hindi catalog strings, and Hindi strategy UI.

## Trust and performance boundary

Expectimax and benchmark code do not depend on `AppController`, `LocalStore`, SharedPreferences, accounts, analytics, network services, or remote AI. Search runs on copied in-memory sandbox boards and does not update trusted player saves, lifetime statistics, per-mode records, achievements, streaks, or Daily Challenge history.

The explicit search depth/node budget is a deterministic work bound, not a claim that every device will have identical wall-clock performance. Real low-end-device responsiveness remains a manual release check.

## Release boundary

These green automated and hosted native-build gates qualify the Phase 18 source/test/runtime candidate. They do **not** by themselves promote the project to stable `1.0.0`.

Stable release still requires the manual checks listed in [`ROADMAP.md`](../ROADMAP.md) and [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md), including physical-device lifecycle/gameplay, real assistive-technology behavior, solver responsiveness on representative slower devices, real clipboard/platform handlers, native branding review, signing/provisioning, and store metadata/review.
