import 'package:flutter/material.dart';

import '../../core/constants/project_info.dart';
import '../../core/localization/nova_localizations.dart';
import '../../shared/external_link.dart';
import '../../shared/nova_scaffold.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return NovaScaffold(
      title: l10n.text('Support 2048 Nova'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.storefront_rounded, size: 56),
                  const SizedBox(height: 12),
                  Text(
                    'Ramsandesh on Gumroad',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const SelectableText(
                    ProjectInfo.gumroad,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Semantics(
                    button: true,
                    label: 'Open Ramsandesh on Gumroad',
                    child: FilledButton.icon(
                      onPressed: () =>
                          openExternal(context, ProjectInfo.gumroad),
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const Text('Open Gumroad'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.coffee_rounded, size: 56),
                  const SizedBox(height: 12),
                  Text(
                    l10n.text('Support Sanskar on Buy Me a Coffee'),
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.text(
                      'Supporting is optional. 2048 Nova remains playable without a donation.',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Semantics(
                    button: true,
                    label: l10n.text('Support Sanskar on Buy Me a Coffee'),
                    child: FilledButton.icon(
                      onPressed: () =>
                          openExternal(context, ProjectInfo.buyMeACoffee),
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: Text(l10n.text('Open Buy Me a Coffee')),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.support_agent_rounded),
              title: Text(l10n.text('Email support')),
              subtitle: const Text(ProjectInfo.supportEmail),
              onTap: () =>
                  openExternal(context, 'mailto:${ProjectInfo.supportEmail}'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.mail_outline_rounded),
              title: Text(l10n.text('Business contact')),
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
              title: Text(l10n.text('Report a bug on GitHub')),
              subtitle: Text(
                l10n.text('Open the repository bug report template'),
              ),
              onTap: () => openExternal(context, ProjectInfo.bugReport),
            ),
          ),
        ],
      ),
    );
  }
}
