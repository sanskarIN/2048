# Verification Record

This document records objective automated evidence for the current 2048 Nova release-candidate line. It distinguishes formatter/analyzer/test/Web verification, native compilation evidence, transparent intermediate failures, and manual release boundaries.

## Phase 24 — Version 1.5 current line and hosted native matrix

Date: **2026-08-16**

Current Version 1.5 package/runtime metadata:

```text
Package: 1.5.0+15
Marketing/runtime version: 1.5.0
```

Permanent quality source:

```text
Commit: 4d4fe634624b069834786a2aaad356e356281c44
CI run: 31940994228
CI job: 95150049412
Result: SUCCESS
Runner: Ubuntu 24.04.4 LTS
Flutter: 3.47.0 stable
Dart: 3.13.0
DevTools: 2.60.0
Flutter metadata drift: PASS
Formatting: PASS — 98 files, 0 changed
Static analysis: PASS — No issues found
Tests: PASS — 211/211
Candidate readiness: PASS — candidateGatePassed=true; readyForStable=false; 0/13 manual evidence complete
Stable promotion boundary: PASS — strict stable mode correctly remained closed with incomplete real-world evidence
Solver smoke benchmark: PASS
WASM dry run: PASS
Missing icon-font warning guard: PASS
Web release: PASS — build/web
```

Version 1.5 hosted native matrix:

```text
Commit: 4d4fe634624b069834786a2aaad356e356281c44
Platform Builds run: 31940994252
Android job 95150049652: SUCCESS
Linux job 95150049660: SUCCESS
Windows job 95150049634: SUCCESS
macOS + unsigned iOS job 95150049606: SUCCESS
Artifact count: 5
```

Accepted hosted artifact archives:

| Artifact | ID | Size | GitHub artifact digest |
| --- | ---: | ---: | --- |
| `nova-2048-android-release` | 9262064041 | 25,409,571 bytes | `sha256:777c912745e7c3fdbdbe6f682699e0edbee9d32e0144dd3d7e72c87f25a5bd00` |
| `nova-2048-linux-x64-release` | 9262027429 | 10,396,713 bytes | `sha256:187975b54ec73f23b49fc8e50f6cd7c5f2e044f551ce153603c13cd75273422a` |
| `nova-2048-windows-x64-release` | 9262041028 | 12,655,269 bytes | `sha256:5d53a9c534b3327b5881087b2f5a9c2d744b841de70e20f9e05115f1f8f18ac1` |
| `nova-2048-macos-release` | 9262077872 | 18,739,219 bytes | `sha256:15cb2d98188fcd0718c382244be0f527a41b5799fc59d5cef57173b2be10097f` |
| `nova-2048-ios-unsigned-release` | 9262078294 | 8,710,168 bytes | `sha256:b09afe7ae21b7563d5407e80de17458e2e5d66e557b591db6aea47bca5b6ac1c` |

All five artifacts expire on **2026-08-30** under the 14-day retention policy. Each job also produced the repository-workflow payload SHA-256 sidecar described in `RELEASE_ARTIFACTS.md`.

This matrix is objective hosted compilation/package evidence. It does **not** mark any real-world qualification item passed. Physical Android/iOS testing, representative input/responsive checks, assistive-technology passes, long sessions, real-target transport/import flows, external handlers, native branding review, and production signing/provisioning/store metadata remain governed by `release_qualification.json`, which is still **0/13** complete.

## Phase 23 — Reproducible metadata, warning-free Web, and retained native artifacts

Date: **2026-08-16**

Final Phase 23 quality source:

```text
Commit: 1f48ebc947596915be3104aa5da56eb6ad291fff
CI run: 31934616568
CI job: 95134494782
Result: SUCCESS
Runner: Ubuntu 24.04.4 LTS
Flutter: 3.47.0 stable
Dart: 3.13.0
DevTools: 2.60.0
Flutter metadata drift: PASS — pubspec.lock + analysis_options.yaml unchanged by pub get
Formatting: PASS — 98 files, 0 changed
Static analysis: PASS — No issues found
Tests: PASS — 208/208
Candidate readiness: PASS — candidateGatePassed=true; readyForStable=false; 0/13 manual evidence complete
Stable promotion boundary: PASS — strict stable mode correctly rejected current 0.9.0+1
Solver smoke benchmark: PASS
WASM dry run: PASS
Missing icon-font warning guard: PASS
Explicit CI dispatch: PASS — workflow_dispatch is present and regression guarded
Web release: PASS — build/web
```

