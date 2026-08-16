import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/data/local_store.dart';
import 'package:nova_2048/domain/game_state.dart';
import 'package:nova_2048/domain/game_types.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const markerKey = 'nova.current_game_unranked.v1';

  GameState state() => GameState(
    config: const GameConfig(mode: GameMode.classic, size: 4),
    board: [
      [2, 2, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ],
    rngState: 77,
    startedAt: DateTime.utc(2026, 8, 14, 9),
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('unranked marker round trips', () async {
    final store = LocalStore();

    expect(await store.loadCurrentGameUnranked(), isFalse);
    await store.saveCurrentGameUnranked(true);
    expect(await store.loadCurrentGameUnranked(), isTrue);
    await store.saveCurrentGameUnranked(false);
    expect(await store.loadCurrentGameUnranked(), isFalse);
  });

  test('malformed marker is removed and treated as ranked', () async {
    SharedPreferences.setMockInitialValues({markerKey: 'not-a-bool'});
    final store = LocalStore();

    expect(await store.loadCurrentGameUnranked(), isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey(markerKey), isFalse);
  });

  test('clear game removes the unranked marker', () async {
    final store = LocalStore();
    await store.saveGame(state());
    await store.saveCurrentGameUnranked(true);

    await store.clearGame();

    expect(await store.loadGame(), isNull);
    expect(await store.loadCurrentGameUnranked(), isFalse);
  });

  test('malformed current game recovery also removes the marker', () async {
    SharedPreferences.setMockInitialValues({
      'nova.current_game.v1': '{broken',
      markerKey: true,
    });
    final store = LocalStore();

    expect(await store.loadGame(), isNull);
    expect(await store.loadCurrentGameUnranked(), isFalse);
  });
}
