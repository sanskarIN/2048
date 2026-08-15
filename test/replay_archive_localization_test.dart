import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/core/localization/nova_localizations.dart';

void main() {
  const hindi = NovaLocalizations(Locale('hi'));

  test('Hindi catalog translates full replay archive controls and status', () {
    expect(hindi.text('Full Replay Archive'), 'पूर्ण रिप्ले आर्काइव');
    expect(hindi.text('Copy full replay'), 'पूर्ण रिप्ले कॉपी करें');
    expect(hindi.text('Open from clipboard'), 'क्लिपबोर्ड से खोलें');
    expect(
      hindi.text('Complete full-session capture available'),
      'पूर्ण-सेशन कैप्चर उपलब्ध है',
    );
    expect(
      hindi.text(
        'Replay archive opened in spectator mode. Your current game was not changed.',
      ),
      'रिप्ले आर्काइव दर्शक मोड में खुला। आपका वर्तमान गेम नहीं बदला गया।',
    );
  });

  test('Hindi catalog translates replay trust and release copy', () {
    const guide =
        'Move Replay can open Full Replay Archive. A newly started game records a bounded deterministic action stream from its opening state, including valid moves, Undo, continue-after-win, and timed status transitions. A complete capture can be copied as portable JSON or opened later from clipboard/manual text in spectator mode. Imported replay data never replaces the live game or imports trusted statistics, achievements, streaks, Daily results, or per-mode records. Capture is limited to 4,096 events; if that safety limit is reached, export is disabled instead of silently creating an incomplete archive. Legacy or restored games that did not begin with full capture remain playable but are not falsely exported as complete sessions.';
    const release =
        'Release candidate 0.9 includes ten game modes, deterministic save and Undo integrity, Daily Challenges, offline shareable seeded Challenge Codes, English/Hindi localization with a persisted language setting, statistics and achievements, seven palettes, accessibility controls, heuristic hints, keyboard shortcuts, an isolated Auto Play Demo with Heuristic and bounded Expectimax strategies, deterministic solver benchmarks, read-only bounded Move Replay, portable spectator-only Full Replay Archives with bounded deterministic action capture, validated portable current-game backup with persistent unranked restore policy, and cross-platform release-build verification.';

    expect(hindi.text(guide), isNot(guide));
    expect(hindi.text(guide), contains('4,096'));
    expect(hindi.text(release), isNot(release));
    expect(hindi.text(release), contains('Full Replay Archives'));
  });
}
