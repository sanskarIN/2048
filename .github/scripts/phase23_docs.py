from pathlib import Path
import re
import subprocess


def run(*args):
    return subprocess.run(args, check=True)


def commit(paths, message):
    run('git', 'add', *paths)
    result = subprocess.run(['git', 'diff', '--cached', '--quiet'])
    if result.returncode == 0:
        print(f'No changes for: {message}')
        return
    run('git', 'commit', '-m', message)


def insert_once(path, anchor, replacement):
    p = Path(path)
    text = p.read_text()
    if replacement in text:
        return
    if anchor not in text:
        raise SystemExit(f'Anchor not found in {path}: {anchor[:80]}')
    p.write_text(text.replace(anchor, replacement, 1))


def append_once(path, marker, section):
    p = Path(path)
    text = p.read_text()
    if marker in text:
        return
    p.write_text(text.rstrip() + '\n\n' + section.strip() + '\n')


# README
readme = Path('README.md')
text = readme.read_text()
needle = 'Release promotion is now fail-closed: `dart run tool/release_readiness.dart` validates candidate metadata and the evidence manifest, while `dart run tool/release_readiness.dart --stable` refuses promotion until the package is actually `1.0.0`, the changelog has a stable release section, and every required real-world qualification item has recorded passed evidence. See [`docs/RELEASE_QUALIFICATION.md`](docs/RELEASE_QUALIFICATION.md).'
addition = needle + '\n\nHosted native release builds are now packaged as short-lived checksummed qualification artifacts for Android, Linux, Windows, macOS, and unsigned iOS. They provide reproducible inputs for real-target testing but do not replace the 13 manual evidence records. See [`docs/RELEASE_ARTIFACTS.md`](docs/RELEASE_ARTIFACTS.md).'
if addition not in text:
    if needle not in text:
        raise SystemExit('README release promotion paragraph missing')
    text = text.replace(needle, addition, 1)
row = '| Release qualification gate | [`docs/RELEASE_QUALIFICATION.md`](docs/RELEASE_QUALIFICATION.md) |'
new_rows = row + '\n| Native qualification artifacts | [`docs/RELEASE_ARTIFACTS.md`](docs/RELEASE_ARTIFACTS.md) |'
if new_rows not in text:
    if row not in text:
        raise SystemExit('README release qualification row missing')
    text = text.replace(row, new_rows, 1)
readme.write_text(text)
commit(['README.md'], 'docs: expose native qualification artifacts')

# Documentation index
docs_index = Path('docs/README.md')
text = docs_index.read_text()
row = '| [`RELEASE_GATE_TESTING.md`](RELEASE_GATE_TESTING.md) | Process-level fixture coverage for candidate/stable release-gate acceptance and rejection paths. |'
replacement = row + '\n| [`RELEASE_ARTIFACTS.md`](RELEASE_ARTIFACTS.md) | Checksummed hosted native qualification artifacts, retention, verification, packaging, and manual-evidence boundaries. |'
if replacement not in text:
    if row not in text:
        raise SystemExit('docs index release gate row missing')
    text = text.replace(row, replacement, 1)
source = '- **Automated quality gates:** `.github/workflows/`.'
source_replacement = source + '\n- **Hosted native qualification artifacts:** `.github/workflows/platform-builds.yml`; handling policy is `RELEASE_ARTIFACTS.md`.'
if source_replacement not in text:
    if source not in text:
        raise SystemExit('docs index automated quality source missing')
    text = text.replace(source, source_replacement, 1)
docs_index.write_text(text)
commit(['docs/README.md'], 'docs: index native qualification artifacts')

# Dependencies
deps = Path('docs/DEPENDENCIES.md')
text = deps.read_text()
anchor = '### shared_preferences\n'
section = '''### cupertino_icons

Pinned at **1.0.8**. The package supplies the Cupertino icon font referenced by Flutter/Cupertino icon data. Phase 23 made the dependency explicit after the Web compiler correctly reported that Cupertino icon data was referenced while the font asset was absent.

Version 1.0.8 is intentionally pinned for the current release-candidate SDK range (`>=3.3.0 <4.0.0`) rather than blindly adopting a newer release with a higher Dart SDK floor. It adds no networking, analytics, account, persistence, or platform permission behavior.

The permanent Web gate now fails if Flutter again emits `Expected to find fonts for`, and repository-integrity tests verify the declaration and resolved lockfile entry remain synchronized.

### shared_preferences
'''
if '### cupertino_icons' not in text:
    if anchor not in text:
        raise SystemExit('dependencies shared_preferences anchor missing')
    text = text.replace(anchor, section, 1)