The Web log now contains a real tree-shaken `CupertinoIcons.ttf` asset instead of the earlier `Expected to find fonts for ... CupertinoIcons` warning. CI would fail if that warning reappeared.

Accepted native artifact source:

```text
Commit: 5b22795d5aba661bd587e7bcbf2ae6442c8b4b3a
Platform Builds run: 31934181987
Linux job 95133491351: SUCCESS
Android job 95133491378: SUCCESS
Windows job 95133491405: SUCCESS
macOS + unsigned iOS job 95133491379: SUCCESS
```

All generated-dependency synchronization checks, release builds, package/checksum steps, and artifact uploads passed. Five artifacts were retained for 14 days: Android `9260209072`, Linux `9260177318`, Windows `9260197932`, macOS `9260232848`, and unsigned iOS `9260233269`. Exact sizes/digests are recorded in [`RELEASE_ARTIFACTS.md`](RELEASE_ARTIFACTS.md).

Phase 23 also repaired generated macOS registration for `file_picker`, made the Flutter 3.47 analysis migration explicit in source, synchronized dependency locking, and moved repository-owned checkout usage to v6. These are release/build/integration changes; the 13 real-world qualification entries remain pending and are not converted into manual evidence by hosted builds.



## Phase 22 — Release-gate regression expansion (current automated source)

Date: **2026-08-16**

The release-readiness CLI now supports isolated fixture roots and is protected by six process-level regression tests. This is the current automated source for Phase 22 and supersedes the earlier 194-test count while preserving that earlier run as historical implementation evidence.

```text
Commit: 57c6312ee26eed0cea8597ebf6417d442cf988cc
CI run: 31932367464
CI job: 95129044532
Result: SUCCESS
Runner: Ubuntu 24.04.4 LTS
Flutter: 3.47.0 stable
Dart: 3.13.0
DevTools: 2.60.0
Formatting: PASS — 97 files, 0 changed
Static analysis: PASS — No issues found
Tests: PASS — 200/200
Release-gate fixture cases: PASS — 6/6
Candidate readiness: PASS — candidateGatePassed=true; readyForStable=false; manualChecksPassed=0/13
Stable promotion boundary: PASS — strict stable mode correctly rejected the live 0.9.0+1 RC
Solver benchmark smoke: PASS — both strategies, four deterministic seeds, eight moves each
Web release: PASS — build/web
WASM dry run: PASS
```

The six new cases prove both acceptance and rejection branches: candidate success, fully qualified synthetic stable success, pending-evidence refusal, version mismatch refusal, evidence-completeness refusal, and missing-ID refusal. Synthetic stable success demonstrates that the gate can open when its declared conditions are satisfied; it is not evidence that the real project has completed those conditions.

The live manifest remains at **0/13** completed manual checks. No physical-device, screen-reader, external-handler, branding, signing/provisioning, or store qualification is inferred from this CI run. The Phase 21 native runtime matrix remains the latest native evidence because no Flutter gameplay/runtime code changed here.

## Phase 22 — Evidence-backed stable-release promotion gate

Date: **2026-08-16**

Accepted maintained CI source:

```text
Commit: 86aaddeb6cfcbfef45c86889060ec5313fdbab31
CI run: 31932018261
CI job: 95128223530
Result: SUCCESS
Runner: Ubuntu 24.04
Flutter: 3.47.0 stable
Dart: 3.13.0
DevTools: 2.60.0
Formatting: PASS — 96 files, 0 changed
Static analysis: PASS — No issues found
Tests: PASS — 194/194
Candidate readiness: PASS
Stable promotion boundary: PASS — strict stable mode correctly rejected the current RC
Solver smoke benchmark: PASS — Heuristic + Expectimax, seeds 2048/4096/8192/20260815, 8 moves each
Web release: PASS — build/web
WASM dry run: PASS
```

