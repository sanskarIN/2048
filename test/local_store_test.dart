import 'dart:convert';

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

  test('keeps valid daily history entries when one record is corrupt',
      () async {
    SharedPreferences.setMockInitialValues({
      'nova.daily_history.v1':
          '[{"seed":20260814,"score":128,"moves":12,"highestTile":64,"completed":false,"won":false,"updatedAt":"2026-08-14T00:00:00.000Z"},{"seed":20260230,"score":999},{"seed":20260813,"score":64,"moves":8,"highestTile":32,"completed":false,"won":false,"updatedAt":"2026-08-13T00:00:00.000Z"}]',
    });
    final store = LocalStore();

    final records = await store.loadDailyHistory();
    final repairedRaw = (await SharedPreferences.getInstance())
        .getString('nova.daily_history.v1');
    final repairedJson = jsonDecode(repairedRaw!) as List<dynamic>;

    expect(records, hasLength(2));
    expect(records.map((record) => record.seed), [20260814, 20260813]);
    expect(repairedJson, hasLength(2));
  });

  test('deduplicates daily history while preserving the strongest record',
      () async {
    SharedPreferences.setMockInitialValues({
      'nova.daily_history.v1': jsonEncode([
        {
          'seed': 20260814,
          'score': 4096,
          'moves': 170,
          'highestTile': 1024,
          'completed': false,
          'won': false,
          'updatedAt': '2026-08-14T01:00:00.000Z',
        },
        {
          'seed': 20260814,
          'score': 1024,
          'moves': 80,
          'highestTile': 2048,
          'completed': true,
          'won': true,
          'updatedAt': '2026-08-14T02:00:00.000Z',
        },
      ]),
    });
    final store = LocalStore();

    final records = await store.loadDailyHistory();
    final repairedRaw = (await SharedPreferences.getInstance())
        .getString('nova.daily_history.v1');
    final repairedJson = jsonDecode(repairedRaw!) as List<dynamic>;

    expect(records, hasLength(1));
    expect(records.single.score, 4096);
    expect(records.single.moves, 170);
    expect(records.single.highestTile, 2048);
    expect(records.single.won, isTrue);
    expect(records.single.completed, isTrue);
    expect(
        records.single.updatedAt, DateTime.parse('2026-08-14T02:00:00.000Z'));
    expect(repairedJson, hasLength(1));
  });

  test('repairs undo history by dropping invalid snapshots', () async {
    final valid = state(2).toJson();
    final invalid = state(4).toJson()..['board'] = 'broken';
    SharedPreferences.setMockInitialValues({
      'nova.undo_history.v1': jsonEncode([valid, invalid, 'bad-entry']),
    });
    final store = LocalStore();

    final restored = await store.loadUndoHistory();
    final repairedRaw = (await SharedPreferences.getInstance())
        .getString('nova.undo_history.v1');
    final repairedJson = jsonDecode(repairedRaw!) as List<dynamic>;

    expect(restored, hasLength(1));
    expect(restored.single.board[0][0], 2);
    expect(repairedJson, hasLength(1));
  });

  test('invalid map persistence is removed after safe recovery', () async {
    SharedPreferences.setMockInitialValues({
      'nova.settings.v1': '["not","a","map"]',
      'nova.stats.v1': '{not-json',
    });
    final store = LocalStore();

    expect(await store.loadSettings(), isEmpty);
    expect(await store.loadStats(), isEmpty);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey('nova.settings.v1'), isFalse);
    expect(prefs.containsKey('nova.stats.v1'), isFalse);
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