old = 'A dedicated GitHub Actions workflow can resolve/commit lockfile changes, while Dependabot provides update discovery. Dependency updates still require analyzer/test/build verification.'
new = 'A dedicated GitHub Actions workflow automatically resolves/commits lockfile changes when dependency metadata changes and can also be manually dispatched. Permanent CI independently fails when `flutter pub get` would change the committed lockfile, while Dependabot provides update discovery. Dependency updates still require analyzer/test/build verification.'
if old in text:
    text = text.replace(old, new, 1)
deps.write_text(text)
commit(['docs/DEPENDENCIES.md'], 'docs: record Cupertino icon dependency policy')

# Release artifacts accepted evidence
art = Path('docs/RELEASE_ARTIFACTS.md')
text = art.read_text()
marker = '## Phase 23 accepted hosted artifact set'
section = '''## Phase 23 accepted hosted artifact set

Accepted Platform Builds run: **31934181987**, source `5b22795d5aba661bd587e7bcbf2ae6442c8b4b3a`.

| Artifact | ID | Size | GitHub artifact digest |
| --- | ---: | ---: | --- |
| `nova-2048-android-release` | 9260209072 | 25,409,651 bytes | `sha256:d88a691dd33bcb3e12544f5fb9b35f623cd5890fe96e74dcefe8af4ada75df5d` |
| `nova-2048-linux-x64-release` | 9260177318 | 10,396,367 bytes | `sha256:8556a5d31017faa4ff7f8c128e097aafc5664cf36e219075ea24499bc58dfcef` |
| `nova-2048-windows-x64-release` | 9260197932 | 12,655,196 bytes | `sha256:9ac4fcc2ce969139e9412466f7d568c361a84b666d0812184b1c671a0966e463` |
| `nova-2048-macos-release` | 9260232848 | 18,739,502 bytes | `sha256:20f52591cb0c3cbd5da330b129a98c03831388d2f8dceadf90d760cf7c7193dc` |
| `nova-2048-ios-unsigned-release` | 9260233269 | 8,709,732 bytes | `sha256:44a0adb2482ef422637eb241659a54fc0b7ed59c343ee7d8e104920783e03721` |

Every build, package, checksum, and upload step completed successfully. These GitHub artifact digests cover the stored Actions artifact archives; each artifact also contains the payload-level SHA-256 sidecar created by the workflow.

The artifacts expire on **2026-08-30** under the configured 14-day retention policy. Expiration does not invalidate the source/build evidence recorded here, but future manual qualification should use a current artifact from the exact commit being qualified when practical.
'''
if marker not in text:
    art.write_text(text.rstrip() + '\n\n' + section.strip() + '\n')
commit(['docs/RELEASE_ARTIFACTS.md'], 'docs: record accepted native artifact set')

# CI/CD
ci_doc = Path('docs/CI_CD.md')
text = ci_doc.read_text()
text = text.replace(
    '`ci.yml` | Format verification for application/tests/tools, analyzer, test suite with coverage, release-readiness gates, deterministic solver smoke benchmark, and Web release build.',
    '`ci.yml` | Flutter-managed metadata drift guard, format verification for application/tests/tools, analyzer, test suite with coverage, release-readiness gates, deterministic solver smoke benchmark, and warning-enforced Web release build.',
    1,
)
text = text.replace(
    '`platform-builds.yml` | Android, Linux, Windows, macOS, and unsigned iOS release-build matrix.',
    '`platform-builds.yml` | Android, Linux, Windows, macOS, and unsigned iOS release-build matrix with generated-dependency drift checks, packaging, SHA-256 sidecars, and retained qualification artifacts.',
    1,
)
text = text.replace(
    '`lock-dependencies.yml` | Resolve and commit `pubspec.lock` when explicitly triggered.',
    '`lock-dependencies.yml` | Resolve and commit `pubspec.lock` automatically when dependency metadata changes or when manually dispatched.',
    1,
)
old_block = '''flutter --version
flutter pub get
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
dart run tool/release_readiness.dart --json
# CI also verifies that --stable fails closed while the package is 0.9.x
dart run tool/solver_benchmark.dart 8
flutter build web --release'''
new_block = '''flutter --version
flutter pub get
git diff --exit-code -- pubspec.lock analysis_options.yaml
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
dart run tool/release_readiness.dart --json
# CI also verifies that --stable fails closed while the package is 0.9.x
dart run tool/solver_benchmark.dart 8
# Web output is captured and fails if Flutter reports missing icon-font assets.
flutter build web --release'''
if old_block in text:
    text = text.replace(old_block, new_block, 1)
