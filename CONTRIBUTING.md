# Contributing to 2048 Nova

Thank you for helping improve 2048 Nova.

## Setup

1. Install Flutter stable and Git.
2. Fork or clone the repository.
3. Run `flutter pub get`.
4. Before opening a pull request, run:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web --release
```

## Development rules

- Keep domain/game logic independent from UI where practical.
- Add regression tests for bug fixes.
- Keep user-facing strings and accessibility labels clear.
- Do not commit secrets, generated credentials, private data, or unlicensed assets.
- Prefer small, coherent Conventional Commits such as `feat:`, `fix:`, `test:`, `docs:`, `chore:`, and `ci:`.

## Pull requests

Explain the change, testing performed, screenshots for UI changes, accessibility impact, performance impact, and any breaking changes. Link relevant issues.
