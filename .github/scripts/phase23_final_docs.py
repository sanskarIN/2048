from pathlib import Path
import re
import subprocess


def run(*args):
    return subprocess.run(args, check=True)


def commit(paths, message):
    run('git', 'add', *paths)
    if subprocess.run(['git', 'diff', '--cached', '--quiet']).returncode == 0:
        print(f'No changes for {message}')
        return
    run('git', 'commit', '-m', message)


def replace_required(path, old, new):
    p = Path(path)
    text = p.read_text()
    if new in text:
        return
    if old not in text:
        raise SystemExit(f'Missing anchor in {path}: {old[:100]}')
    p.write_text(text.replace(old, new, 1))


# TESTING: final 208-test source and eighth repository contract.
p = Path('docs/TESTING.md')
text = p.read_text()
text = text.replace(
    'Phase 23 adds `test/repository_integrity_test.dart` with **7 source/repository contract tests**, increasing the maintained suite from 200 to **207 tests**.',
    'Phase 23 adds `test/repository_integrity_test.dart` with **8 source/repository contract tests**, increasing the maintained suite from 200 to **208 tests**.',
)
text = text.replace(
    '7. native builds declare all five checksummed qualification artifacts, hard-fail on missing files, and use bounded retention.',
    '7. native builds declare all five checksummed qualification artifacts, hard-fail on missing files, and use bounded retention;\n8. permanent CI exposes `workflow_dispatch` so maintainers can explicitly verify a bot-authored/documentation head when GitHub intentionally suppresses recursive workflow-token push triggers.',
)
text = text.replace(
    'Accepted permanent CI run `31934191150`, job `95133484471`, on source `a93542ecae7713214f7f3e4e11a03c647e880129` reports:',
    'Final accepted permanent CI run `31934616568`, job `95134494782`, on source `1f48ebc947596915be3104aa5da56eb6ad291fff` reports:',
)
text = text.replace('Tests: PASS — 207/207', 'Tests: PASS — 208/208')
p.write_text(text)
commit(['docs/TESTING.md'], 'docs: finalize 208-test Phase 23 evidence')

# CI/CD: dispatch and final CI evidence.
p = Path('docs/CI_CD.md')
text = p.read_text()
text = text.replace(
    '- every push to `main`;\n- pull requests targeting `main`.',
    '- every push to `main`;\n- pull requests targeting `main`;\n- explicit maintainer `workflow_dispatch` for verifying a chosen current `main` head, including heads produced by repository-writing workflows whose token-authored push intentionally does not recurse into another Actions run.',
)
text = text.replace(
    'Tests: PASS — 207/207',
    'Tests: PASS — 208/208',
)
text = text.replace(
    'CI run: 31934191150\nJob: 95133484471\nSource: a93542ecae7713214f7f3e4e11a03c647e880129',
    'CI run: 31934616568\nJob: 95134494782\nSource: 1f48ebc947596915be3104aa5da56eb6ad291fff',
)
if 'Phase 23 final dispatch hardening' not in text:
    text += '''\n\n### Phase 23 final dispatch hardening\n\nPermanent CI now supports `workflow_dispatch`. This closes a verification usability gap exposed by the Phase 23 documentation refresh: GitHub correctly does not recursively start another workflow from a push authenticated with the repository workflow token, so maintainers need an explicit supported way to run the same quality gate against the resulting head. `test/repository_integrity_test.dart` guards the dispatch trigger as the eighth repository-integrity contract.\n'''
p.write_text(text)
commit(['docs/CI_CD.md'], 'docs: finalize CI dispatch and 208-test evidence')

# Verification: supersede interim Phase 23 quality source, keep native artifact source unchanged.
p = Path('docs/VERIFICATION.md')
text = p.read_text()
text = text.replace(
    'Commit: a93542ecae7713214f7f3e4e11a03c647e880129\nCI run: 31934191150\nCI job: 95133484471',
    'Commit: 1f48ebc947596915be3104aa5da56eb6ad291fff\nCI run: 31934616568\nCI job: 95134494782',
)
text = text.replace('Tests: PASS — 207/207', 'Tests: PASS — 208/208')
if 'Explicit CI dispatch: PASS — workflow_dispatch is present and regression guarded' not in text:
    text = text.replace(
        'Missing icon-font warning guard: PASS\nWeb release: PASS — build/web',
        'Missing icon-font warning guard: PASS\nExplicit CI dispatch: PASS — workflow_dispatch is present and regression guarded\nWeb release: PASS — build/web',
        1,
    )
p.write_text(text)
commit(['docs/VERIFICATION.md'], 'docs: supersede Phase 23 quality evidence with 208 tests')

# Release checklist.
p = Path('docs/RELEASE_CHECKLIST.md')
text = p.read_text()
anchor = '- [x] Five native qualification artifacts upload successfully with hard failure on missing output files and 14-day retention\n'
addition = anchor + '- [x] Permanent CI supports explicit `workflow_dispatch` and the trigger is regression guarded\n'
if 'Permanent CI supports explicit `workflow_dispatch`' not in text:
    if anchor not in text:
        raise SystemExit('Release checklist Phase 23 anchor missing')
    text = text.replace(anchor, addition, 1)