old_lock = 'This workflow is intentionally narrow. It runs when its own workflow file changes or when manually dispatched, executes `flutter pub get`, and commits `pubspec.lock` only if resolution changes the lockfile.'
new_lock = 'This workflow is intentionally narrow. It runs when `pubspec.yaml`, `pubspec.lock`, or its own workflow file changes and can also be manually dispatched. It executes `flutter pub get` and commits `pubspec.lock` only if resolution changes the lockfile.'
if old_lock in text:
    text = text.replace(old_lock, new_lock, 1)
marker = '## Phase 23 release-engineering hardening'
section = '''## Phase 23 release-engineering hardening

Phase 23 hardened reproducibility and retained-build evidence without changing gameplay rules or claiming manual device qualification.

Permanent changes include:

- every repository-owned checkout moved to `actions/checkout@v6`, removing the prior Node-20 checkout warning on current runners;
- exact `cupertino_icons 1.0.8` dependency/lock entry so Web includes the referenced Cupertino icon font;
- CI fails when `flutter pub get` changes `pubspec.lock` or `analysis_options.yaml`;
- `analysis_options.yaml` contains Flutter 3.47's generated-platform exclusions, so Flutter no longer silently migrates it during CI;
- platform jobs fail when generated plugin registrants/CMake files drift from dependency metadata;
- macOS generated plugin registration now includes `FilePickerPlugin`, repairing the native file-picker registration required by Game Backup file transport;
- the Web build is captured and fails if the missing-icon-font warning returns;
- native outputs are packaged with SHA-256 sidecars and uploaded as five 14-day qualification artifacts using `actions/upload-artifact@v7`.

Accepted quality evidence:

```text
CI run: 31934191150
Job: 95133484471
Source: a93542ecae7713214f7f3e4e11a03c647e880129
Flutter: 3.47.0 stable
Dart: 3.13.0
DevTools: 2.60.0
Flutter metadata drift: PASS
Formatting: PASS — 98 files, 0 changed
Analyzer: PASS — No issues found
Tests: PASS — 207/207
Candidate release gate: PASS — 0/13 manual evidence remains
Stable boundary assertion: PASS — current 0.9.0+1 remains fail-closed
Solver smoke benchmark: PASS
Web/WASM dry run: PASS
Missing icon-font warning guard: PASS
Web release: PASS — build/web
```

Accepted native/package evidence:

```text
Platform Builds run: 31934181987
Source: 5b22795d5aba661bd587e7bcbf2ae6442c8b4b3a
Android job: 95133491378 — PASS
Linux job: 95133491351 — PASS
Windows job: 95133491405 — PASS
macOS + unsigned iOS job: 95133491379 — PASS
Qualification artifacts: 5/5 uploaded with SHA-256 sidecars
```

See [`RELEASE_ARTIFACTS.md`](RELEASE_ARTIFACTS.md) for the exact accepted artifact IDs/digests and the boundary between hosted artifacts and real-world qualification.
'''
if marker not in text:
    text = text.rstrip() + '\n\n' + section.strip() + '\n'
ci_doc.write_text(text)
commit(['docs/CI_CD.md'], 'docs: record Phase 23 CI and artifact pipeline')

# Testing
testing = Path('docs/TESTING.md')
text = testing.read_text()
marker = '## Phase 23 repository-integrity evidence'
section = '''## Phase 23 repository-integrity evidence

Phase 23 adds `test/repository_integrity_test.dart` with **7 source/repository contract tests**, increasing the maintained suite from 200 to **207 tests**.

The added cases verify:

1. `cupertino_icons 1.0.8` is declared and locked;
2. macOS generated registration contains `FilePickerPlugin`;
3. Flutter analysis excludes every generated platform tree required by the current Flutter migration;
4. permanent workflows no longer use `actions/checkout@v4` or `@v5`;
5. dependency-lock automation watches dependency metadata and uses checkout v6;
6. CI rejects Flutter-managed metadata drift and fails if the missing Web icon-font warning returns;
7. native builds declare all five checksummed qualification artifacts, hard-fail on missing files, and use bounded retention.

Accepted permanent CI run `31934191150`, job `95133484471`, on source `a93542ecae7713214f7f3e4e11a03c647e880129` reports:

```text
Formatting: PASS — 98 files, 0 changed
Analysis: PASS — No issues found
Tests: PASS — 207/207
Metadata drift guard: PASS
Release-candidate gate: PASS
Stable-boundary assertion: PASS
Solver smoke benchmark: PASS
WASM dry run: PASS
Warning-enforced Web release: PASS
```

The repository-integrity tests complement rather than replace the real-device/manual qualification manifest.
'''
if marker not in text:
    testing.write_text(text.rstrip() + '\n\n' + section.strip() + '\n')