Candidate-gate output on the accepted source reported `candidateGatePassed=true`, `readyForStable=false`, and **0/13** required manual evidence items passed. The CI then deliberately invoked strict stable mode and required it to fail; it correctly rejected version `0.9.0+1`, the absence of a `[1.0.0]` changelog section, and every still-pending manual evidence item. The workflow treats that expected refusal as a passing assertion, so a future accidental weakening of the boundary fails CI.

Phase 22 changes release engineering and documentation only; it does not alter Flutter gameplay/runtime behavior. Therefore the latest native runtime build evidence remains the Phase 21 Android/Linux/Windows/macOS/unsigned-iOS matrix. Physical-device, real screen-reader, external-handler, native-branding, signing/provisioning, and store metadata checks remain unqualified until genuine evidence is recorded in `release_qualification.json`.

## Phase 21 — Offline Challenge Code QR rendering and current-source matrix

Date: **2026-08-15**

Final accepted runtime source:

```text
Commit: 2678e65824ca088c4ba93342bc8737fc18ec7708
CI run: 31877515001
CI job: 94995319221
Result: SUCCESS
Runner: Ubuntu 24.04
Flutter: 3.47.0 stable
Dart: 3.13.0
DevTools: 2.60.0
Formatting: PASS — 94 files, 0 changed
Static analysis: PASS — No issues found
Tests: PASS — 194/194
Web release: PASS — build/web
Web WASM dry run: PASS
```

Fresh hosted native matrix on the same source:

```text
Platform Builds run: 31877514960
Result: SUCCESS
Android release APK: PASS — job 94995348734
Linux release: PASS — job 94995348682
Windows release: PASS — job 94995348743
macOS release: PASS — job 94995348674
unsigned iOS release: PASS — job 94995348674
```

Phase 21 adds presentation-only, offline QR rendering for the exact existing `NOVA1` Challenge Code text. It does not add in-app scanning, camera permission, networking, cloud transfer, a second portable protocol, or any trusted-progress path. The project keeps selectable/copyable text next to the QR, uses fixed black-on-white scan contrast, caps normal QR size at 260 logical pixels, respects narrower parent constraints, and localizes QR semantics/trust copy in English/Hindi.

Phase 21 adds five net tests to the Phase 20 total of 189. The first source-freeze CI `31877417527` failed at formatting because Dart 3.13 identified 32 existing/new source-test files requiring canonical formatting. Maintained formatter run `31877417558`, job `94995089435`, created `03f26863462609b3b7ff33b0bce81640580fbe18`; the final meaningful source trigger `2678e658...` then passed all permanent gates.

The existing non-fatal Cupertino icon-font availability warning remained visible during Web compilation while `build/web` completed successfully. Hosted compilation does not replace optical QR scanning, physical-device/accessibility, signing/provisioning, or store qualification.

Focused details: [`PHASE_21_VERIFICATION.md`](PHASE_21_VERIFICATION.md).

## Phase 20 - File-Based Game Backup and current-source plugin matrix

Date: **2026-08-15**

Final accepted runtime source:

```text
Commit: 188e81c607eca76516018be8c668eab41b777cc1
CI run: 31875447398
CI job: 94990368739
Result: SUCCESS
Flutter: 3.47.0 stable
Dart: 3.13.0
DevTools: 2.60.0
Formatting: PASS - 91 files, 0 changed
Static analysis: PASS - No issues found
Tests: PASS - 189/189
Web release: PASS - build/web
Web WASM dry run: PASS
```

Fresh hosted native matrix on the same source:

```text
Platform Builds run: 31875447417
Result: SUCCESS
Android release APK: PASS - job 94990368847
Linux release: PASS - job 94990368919
Windows release: PASS - job 94990368886
macOS release: PASS - job 94990368933
unsigned iOS release: PASS - job 94990368933
```

The first final-source matrix `31875177571` failed Android only because `file_picker 11.0.2` was not being compiled into generated plugin registration with the host's AGP-9 built-in-Kotlin flag disabled. Linux, Windows, macOS, and unsigned iOS passed that run. Commit `188e81c607eca76516018be8c668eab41b777cc1` enabled `android.builtInKotlin=true`; the complete fresh matrix above then passed all configured targets.

