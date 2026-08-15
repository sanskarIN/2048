from pathlib import Path
import subprocess


def run(*args: str) -> None:
    subprocess.run(args, check=True)


def commit(paths: list[str], message: str) -> None:
    run('git', 'add', *paths)
    run('git', 'commit', '-m', message)


run('git', 'config', 'user.name', 'Sanskar')
run('git', 'config', 'user.email', 'sanskarin@outlook.in')

# Guide: expose QR behavior and its trust/privacy boundary.
p = Path('lib/features/guide/guide_screen.dart')
s = p.read_text()
old = "Home can open Challenge Codes to create or open an offline shared deterministic challenge. A NOVA1 code contains only a supported game configuration and random seed, so the same code produces the same opening board and random state. It never contains board progress, score, lifetime statistics, achievements, Daily history, settings, or Undo snapshots. Codes are checksummed for accidental corruption, not signed or encrypted. Daily Challenge stays separate because it already uses the UTC date as its shared seed. Starting a valid code creates a fresh normal non-Daily game and uses the normal local statistics policy."
new = "Home can open Challenge Codes to create or open an offline shared deterministic challenge. A generated code is shown as selectable NOVA1 text and as a local black-on-white QR containing that exact same text, so another device can scan it with its own camera or scanner app. 2048 Nova does not request camera access or upload QR contents. A NOVA1 code contains only a supported game configuration and random seed, never board progress, score, lifetime statistics, achievements, Daily history, settings, or Undo snapshots. Codes are checksummed for accidental corruption, not signed, encrypted, authenticated, or proof of identity. Daily Challenge stays separate because it already uses the UTC date as its shared seed. Starting a valid code creates a fresh normal non-Daily game and uses the normal local statistics policy."
assert old in s
s = s.replace(old, new, 1)
old_access = "Use system text scaling, keyboard controls, positional semantic tile labels, high contrast, and reduced motion. Tile values are always shown as text, not color alone. Challenge Codes use labeled form controls, selectable generated text, explicit validation feedback, and a decoded configuration preview."
new_access = "Use system text scaling, keyboard controls, positional semantic tile labels, high contrast, and reduced motion. Tile values are always shown as text, not color alone. Challenge Codes use labeled form controls, selectable generated text, a semantic label for the QR, explicit validation feedback, and a decoded configuration preview; the text remains available so QR scanning is never the only sharing path."
assert old_access in s
s = s.replace(old_access, new_access, 1)
old_privacy = "Core gameplay, Challenge Codes, Game Backup validation, Move Replay, Full Replay Archive, Auto Play Demo, and language switching work without a project server. No account, analytics, advertising tracker, remote AI service, cloud synchronization, or online translation service is required. Clipboard text is read or written only after you choose the corresponding Challenge Code, Game Backup, or Full Replay Archive action."
new_privacy = "Core gameplay, Challenge Code text/QR generation, Game Backup validation, Move Replay, Full Replay Archive, Auto Play Demo, and language switching work without a project server. QR rendering is local and does not request camera access. No account, analytics, advertising tracker, remote AI service, cloud synchronization, or online translation service is required. Clipboard text is read or written only after you choose the corresponding Challenge Code, Game Backup, or Full Replay Archive action."
assert old_privacy in s
s = s.replace(old_privacy, new_privacy, 1)
p.write_text(s)
commit([str(p)], 'docs: explain Challenge Code QR in guide')

# About release highlights.
p = Path('lib/features/about/about_screen.dart')
s = p.read_text()
old = "Release candidate 0.9 includes ten game modes, deterministic save and Undo integrity, Daily Challenges, offline shareable seeded Challenge Codes, English/Hindi localization with a persisted language setting, statistics and achievements, seven palettes, accessibility controls, heuristic hints, keyboard shortcuts, an isolated Auto Play Demo with Heuristic and bounded Expectimax strategies, deterministic solver benchmarks, read-only bounded Move Replay, portable spectator-only Full Replay Archives with bounded deterministic action capture, validated portable current-game backup with persistent unranked restore policy, and cross-platform release-build verification."
new = "Release candidate 0.9 includes ten game modes, deterministic save and Undo integrity, Daily Challenges, offline shareable seeded Challenge Codes with local QR rendering, English/Hindi localization with a persisted language setting, statistics and achievements, seven palettes, accessibility controls, heuristic hints, keyboard shortcuts, an isolated Auto Play Demo with Heuristic and bounded Expectimax strategies, deterministic solver benchmarks, read-only bounded Move Replay, portable spectator-only Full Replay Archives with bounded deterministic action capture, validated portable current-game backup with persistent unranked restore policy, and cross-platform release-build verification."
assert old in s
s = s.replace(old, new, 1)
p.write_text(s)
commit([str(p)], 'docs: add Challenge Code QR to release highlights')

