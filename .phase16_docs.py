from pathlib import Path


def append_once(path: str, heading: str, body: str) -> None:
    file = Path(path)
    text = file.read_text()
    if heading in text:
        return
    file.write_text(text.rstrip() + "\n\n" + heading + "\n\n" + body.strip() + "\n")


def replace_once(path: str, old: str, new: str) -> None:
    file = Path(path)
    text = file.read_text()
    if new in text:
        return
    if old not in text:
        raise SystemExit(f"missing anchor in {path}: {old}")
    file.write_text(text.replace(old, new, 1))


append_once(
    "README.md",
    "## Language and localization",
    """
2048 Nova supports **English** and **Hindi (हिन्दी)** without requiring a translation service or project server. Settings can follow the supported system locale or explicitly choose English or Hindi. The choice is persisted locally with the existing app settings and malformed/unsupported stored language values safely fall back to System default.

Player-facing Home, modes, gameplay controls/dialogs, Daily Challenge, statistics, achievements, Challenge Codes, Game Backup, Move Replay, Auto Play Demo, Guide, About, Support, external-link fallbacks, and board accessibility semantics use the localization layer. Protocol identifiers such as `NOVA1`, JSON keys, seeds, tile values, URLs, and email addresses remain exact.

See [`docs/LOCALIZATION.md`](docs/LOCALIZATION.md) for architecture, fallback rules, privacy behavior, contributor guidance, automated coverage, and remaining manual Hindi accessibility/layout qualification.
""",
)

append_once(
    "docs/USER_GUIDE.md",
    "## Language",
    """
Open **Settings → Language** and choose **System default**, **English**, or **हिन्दी**. The choice is stored locally and takes effect across the app without an account, cloud sync, or online translation request.

System default follows English or Hindi when the device reports one of those supported locales; unsupported system locales fall back to English. Clearing all 2048 Nova local data also restores the language setting to System default.

Machine-readable Challenge Code/backup data, URLs, email addresses, seeds, and tile numbers are not translated. Hindi mode localizes player-facing controls, status text, error paths, and positional board semantics while preserving game rules and deterministic behavior.
""",
)

append_once(
    "docs/FAQ.md",
    "## Can I use 2048 Nova in Hindi?",
    """
Yes. Open **Settings → Language** and select **हिन्दी**. You can also choose **System default** or **English**. Language preference is local, works offline, and does not send text to an online translation service.

If the stored language value becomes malformed or references an unsupported value, the app safely falls back to System default. Automated tests cover representative Hindi UI and board semantics, while real-device Hindi font/layout and screen-reader qualification remains part of the manual release checklist.
""",
)

append_once(
    "docs/ARCHITECTURE.md",
    "## Localization architecture",
    """
Localization is kept under `lib/core/localization/` rather than inside game rules or persistence code. `NovaLocalizations` declares supported locales, exposes `BuildContext.l10n`, owns typed dynamic helpers, and uses English source text as the defensive fallback. `hindi_translations.dart` contains the main Hindi fixed-string catalog.

`NovaApp` registers the project delegate plus Flutter's Material, Widgets, and Cupertino localization delegates. `AppSettings.language` stores `system`, `english`, or `hindi`; malformed persisted values fall back to System default. Switching language does not recreate or reinterpret `GameState`, RNG, Undo, ranking policy, Daily history, Challenge Codes, Replay, Auto Play, or portable backup data.

The architecture deliberately has no remote translation service. See [`LOCALIZATION.md`](LOCALIZATION.md).
""",
)

append_once(
    "docs/DATA_STORAGE.md",
    "## Language preference",
    """
The existing settings object now includes `language` with one of three validated values: `system`, `english`, or `hindi`. It does not require a new top-level SharedPreferences key or a settings schema migration.

Missing, wrongly typed, or unsupported language values are interpreted as `system`. The setting contains only the user's local UI preference; no locale selection is uploaded by the project. Clearing all project data restores the default `system` preference.
""",
)

append_once(
    "docs/ACCESSIBILITY.md",
    "## Localized accessibility semantics",
    """
English and Hindi use the same accessibility structure. In Hindi mode the game-board container and positional tile/empty-cell semantics are localized, including row, column, and tile value. Standard Material controls receive the selected locale through Flutter's official localization delegates.

Automated widget/semantics tests verify representative Hindi Home/Settings text and board labels. They do **not** prove final real assistive-technology quality. Stable release still requires Hindi checks with TalkBack, VoiceOver, representative desktop/browser screen readers, large text, narrow layouts, focus traversal, and language switching on real platforms.
""",
)

append_once(
    "docs/PRIVACY.md",
    "## Localization privacy",
    """
Language switching is an offline local operation. 2048 Nova does not send UI strings, selected language, game text, clipboard contents, or user data to an online translation API. English and Hindi strings ship with the application.

Changing language does not alter or upload saved games, statistics, achievements, Daily history, Challenge Codes, Game Backup, Replay, or Auto Play data. The only network-capable actions remain explicit external browser/email/support destinations initiated by the player.
""",
)

append_once(
    "docs/DEPENDENCIES.md",
    "## Localization dependency",
    """
Phase 16 adds `flutter_localizations` from the **Flutter SDK** so Material, Widgets, and Cupertino framework controls follow English/Hindi locale selection correctly. It is not a third-party analytics, translation, networking, or cloud dependency. Flutter's SDK localization package resolves `intl` transitively in `pubspec.lock`.

Project-specific English/Hindi strings remain in repository source under `lib/core/localization/`; no remote translation package or service is used.
""",
)

