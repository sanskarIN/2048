# Dependency Policy

2048 Nova keeps runtime dependencies deliberately small so the deterministic game engine stays easy to audit, test, and maintain.

## Runtime packages

### Flutter SDK

Provides the application framework, Material UI, animation, accessibility/semantics, keyboard and gesture handling, platform channels, and testing foundations.

### shared_preferences

Used for small local values such as the current game snapshot, bounded undo history, settings, statistics, achievements, and Daily Challenge history.

Why it is used:
- The stored data is small and local.
- No relational queries or remote synchronization are needed.
- It avoids introducing a database solely for a lightweight puzzle game.

The application validates decoded structures and fails safely when project-owned persisted JSON is malformed.

### url_launcher

Used only when a player explicitly opens GitHub, LinkedIn, Buy Me a Coffee, or an email action.

Why it is used:
- It delegates external navigation to supported platform handlers.
- It avoids implementing custom browser/payment/email behavior.
- Failure is handled with a friendly in-app message rather than a crash.

## Development packages

### flutter_test

Provides unit and widget testing support.

### flutter_lints

Provides the baseline static-analysis rules, supplemented by project-specific analyzer rules in `analysis_options.yaml`.

## Policy

Before adding a dependency:

1. Confirm the capability is not already practical with Flutter/Dart.
2. Prefer maintained packages with compatible licenses.
3. Avoid duplicate-purpose packages.
4. Do not add packages that require unnecessary accounts, trackers, or network access.
5. Keep dependency versions controlled in `pubspec.yaml` and the application lockfile when generated.
6. Review dependency updates through CI and Dependabot.
7. Remove packages that become unnecessary or abandoned.

Third-party license information is exposed through Flutter's standard `showLicensePage` UI.
