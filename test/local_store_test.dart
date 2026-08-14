import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/data/local_store.dart';
import 'package:nova_2048/domain/daily_record.dart';
import 'package:nova_2048/domain/game_state.dart';
import 'package:nova_2048/domain/game_types.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  GameState state(int value, {int rngState = 0}) => GameState(
        board: [
          [value, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ],
        config: const GameConfig(mode: GameMode.classic, size: 4),
        rngState: rngState,
      );

  test('persists current game and undo history', () async {
    final store = LocalStore();
    await store.saveGame(state(4, rngState: 42));
    await store.saveUndoHistory([
      state(2, rngState: 10),
      state(4, rngState: 20),
    ]);

    final restored = await store.loadGame();
    final undo = await store.loadUndoHistory();

    expect(restored?.board[0][0], 4);
    expect(restored?.rngState, 42);
    expect(undo, hasLength(2));
    expect(undo.last.board[0][0], 4);
    expect(undo.last.rngState, 20);
  });

  test('persists daily challenge history', () async {
    final store = LocalStore();
    final dailyState = GameState(
      board: [
        [512, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ],
      config: const GameConfig(
        mode: GameMode.daily,
        size: 4,
        seed: 20260814,
      ),
      score: 1024,
      moves: 90,
    );
    await store.saveDailyHistory([DailyRecord.fromState(dailyState)]);

    final records = await store.loadDailyHistory();

    expect(records, hasLength(1));
    expect(records.single.seed, 20260814);
    expect(records.single.score, 1024);
  });

  test('clearing game also clears undo history', () async {
    final store = LocalStore();
    await store.saveGame(state(4));
    await store.saveUndoHistory([state(2)]);

    await store.clearGame();

    expect(await store.loadGame(), isNull);
    expect(await store.loadUndoHistory(), isEmpty);
  });

  test('clear all removes every project-owned data category', () async {
    final store = LocalStore();
    await store.saveGame(state(4));
    await store.saveUndoHistory([state(2)]);
    await store.saveSettings({'themeMode': 'dark'});
    await store.saveStats({'gamesPlayed': 10});
    await store.saveAchievements({'tile_128': '2026-08-14T00:00:00Z'});

    await store.clearAll();

    expect(await store.loadGame(), isNull);
    expect(await store.loadUndoHistory(), isEmpty);
    expect(await store.loadSettings(), isEmpty);
    expect(await store.loadStats(), isEmpty);
    expect(await store.loadAchievements(), isEmpty);
    expect(await store.loadDailyHistory(), isEmpty);
  });

  test('corrupt current game fails safely', () async {
    SharedPreferences.setMockInitialValues({
      'nova.current_game.v1': '{not-json',
      'nova.undo_history.v1': '[also-bad',
    });
    final store = LocalStore();

    expect(await store.loadGame(), isNull);
    expect(await store.loadUndoHistory(), isEmpty);
  });
}
