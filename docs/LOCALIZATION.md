# Localization

2048 Nova includes an offline localization layer for **English** and **Hindi (हिन्दी)**. The player can follow the device/system language or explicitly choose English or Hindi from Settings.

## Supported languages

| Setting | Effective locale |
| --- | --- |
| System default | Uses a supported system locale when possible; otherwise falls back to English. |
| English | `en` |
| हिन्दी | `hi` |

The selected preference is stored inside the existing local `AppSettings` JSON. Invalid, missing, or unsupported stored values safely fall back to **System default**.

## Runtime architecture

Localization code lives under:

```text
lib/core/localization/
├── nova_localizations.dart
└── hindi_translations.dart
```

`NovaLocalizations` owns:

- supported locale declarations;
- the Flutter localization delegate;
- English-as-source fallback behavior;
- dynamic helpers for modes, directions, board sizes, targets, limits, score/move/tile metrics, and achievement text;
- a `BuildContext.l10n` extension used by feature screens.

`hindi_translations.dart` contains the larger static Hindi catalog. A small compatibility catalog remains in `nova_localizations.dart`; new fixed UI strings should normally be added to `hindi_translations.dart`.

The application also registers Flutter's official SDK delegates:

- `GlobalMaterialLocalizations`;
- `GlobalWidgetsLocalizations`;
- `GlobalCupertinoLocalizations`.

This allows standard Material/Cupertino controls to follow the selected locale without adding a third-party translation framework.

## Fallback rule

English source text is the fallback. If a Hindi catalog entry is absent, `NovaLocalizations.text()` returns the English source string instead of throwing, rendering an empty label, or preventing startup.

That fallback is defensive; a new user-facing feature should still add Hindi text and regression coverage in the same change.

## Persisted language setting

`AppSettings` stores:

```json
{
  "language": "system"
}
```

Supported stored values are:

```text
system
english
hindi
```

`AppLanguageX.parse()` validates stored input. Wrong types and unknown strings return `AppLanguage.system`.

Clearing all project data recreates default settings, so language returns to System default together with the rest of the app preferences.

## Offline and privacy behavior

Localization is entirely local:

- no translation request is sent to a project server;
- no online translation API is used;
- no language choice is sent to analytics or advertising software;
- no account is required;
- switching language does not change game rules, RNG, ranking, Daily history, backups, replays, or Challenge Codes.

Challenge Code protocol identifiers such as `NOVA1`, JSON field names, deterministic seeds, tile values, repository URLs, email addresses, and other machine-readable identifiers remain unchanged across locales.

## Accessibility

Player-facing board semantics are locale aware. Hindi mode includes Hindi board-size, row/column, tile-value, and empty-cell semantic labels. The language selector itself uses visible text rather than flags alone.

Automated semantics tests protect representative English and Hindi labels, but stable release still requires manual checks with real assistive technologies, including:

- TalkBack on Android;
- VoiceOver on iOS/macOS;
- Narrator or another representative Windows screen reader;
- representative browser screen readers;
- large text and narrow layouts in Hindi;
- focus order and control announcements after changing language.

## Adding a new fixed string

For a user-facing fixed string:

1. Keep the English source wording clear and stable.
2. Render it through `context.l10n.text(...)` or an appropriate typed localization helper.
3. Add the exact English key and Hindi translation to the catalog.
4. Do not translate protocol tokens, URLs, email addresses, code, or numeric game values that must remain exact.
5. Add/update a focused unit or widget test when the string belongs to a critical flow.
6. Run formatting, analyzer, tests, and the Web release build.
7. Update relevant user/maintainer documentation.

## Adding dynamic text

Do not construct complex translated grammar by blindly concatenating individually translated English fragments. Prefer a typed helper on `NovaLocalizations` when values are dynamic, for example score, move counts, targets, time limits, modes, directions, or other parameterized messages.

If plural/grammar requirements expand beyond the current English/Hindi needs, migrate the specific message family to a structured message format rather than adding fragile string concatenation.

## Adding another locale

A new locale requires all of the following:

1. add the locale to `NovaLocalizations.supportedLocales`;
2. extend `AppLanguage` and its persisted parser/locale mapping;
3. add the locale's catalog or structured message implementation;
4. ensure Flutter Material/Widgets/Cupertino delegates support the locale;
5. add persistence/malformed-value tests;
6. add representative app/navigation/widget/semantics tests;
7. test real layouts, font fallback, input, and assistive technology manually;
8. update privacy, accessibility, user guide, FAQ, testing, verification, and release documentation.

Do not claim a locale as complete merely because `Locale(...)` is registered. Player-visible strings, dynamic messages, semantics, error paths, and manual layout/accessibility qualification all matter.

## Testing

Phase 16 adds focused tests for:

- supported and malformed `AppLanguage` parsing;
- critical Hindi catalog translations;
- English identity behavior;
- safe unknown-key fallback;
- mode/direction/achievement helper localization;
- language preference persistence across controller restart;
- malformed persisted-language recovery;
- Hindi Home and Settings rendering;
- Hindi board semantics.

See [`TESTING.md`](TESTING.md) and [`VERIFICATION.md`](VERIFICATION.md) for current repository-wide evidence.

## Verified Phase 16 evidence

The completed repository-wide gate for the localization phase is:

```text
CI run: 31806785165
Commit: 9dea87e73803d83c3aa0614d35f7860773dbca04
Flutter: 3.47.0 stable
Dart: 3.13.0
Format: 70 files, 0 changed
Analyze: No issues found
Tests: 134/134 passed
Web release: passed
```

The runtime localization source was also compiled successfully by Platform Builds run `31804713200` on commit `5048486775b0c9702583f348bfc5be71219e83ae` for Android, Linux, Windows, macOS, and unsigned iOS.

These automated results do not replace real English/Hindi font, layout, screen-reader, focus, clipboard, lifecycle, or store-metadata qualification.
