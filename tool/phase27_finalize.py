from pathlib import Path


def read(path: str) -> str:
    return Path(path).read_text(encoding="utf-8")


def write(path: str, text: str) -> None:
    Path(path).write_text(text, encoding="utf-8")


# Current continuity summary and full Phase 27 history.
path = "what_changed.md"
text = read(path)
old = """- **Current phase:** Phase 26 — GitHub Actions runtime hardening complete; permanent CI is green at 216 tests; checkout v7 is verified across Ubuntu/Windows/macOS native runners; Dependency Review v5 is verified on a real pull-request event; 13 real-world qualification checks remain before stable promotion
- **Latest Version 1.5 native-matrix source:** `bd11a4bdeec6115f132d6b2d2cebef0be34d74f7` — `ci: use checkout v7 in native matrix`
- **Permanent Version 1.5 CI evidence:** run `31943741993`, job `95156594200` — SUCCESS, 216/216 tests, analyzer clean, checkout v7, candidate gate passed, strict stable gate correctly closed, solver smoke passed, Web release passed
- **Version 1.5 native build evidence:** Platform Builds run `31943702153` — Android, Linux, Windows, macOS, and unsigned iOS jobs all SUCCESS using checkout v7 with checksummed artifacts retained for 14 days
"""
new = """- **Current phase:** Phase 27 — Android toolchain compatibility qualification complete; AGP 9.1.0 + Kotlin 2.4.10 + Gradle 9.7.0 is the protected hosted-build baseline; permanent CI is green at 217 tests; AGP 9.3.1 remains explicitly deferred under issue #10; 13 real-world qualification checks remain before stable promotion
- **Latest accepted Version 1.5 native-matrix source:** `b5ddc657880826bb8a0a5621ff03a99050350342` — `build(android): adopt safe Kotlin and Gradle updates`
- **Permanent Version 1.5 CI evidence:** run `31945071057`, job `95159704902` — SUCCESS, 217/217 tests, analyzer clean, protected Android toolchain baseline, candidate gate passed, strict stable gate correctly closed, solver smoke passed, Web release passed
- **Version 1.5 native build evidence:** Platform Builds run `31944999081` — Android, Linux, Windows, macOS, and unsigned iOS jobs all SUCCESS with the accepted Android toolchain and checksummed artifacts retained for 14 days
"""
if old not in text:
    raise SystemExit("Phase 26 current summary not found")
text = text.replace(old, new, 1)
if "## Phase 27 — Android toolchain compatibility qualification" not in text:
    text += """

---

## Phase 27 — Android toolchain compatibility qualification (2026-08-16)

- Evaluated Android build-tool updates as coordinated compatibility sets instead of blindly merging independent Dependabot PRs.
- PR #9 tested AGP 9.3.1 + Kotlin 2.4.10 + Gradle 9.7.0. Normal Flutter CI, Dependency Review, and non-Android hosted targets passed, but Android release lint failed on the normal JDK 17 baseline in `:url_launcher_android:lintVitalAnalyzeRelease` with a `java.util.List.removeLast()` `NoSuchMethodError`.
- A branch-only Temurin JDK 21 diagnostic then passed the exact AGP 9.3.1 stack, including Android release lint/APK/checksum/artifact upload. The project did not promote that workaround because AGP 9.3 still documents JDK 17 compatibility; release lint was never disabled.
- Opened issue #10 as the explicit AGP 9.3 follow-up and closed PR #9 plus the standalone Dependabot AGP PR #3 without merge.
- Kept stable `file_picker 11.0.2`; the relevant built-in-Kotlin cleanup remains on its 12.0.0 prerelease line, so Version 1.5 does not replace a stable runtime dependency with a beta merely to suppress a forward-looking build warning.
- PR #11 isolated the safe subset: AGP remained 9.1.0, Kotlin moved to 2.4.10, and Gradle moved to 9.7.0. Dependency Review v5, complete CI, Android JDK-17 release APK, Linux, Windows, macOS, unsigned iOS, checksum creation, and artifact uploads all passed before merge.
- Merged PR #11 as `b5ddc657880826bb8a0a5621ff03a99050350342`; standalone Dependabot Kotlin/Gradle PRs #6 and #7 were closed as superseded.
- Post-merge Platform Builds run `31944999081` passed Android job `95159531941`, Linux `95159531882`, Windows `95159531908`, and macOS + unsigned iOS `95159531916`.
- Added repository-integrity coverage at `4f17442920026fdfef2c342707883c0454558195` that pins AGP 9.1.0, Kotlin 2.4.10, and Gradle 9.7.0 and explicitly rejects AGP 9.3.1 while issue #10 remains unresolved.
- Permanent CI run `31945071057`, job `95159704902`, passed formatter, analyzer, **217/217 tests**, Version 1.5 candidate gate, expected-closed stable gate, deterministic solver smoke, WASM dry run, and Web release build.
- Added `docs/ANDROID_TOOLCHAIN.md` and `docs/PHASE_27_VERIFICATION.md` with upgrade policy, failure/diagnostic evidence, accepted artifact digests, and revisit criteria.
- Real-device/accessibility/handler/signing qualification remains **0/13**; no hosted toolchain result was substituted for manual evidence.
"""
write(path, text)

