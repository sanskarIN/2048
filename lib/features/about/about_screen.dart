import 'package:flutter/material.dart';

import '../../core/constants/project_info.dart';
import '../../shared/external_link.dart';
import '../../shared/nova_scaffold.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      title: 'About',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.grid_view_rounded, size: 56),
                  SizedBox(height: 10),
                  Text(
                    ProjectInfo.name,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                  Text('Version ${ProjectInfo.version}'),
                  SizedBox(height: 6),
                  Text(ProjectInfo.watermark),
                ],
              ),
            ),
          ),
          for (final item in links)
            Card(
              child: ListTile(
                title: Text(item.$1),
                subtitle: Text(item.$2),
                trailing: const Icon(Icons.open_in_new_rounded),
                onTap: () => openExternal(context, item.$2),
              ),
            ),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '2048 Nova is open source under the MIT License. Third-party package licenses remain available through Flutter’s standard license system.',
              ),
            ),
          ),
          TextButton(
            onPressed: () => showLicensePage(
              context: context,
              applicationName: ProjectInfo.name,
              applicationVersion: ProjectInfo.version,
            ),
            child: const Text('View third-party licenses'),
          ),
        ],
      ),
    );
  }
}
