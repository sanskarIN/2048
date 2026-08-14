import 'package:flutter/material.dart';

import '../../core/constants/project_info.dart';
import '../../shared/external_link.dart';
import '../../shared/nova_scaffold.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NovaScaffold(
      title: 'Support 2048 Nova',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.coffee_rounded, size: 56),
                  const SizedBox(height: 12),
                  Text(
                    'Support Sanskar on Buy Me a Coffee',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Supporting is optional. 2048 Nova remains playable without a donation.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Semantics(
                    button: true,
                    label: 'Support Sanskar on Buy Me a Coffee',
                    child: FilledButton.icon(
                      onPressed: () =>
                          openExternal(context, ProjectInfo.buyMeACoffee),
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const Text('Open Buy Me a Coffee'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.support_agent_rounded),
              title: const Text('Email support'),
              subtitle: const Text(ProjectInfo.supportEmail),
              onTap: () => openExternal(
                context,
                'mailto:${ProjectInfo.supportEmail}',
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.mail_outline_rounded),
              title: const Text('Business contact'),
              subtitle: const Text(ProjectInfo.businessEmailPrimary),
              onTap: () => openExternal(
                context,
                'mailto:${ProjectInfo.businessEmailPrimary}',
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.bug_report_outlined),
              title: const Text('Report a bug on GitHub'),
              subtitle: const Text(ProjectInfo.repository),
              onTap: () => openExternal(context, ProjectInfo.repository),
            ),
          ),
        ],
      ),
    );
  }
}
