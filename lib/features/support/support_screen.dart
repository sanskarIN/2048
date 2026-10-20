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
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              l10n.text(
                'Supporting is optional. 2048 Nova remains playable without a donation.',
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.coffee_rounded),
              title: Text(l10n.text('Support Sanskar on Buy Me a Coffee')),
              subtitle: const Text(ProjectInfo.buyMeACoffee),
              onTap: () => openExternal(context, ProjectInfo.buyMeACoffee),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.payment_rounded),
              title: Text(l10n.text('Support via Razorpay')),
              subtitle: const Text(ProjectInfo.razorpay),
              onTap: () => openExternal(context, ProjectInfo.razorpay),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.volunteer_activism_rounded),
              title: Text(l10n.text('Support via PayPal')),
              subtitle: const Text(ProjectInfo.paypal),
              onTap: () => openExternal(context, ProjectInfo.paypal),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.support_agent_rounded),
              title: Text(l10n.text('Contact support')),
              subtitle: const Text(ProjectInfo.contact),
              onTap: () => openExternal(context, ProjectInfo.contact),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.public_rounded),
              title: Text(l10n.text('Website')),
              subtitle: const Text(ProjectInfo.website),
              onTap: () => openExternal(context, ProjectInfo.website),
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
              leading: const Icon(Icons.alternate_email_rounded),
              title: Text(l10n.text('Business email 2')),
              subtitle: const Text(ProjectInfo.businessEmailSecondary),
              onTap: () => openExternal(
                context,
                'mailto:${ProjectInfo.businessEmailSecondary}',
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