Phase 20 adds explicit user-selected `.nova2048` / `.json` Game Backup file transport with pre-decode byte bounds, strict UTF-8, the existing version-1 backup decoder, explicit confirmation, and the unchanged persistent unranked import policy. It adds six focused tests over the Phase 19 total of 183.

Focused details: [`PHASE_20_VERIFICATION.md`](PHASE_20_VERIFICATION.md).

## Phase 19 repository-audit correction

Phase 19's earlier clean behavioral gate remains valid:

```text
Commit: 4a16608c9f8e94de529ef79ca5d213a81b66baae
CI run: 31871817119
CI job: 94981543084
Result: SUCCESS
Flutter: 3.47.0 stable
Dart: 3.13.0
DevTools: 2.60.0
Formatting: PASS - 88 files, 0 changed
Static analysis: PASS - No issues found
Tests: PASS - 183/183
Web release: PASS
Web WASM dry run: PASS
```

A later Phase 19 final-recorder run `31873308985` failed, final-source CI `31873227162` was cancelled, and stale temporary Phase 19 helpers were found and removed at the start of Phase 20. Those later failed/cancelled runs are not represented as successful Phase 19 acceptance evidence. Phase 20's native matrix compiles the accumulated runtime including Phase 19 code but is not relabeled as a Phase 19 focused matrix.

## Phase 18 — Bounded Expectimax and solver benchmarks

Date: **2026-08-15**

Final maintained automated evidence:

```text
Final CI commit: b114255b6f510f0e7ba8d0516e9a30eebf4451b8
CI run: 31869835223
CI job: 94976646621
Result: SUCCESS
Flutter: 3.47.0 stable
Dart: 3.13.0
DevTools: 2.60.0
Formatting: PASS — 80 files, 0 changed
Static analysis: PASS — No issues found
Tests: PASS — 161/161
Web release: PASS
Web WASM dry run: PASS

Runtime native commit: e324882fc861e9e4221020aabb00515c7366a6f7
Platform Builds run: 31869794809
Result: SUCCESS
Android APK: PASS — job 94976574376
Linux: PASS — job 94976574317
Windows: PASS — job 94976574323
macOS: PASS — job 94976574495
unsigned iOS: PASS — job 94976574495
```

The later final CI commit changes only a test import, so the runtime application tree covered by the native matrix is unchanged. Phase 18 adds 17 focused tests to the Phase 17 total of 144. Normal Hint remains heuristic-only; bounded Expectimax and deterministic benchmarking remain isolated from trusted player state.

Transparent acceptance failures are retained: CI `31869526679` caught one duplicate Hindi map key and eight benchmark-CLI `avoid_print` lints; CI `31869794852` later caught a missing `AppLanguage` import in the Hindi solver widget test. Both were corrected before the final 161-test green gate.

The Web build continued to emit the existing non-fatal Cupertino icon-font availability warning while successfully producing `build/web`. Hosted compilation does not replace physical-device/accessibility/performance/signing/store qualification.

Focused details: [`PHASE_18_VERIFICATION.md`](PHASE_18_VERIFICATION.md).


## Phase 17 — Current-source CI and native matrix

Date: **2026-08-15**

A final `lib/**` source-documentation commit was used to qualify the complete current runtime tree after the Phase 17 parser correction. This closes the gap where an earlier native matrix predated that parser fix.

```text
Commit: d33d65840aff67c4e9bf69ad203f46b85146093c
CI run: 31867788776
CI job: 94971490776
Result: SUCCESS
Flutter: 3.47.0 stable
Dart: 3.13.0
DevTools: 2.60.0
Formatting: PASS — 74 files, 0 changed
Static analysis: PASS — No issues found
Tests: PASS — 144/144
Web release: PASS
Web WASM dry run: PASS
```

Fresh hosted native matrix:

```text
Platform Builds run: 31867788753
Result: SUCCESS
Android release APK: PASS — job 94971490848
Linux release: PASS — job 94971490809
Windows release: PASS — job 94971490788
macOS release: PASS — job 94971490875
unsigned iOS release: PASS — job 94971490875
```

This evidence covers the runtime tree containing the final per-mode-record deserializer, trusted update policy, Statistics presentation, and all 144 tests. Hosted compilation remains separate from physical-device, accessibility, signing/provisioning, and store qualification.

## Phase 17 — Trusted per-mode records