# Compact verification record.
path = "docs/VERIFICATION.md"
text = read(path)
if "## Phase 27 — Android toolchain compatibility qualification" not in text:
    marker = "## Phase 26 — GitHub Actions runtime hardening"
    if marker not in text:
        raise SystemExit("Phase 26 verification marker not found")
    phase27 = """## Phase 27 — Android toolchain compatibility qualification

Date: **2026-08-16**

Accepted Android baseline:

```text
AGP: 9.1.0
Kotlin Android: 2.4.10
Gradle: 9.7.0
Normal hosted Android Java baseline: JDK 17
```

Permanent quality evidence after adding the baseline regression:

```text
Commit: 4f17442920026fdfef2c342707883c0454558195
CI run: 31945071057
CI job: 95159704902
Result: SUCCESS
Runner: 2.336.0 / Ubuntu 24.04.4 LTS
Flutter: 3.47.0 stable
Dart: 3.13.0
Formatting: PASS — 98 files, 0 changed
Static analysis: PASS — No issues found
Tests: PASS — 217/217
Candidate readiness: PASS — candidateGatePassed=true; readyForStable=false; 0/13 manual evidence complete
Stable promotion boundary: PASS — strict stable mode correctly remained closed
Solver smoke benchmark: PASS
WASM dry run: PASS
Missing icon-font warning guard: PASS
Web release: PASS — build/web
```

Post-merge hosted native matrix:

```text
Source: b5ddc657880826bb8a0a5621ff03a99050350342
Platform Builds run: 31944999081
Android job 95159531941: SUCCESS
Linux job 95159531882: SUCCESS
Windows job 95159531908: SUCCESS
macOS + unsigned iOS job 95159531916: SUCCESS
```

AGP 9.3.1 is intentionally deferred. PR #9 failed Android release lint on JDK 17 but passed a branch-only JDK 21 diagnostic; issue #10 tracks the upstream/toolchain mismatch. The accepted safe subset was merged through PR #11. Focused evidence is in [`PHASE_27_VERIFICATION.md`](PHASE_27_VERIFICATION.md) and policy/revisit criteria are in [`ANDROID_TOOLCHAIN.md`](ANDROID_TOOLCHAIN.md).

Real-world stable qualification remains **0/13**.

"""
    text = text.replace(marker, phase27 + marker, 1)
write(path, text)

# Hosted artifact ledger.
path = "docs/RELEASE_ARTIFACTS.md"
text = read(path)
if "## Phase 27 accepted Android-toolchain hosted artifact set" not in text:
    text += """

## Phase 27 accepted Android-toolchain hosted artifact set

Accepted Platform Builds run: **31944999081**, source `b5ddc657880826bb8a0a5621ff03a99050350342`.

| Artifact | ID | Size | GitHub artifact digest |
| --- | ---: | ---: | --- |
| `nova-2048-android-release` | 9263084669 | 25,409,403 bytes | `sha256:9ad0c47f342114d73e6406ccaa5cff04c67e4c708fb689ae3ec3c0bdb359acb4` |
| `nova-2048-linux-x64-release` | 9263046299 | 10,396,699 bytes | `sha256:8c69f45255c519d83c1c31be865245fb4f0e8341418d7e45c37860e98281c0ef` |
| `nova-2048-windows-x64-release` | 9263072124 | 12,655,205 bytes | `sha256:6428785087a24c9159015359b1050312358f03c126f52619e321769f903042ae` |
| `nova-2048-macos-release` | 9263081008 | 18,739,173 bytes | `sha256:e83fc68b20008031de909cd80b170b1cc599aac3db6d98dd74d3390cf5a3beb1` |
| `nova-2048-ios-unsigned-release` | 9263081347 | 8,709,456 bytes | `sha256:c775b87f66d1fd48a7f1ef8714350d6f832d93a24e48744925a34c77b4f9812f` |

Every Phase 27 accepted-baseline hosted native dependency-sync, build, package, checksum, and upload step completed successfully. These artifacts expire on **2026-08-30**. They remain hosted qualification inputs only and do not change the **0/13** real-world stable-release qualification status.
"""
write(path, text)