commit(['docs/TESTING.md'], 'docs: record 207-test repository integrity gate')

# Verification
verification = Path('docs/VERIFICATION.md')
text = verification.read_text()
marker = '## Phase 23 — Reproducible metadata, warning-free Web, and retained native artifacts'
section = '''## Phase 23 — Reproducible metadata, warning-free Web, and retained native artifacts

Date: **2026-08-16**

Final Phase 23 quality source:

```text
Commit: a93542ecae7713214f7f3e4e11a03c647e880129
CI run: 31934191150
CI job: 95133484471
Result: SUCCESS
Runner: Ubuntu 24.04.4 LTS
Flutter: 3.47.0 stable
Dart: 3.13.0
DevTools: 2.60.0
Flutter metadata drift: PASS — pubspec.lock + analysis_options.yaml unchanged by pub get
Formatting: PASS — 98 files, 0 changed
Static analysis: PASS — No issues found
Tests: PASS — 207/207
Candidate readiness: PASS — candidateGatePassed=true; readyForStable=false; 0/13 manual evidence complete
Stable promotion boundary: PASS — strict stable mode correctly rejected current 0.9.0+1
Solver smoke benchmark: PASS
WASM dry run: PASS
Missing icon-font warning guard: PASS
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
'''
if marker not in text:
    intro = 'This document records objective automated evidence for the current 2048 Nova release-candidate line. It distinguishes formatter/analyzer/test/Web verification, native compilation evidence, transparent intermediate failures, and manual release boundaries.\n'
    if intro not in text:
        raise SystemExit('verification intro missing')
    text = text.replace(intro, intro + '\n' + section.strip() + '\n\n', 1)
    verification.write_text(text)
commit(['docs/VERIFICATION.md'], 'docs: record Phase 23 verification evidence')

# Release checklist
checklist = Path('docs/RELEASE_CHECKLIST.md')
text = checklist.read_text()
anchor = '- [x] `flutter build web --release`\n'
extra = anchor + '- [x] `flutter pub get` leaves `pubspec.lock` and `analysis_options.yaml` unchanged in permanent CI\n- [x] Warning-enforced Web build contains the Cupertino icon font and does not emit the missing-font warning\n- [x] Native jobs verify generated dependency/plugin registration files stay synchronized\n- [x] macOS generated plugin registration includes `FilePickerPlugin` for Game Backup file transport\n- [x] Android/Linux/Windows/macOS/unsigned-iOS outputs are packaged with payload SHA-256 sidecars\n- [x] Five native qualification artifacts upload successfully with hard failure on missing output files and 14-day retention\n'
if 'Five native qualification artifacts upload successfully' not in text:
    if anchor not in text:
        raise SystemExit('release checklist web anchor missing')
    text = text.replace(anchor, extra, 1)
checklist.write_text(text)
commit(['docs/RELEASE_CHECKLIST.md'], 'docs: add Phase 23 automated release checks')

# Release qualification
qual = Path('docs/RELEASE_QUALIFICATION.md')
text = qual.read_text()
marker = '## Hosted qualification artifacts'
section = '''## Hosted qualification artifacts

The permanent native build matrix now publishes short-lived checksummed outputs documented in [`RELEASE_ARTIFACTS.md`](RELEASE_ARTIFACTS.md). Use those outputs when they help perform a real target check against a known source commit.

Artifact existence, hosted compilation, checksum generation, and upload success **do not** mark any manual manifest item passed. Evidence must still describe what was exercised on the representative real environment. An unsigned iOS artifact is compilation/package evidence only until real signing/provisioning and device/distribution checks are completed.
'''
if marker not in text:
    qual.write_text(text.rstrip() + '\n\n' + section.strip() + '\n')