Date: **2026-08-15**

Authoritative maintained gate:

```text
Commit: c443f9fde0cc243269be57515772378c06284e86
CI workflow run: 31867499047
CI job: 94970781061
Result: SUCCESS
Runner: ubuntu-24.04
Flutter: 3.47.0 stable
Dart: 3.13.0
DevTools: 2.60.0
Formatting: PASS — 74 files, 0 changed
Static analysis: PASS — No issues found
Automated tests: PASS — 144/144
Flutter Web release build: PASS
Flutter Web WASM dry run: PASS
```

Phase 17 added ten focused tests on top of the Phase 16 total of 134. Coverage includes per-mode record serialization/backward compatibility, ranked migration/tracking/reset behavior, imported-backup exclusion, locally seeded ranking behavior, and English/Hindi Statistics UI.

Acceptance history is intentionally retained:

- CI `31867316152` failed static analysis because `mode_record_serialization_test.dart` contained an unused local variable. Commit `f42a8ab18edd4661a066419de0daa84a2ce22f85` removed it.
- CI `31867370893` passed formatting/analysis but finished 142 passed / 2 failed because the Statistics widget tests searched for board-size and target metadata as separate `Text` widgets even though production intentionally renders one combined subtitle. Commit `c443f9fde0cc243269be57515772378c06284e86` aligned the tests with the production component contract.
- CI `31867499047` passed all 144 tests and the Web/WASM build gate.

The Web build emitted a non-fatal Cupertino icon-font availability warning but still produced `build/web`. This automated result does not replace physical-device, assistive-technology, signing/provisioning, or store-metadata qualification. The Phase 17 current-source matrix superseded Phase 16 at that time; the newer Phase 18 matrix recorded above is now the latest hosted multi-platform build evidence.

Focused details: [`PHASE_17_VERIFICATION.md`](PHASE_17_VERIFICATION.md).


## Phase 16 — Offline English/Hindi localization

### Final permanent quality gate

```text
Workflow: CI
Run: 31806785165
Verified commit: 9dea87e73803d83c3aa0614d35f7860773dbca04
Conclusion: SUCCESS
Flutter: 3.47.0 stable
Dart: 3.13.0
Formatting: PASS — 70 files, 0 changed
Static analysis: PASS — No issues found
Automated tests: PASS — 134/134
Web release build: PASS — build/web
WASM dry run: PASS
```

Phase 16 adds seven focused localization tests to the Phase 15 total of 127. The tests cover language parsing/recovery, Hindi catalog behavior, English fallback, dynamic helpers, persistence, Hindi Home/Settings UI, and Hindi board semantics. The final suite also verifies that every pre-existing feature harness continues to pass with production-like localization delegates.

### Final runtime native matrix

```text
Workflow: Platform Builds
Run: 31804713200
Verified production localization commit: 5048486775b0c9702583f348bfc5be71219e83ae
Conclusion: SUCCESS
```

- Windows release job `94780817747` — **PASS**
- Linux release job `94780817828` — **PASS**
- Android release APK job `94780817929` — **PASS**
- macOS + unsigned iOS job `94780818361` — **PASS**

The Apple job deliberately uses unsigned iOS verification. Signing/provisioning remains outside public CI.

### Localization verification boundary

Automated evidence establishes that the tested repository state supports persisted System/English/Hindi selection, uses Flutter's official framework delegates, safely falls back from malformed/unsupported stored language values, renders representative Hindi UI/semantics, retains all previous deterministic/trust boundaries, builds Web, and compiles the runtime localization state on every configured native runner.

It does **not** establish complete real-device Hindi font/layout quality, every text-scale/device-size combination, Hindi pronunciation on real screen readers, store metadata localization, or physical-device lifecycle/clipboard/focus behavior. Those remain manual release checks.

### Transparent intermediate failures

