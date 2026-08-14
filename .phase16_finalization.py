from pathlib import Path


def append_once(path: str, marker: str, text: str) -> None:
    p = Path(path)
    current = p.read_text()
    if marker in current:
        return
    p.write_text(current.rstrip() + "\n\n" + text.strip() + "\n")


def insert_before(path: str, before: str, marker: str, text: str) -> None:
    p = Path(path)
    current = p.read_text()
    if marker in current:
        return
    if before not in current:
        raise SystemExit(f"missing anchor {before!r} in {path}")
    p.write_text(current.replace(before, text.strip() + "\n\n" + before, 1))


def insert_after(path: str, after: str, marker: str, text: str) -> None:
    p = Path(path)
    current = p.read_text()
    if marker in current:
        return
    if after not in current:
        raise SystemExit(f"missing anchor {after!r} in {path}")
    p.write_text(current.replace(after, after + "\n" + text.strip() + "\n", 1))


phase16_testing = r'''## Phase 16 — English/Hindi localization evidence

Phase 16 adds **7 focused localization tests** to the Phase 15 total of 127, producing a final suite of **134 tests**:

- supported/malformed `AppLanguage` parsing;
- critical Hindi catalog translations;
- English identity plus safe unknown-key fallback;
- localized mode/direction/achievement helpers;
- persisted language preference plus malformed-value recovery;
- Hindi Home and Settings rendering;
- Hindi board-size/row/column/tile/empty-cell semantics.

A reusable `test/support/localized_test_app.dart` harness now mirrors production localization delegates for widget tests that mount localized feature widgets directly.

Final maintained gate:

```text
Workflow: CI
Run: 31806785165
Verified commit: 9dea87e73803d83c3aa0614d35f7860773dbca04
Flutter: 3.47.0 stable
Dart: 3.13.0
Formatting: PASS — 70 files, 0 changed
Analysis: PASS — No issues found
Tests: PASS — 134/134
Web release build: PASS — build/web
WASM dry run: PASS
Overall: SUCCESS
```

Final runtime localization native evidence:

```text
Workflow: Platform Builds
Run: 31804713200
Verified production commit: 5048486775b0c9702583f348bfc5be71219e83ae
Overall: SUCCESS
```

Jobs:

- Windows release `94780817747` — **PASS**;
- Linux release `94780817828` — **PASS**;
- Android release APK `94780817929` — **PASS**;
- macOS + unsigned iOS `94780818361` — **PASS**.

### Transparent Phase 16 regressions/tooling failures

- CI run `31804557648` stopped at static analysis because `solver_demo_screen.dart` retained one unused import after localization refactoring. Commit `5048486775b0c9702583f348bfc5be71219e83ae` removed it.
- Localization lock helper run `31804740412` resolved dependencies but failed before rebase because Flutter 3.47 rewrote `analysis_options.yaml` in the runner and left an unrelated unstaged change. Commit `f91ee2d423af2142d4d660b3a1d1402bf942f13f` scoped the helper to the lockfile; corrected run `31804909137` succeeded and produced lock commit `abf4c95c411658abae27c44f76d39f2f6a9a8bdd`.
- CI run `31805260580` exposed a stale bare `MaterialApp` harness in `game_screen_interaction_test.dart`; localized `GameScreen` correctly required `NovaLocalizations`. Diagnostic run `31805881265` confirmed formatting, analysis, and focused localization tests were clean while the full suite failed. Commit `8990a904f6ecfb487c722b3705f7061237ca270f` added production localization delegates to that harness.
- CI run `31806175302` then reached **123 passed / 11 failed**. Machine-readable diagnostic run `31806445596` showed all eleven failures were old direct-widget harnesses without localization delegates: Challenge Codes (4), Game Backup (4), replacement guard (1), board semantics (1), and Home lost-game state (1). A shared localized test app plus focused harness commits corrected all eleven; the final CI passed 134/134.
- Temporary Phase 16 diagnostics and generated failure reports were removed after use and are not part of the permanent workflow/file surface.

Manual English/Hindi qualification still includes representative real-device font rendering, large-text/narrow-layout wrapping, System-default locale behavior, language persistence after real process termination, keyboard/focus, clipboard flows, and TalkBack/VoiceOver/desktop-browser screen-reader behavior. Automated success does not replace those checks.
'''

phase16_verification = r'''## Phase 16 — Offline English/Hindi localization

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
'''

phase16_changelog = r'''- Phase 16 English/Hindi localization final gate: CI run `31806785165` on commit `9dea87e73803d83c3aa0614d35f7860773dbca04` used Flutter 3.47.0 / Dart 3.13.0; formatting passed with 70 files and 0 changes, analysis reported no issues, **134/134 tests passed**, the Web release build succeeded, and the WASM dry run passed.
- Phase 16 localization native matrix: Platform Builds run `31804713200` on production commit `5048486775b0c9702583f348bfc5be71219e83ae`; Android release APK, Linux, Windows, macOS, and unsigned iOS all succeeded.
- Transparent Phase 16 failures remained visible: analyzer run `31804557648` found an unused Auto Play import; lock helper run `31804740412` hit an unrelated Flutter-generated working-tree change; full-suite runs `31805260580` and `31806175302` exposed stale direct-widget harnesses missing localization delegates. Those issues were corrected and the final 134-test gate passed.
'''

phase16_localization_verification = r'''## Verified Phase 16 evidence

The completed repository-wide gate for the localization phase is:

```text
CI run: 31806785165
Commit: 9dea87e73803d83c3aa0614d35f7860773dbca04
Flutter: 3.47.0 stable
Dart: 3.13.0
Format: 70 files, 0 changed
Analyze: No issues found
Tests: 134/134 passed
Web release: passed
```

The runtime localization source was also compiled successfully by Platform Builds run `31804713200` on commit `5048486775b0c9702583f348bfc5be71219e83ae` for Android, Linux, Windows, macOS, and unsigned iOS.

These automated results do not replace real English/Hindi font, layout, screen-reader, focus, clipboard, lifecycle, or store-metadata qualification.
'''

insert_before("docs/TESTING.md", "## Historical Phase 13 quality evidence", "## Phase 16 — English/Hindi localization evidence", phase16_testing)
insert_before("docs/VERIFICATION.md", "## Phase 15 — Offline Shareable Seeded Challenge Codes", "## Phase 16 — Offline English/Hindi localization", phase16_verification)
insert_after("CHANGELOG.md", "### Verification\n", "Phase 16 English/Hindi localization final gate", phase16_changelog)
append_once("docs/LOCALIZATION.md", "## Verified Phase 16 evidence", phase16_localization_verification)
append_once("what_changed.md", "## Phase 16 — Offline English/Hindi Localization", Path('.phase16_log.md').read_text())
