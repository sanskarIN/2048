from pathlib import Path


def read(path: str) -> str:
    return Path(path).read_text(encoding="utf-8")


def write(path: str, text: str) -> None:
    Path(path).write_text(text, encoding="utf-8")


# Move every maintained checkout step to the current v7 runtime.
workflow_dir = Path('.github/workflows')
changed_workflows: list[str] = []
for workflow in sorted(workflow_dir.glob('*.yml')):
    source = workflow.read_text(encoding='utf-8')
    updated = source.replace('actions/checkout@v6', 'actions/checkout@v7')
    if workflow.name == 'dependency-review.yml':
        updated = updated.replace(
            'actions/dependency-review-action@v4',
            'actions/dependency-review-action@v5',
        )
    if updated != source:
        workflow.write_text(updated, encoding='utf-8')
        changed_workflows.append(str(workflow))

if not changed_workflows:
    raise SystemExit('No permanent workflow runtime references required migration.')

# Strengthen repository regression coverage for the maintained workflow runtime baseline.
path = 'test/repository_integrity_test.dart'
text = read(path)
text = text.replace(
    "expect(dependencyReview, contains('actions/dependency-review-action@v4'));",
    "expect(dependencyReview, contains('actions/dependency-review-action@v5'));",
    1,
)
old = """        expect(
          source,
          isNot(contains('actions/checkout@v5')),
          reason: '${workflow.path} still uses checkout v5',
        );
"""
new = old + """        expect(
          source,
          isNot(contains('actions/checkout@v6')),
          reason: '${workflow.path} still uses checkout v6',
        );
"""
if old not in text:
    raise SystemExit('checkout runtime integrity block not found')
text = text.replace(old, new, 1)
text = text.replace(
    "expect(workflow, contains('actions/checkout@v6'));",
    "expect(workflow, contains('actions/checkout@v7'));",
    2,
)
insert = """    test('dependency review uses maintained Node 24 action runtime', () {
      final workflow = File(
        '.github/workflows/dependency-review.yml',
      ).readAsStringSync();

      expect(workflow, contains('actions/checkout@v7'));
      expect(workflow, contains('actions/dependency-review-action@v5'));
      expect(workflow, contains('fail-on-severity: high'));
    });

"""
marker = "    test('CODEOWNERS covers release and platform policy', () {"
if marker not in text:
    raise SystemExit('repository integrity insertion marker not found')
text = text.replace(marker, insert + marker, 1)
write(path, text)

# Keep CI/CD documentation aligned with the actual release gate and workflow set.
path = 'docs/CI_CD.md'
text = read(path)
row = "| `ci.yml` | Flutter-managed metadata drift guard, format verification for application/tests/tools, analyzer, test suite with coverage, release-readiness gates, deterministic solver smoke benchmark, and warning-enforced Web release build. |"
new_row = row + "\n| `dependency-review.yml` | Pull-request dependency diff review for dependency-sensitive changes, failing on newly introduced high-severity vulnerable dependencies. |"
if '`dependency-review.yml` |' not in text:
    if row not in text:
        raise SystemExit('CI workflow table insertion point not found')
    text = text.replace(row, new_row, 1)
text = text.replace(
    '# CI also verifies that --stable fails closed while the package is 0.9.x',
    '# CI also verifies that --stable fails closed while real-world Version 1.5 qualification is incomplete',
    1,
)
runtime_heading = '## Maintained GitHub Actions runtime baseline'
if runtime_heading not in text:
    marker = '## CI quality gate\n'
    if marker not in text:
        raise SystemExit('CI quality heading not found')
    runtime = """## Maintained GitHub Actions runtime baseline

Permanent workflows use `actions/checkout@v7`. Pull-request dependency review uses `actions/dependency-review-action@v5`. These Node 24 action generations are validated on GitHub-hosted runners and are regression-guarded by `test/repository_integrity_test.dart` so an older checkout runtime cannot silently return.

Dependency Review remains a pull-request gate rather than a push-time replacement for normal CI. Its purpose is to inspect dependency changes; formatter, analyzer, tests, release gates, solver smoke, Web build, and applicable native builds remain independent acceptance checks.

"""
    text = text.replace(marker, runtime + marker, 1)
write(path, text)

# Make the supply-chain guide explicit about the maintained action majors.
path = 'docs/SUPPLY_CHAIN.md'
text = read(path)
text = text.replace(
    '`.github/workflows/dependency-review.yml` runs for pull requests that change Pub, Android, or GitHub Actions dependency surfaces. It uses GitHub\'s dependency-review action and fails when a dependency change introduces a known **high-or-higher severity** vulnerability.',
    '`.github/workflows/dependency-review.yml` runs for pull requests that change Pub, Android, or GitHub Actions dependency surfaces. It uses `actions/dependency-review-action@v5` with `actions/checkout@v7` and fails when a dependency change introduces a known **high-or-higher severity** vulnerability.',
    1,
)
if 'actions/dependency-review-action@v5' not in text:
    raise SystemExit('SUPPLY_CHAIN dependency review paragraph was not updated')
write(path, text)

# Record release-facing workflow runtime hardening.
path = 'CHANGELOG.md'
text = read(path)
changed = '### Changed\n'
entry = (
    '- GitHub Actions checkout runtime baseline moved to `actions/checkout@v7` across permanent workflows, including safer fork-PR handling and current action dependencies.\n'
    '- Pull-request dependency review moved to `actions/dependency-review-action@v5` on the Node 24 action runtime.\n'
)
if entry.strip() not in text:
    if changed not in text:
        raise SystemExit('CHANGELOG Changed heading not found')
    text = text.replace(changed, changed + entry, 1)
write(path, text)