- `31804557648`: analyzer caught one unused Auto Play import; fixed by `5048486775b0c9702583f348bfc5be71219e83ae`.
- `31804740412`: one-time lock helper hit an unrelated Flutter-generated `analysis_options.yaml` working-tree change before rebase; fixed by `f91ee2d423af2142d4d660b3a1d1402bf942f13f`; `31804909137` then succeeded and produced `abf4c95c411658abae27c44f76d39f2f6a9a8bdd`.
- `31805260580`: localized Game screen exposed an outdated direct-widget harness without localization delegates; diagnostic `31805881265` isolated it; fixed by `8990a904f6ecfb487c722b3705f7061237ca270f`.
- `31806175302`: 123 tests passed and 11 failed because five other legacy harness areas also mounted localized widgets without delegates. Diagnostic `31806445596` identified all eleven. The shared production-like localized test harness and focused follow-up commits fixed them; final run `31806785165` passed 134/134.

Temporary helper/diagnostic workflows and reports were removed after use. The permanent workflow directory remains the maintained six-workflow set.

## Phase 15 — Offline Shareable Seeded Challenge Codes

### Final maintained quality gate

The completed Phase 15 source/test/documentation state before evidence-only commits was verified by the permanent `CI` workflow:

```text
Workflow: CI
Run: 31796242355
Verified commit: 643b38665738ce314eea81e3dcc8887c77fb2257
Commit message: docs: explain challenge code deterministic engine relationship
Flutter: 3.47.0 stable
Dart: 3.13.0
Conclusion: SUCCESS
```

All maintained quality steps passed:

- dependency resolution — **PASS**
- Dart formatting — **PASS: 66 files, 0 changed**
- Flutter static analysis — **PASS: No issues found**
- complete automated suite — **PASS: 127/127 tests**
- Flutter Web release build — **PASS: `build/web`**
- Flutter WASM dry run — **PASS**
- overall CI job — **SUCCESS**

Phase 14 ended at 112 tests. Phase 15 adds exactly 15 automated cases:

- `test/challenge_code_test.dart` — 10 pure codec/determinism/validation tests;
- `test/challenge_code_screen_test.dart` — 4 widget/state-flow tests;
- `test/widget_smoke_test.dart` — 1 Home-to-Challenge-Codes navigation regression.

The Challenge Code tests verify supported preset round trip, stable encoding, same-seed opening-board/RNG equivalence, required seed, Daily-mode rejection, unsupported/empty input rejection, checksum tampering, malformed shape/checksum, pre-parse oversize rejection, seed bounds, deterministic generation/copy, paste/validate/preview/start, invalid-input preservation, and replacement-cancellation preservation.

### Native production gate

The final Phase 15 application source requiring native compilation includes the Challenge Code codec, screen, route, Home navigation, clipboard boundary use, in-app Guide text, and About release highlights. It was verified by the permanent native matrix:

```text
Workflow: Platform Builds
Run: 31795329370
Verified production/in-app-doc commit: 7c83d7a14656d9309b54205de1f72e0af131f551
Commit message: docs: include challenge codes in app release highlights
Conclusion: SUCCESS
```

Jobs:

- Android release APK — **PASS**
- Linux release — **PASS**
- Windows release — **PASS**
- macOS release — **PASS**
- iOS release with `--no-codesign` — **PASS**

The Apple CI target remains intentionally unsigned for iOS. Real device/App Store signing/provisioning remains a manual release boundary.

### Phase 15 trust-boundary evidence

Automated/source review now supports these implementation claims:

- Challenge Code format is `NOVA1.<base64url-payload>.<8-hex-checksum>`;
- payload format identifier is `2048-nova-challenge`, version `1`;
- input is capped at 1024 characters before payload parsing;
- checksum is checked before Base64URL/JSON configuration parsing;
- strict existing `GameConfig.fromJson()` validation is reused;
- a deterministic seed is mandatory and limited to the existing safe seed range;
- supported modes are Classic, Quick, Extended, Challenge, Endless, Target, Time Challenge, Move Limit, and Zen;
- Daily Challenge is rejected from this portable format;
- codes carry configuration/seed only and cannot import board progress, score, statistics, achievements, settings, Daily history, or Undo snapshots;
- starting a valid code uses the normal recoverable-game replacement guard and `AppController.newGame()` fresh-game path;
- Challenge Codes introduce no new runtime dependency, persistence key, account, cloud service, or network requirement;
- checksum is documented as accidental corruption detection, not cryptographic authentication or anti-cheat proof.

### Transparent Phase 15 intermediate history

The first codec implementation used an unsupported Dart string-multiplication expression while rebuilding Base64URL padding. It was corrected immediately by:

