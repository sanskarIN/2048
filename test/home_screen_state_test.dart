import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/app/state/app_controller.dart';
import 'package:nova_2048/app/state/app_scope.dart';
import 'package:nova_2048/data/local_store.dart';
import 'package:nova_2048/domain/game_state.dart';
import 'package:nova_2048/domain/game_types.dart';
import 'package:nova_2048/features/home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/localized_test_app.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('lost game does not expose Continue Game', (tester) async {
    final controller = AppController(store: LocalStore());
    await controller.initialize();
    controller.game = GameState(
      board: const [
        [2, 4, 2, 4],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
        [4, 2, 4, 2],
      ],
      config: const GameConfig(mode: GameMode.classic, size: 4),
      status: GameStatus.lost,
    );

    await tester.pumpWidget(
      localizedTestApp(
        home: AppScope(
          controller: controller,
          child: const HomeScreen(),
        ),
      ),
    );

    expect(find.text('Continue Game'), findsNothing);
    expect(find.text('New Game'), findsOneWidget);
  });
}