commit(['docs/RELEASE_QUALIFICATION.md'], 'docs: connect hosted artifacts to manual qualification')

# Platform docs
platforms = Path('docs/PLATFORMS.md')
text = platforms.read_text()
marker = '## Phase 23 retained qualification artifacts'
section = '''## Phase 23 retained qualification artifacts

The permanent Platform Builds matrix packages checksummed qualification inputs for Android, Linux x64, Windows x64, macOS, and unsigned iOS after successful hosted release compilation. The artifact policy, exact packaging formats, checksum commands, current accepted IDs, and 14-day retention boundary are documented in [`RELEASE_ARTIFACTS.md`](RELEASE_ARTIFACTS.md).

The macOS generated plugin registrant now explicitly registers `FilePickerPlugin`, matching the pinned `file_picker 11.0.2` dependency used by Game Backup file transport. Platform jobs verify generated dependency/plugin files remain synchronized after `flutter pub get`.

Hosted artifacts do not replace device, handler, accessibility, signing, notarization, provisioning, or store qualification.
'''
if marker not in text:
    platforms.write_text(text.rstrip() + '\n\n' + section.strip() + '\n')
commit(['docs/PLATFORMS.md'], 'docs: document retained platform qualification outputs')

# Roadmap
roadmap = Path('ROADMAP.md')
text = roadmap.read_text()
text = text.replace(
    'Release-readiness CLI regression fixtures now exercise both opening and fail-closed branches end to end, including a fully qualified synthetic stable fixture plus malformed/incomplete evidence rejection; maintained CI is 200/200 tests.',
    'Release-readiness CLI regression fixtures exercise both opening and fail-closed branches end to end, including a fully qualified synthetic stable fixture plus malformed/incomplete evidence rejection; maintained CI is now 207/207 tests after Phase 23 repository-integrity coverage.',
    1,
)
anchor = '- Permanent CI now formats `tool/` together with application/tests, runs the release-candidate readiness gate, and smoke-runs the deterministic solver benchmark in addition to the existing analyzer/tests/Web release build.\n'
extra = anchor + '- Phase 23 makes Flutter-managed metadata reproducible, includes the Cupertino icon font without Web warnings, verifies generated plugin registration, uses checkout v6, and guards these repository contracts with focused tests.\n- Native hosted builds now package SHA-256 sidecars and retain five short-lived qualification artifacts for Android, Linux, Windows, macOS, and unsigned iOS; artifacts remain inputs to manual qualification rather than substitutes for it.\n'
if 'Phase 23 makes Flutter-managed metadata reproducible' not in text:
    if anchor not in text:
        raise SystemExit('roadmap permanent CI anchor missing')
    text = text.replace(anchor, extra, 1)
roadmap.write_text(text)
commit(['ROADMAP.md'], 'docs: mark Phase 23 release hardening complete')

# Changelog
changelog = Path('CHANGELOG.md')
text = changelog.read_text()
added = '### Added\n'
added_block = '''### Added
- Seven repository-integrity regressions covering dependency/lock pairing, macOS FilePicker registration, Flutter analysis migration exclusions, checkout runtime policy, dependency-lock triggers, CI metadata/font guards, and native artifact publishing contracts.
- Checksummed 14-day native qualification artifacts for Android, Linux x64, Windows x64, macOS, and unsigned iOS, with hard failure when expected package files are absent.
'''
if 'Seven repository-integrity regressions' not in text:
    if added not in text:
        raise SystemExit('changelog Added heading missing')
    text = text.replace(added, added_block, 1)
changed = '### Changed\n'
changed_block = '''### Changed
- Repository-owned workflows now use `actions/checkout@v6`; platform artifacts use `actions/upload-artifact@v7`.
- Dependency-lock automation watches dependency metadata, while permanent CI fails when `flutter pub get` changes the committed lockfile or Flutter-managed analysis options.
- `analysis_options.yaml` explicitly carries Flutter 3.47 generated-platform exclusions instead of being silently migrated during CI.
- Maintained CI now passes 207/207 tests, 98-file formatting, metadata drift checks, release gates, solver smoke, and a warning-enforced Web build.
'''
if 'Repository-owned workflows now use `actions/checkout@v6`' not in text:
    if changed not in text:
        raise SystemExit('changelog Changed heading missing')
    text = text.replace(changed, changed_block, 1)