# Documentation index.
path = "docs/README.md"
text = read(path)
if "[`ANDROID_TOOLCHAIN.md`](ANDROID_TOOLCHAIN.md)" not in text:
    row = "| [`PLATFORMS.md`](PLATFORMS.md) | Android/iOS/Web/Windows/macOS/Linux setup, build commands, hosted verification, locale behavior, and signing/distribution boundaries. |"
    if row not in text:
        raise SystemExit("PLATFORMS row not found")
    text = text.replace(
        row,
        row + "\n| [`ANDROID_TOOLCHAIN.md`](ANDROID_TOOLCHAIN.md) | Maintained AGP/Kotlin/Gradle baseline, AGP 9.3 deferral evidence, upgrade acceptance rules, and revisit criteria. |",
        1,
    )
if "[`PHASE_27_VERIFICATION.md`](PHASE_27_VERIFICATION.md)" not in text:
    row = "| [`PHASE_26_VERIFICATION.md`](PHASE_26_VERIFICATION.md) | Focused checkout v7, Dependency Review v5, 216-test, Web, and cross-platform Actions-runtime verification record. |"
    if row not in text:
        raise SystemExit("Phase 26 row not found")
    text = text.replace(
        row,
        "| [`PHASE_27_VERIFICATION.md`](PHASE_27_VERIFICATION.md) | Focused Android toolchain experiment, AGP 9.3 deferral, accepted Kotlin/Gradle subset, 217-test, and post-merge native-matrix evidence. |\n" + row,
        1,
    )
write(path, text)

# Platform guide.
path = "docs/PLATFORMS.md"
text = read(path)
marker = "### Development prerequisites\n\nTypical Flutter Android development requires:"
if "AGP **9.1.0**" not in text:
    replacement = """### Maintained build-tool baseline

Version 1.5 currently pins AGP **9.1.0**, Kotlin Android **2.4.10**, and Gradle **9.7.0**. The accepted combination is protected by repository-integrity tests. AGP 9.3.1 is intentionally deferred after its release-lint path failed on the normal JDK 17 baseline even though a branch-only JDK 21 diagnostic succeeded. See [`ANDROID_TOOLCHAIN.md`](ANDROID_TOOLCHAIN.md) and GitHub issue #10 before changing these versions.

### Development prerequisites

Typical Flutter Android development requires:"""
    if marker not in text:
        raise SystemExit("Android development prerequisite marker not found")
    text = text.replace(marker, replacement, 1)
write(path, text)

# Changelog.
path = "CHANGELOG.md"
text = read(path)
added = "### Added\n"
if "Dedicated Android toolchain compatibility policy" not in text:
    text = text.replace(
        added,
        added + "- Dedicated Android toolchain compatibility policy and Phase 27 verification record covering the rejected AGP 9.3/JDK-17 path, JDK-21 diagnostic, accepted safe subset, and final artifacts.\n- Repository-integrity regression pinning the accepted AGP 9.1.0 / Kotlin 2.4.10 / Gradle 9.7.0 baseline and rejecting AGP 9.3.1 while issue #10 remains open.\n",
        1,
    )
changed = "### Changed\n"
if "Kotlin Android 2.4.10" not in text:
    text = text.replace(
        changed,
        changed + "- Android build tooling now uses AGP 9.1.0, Kotlin Android 2.4.10, and Gradle 9.7.0 after a coordinated safe-subset qualification on JDK 17 and all hosted targets.\n- AGP 9.3.1 is intentionally deferred under issue #10: its Android release lint failed on JDK 17 but passed a branch-only JDK 21 diagnostic; release lint was not disabled and the project Java baseline was not raised solely as a workaround.\n- Stable `file_picker 11.0.2` remains in Version 1.5 while the relevant built-in-Kotlin cleanup is still on the package's 12.0.0 prerelease line.\n",
        1,
    )
text = text.replace(
    "- Maintained CI now passes 215/215 tests, 98-file formatting, metadata drift checks, release gates, solver smoke, and a warning-enforced Web build.",
    "- Maintained CI now passes 217/217 tests, 98-file formatting, metadata drift checks, release gates, solver smoke, and a warning-enforced Web build.",
    1,
)
write(path, text)