```text
88c2954f9703a72626ddf47d93b4d6e9e8e8dfeb
fix: decode challenge code padding with valid Dart
```

The corrected implementation uses `List.filled(paddingCount, '=').join()`.

An earlier CI source-state run `31795076552` had already passed formatting, static analysis, and tests, but its Web build was cancelled by the repository's concurrency policy after newer commits arrived. It is therefore not promoted as final Phase 15 evidence. Run `31796242355` supersedes it with a complete formatter/analyzer/127-test/Web success.

No temporary diagnostic/patch workflow was required for Phase 15. The maintained workflow directory remains:

- `bootstrap-branding.yml`
- `bootstrap-platforms.yml`
- `ci.yml`
- `format-code.yml`
- `lock-dependencies.yml`
- `platform-builds.yml`

## Historical Phase 14 — Portable Game Backup + complete documentation

### Final permanent quality gate

The final Phase 14 source/test state was verified by the maintained `CI` workflow:

```text
Workflow: CI
Run: 31787639781
Verified source/test commit: 1371ef9eaa00f1da5a2ce0370a1f22eb1f2f4cd2
Conclusion: SUCCESS
```

All maintained quality steps passed:

- dependency resolution — **PASS**
- Dart formatting check — **PASS**
- Flutter static analysis — **PASS**
- complete automated test suite — **PASS: 112/112**
- Flutter Web release build — **PASS**
- overall CI job — **SUCCESS**

Phase 13 completed at 92 tests. Phase 14 added exactly 20 focused tests:

- `test/game_backup_test.dart` — 7;
- `test/imported_game_policy_test.dart` — 5;
- `test/game_backup_screen_test.dart` — 4;
- `test/unranked_marker_test.dart` — 4.

Automated Phase 14 coverage verifies that backup round trip preserves the current game; unrelated lifetime/settings/achievement/Daily/Undo data is excluded; malformed/unsupported/invalid/oversized backup text is rejected; strict embedded `GameState` validation remains authoritative; clipboard export is decodable; import requires explicit confirmation; Cancel/invalid input preserve existing state; imported sessions remain unranked across restart; imported moves cannot mutate lifetime records, achievements, streaks, or Daily history; imported historical best cannot replace the device lifetime record; terminal imported state cannot award a ranked win; a normal new game exits imported policy; and malformed/cleared/corrupt current-game state cleans the associated unranked marker.

### Final native production gate

The clipboard production boundary was refactored behind `TextClipboard` so normal builds still use Flutter's system clipboard while widget tests use an in-memory implementation. The production state containing that abstraction and the injectable Game Backup screen was verified by the maintained native matrix:

```text
Workflow: Platform Builds
Run: 31787016748
Verified production commit: dd3c79bec40cf1aa1e4b00190d32393b249902e0
Commit message: refactor: inject clipboard service into game backup screen
Conclusion: SUCCESS
```

Jobs:

- Android release APK — **PASS**
- Linux release — **PASS**
- Windows release — **PASS**
- macOS release — **PASS**
- iOS release with `--no-codesign` — **PASS**

The iOS job is intentionally unsigned. Real signing/provisioning remains a manual distribution boundary.

An earlier Phase 14 native matrix (`31784286707` on `741dfd42e51386646aa64be116cf7e913e98d211`) had already passed all five configured targets before the clipboard abstraction. Run `31787016748` supersedes it for current Phase 14 production-code evidence.

### Transparent Phase 14 intermediate failures

These are not counted as final verification:

