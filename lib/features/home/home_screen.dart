import 'package:flutter/material.dart';

import '../../app/state/app_scope.dart';
import '../../core/constants/project_info.dart';
import '../../domain/game_types.dart';
import '../../shared/external_link.dart';
import '../../shared/nova_scaffold.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final canContinue =
        controller.game != null && controller.game!.status != GameStatus.lost;
    return NovaScaffold(
      title: ProjectInfo.name,
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
                    label: const Text('Continue Game'),
                  ),
                FilledButton.tonalIcon(
                  onPressed: () => Navigator.pushNamed(context, '/modes'),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('New Game'),
                ),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/daily'),
                  icon: const Icon(Icons.calendar_today_rounded),
                  label: const Text('Daily Challenge'),
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
              children: const [
                _NavCard('Daily', Icons.today_rounded, '/daily'),
                _NavCard(
                  'Auto Play Demo',
                  Icons.auto_awesome_rounded,
                  '/solver-demo',
                ),
                _NavCard('Statistics', Icons.insights_rounded, '/statistics'),
                _NavCard(
                  'Achievements',
                  Icons.emoji_events_rounded,
                  '/achievements',
                ),
                _NavCard('Guide', Icons.menu_book_rounded, '/guide'),
                _NavCard('Settings', Icons.tune_rounded, '/settings'),
                _NavCard('About', Icons.info_outline_rounded, '/about'),
                _NavCard('Support', Icons.coffee_rounded, '/support'),
              ],
            ),
            const SizedBox(height: 20),
            Semantics(
              button: true,
              label: 'Support Sanskar on Buy Me a Coffee',
              child: OutlinedButton.icon(
                onPressed: () =>
                    openExternal(context, ProjectInfo.buyMeACoffee),
                icon: const Icon(Icons.coffee_rounded),
                label: const Text('Support on Buy Me a Coffee'),
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
    return Semantics(
      label: '2048 Nova, modern puzzle game',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [scheme.primaryContainer, scheme.tertiaryContainer],
          ),
          borderRadius: BorderRadius.circular(32),
        ),
        child: const Column(
          children: [
            Icon(Icons.grid_view_rounded, size: 64),
            SizedBox(height: 10),
            Text(
              '2048 NOVA',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 34),
            ),
            SizedBox(height: 8),
            Text(
              'Classic strategy. Modern polish. Offline-first.',
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
