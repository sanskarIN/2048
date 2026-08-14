import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../domain/game_types.dart';
import 'hindi_translations.dart';

enum AppLanguage { system, english, hindi }

extension AppLanguageX on AppLanguage {
  String get storageValue => name;

  String get label => switch (this) {
        AppLanguage.system => 'System default',
        AppLanguage.english => 'English',
        AppLanguage.hindi => 'हिन्दी',
      };

  Locale? get locale => switch (this) {
        AppLanguage.system => null,
        AppLanguage.english => const Locale('en'),
        AppLanguage.hindi => const Locale('hi'),
      };

  static AppLanguage parse(Object? value) {
    if (value is String) {
      for (final language in AppLanguage.values) {
        if (language.storageValue == value) return language;
      }
    }
    return AppLanguage.system;
  }
}

class NovaLocalizations {
  const NovaLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  static const LocalizationsDelegate<NovaLocalizations> delegate =
      _NovaLocalizationsDelegate();

  static NovaLocalizations of(BuildContext context) {
    final value = Localizations.of<NovaLocalizations>(
      context,
      NovaLocalizations,
    );
    assert(value != null, 'NovaLocalizations not found in widget tree.');
    return value!;
  }

  bool get isHindi => locale.languageCode.toLowerCase() == 'hi';

  String text(String english) {
    if (!isHindi) return english;
    return hindiTranslations[english] ?? _hindi[english] ?? english;
  }

  String modeName(GameMode mode) => text(
        switch (mode) {
          GameMode.classic => 'Classic',
          GameMode.quick => 'Quick',
          GameMode.extended => 'Extended',
          GameMode.challenge => 'Challenge',
          GameMode.endless => 'Endless',
          GameMode.target => 'Target',
          GameMode.timeChallenge => 'Time Challenge',
          GameMode.moveLimit => 'Move Limit',
          GameMode.daily => 'Daily Challenge',
          GameMode.zen => 'Zen',
        },
      );

  String directionName(Direction direction) => text(
        switch (direction) {
          Direction.up => 'Up',
          Direction.down => 'Down',
          Direction.left => 'Left',
          Direction.right => 'Right',
        },
      );

  String boardSize(int size) =>
      isHindi ? '$size × $size बोर्ड' : '$size × $size board';

  String targetTile(int target) =>
      isHindi ? 'लक्ष्य टाइल: $target' : 'Target tile: $target';

  String moveLimit(int moves) =>
      isHindi ? 'चाल सीमा: $moves' : 'Move limit: $moves';

  String timeLimit(int seconds) =>
      isHindi ? 'समय सीमा: $seconds सेकंड' : 'Time limit: $seconds seconds';

  String score(int value) => isHindi ? 'स्कोर: $value' : 'Score: $value';

  String moves(int value) => isHindi ? 'चालें: $value' : 'Moves: $value';

  String highestTile(int value) =>
      isHindi ? 'सबसे बड़ी टाइल: $value' : 'Highest tile: $value';

  String seed(int value) => isHindi ? 'सीड: $value' : 'Seed: $value';

  String achievementTitle(String id, String fallback) {
    if (!isHindi) return fallback;
    return _achievementTitles[id] ?? fallback;
  }

  String achievementDescription(String id, String fallback) {
    if (!isHindi) return fallback;
    return _achievementDescriptions[id] ?? fallback;
  }

  static const _achievementTitles = <String, String>{
    'first_merge': 'पहला मर्ज',
    'tile_128': 'नोवा 128',
    'tile_256': 'नोवा 256',
    'tile_512': 'नोवा 512',
    'tile_1024': 'नोवा 1024',
    'tile_2048': 'नोवा मास्टर',
    'tile_4096': 'नोवा से आगे',
    'tile_8192': 'डीप स्पेस',
    'score_10000': 'पाँच अंक',
    'score_50000': 'स्कोर सुपरनोवा',
    'win_1': 'पहली जीत',
    'win_5': 'नोवा स्ट्रीकर',
    'daily_1': 'डेली एक्सप्लोरर',
    'daily_7': 'डेली वॉयेजर',
  };

