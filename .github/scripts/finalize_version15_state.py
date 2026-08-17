from pathlib import Path


def replace_once(path: str, old: str, new: str) -> None:
    file = Path(path)
    text = file.read_text(encoding="utf-8")
    if new in text:
        return
    if old not in text:
        raise SystemExit(f"Expected text not found in {path}: {old[:100]!r}")
    file.write_text(text.replace(old, new, 1), encoding="utf-8")


def main() -> None:
    replace_once(
        "what_changed.md",
        "- **Current phase:** Phase 28 — workflow and supply-chain reproducibility hardening complete; permanent CI is green at 225 tests with immutable Action revisions, Flutter 3.47.0, disabled composite-action cache execution, least-privilege checkout credentials, explicit Android Temurin 17, verified Gradle 9.7 distribution checksum, and pinned branding-generator dependencies; AGP issue #10 and repository-protection issue #12 remain explicit; 13 real-world qualification checks remain before stable promotion\n- **Latest accepted Version 1.5 native-matrix source:** `f694f508057ebcf1e91a825a90cc764398051647` — `ci(android): pin hosted JDK 17 runtime`\n- **Permanent Version 1.5 CI evidence:** run `31948413257`, job `95167995837` — SUCCESS, 225/225 tests, 99 files formatter-clean, analyzer clean, Flutter 3.47.0, candidate gate passed, strict stable gate correctly closed, solver smoke passed, WASM/Web release passed\n- **Version 1.5 native build evidence:** Platform Builds run `31948335974` — Android, Linux, Windows, macOS, and unsigned iOS jobs all SUCCESS with immutable workflow revisions, frozen Flutter 3.47.0, read-only checkout credential persistence disabled, explicit Android JDK 17, checksummed packaging, and 14-day qualification artifacts",
        "- **Current phase:** Phase 29 — cross-platform timestamp and release-evidence integrity hardening complete; permanent CI is green at 232 tests with 105 Dart files formatter-clean, analyzer-clean Flutter 3.47.0 / Dart 3.13.0, UTC-normalized persisted/portable timestamps, explicit-offset release evidence enforcement, and a fail-closed 0/13 stable qualification boundary; AGP issue #10 and repository-protection issue #12 remain explicit\n- **Latest accepted Version 1.5 native-matrix source:** `439a4441ebd2b36c4e1b6e0700d6f3d3359bd016` — `fix: normalize daily record timestamps to utc`\n- **Permanent Version 1.5 CI evidence:** run `32016750775`, job `95347802636` — SUCCESS, 232/232 tests, 105 files formatter-clean, analyzer clean, Flutter 3.47.0 / Dart 3.13.0, candidate gate passed, strict stable gate correctly closed at 0/13 manual evidence, solver smoke passed, WASM dry run passed, Web release passed\n- **Version 1.5 native build evidence:** Platform Builds run `32015893841` — Android job `95345268019`, Linux `95345268049`, Windows `95345268000`, and macOS + unsigned iOS `95345267946` all SUCCESS with checksummed qualification artifacts",
    )

    verification = Path("docs/VERIFICATION.md")
    verification_text = verification.read_text(encoding="utf-8")
    phase29 = """## Phase 29 — Cross-platform timestamp and release-evidence integrity hardening

Date: **2026-08-17**

```text
Quality source: 32d50735065cb4ec084990ccfe178d16ba5f0c79
CI run: 32016750775
CI job: 95347802636
Result: SUCCESS
Runner: 2.336.0 / Ubuntu 24.04.4 LTS
Flutter: 3.47.0 stable
Dart: 3.13.0
Formatting: PASS — 105 files, 0 changed
Static analysis: PASS — No issues found
Tests: PASS — 232/232
Candidate readiness: PASS — candidateGatePassed=true; readyForStable=false; 0/13 manual evidence complete
Stable promotion boundary: PASS — strict stable mode correctly remained closed
Solver smoke benchmark: PASS
WASM dry run: PASS
Web release: PASS — build/web
```

```text
Native source: 439a4441ebd2b36c4e1b6e0700d6f3d3359bd016
Platform Builds run: 32015893841
Android job 95345268019: SUCCESS — JDK 17, release APK, checksum, artifact upload
Linux job 95345268049: SUCCESS — release bundle, checksum, artifact upload
Windows job 95345268000: SUCCESS — release bundle, checksum, artifact upload
macOS + unsigned iOS job 95345267946: SUCCESS — both release builds, checksums, artifact uploads
```

Phase 29 normalizes persisted game-start, Backup export, Full Replay export, and Daily record timestamps to absolute UTC while retaining legacy timezone-less game-state readability. The release gate also rejects timezone-less passed-evidence timestamps so future qualification evidence always identifies an absolute instant. Focused details are in [`PHASE_29_VERIFICATION.md`](PHASE_29_VERIFICATION.md) and [`PORTABLE_TIMESTAMPS.md`](PORTABLE_TIMESTAMPS.md).

GitHub issue #10 remains the explicit AGP 9.3/JDK-17 compatibility hold and issue #12 remains the repository-settings protection task. Real-world stable qualification remains **0/13**; no physical-device, assistive-technology, signing, or store evidence is inferred from hosted automation.

"""
    if "## Phase 29 — Cross-platform timestamp and release-evidence integrity hardening" not in verification_text:
        anchor = "## Phase 28 — Workflow and supply-chain reproducibility hardening\n"
        if anchor not in verification_text:
            raise SystemExit("Phase 28 verification anchor not found")
        verification.write_text(
            verification_text.replace(anchor, phase29 + anchor, 1),
            encoding="utf-8",
        )

    replace_once(
        "ROADMAP.md",
        "- Release-readiness CLI regression fixtures exercise both opening and fail-closed branches end to end, including a fully qualified synthetic stable fixture plus malformed/incomplete evidence rejection; maintained CI is now 208/208 tests after Phase 23 repository-integrity and explicit-dispatch coverage.",
        "- Release-readiness CLI regression fixtures exercise both opening and fail-closed branches end to end, including a fully qualified synthetic stable fixture plus malformed/incomplete evidence rejection. Phase 29 current maintained CI is 232/232 tests with 105 Dart files formatter-clean, UTC-normalized portable timestamps, and explicit-offset release-evidence validation.",
    )

    replace_once(
        "CHANGELOG.md",
        "- Maintained CI now passes 225/225 tests, 99-file formatting, metadata drift checks, release gates, solver smoke, and a warning-enforced Web build.",
        "- Maintained CI now passes 232/232 tests, 105-file formatting, metadata drift checks, release gates, solver smoke, and a warning-enforced Web build after Phase 29 timestamp/release-evidence hardening.",
    )
    replace_once(
        "CHANGELOG.md",
        "- Current maintained CI evidence now passes 200/200 tests and 97-file formatting on the fixture-tested release-gate source.",
        "- Phase 22 release-gate fixture evidence passed 200/200 tests and 97-file formatting on that historical fixture-tested source; newer current evidence supersedes this count.",
    )

    Path("test/current_release_state_test.dart").write_text(
        """import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('current release-candidate records', () {
    test('primary continuity header points at Phase 29 evidence', () {
      final log = File('what_changed.md').readAsStringSync();

      expect(log, contains('**Current phase:** Phase 29'));
      expect(log, contains('232/232 tests'));
      expect(log, contains('105 files formatter-clean'));
      expect(log, contains('32016750775'));
      expect(log, contains('32015893841'));
    });

    test('verification record keeps Phase 29 ahead of Phase 28', () {
      final verification = File('docs/VERIFICATION.md').readAsStringSync();
      final phase29 = verification.indexOf('## Phase 29 —');
      final phase28 = verification.indexOf('## Phase 28 —');

      expect(phase29, greaterThanOrEqualTo(0));
      expect(phase28, greaterThan(phase29));
      expect(verification, contains('Tests: PASS — 232/232'));
    });

    test('roadmap and changelog expose the current CI baseline', () {
      final roadmap = File('ROADMAP.md').readAsStringSync();
      final changelog = File('CHANGELOG.md').readAsStringSync();

      expect(
        roadmap,
        contains('Phase 29 current maintained CI is 232/232 tests'),
      );
      expect(roadmap, isNot(contains('maintained CI is now 208/208 tests')));
      expect(changelog, contains('Maintained CI now passes 232/232 tests'));
    });
  });
}
""",
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()