append_once(
    "docs/DEVELOPMENT.md",
    "## Localization development",
    """
New player-facing fixed strings should be rendered through `context.l10n.text(...)` and supplied with a Hindi catalog entry. Dynamic grammar should use a typed `NovaLocalizations` helper instead of fragile translated-fragment concatenation.

When changing locale behavior, test AppLanguage parsing/persistence, English fallback, Hindi rendering, and relevant semantics. Do not translate protocol tokens, JSON field names, URLs, email addresses, deterministic seeds, or numeric tile values that must remain exact. See [`LOCALIZATION.md`](LOCALIZATION.md) for the full contributor procedure.
""",
)

append_once(
    "docs/PLATFORMS.md",
    "## Locale behavior across platforms",
    """
The application registers English (`en`) and Hindi (`hi`) for Android, iOS, Web, Windows, macOS, and Linux Flutter builds. **System default** follows a supported platform locale; unsupported locales fall back to English. Explicit English/Hindi selection overrides the system locale through `MaterialApp.locale`.

Hosted compilation verifies the code path can build for configured targets, but real platform font rendering, large-text wrapping, IME/input behavior, clipboard dialogs, and screen-reader pronunciation in Hindi remain manual release checks.
""",
)

append_once(
    "docs/TROUBLESHOOTING.md",
    "## Language does not look correct",
    """
Open **Settings → Language** and select English or हिन्दी explicitly to distinguish an app preference issue from the platform's System default locale. If a stored language value is invalid, 2048 Nova falls back safely to System default.

If a specific label remains English while Hindi is selected, report the screen and exact label: the localization layer intentionally falls back to the English source string rather than crashing when a translation key is missing. For clipped/wrapped Hindi text, include device/platform, display size, text-scale setting, and a screenshot when possible.
""",
)

append_once(
    "CONTRIBUTING.md",
    "## Localization contributions",
    """
Player-facing behavior changes must keep English/Hindi localization coherent. Route fixed UI strings through the project localization layer, add Hindi catalog entries, preserve English fallback, and add focused tests for critical flows. Dynamic messages should use typed helpers where grammar or values vary.

Do not translate protocol identifiers, JSON keys, URLs, email addresses, seeds, or code. A registered locale is not considered release-qualified until representative layout and assistive-technology checks are also documented. See [`docs/LOCALIZATION.md`](docs/LOCALIZATION.md).
""",
)

append_once(
    "SUPPORT.md",
    "## Language-related reports",
    """
For a localization issue, include the selected language (**System default**, **English**, or **हिन्दी**), device/platform, the exact screen/label, and the expected wording or layout behavior. For System default problems, also include the device language/region. Do not include unrelated private device data.
""",
)

append_once(
    "SECURITY.md",
    "## Localization security boundary",
    """
Localization is static application data plus a validated local preference. No remote translation endpoint, locale-specific executable code, or downloaded language pack is used. Unknown persisted language values fall back to System default and cannot select arbitrary assets, URLs, or code paths.
""",
)

append_once(
    "docs/RELEASE_CHECKLIST.md",
    "## English/Hindi localization qualification",
    """
Before stable release, manually verify System default, explicit English, and explicit हिन्दी on representative mobile, desktop, and Web targets. Check Home, Settings, modes, gameplay dialogs/metrics, Daily, statistics, achievements, Challenge Codes, Backup, Replay, Auto Play, Guide, About, Support, and external-link fallback text.

Also verify Hindi large-text/narrow-layout wrapping, no clipped critical actions, game-board positional semantics, focus traversal, TalkBack/VoiceOver/representative desktop-browser screen readers, and persistence of the language choice across a real app termination/relaunch. Automated localization tests are evidence, not a substitute for these checks.
""",
)

replace_once(
    "ROADMAP.md",
    "- Responsive touch/keyboard UI, desktop shortcuts, themes, high contrast, reduced motion, sound/haptic toggles, and accessibility semantics.",
    "- Responsive touch/keyboard UI, desktop shortcuts, themes, high contrast, reduced motion, sound/haptic toggles, accessibility semantics, and offline English/Hindi localization with persisted System/English/हिन्दी language selection.",
)
replace_once(
    "ROADMAP.md",
    "- VoiceOver, TalkBack, Narrator/browser-screen-reader checks on representative platforms.",
    "- VoiceOver, TalkBack, Narrator/browser-screen-reader checks on representative platforms, including Hindi semantics, pronunciation, large-text wrapping, and language switching.",
)
replace_once(
    "ROADMAP.md",
    "- Localization framework and Hindi translation.\n",
    "- Additional languages beyond the implemented English/Hindi framework, only with complete translation, layout, persistence, and accessibility qualification.\n",
)

replace_once(
    "CHANGELOG.md",
    "### Added\n",
    "### Added\n- Offline English/Hindi localization framework with System default, English, and हिन्दी language selection, persisted settings, English fallback, localized critical error paths, and Hindi board accessibility semantics.\n- Flutter SDK Material/Widgets/Cupertino localization delegates and a repository-owned Hindi translation catalog; no online translation service is required.\n",
)
replace_once(
    "CHANGELOG.md",
    "### Changed\n",
    "### Changed\n- Home, modes, gameplay controls/dialogs, Daily Challenge, statistics, achievements, Challenge Codes, Game Backup, Move Replay, Auto Play Demo, Guide, About, Support, splash semantics, and external-link fallbacks now use the shared localization layer.\n",
)