- CI run `31781326279` failed because strict analysis exposed an unused backup-test import. Commit `3446413574582c196a47877fe1bfbe63addbf71d` fixed it.
- The oversized-backup fixture initially used unsupported Dart string multiplication; commit `a4a2de5bfb9e32fb9f02cf13b5019f69141ff567` replaced it with a valid `List.filled(...).join()` fixture.
- Backup widget tests initially assumed the below-the-fold Home card was visible in Flutter's default 800×600 test viewport; commit `24b2063f365b63a86009c9acbebf2c4bafe73bed` added explicit scrolling.
- A later full suite completed with **110 passed / 2 failed** after the clipboard abstraction. Focused diagnostics showed only the Backup **export** and **cancel** widget cases failed because their page actions were still below the bottom navigation/test viewport. Commit `1371ef9eaa00f1da5a2ce0370a1f22eb1f2f4cd2` (`test: scroll backup page beyond bottom navigation before taps`) corrected those page-action taps. The maintained CI then passed **112/112** in run `31787639781`.
- Temporary one-time patch/wiring helpers had development-tooling failures (`31780514759`, `31780577741`, `31780703213`, `31780791461`, `31781232021`) and were removed after source changes were committed normally.
- Phase-14-log helper attempts `31785071035` and `31785159285` failed at workflow parsing; `31785331045` appended successfully in its temporary checkout but failed before commit because staging named an already-removed helper path. Final helper run `31785495844` completed successfully, appended Phase 14 to `what_changed.md`, committed it, and removed itself.
- Temporary Phase 14 diagnostic workflows were removed after they isolated the widget failures; they are not part of the permanent automation surface.

The maintained workflow directory is limited to the six workflows listed above.

## Historical Phase 13 — Move Replay

```text
Workflow: CI
Run: 31779838751
Verified commit: 278ba039d0b7b59ce54c72c5ed0fcd0401ba537a
Flutter: 3.47.0 stable
Dart: 3.13.0
Formatting: PASS — 55 files, 0 changed
Analysis: PASS — No issues found
Tests: PASS — 92/92
Web release build: PASS — build/web
WASM dry run: PASS
Overall CI job: SUCCESS
```

Native matrix `31779566057` on production commit `4f3cc6f55ae6b2f50b4758db22569b7ec48ddafd` passed Android release APK, Linux, Windows, macOS, and unsigned iOS.

Intermediate Replay CI run `31779369661` recorded 90 passing / 2 failing tests because the widget harness tapped below-the-fold controls without scrolling. Commit `501b2a512c2f185461129f2e294504e43e883d59` fixed the harness; the final 92-test gate above passed.

## Historical Phase 12 — Auto Play Demo

```text
Workflow: CI
Run: 31778558429
Commit: 1d98042558ab7ffe40c9da4ad42dbbf8263dcaf6
Flutter: 3.47.0 stable
Dart: 3.13.0
Formatting: PASS — 51 files, 0 changed
Analysis: PASS — No issues found
Tests: PASS — 86/86
Web release build: PASS
```

Native matrix `31778424208` on production commit `a1cc17836834750c542c69ffdf3c5e582d4e43ab` passed Android, Linux, Windows, macOS, and unsigned iOS release builds.

## Historical Phase 11 — Deep hardening

```text
Workflow: CI
Run: 31777374553
Commit: 1ecbf0881f723af1829fda523752562660a86a98
Flutter: 3.47.0 stable
Dart: 3.13.0
Formatting: PASS — 47 files, 0 changed
Analysis: PASS — No issues found
Tests: PASS — 81/81
Web release build: PASS
```

## What automated verification proves

A successful current quality gate provides evidence that the tested repository state is Dart-format clean, passes configured Flutter static analysis, passes the complete automated unit/widget regression suite, produces a Flutter Web release build, and preserves the tested deterministic/persistence/accessibility/Challenge Code/Replay/Auto Play/Backup boundaries. A successful native matrix provides evidence that the relevant production code compiles as configured on GitHub-hosted Android/Linux/Windows/macOS/iOS runners.

## What automated verification does not prove

It does not prove universal absence of defects; every physical device or OS version; real touch/orientation behavior on all devices; final TalkBack/VoiceOver/Narrator/browser-screen-reader quality; every real Challenge Code/Game Backup clipboard/browser/email handler; platform clipboard history/permission behavior; long-duration lifecycle behavior; Android production keystore/store signing; Apple signing/provisioning/notarization; or store acceptance/final privacy-data-safety listing accuracy.

Those remain explicit tasks in [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md).

## Release-candidate status

```text
Project: 2048 Nova
Version: 0.9.0+1
Stable 1.0.0 claim: NOT YET
```

Use this document with [`TESTING.md`](TESTING.md), [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md), [`CHALLENGE_CODES.md`](CHALLENGE_CODES.md), [`../CHANGELOG.md`](../CHANGELOG.md), and [`../what_changed.md`](../what_changed.md).