# Hindi catalog entries for every newly changed product string.
p = Path('lib/core/localization/hindi_translations.dart')
s = p.read_text()
marker = "const hindiTranslations = <String, String>{\n"
assert marker in s
entries = """  'Home can open Challenge Codes to create or open an offline shared deterministic challenge. A generated code is shown as selectable NOVA1 text and as a local black-on-white QR containing that exact same text, so another device can scan it with its own camera or scanner app. 2048 Nova does not request camera access or upload QR contents. A NOVA1 code contains only a supported game configuration and random seed, never board progress, score, lifetime statistics, achievements, Daily history, settings, or Undo snapshots. Codes are checksummed for accidental corruption, not signed, encrypted, authenticated, or proof of identity. Daily Challenge stays separate because it already uses the UTC date as its shared seed. Starting a valid code creates a fresh normal non-Daily game and uses the normal local statistics policy.':
      'होम से चैलेंज कोड खोलकर ऑफलाइन साझा निर्धारक चैलेंज बनाया या खोला जा सकता है। बनाया गया कोड चुनने योग्य NOVA1 टेक्स्ट और उसी टेक्स्ट वाले स्थानीय काले-सफेद QR के रूप में दिखता है, जिसे दूसरा डिवाइस अपने कैमरा या स्कैनर ऐप से स्कैन कर सकता है। 2048 Nova कैमरा अनुमति नहीं मांगता और QR सामग्री अपलोड नहीं करता। NOVA1 कोड में केवल समर्थित गेम कॉन्फ़िगरेशन और रैंडम सीड होता है; बोर्ड प्रगति, स्कोर, लाइफटाइम आँकड़े, उपलब्धियाँ, डेली इतिहास, सेटिंग्स या Undo स्नैपशॉट नहीं। चेकसम केवल आकस्मिक खराबी पहचानता है; यह हस्ताक्षर, एन्क्रिप्शन, प्रमाणीकरण या पहचान का प्रमाण नहीं है। डेली चैलेंज अलग रहता है क्योंकि वह UTC तारीख को साझा सीड के रूप में उपयोग करता है। वैध कोड शुरू करने पर नया सामान्य गैर-डेली गेम बनता है और सामान्य स्थानीय आँकड़ा नीति लागू होती है।',
  'Use system text scaling, keyboard controls, positional semantic tile labels, high contrast, and reduced motion. Tile values are always shown as text, not color alone. Challenge Codes use labeled form controls, selectable generated text, a semantic label for the QR, explicit validation feedback, and a decoded configuration preview; the text remains available so QR scanning is never the only sharing path.':
      'सिस्टम टेक्स्ट स्केलिंग, कीबोर्ड नियंत्रण, स्थान-आधारित सिमेंटिक टाइल लेबल, हाई कॉन्ट्रास्ट और कम मोशन का उपयोग करें। टाइल मान हमेशा टेक्स्ट में दिखते हैं, केवल रंग से नहीं। चैलेंज कोड में लेबल वाले फॉर्म नियंत्रण, चुनने योग्य बनाया गया टेक्स्ट, QR के लिए सिमेंटिक लेबल, स्पष्ट वैलिडेशन प्रतिक्रिया और डिकोडेड कॉन्फ़िगरेशन प्रीव्यू है; टेक्स्ट उपलब्ध रहता है ताकि QR स्कैनिंग कभी भी एकमात्र साझा करने का तरीका न हो।',
  'Core gameplay, Challenge Code text/QR generation, Game Backup validation, Move Replay, Full Replay Archive, Auto Play Demo, and language switching work without a project server. QR rendering is local and does not request camera access. No account, analytics, advertising tracker, remote AI service, cloud synchronization, or online translation service is required. Clipboard text is read or written only after you choose the corresponding Challenge Code, Game Backup, or Full Replay Archive action.':
      'मुख्य गेमप्ले, चैलेंज कोड टेक्स्ट/QR निर्माण, गेम बैकअप वैलिडेशन, मूव रिप्ले, फुल रिप्ले आर्काइव, ऑटो प्ले डेमो और भाषा बदलना प्रोजेक्ट सर्वर के बिना काम करते हैं। QR स्थानीय रूप से बनता है और कैमरा एक्सेस नहीं मांगता। किसी अकाउंट, एनालिटिक्स, विज्ञापन ट्रैकर, रिमोट AI सेवा, क्लाउड सिंक्रोनाइज़ेशन या ऑनलाइन अनुवाद सेवा की आवश्यकता नहीं है। क्लिपबोर्ड टेक्स्ट केवल संबंधित चैलेंज कोड, गेम बैकअप या फुल रिप्ले आर्काइव कार्रवाई चुनने पर पढ़ा या लिखा जाता है।',
  'Release candidate 0.9 includes ten game modes, deterministic save and Undo integrity, Daily Challenges, offline shareable seeded Challenge Codes with local QR rendering, English/Hindi localization with a persisted language setting, statistics and achievements, seven palettes, accessibility controls, heuristic hints, keyboard shortcuts, an isolated Auto Play Demo with Heuristic and bounded Expectimax strategies, deterministic solver benchmarks, read-only bounded Move Replay, portable spectator-only Full Replay Archives with bounded deterministic action capture, validated portable current-game backup with persistent unranked restore policy, and cross-platform release-build verification.':
      'रिलीज़ कैंडिडेट 0.9 में दस गेम मोड, निर्धारक सेव और Undo अखंडता, डेली चैलेंज, स्थानीय QR रेंडरिंग वाले ऑफलाइन साझा सीडेड चैलेंज कोड, सहेजी हुई भाषा सेटिंग के साथ अंग्रेज़ी/हिन्दी स्थानीयकरण, आँकड़े और उपलब्धियाँ, सात पैलेट, एक्सेसिबिलिटी नियंत्रण, ह्यूरिस्टिक हिंट, कीबोर्ड शॉर्टकट, ह्यूरिस्टिक और सीमित Expectimax रणनीतियों वाला अलग ऑटो प्ले डेमो, निर्धारक सॉल्वर बेंचमार्क, केवल-पढ़ने योग्य सीमित मूव रिप्ले, सीमित निर्धारक एक्शन कैप्चर वाले पोर्टेबल केवल-दर्शक फुल रिप्ले आर्काइव, स्थायी अनरैंक्ड रिस्टोर नीति वाला वैलिडेटेड पोर्टेबल वर्तमान-गेम बैकअप और क्रॉस-प्लेटफ़ॉर्म रिलीज़-बिल्ड सत्यापन शामिल हैं।',
"""
s = s.replace(marker, marker + entries, 1)
p.write_text(s)
commit([str(p)], 'feat: localize Phase 21 QR guidance')

