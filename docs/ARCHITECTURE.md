# Architecture

2048 Nova uses a deliberately small layered architecture.

## Domain

`lib/domain` contains the board state, game configuration, deterministic random-source abstraction, and move engine. The engine does not depend on Flutter widgets or local storage.

## Data

`lib/data/local_store.dart` provides versioned SharedPreferences-backed persistence. Corrupt current-game JSON is discarded safely instead of crashing startup.

## App state

`AppController` owns current game orchestration, undo snapshots, settings, statistics, achievements, challenge status refresh, and persistence coordination. UI widgets observe it through `AppScope` (`InheritedNotifier`).

## Features

Each screen sits under `lib/features`. Reusable UI lives in `lib/shared`; theme and project constants live in `lib/core`.

## Dependency policy

The project intentionally uses only `shared_preferences` and `url_launcher` beyond Flutter itself. This keeps the offline game lightweight and avoids coupling the deterministic engine to a state-management or database framework.
