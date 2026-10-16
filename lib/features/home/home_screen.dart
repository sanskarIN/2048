import 'package:flutter/material.dart';

import '../../app/state/app_scope.dart';
import '../../core/constants/project_info.dart';
import '../../core/localization/nova_localizations.dart';
import '../../domain/game_types.dart';
import '../../shared/external_link.dart';
import '../../shared/nova_scaffold.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final l10n = context.l10n;
    final hasGame = controller.game != null;
    final canContinue =
        controller.game != null && controller.game!.status != GameStatus.lost;
    return NovaScaffold(
      title: l10n.text(ProjectInfo.name),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const _Hero(),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                if (canContinue)
                  FilledButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/game'),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(
                      l10n.text(
                        controller.currentGameIsUnranked
                            ? 'Continue Unranked Backup'
                            : 'Continue Game',
                      ),
                    ),
                  ),
                FilledButton.tonalIcon(
                  onPressed: () => Navigator.pushNamed(context, '/modes'),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n.text('New Game')),
                ),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/daily'),
                  icon: const Icon(Icons.calendar_today_rounded),
                  label: Text(l10n.text('Daily Challenge')),
                ),
                if (hasGame)
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/replay'),
                    icon: const Icon(Icons.movie_filter_outlined),
                    label: Text(l10n.text('Move Replay')),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            GridView.count(
              crossAxisCount: MediaQuery.sizeOf(context).width < 650 ? 2 : 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.25,
              children: [
                _NavCard(l10n.text('Daily'), Icons.today_rounded, '/daily'),
                _NavCard(
                  l10n.text('Challenge Codes'),
                  Icons.hub_outlined,
                  '/challenge-codes',
                ),
                _NavCard(
                  l10n.text('Auto Play Demo'),
                  Icons.auto_awesome_rounded,
                  '/solver-demo',
                ),
                _NavCard(
                  l10n.text('Statistics'),
                  Icons.insights_rounded,
                  '/statistics',
                ),
                _NavCard(
                  l10n.text('Achievements'),
                  Icons.emoji_events_rounded,
                  '/achievements',
                ),
                _NavCard(l10n.text('Guide'), Icons.menu_book_rounded, '/guide'),
                _NavCard(
                  l10n.text('Settings'),
                  Icons.tune_rounded,
                  '/settings',
                ),
                _NavCard(
                  l10n.text('Game Backup'),
                  Icons.backup_rounded,
                  '/backup',
                ),
                _NavCard(
                  l10n.text('About'),
                  Icons.info_outline_rounded,
                  '/about',
                ),
                _NavCard(
                  l10n.text('Support'),
                  Icons.coffee_rounded,
                  '/support',
                ),
              ],
            ),
            const SizedBox(height: 20),
            Semantics(
              button: true,
              label: l10n.text('Support Sanskar on Buy Me a Coffee'),
              child: OutlinedButton.icon(
                onPressed: () =>
                    openExternal(context, ProjectInfo.buyMeACoffee),
                icon: const Icon(Icons.coffee_rounded),
                label: Text(l10n.text('Support on Buy Me a Coffee')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    return Semantics(
      label: l10n.text('2048 Nova, modern puzzle game'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [scheme.primaryContainer, scheme.tertiaryContainer],
          ),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          children: [
            const Icon(Icons.grid_view_rounded, size: 64),
            const SizedBox(height: 10),
            const Text(
              '2048 NOVA',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 34),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.text('Classic strategy. Modern polish. Offline-first.'),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  const _NavCard(this.label, this.icon, this.route);

  final String label;
  final IconData icon;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