# Focused catalog regression for the new product strings.
p = Path('test/challenge_code_qr_localization_test.dart')
p.write_text("""import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/core/localization/nova_localizations.dart';

void main() {
  test('Hindi catalog covers Challenge Code QR trust and accessibility copy', () {
    const l10n = NovaLocalizations(Locale('hi'));

    expect(l10n.text('Scan to share'), 'स्कैन करके साझा करें');
    expect(
      l10n.text('QR code containing this challenge code'),
      'इस चैलेंज कोड वाला QR कोड',
    );
    expect(l10n.text('Unable to render QR code.'), 'QR कोड नहीं बनाया जा सका।');
    expect(
      l10n.text(
        'The QR code contains the same plain NOVA1 text shown above. It does not add identity, authentication, or cloud transfer.',
      ),
      contains('NOVA1'),
    );
    expect(
      l10n.text(
        'Core gameplay, Challenge Code text/QR generation, Game Backup validation, Move Replay, Full Replay Archive, Auto Play Demo, and language switching work without a project server. QR rendering is local and does not request camera access. No account, analytics, advertising tracker, remote AI service, cloud synchronization, or online translation service is required. Clipboard text is read or written only after you choose the corresponding Challenge Code, Game Backup, or Full Replay Archive action.',
      ),
      isNot(contains('Core gameplay')),
    );
  });
}
""")
commit([str(p)], 'test: cover Hindi Challenge QR guidance')

run('dart', 'format', 'lib', 'test')
if subprocess.run(['git', 'diff', '--quiet', '--', 'lib', 'test']).returncode != 0:
    run('git', 'add', 'lib', 'test')
    run('git', 'commit', '-m', 'style: format Phase 21 product copy')

run('flutter', 'test', 'test/challenge_code_qr_test.dart', 'test/challenge_code_screen_test.dart', 'test/challenge_code_qr_localization_test.dart')