  static const _achievementDescriptions = <String, String>{
    'first_merge': 'टाइलों की अपनी पहली जोड़ी मर्ज करें।',
    'tile_128': '128 टाइल तक पहुँचें।',
    'tile_256': '256 टाइल तक पहुँचें।',
    'tile_512': '512 टाइल तक पहुँचें।',
    'tile_1024': '1024 टाइल तक पहुँचें।',
    'tile_2048': '2048 टाइल तक पहुँचें।',
    'tile_4096': '4096 टाइल तक पहुँचें।',
    'tile_8192': '8192 टाइल तक पहुँचें।',
    'score_10000': 'एक गेम में कम से कम 10,000 अंक बनाएँ।',
    'score_50000': 'एक गेम में कम से कम 50,000 अंक बनाएँ।',
    'win_1': 'पहली बार किसी गेम के लक्ष्य तक पहुँचें।',
    'win_5': 'पाँच गेम जीतें।',
    'daily_1': 'एक डेली चैलेंज जीतें।',
    'daily_7': 'सात डेली चैलेंज जीतें।',
  };

  static const _hindi = <String, String>{
    '2048 Nova': '2048 नोवा',
    'Classic strategy. Modern polish. Offline-first.':
        'क्लासिक रणनीति। आधुनिक अनुभव। ऑफलाइन-फर्स्ट।',
    'Continue Game': 'गेम जारी रखें',
    'Continue Unranked Backup': 'अनरैंक्ड बैकअप जारी रखें',
    'New Game': 'नया गेम',
    'Daily Challenge': 'डेली चैलेंज',
    'Move Replay': 'मूव रिप्ले',
    'Daily': 'डेली',
    'Challenge Codes': 'चैलेंज कोड',
    'Auto Play Demo': 'ऑटो प्ले डेमो',
    'Statistics': 'आँकड़े',
    'Achievements': 'उपलब्धियाँ',
    'Guide': 'गाइड',
    'Settings': 'सेटिंग्स',
    'Game Backup': 'गेम बैकअप',
    'About': 'परिचय',
    'Support': 'सहायता',
    'Support on Buy Me a Coffee': 'Buy Me a Coffee पर सहयोग करें',
    'Support Sanskar on Buy Me a Coffee':
        'Buy Me a Coffee पर Sanskar का सहयोग करें',
    '2048 Nova, modern puzzle game': '2048 नोवा, आधुनिक पज़ल गेम',
    'Appearance': 'दिखावट',
    'Language': 'भाषा',
    'System default': 'सिस्टम डिफ़ॉल्ट',
    'Brightness': 'ब्राइटनेस',
    'Color theme': 'रंग थीम',
    'High contrast': 'हाई कॉन्ट्रास्ट',
    'Reduced motion': 'कम मोशन',
    'Audio & haptics': 'ऑडियो और हैप्टिक्स',
    'Sound': 'ध्वनि',
    'Enable lightweight game and UI feedback.':
        'हल्का गेम और UI फीडबैक सक्षम करें।',
    'Haptics': 'हैप्टिक्स',
    'Used only on supported platforms.':
        'केवल समर्थित प्लेटफ़ॉर्म पर उपयोग होता है।',
    'Gameplay': 'गेमप्ले',
    'Confirm restart': 'रीस्टार्ट की पुष्टि करें',
    'Data': 'डेटा',
    'Reset current game': 'वर्तमान गेम रीसेट करें',
    'Remove the saved board and undo history.':
        'सेव बोर्ड और अनडू हिस्ट्री हटाएँ।',
    'Reset current game?': 'वर्तमान गेम रीसेट करें?',
    'Your saved board and undo history will be removed.':
        'आपका सेव बोर्ड और अनडू हिस्ट्री हटा दी जाएगी।',
    'Reset statistics': 'आँकड़े रीसेट करें',
    'Clear historical statistics while keeping the active game as the current session.':
        'सक्रिय गेम को वर्तमान सत्र बनाए रखते हुए पुराने आँकड़े साफ करें।',
    'Clear all locally stored statistics.': 'सभी स्थानीय आँकड़े साफ करें।',
    'Reset statistics?': 'आँकड़े रीसेट करें?',
    'Historical statistics will be cleared. The active game remains counted as the current session so future win-rate data stays valid.':
        'पुराने आँकड़े साफ हो जाएँगे। सक्रिय गेम वर्तमान सत्र के रूप में गिना रहेगा ताकि आगे की जीत-दर सही रहे।',
    'All locally stored statistics will be cleared.':
        'सभी स्थानीय आँकड़े साफ कर दिए जाएँगे।',
    'Reset achievements': 'उपलब्धियाँ रीसेट करें',
    'Reset achievements?': 'उपलब्धियाँ रीसेट करें?',
    'All local achievement unlock dates will be cleared.':
        'सभी स्थानीय उपलब्धि अनलॉक तिथियाँ साफ हो जाएँगी।',
    'Clear all local data': 'सभी स्थानीय डेटा साफ करें',
    'Reset game, settings, statistics, achievements, and daily history.':
        'गेम, सेटिंग्स, आँकड़े, उपलब्धियाँ और डेली हिस्ट्री रीसेट करें।',
    'Clear all local data?': 'सभी स्थानीय डेटा साफ करें?',
    'This removes all 2048 Nova data stored on this device and cannot be undone.':
        'यह इस डिवाइस पर रखा सारा 2048 नोवा डेटा हटा देगा और इसे वापस नहीं किया जा सकता।',
    'Cancel': 'रद्द करें',
    'Clear all': 'सब साफ करें',
    'Reset': 'रीसेट',
    'Local data updated.': 'स्थानीय डेटा अपडेट हो गया।',
    'Classic': 'क्लासिक',
    'Quick': 'क्विक',
    'Extended': 'एक्सटेंडेड',
    'Challenge': 'चैलेंज',
    'Endless': 'एंडलेस',
    'Target': 'टार्गेट',
    'Time Challenge': 'टाइम चैलेंज',
    'Move Limit': 'मूव लिमिट',
    'Zen': 'ज़ेन',
    'Up': 'ऊपर',
    'Down': 'नीचे',
    'Left': 'बाएँ',
    'Right': 'दाएँ',
    'Play': 'खेलें',
    'Continue': 'जारी रखें',
    'Pause': 'रोकें',
    'Resume': 'फिर शुरू करें',
    'Restart': 'रीस्टार्ट',
    'Undo': 'अनडू',
    'Hint': 'संकेत',
    'Home': 'होम',
    'Score': 'स्कोर',
    'Best': 'सर्वश्रेष्ठ',
    'Moves': 'चालें',
    'Highest': 'सबसे बड़ी',
    'Game over': 'गेम समाप्त',
    'You reached the target!': 'आप लक्ष्य तक पहुँच गए!',
    'Keep playing': 'खेलना जारी रखें',
    'Try again': 'फिर प्रयास करें',
    'Back': 'वापस',
    'Close': 'बंद करें',
    'Copy': 'कॉपी',
    'Paste': 'पेस्ट',
    'Validate': 'जाँचें',
    'Generate': 'बनाएँ',
    'Start this challenge': 'यह चैलेंज शुरू करें',
    'Replace current game?': 'वर्तमान गेम बदलें?',
    'Keep current game': 'वर्तमान गेम रखें',
    'Replace': 'बदलें',
    'English': 'English',
    'Hindi': 'हिन्दी',
    'Unlocked': 'अनलॉक',
    'Locked': 'लॉक',
    'Progress': 'प्रगति',
    'Games played': 'खेले गए गेम',
    'Games won': 'जीते गए गेम',
    'Win rate': 'जीत दर',
    'Best score': 'सर्वश्रेष्ठ स्कोर',
    'Highest tile': 'सबसे बड़ी टाइल',
    'Total moves': 'कुल चालें',
    'Total merges': 'कुल मर्ज',
    'Current streak': 'वर्तमान स्ट्रीक',
    'Best streak': 'सर्वश्रेष्ठ स्ट्रीक',
    'Average moves/game': 'औसत चालें/गेम',
    'Average merges/game': 'औसत मर्ज/गेम',
  };
}

class _NovaLocalizationsDelegate
    extends LocalizationsDelegate<NovaLocalizations> {
  const _NovaLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'en' || locale.languageCode == 'hi';

  @override
  Future<NovaLocalizations> load(Locale locale) =>
      SynchronousFuture(NovaLocalizations(locale));

  @override
  bool shouldReload(_NovaLocalizationsDelegate old) => false;
}

extension NovaLocalizationBuildContext on BuildContext {
  NovaLocalizations get l10n => NovaLocalizations.of(this);
}