p.write_text(text)
commit(['docs/RELEASE_CHECKLIST.md'], 'docs: record explicit CI dispatch release check')

# Roadmap.
p = Path('ROADMAP.md')
text = p.read_text().replace('maintained CI is now 207/207 tests after Phase 23 repository-integrity coverage.', 'maintained CI is now 208/208 tests after Phase 23 repository-integrity and explicit-dispatch coverage.')
if 'Permanent CI also exposes an explicit maintainer dispatch path' not in text:
    anchor = '- Native hosted builds now package SHA-256 sidecars and retain five short-lived qualification artifacts for Android, Linux, Windows, macOS, and unsigned iOS; artifacts remain inputs to manual qualification rather than substitutes for it.\n'
    if anchor not in text:
        raise SystemExit('Roadmap Phase 23 artifact anchor missing')
    text = text.replace(anchor, anchor + '- Permanent CI also exposes an explicit maintainer dispatch path, regression guarded so bot-authored documentation/generator heads can be verified without relying on recursive workflow-token pushes.\n', 1)
p.write_text(text)
commit(['ROADMAP.md'], 'docs: finalize Phase 23 roadmap at 208 tests')

# Changelog.
p = Path('CHANGELOG.md')
text = p.read_text()
text = text.replace('Seven repository-integrity regressions', 'Eight repository-integrity regressions')
text = text.replace('Maintained CI now passes 207/207 tests', 'Maintained CI now passes 208/208 tests')
if 'Permanent CI now supports explicit maintainer `workflow_dispatch`' not in text:
    anchor = '- Repository-owned workflows now use `actions/checkout@v6`; platform artifacts use `actions/upload-artifact@v7`.\n'
    if anchor not in text:
        raise SystemExit('Changelog checkout anchor missing')
    text = text.replace(anchor, anchor + '- Permanent CI now supports explicit maintainer `workflow_dispatch`, guarded by a repository-integrity regression for verification of bot-authored heads.\n', 1)
p.write_text(text)
commit(['CHANGELOG.md'], 'docs: finalize Phase 23 changelog at 208 tests')

# what_changed: top pointers + final evidence/addendum.
p = Path('what_changed.md')
text = p.read_text()
text = text.replace(
    '- **Latest production-code commit used by native build verification:** `eacdb9dc04b4467271f98ce2104e60daf0124f6d` — `fix: use portable page transition builders`',
    '- **Latest runtime/native integration commit used by Phase 23 native build verification:** `1d445c7b8291260e974a1d0132c9417f1132b48e` — `build: generate Flutter platform runners`\n- **Latest release-pipeline commit used by retained native artifact verification:** `5b22795d5aba661bd587e7bcbf2ae6442c8b4b3a` — `ci: retain checksummed native qualification artifacts`',
)
text = text.replace('Tests: PASS — 207/207', 'Tests: PASS — 208/208')
text = text.replace('Repository-integrity regressions: PASS — 7/7', 'Repository-integrity regressions: PASS — 8/8')
text = text.replace(
    'Permanent CI run **31934191150**, job **95133484471**, verified source `a93542ecae7713214f7f3e4e11a03c647e880129`:',
    'Final permanent CI run **31934616568**, job **95134494782**, verified source `1f48ebc947596915be3104aa5da56eb6ad291fff`:',
)
if '8997945b11e0db749ad24dbb434d3f3ef8c3dc5e  ci: allow explicit quality gate dispatch' not in text:
    old = 'a0581eb13722b28e9f98cf3e2920832b80fa48af  docs: define native qualification artifact handling\n```'
    new = 'a0581eb13722b28e9f98cf3e2920832b80fa48af  docs: define native qualification artifact handling\n8997945b11e0db749ad24dbb434d3f3ef8c3dc5e  ci: allow explicit quality gate dispatch\n1f48ebc947596915be3104aa5da56eb6ad291fff  test: guard manual CI dispatch support\n```'
    if old not in text:
        raise SystemExit('what_changed Phase23 commit block anchor missing')
    text = text.replace(old, new, 1)
if '### Final Phase 23 dispatch verification improvement' not in text:
    text += '''\n\n### Final Phase 23 dispatch verification improvement\n\nThe documentation helper completed successfully and removed itself, but its cleanup push was authenticated by GitHub Actions. GitHub intentionally suppresses recursive workflow execution for ordinary workflow-token pushes, which meant the permanent CI workflow had no supported explicit trigger for verifying that exact bot-authored documentation head.\n\nCommit `8997945b11e0db749ad24dbb434d3f3ef8c3dc5e` adds `workflow_dispatch` to permanent CI. Commit `1f48ebc947596915be3104aa5da56eb6ad291fff` adds the eighth repository-integrity regression so that manual dispatch support cannot silently disappear. The normal push-triggered CI on `1f48ebc947596915be3104aa5da56eb6ad291fff` then passed 208/208 tests, metadata drift, formatting, analysis, both release-gate directions, solver smoke, WASM dry run, and the warning-enforced Web release build.\n\nThis changes no manual release evidence. The real qualification manifest remains 0/13 passed, and stable `1.0.0` remains intentionally unavailable.\n'''
p.write_text(text)
commit(['what_changed.md'], 'docs: finalize Phase 23 continuity at 208 tests')
