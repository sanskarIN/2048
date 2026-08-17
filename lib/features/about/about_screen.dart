import 'package:flutter/material.dart';

import '../../core/constants/project_info.dart';
import '../../core/localization/nova_localizations.dart';
import '../../shared/external_link.dart';
import '../../shared/nova_scaffold.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final links = [
      ('Repository', ProjectInfo.repository),
      ('GitHub profile', ProjectInfo.githubProfile),
      ('LinkedIn', ProjectInfo.linkedIn),
      ('Buy Me a Coffee', ProjectInfo.buyMeACoffee),
      ('Business email', 'mailto:${ProjectInfo.businessEmailPrimary}'),
      ('Business email 2', 'mailto:${ProjectInfo.businessEmailSecondary}'),
      ('Support email', 'mailto:${ProjectInfo.supportEmail}'),
    ];
    return NovaScaffold(
      title: l10n.text('About'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.grid_view_rounded, size: 56),
                  const SizedBox(height: 10),
                  const Text(
                    ProjectInfo.name,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                  Text(
                    l10n.isHindi
                        ? 'वर्ज़न ${ProjectInfo.version}'
                        : 'Version ${ProjectInfo.version}',
                  ),
                  const SizedBox(height: 6),
                  const Text(ProjectInfo.watermark),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.text('What’s new'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.text(
                      'Version ${ProjectInfo.version} release candidate includes ten game modes, deterministic save and Undo integrity, Daily Challenges, offline shareable seeded Challenge Codes with local QR rendering, English/Hindi localization with a persisted language setting, statistics and achievements, seven palettes, accessibility controls, heuristic hints, keyboard shortcuts, an isolated Auto Play Demo with Heuristic and bounded Expectimax strategies, deterministic solver benchmarks, read-only bounded Move Replay, portable spectator-only Full Replay Archives with bounded deterministic action capture, validated portable current-game backup with persistent unranked restore policy, and cross-platform release-build verification.',
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.storefront_rounded),
              title: const Text(
                'Gumroad',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: const Text(ProjectInfo.gumroad),
              trailing: const Icon(Icons.open_in_new_rounded),
              onTap: () => openExternal(context, ProjectInfo.gumroad),
            ),
          ),
          for (final item in links)
            Card(
              child: ListTile(
                title: Text(l10n.text(item.$1)),
                subtitle: Text(item.$2),
                trailing: const Icon(Icons.open_in_new_rounded),
                onTap: () => openExternal(context, item.$2),
              ),
            ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.text('Credits and license'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.text(
                      'Created by Sanskar. 2048 Nova is open source under the MIT License. Third-party package licenses remain available through Flutter’s standard license system.',
                    ),
                  ),
                ],
              ),
            ),
          ),
          TextButton(
            onPressed: () => showLicensePage(
              context: context,
              applicationName: ProjectInfo.name,
              applicationVersion: ProjectInfo.version,
            ),
            child: Text(l10n.text('View third-party licenses')),
          ),
        ],
      ),
    );
  }
}
