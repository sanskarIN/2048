import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/data/local_store.dart';
import 'package:nova_2048/domain/game_engine.dart';
import 'package:nova_2048/domain/game_types.dart';
import 'package:nova_2048/domain/replay_archive.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const config = GameConfig(mode: GameMode.classic, size: 4, seed: 99);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('replay capture persists and restores with events', () async {
    final store = LocalStore();
    final initial = GameEngine(config: config).createGame();
    final capture = ReplayCapture.start(initial)
      ..appendMove(
        Direction.left,
        initial.startedAt.add(const Duration(seconds: 1)),
      );

    await store.saveReplayCapture(capture);
    final restored = await store.loadReplayCapture();

    expect(restored, isNotNull);
    expect(restored!.startsAtSessionStart, isTrue);
    expect(restored.events.length, 1);
    expect(restored.events.single.kind, ReplayEventKind.move);
    expect(restored.events.single.direction, Direction.left);
  });

  test('malformed replay capture is removed during safe recovery', () async {
    SharedPreferences.setMockInitialValues({
      'nova.replay_capture.v1': '{not-valid-json',
    });
    final store = LocalStore();

    expect(await store.loadReplayCapture(), isNull);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey('nova.replay_capture.v1'), isFalse);
  });

  test('clearing game and all data removes replay capture', () async {
    final store = LocalStore();
    final initial = GameEngine(config: config).createGame();
    final capture = ReplayCapture.start(initial);

    await store.saveGame(initial);
    await store.saveReplayCapture(capture);
    await store.clearGame();
    expect(await store.loadReplayCapture(), isNull);

    await store.saveReplayCapture(capture);
    await store.clearAll();
    expect(await store.loadReplayCapture(), isNull);
  });
}
