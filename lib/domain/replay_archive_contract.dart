// Full Replay Archive maintenance contract.
//
// The executable protocol and reconstruction logic lives in
// `replay_archive.dart`. This source-level contract intentionally contains no
// runtime declarations; it keeps the security/trust assumptions adjacent to
// the domain implementation so future changes are reviewed against them.
//
// - `nova2048.fullReplay` is a versioned, user-editable spectator format.
// - Deterministic reconstruction proves self-consistency, not authorship,
//   identity, signing, authentication, or anti-cheat provenance.
// - Imported replay data must never become `AppController.game` or trusted
//   statistics, achievements, streaks, Daily history, or per-mode records.
// - Full-session export requires capture from the session start and must fail
//   closed after the 4,096-event bound is exceeded.
// - Timed reconstruction must use recorded replay event time, never the
//   spectator device's current wall clock.
// - Growing replay history must remain bounded and corruption-safe.
// - Clipboard reads/writes remain explicit user actions through TextClipboard.
//
// See `docs/REPLAY_ARCHIVES.md` for the complete protocol and release boundary.
