# 2048 Nova Maintainer Tools

The `tool/` directory contains deterministic, repository-owned command-line utilities used for solver benchmarking and release maintenance. These tools are intended to be run from the repository root with the Dart SDK supplied by the supported Flutter toolchain.

## Repository integrity audit

```bash
dart run tool/repository_audit.dart --json
```

Checks required project/open-source/release/workflow files, package/runtime/qualification version consistency, known temporary maintenance leftovers, and repository-local Markdown destinations. See [`../docs/REPOSITORY_AUDIT.md`](../docs/REPOSITORY_AUDIT.md).

## Release readiness gate

Candidate mode:

```bash
dart run tool/release_readiness.dart --json
```

Strict stable mode:

```bash
dart run tool/release_readiness.dart --stable --json
```

The stable form must remain fail-closed until all 13 genuine real-world qualification records and final stable metadata are complete. See [`../docs/RELEASE_QUALIFICATION.md`](../docs/RELEASE_QUALIFICATION.md).

## Qualification evidence recorder

List the current manual checks without mutation:

```bash
dart run tool/record_release_qualification.dart --list
```

Record evidence only after the corresponding representative real-world check has actually been performed. See [`../docs/QUALIFICATION_RECORDER.md`](../docs/QUALIFICATION_RECORDER.md).

## Solver benchmark

Run the deterministic solver smoke/benchmark harness:

```bash
dart run tool/solver_benchmark.dart 8
```

The benchmark compares the isolated Auto Play strategies without touching player saves, statistics, achievements, or Daily Challenge history. See [`../docs/SOLVER_BENCHMARKS.md`](../docs/SOLVER_BENCHMARKS.md).

## Maintenance rule

These utilities are part of the source-controlled release contract. Changes to them must remain formatter-clean, analyzer-clean, regression-tested where applicable, documented, and compatible with the permanent CI workflow. Tool output is automated evidence only; it must never be misrepresented as physical-device, assistive-technology, signing, provisioning, external-handler, or store-distribution qualification.