if '### Fixed\n- Missing Cupertino icon-font asset' not in text:
    fixed = '''### Fixed
- Missing Cupertino icon-font asset in Web release builds by explicitly pinning `cupertino_icons 1.0.8`; CI now fails if the missing-font warning returns.
- Generated macOS `file_picker` registration so Game Backup file transport has the expected native plugin registration on macOS.

'''
    text = text.replace('### Changed\n', fixed + '### Changed\n', 1)
changelog.write_text(text)
commit(['CHANGELOG.md'], 'docs: record Phase 23 release engineering changes')

# what_changed continuity
log = Path('what_changed.md')
text = log.read_text()
text, count = re.subn(
    r'- \*\*Current phase:\*\*.*',
    '- **Current phase:** Phase 23 — reproducible Flutter metadata, warning-free Web assets, generated-plugin integrity, and retained checksummed native qualification artifacts complete; 13 real-world checks remain before 1.0.0',
    text,
    count=1,
)
if count != 1:
    raise SystemExit('what_changed current phase line missing')
marker = '## 2026-08-16 — Phase 23: reproducible release engineering and retained qualification artifacts'
section = '''---

## 2026-08-16 — Phase 23: reproducible release engineering and retained qualification artifacts

Phase 23 continued from the fixture-tested Phase 22 release gate and focused on codeable release/build defects already visible in objective CI logs. It does not claim completion of any physical-device or assistive-technology check.

### Problems found and corrected

1. **Web Cupertino icon font warning.** Phase 22 Web builds succeeded but emitted `Expected to find fonts for ... CupertinoIcons`. `pubspec.yaml` did not declare the font package even though Flutter/Cupertino icon data referenced it. Exact `cupertino_icons 1.0.8` was added and locked to preserve the repository's declared Dart SDK range. Permanent CI now fails if the warning returns. The accepted Phase 23 Web log shows `CupertinoIcons.ttf` being tree-shaken and no missing-font warning.
2. **Deprecated checkout runtime warning.** All repository-owned workflows used `actions/checkout@v4`, which current GitHub-hosted runners were forcing away from its deprecated Node 20 runtime. All six permanent workflows now use `actions/checkout@v6`.
3. **Dependency-lock drift risk.** `lock-dependencies.yml` previously did not automatically follow ordinary `pubspec.yaml` edits. It now watches dependency metadata, while CI independently rejects an unstaged `pubspec.lock` rewrite after `flutter pub get`.
4. **Silent Flutter analysis-options migration.** Flutter 3.47 was rewriting `analysis_options.yaml` in hosted jobs because generated platform trees were not all excluded. The repository now carries the current generated-platform exclusion set explicitly, and CI rejects future drift.
5. **Missing generated macOS FilePicker registration.** Re-running the platform generator produced one meaningful native difference: `macos/Flutter/GeneratedPluginRegistrant.swift` was missing `FilePickerPlugin`. The generated registration was committed, and native jobs now fail if generated dependency/plugin files drift after dependency resolution.
6. **Ephemeral native build evidence.** Successful native builds were discarded when jobs ended. The permanent matrix now creates payload SHA-256 sidecars, packages desktop/Apple bundles safely, hard-fails on missing outputs, and uploads five 14-day qualification artifacts.

### Phase 23 implementation commits

```text
83a8b02443aed3e3e99ea15a5fadebf462094d80  ci: keep dependency lockfile synchronized
3c54a6c33472d6e4cdce732a071e69685a7ad233  ci: move formatter checkout to Node 24 action
5419e3cfbfcc75764dec33c143b43cea6009acbc  ci: modernize branding workflow checkout
91e12965fc2a90cd589b99325f0bf525af5310bf  ci: modernize platform bootstrap checkout
5dd6c0e060295d8f57f5fe9e5340932e9778b77b  ci: move platform builds to checkout v6
ffa40ffc7eca91bf8c4c58eb8174919f92f4d836  ci: fail web builds on missing font assets
1cbf482d1b3eded98f1e1e079bcb02ecab9d4735  build: include Cupertino icon font asset
1d445c7b8291260e974a1d0132c9417f1132b48e  build: generate Flutter platform runners
c82b77f71b650fb0fb9c7e7e3fb75f64ded175ec  build: lock Flutter dependencies
36cf29014a610092f8577cf467dee66b7ce96d8e  ci: reject stale dependency lockfiles
21065f20797f3aa9cad71153f4faf22f90b9dd8e  ci: verify native dependency generation stays clean
c63811d35529c2a7d0b27e441fb5a7466a6dc8e4  test: guard release engineering repository integrity
1024a543e9fc114ee977d69ee6d708413026e000  build: apply current Flutter analysis migration
77d9bb931decdb0840e65131b3b32ebbca5eacd4  ci: reject Flutter project metadata drift
7b21997474a9d68d15151a01ed5b51a563d115f1  test: guard Flutter project metadata migration
5b22795d5aba661bd587e7bcbf2ae6442c8b4b3a  ci: retain checksummed native qualification artifacts
a93542ecae7713214f7f3e4e11a03c647e880129  test: guard qualification artifact publishing
a0581eb13722b28e9f98cf3e2920832b80fa48af  docs: define native qualification artifact handling
```

The platform-bootstrap commit is retained because it repaired the missing macOS FilePicker registration. The dependency lock commit was created by the corrected lockfile automation. Formatting automation found the final repository-integrity test source already canonical and produced no extra formatter commit.

### Accepted Phase 23 quality gate

Permanent CI run **31934191150**, job **95133484471**, verified source `a93542ecae7713214f7f3e4e11a03c647e880129`:

```text
Runner: Ubuntu 24.04.4 LTS
Flutter: 3.47.0 stable
Dart: 3.13.0
DevTools: 2.60.0
Checkout v6: PASS
Flutter metadata drift: PASS
Formatting: PASS — 98 files, 0 changed
Static analysis: PASS — No issues found
Tests: PASS — 207/207
Repository-integrity regressions: PASS — 7/7
Candidate gate: PASS — candidateGatePassed=true; readyForStable=false; 0/13 manual evidence complete
Strict stable boundary: PASS — current 0.9.0+1 correctly refused
Solver benchmark: PASS — Heuristic + Expectimax; seeds 2048/4096/8192/20260815; 8 moves each
WASM dry run: PASS
Missing icon-font warning guard: PASS
Web release: PASS — build/web
```

The accepted Web log now reports a tree-shaken `CupertinoIcons.ttf` asset and no `Expected to find fonts for` warning, directly closing the warning that remained documented in Phase 22.

### Accepted native matrix and retained artifacts

Platform Builds run **31934181987** verified source `5b22795d5aba661bd587e7bcbf2ae6442c8b4b3a`:

```text
Linux job 95133491351: PASS — build + package + checksum + upload
Android job 95133491378: PASS — APK + checksum + upload
Windows job 95133491405: PASS — build + ZIP + checksum + upload
Apple job 95133491379: PASS — macOS + unsigned iOS builds + ZIPs + checksums + uploads
```

GitHub retained exactly five artifacts:

```text
9260209072  nova-2048-android-release      25,409,651 bytes  sha256:d88a691dd33bcb3e12544f5fb9b35f623cd5890fe96e74dcefe8af4ada75df5d
9260177318  nova-2048-linux-x64-release     10,396,367 bytes  sha256:8556a5d31017faa4ff7f8c128e097aafc5664cf36e219075ea24499bc58dfcef
9260197932  nova-2048-windows-x64-release   12,655,196 bytes  sha256:9ac4fcc2ce969139e9412466f7d568c361a84b666d0812184b1c671a0966e463
9260232848  nova-2048-macos-release         18,739,502 bytes  sha256:20f52591cb0c3cbd5da330b129a98c03831388d2f8dceadf90d760cf7c7193dc
9260233269  nova-2048-ios-unsigned-release   8,709,732 bytes  sha256:44a0adb2482ef422637eb241659a54fc0b7ed59c343ee7d8e104920783e03721
```

The configured artifact retention expires these run artifacts on **2026-08-30**. Every uploaded artifact also contains the payload-level `.sha256` sidecar generated before upload.

### Manual stable-release boundary remains intact

None of the 13 entries in `docs/release_qualification.json` were changed from `pending`. Hosted artifact availability makes real-target testing more reproducible, but it cannot substitute for physical Android/iOS interaction, real screen readers, external handlers, long sessions, native branding review, signing/provisioning, or store/privacy metadata qualification. The project therefore remains correctly on `0.9.0+1`; strict stable mode remains intentionally closed.
'''
if marker not in text:
    text = text.rstrip() + '\n\n' + section.strip() + '\n'
log.write_text(text)
commit(['what_changed.md'], 'docs: record complete Phase 23 implementation log')
