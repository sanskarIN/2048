import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/domain/game_engine.dart';
import 'package:nova_2048/domain/game_state.dart';
import 'package:nova_2048/domain/game_types.dart';
import 'package:nova_2048/domain/random_source.dart';

void main() {
  group('GameEngine', () {
    const config = GameConfig(mode: GameMode.classic, size: 4);

    GameState state(List<List<int>> board) =>
        GameState(board: board, config: config);

    test('creates board with exactly two starting tiles', () {
      final engine = GameEngine(
        config: config,
        random: SequenceRandomSource([0, 0, 1, 0]),
      );
      final game = engine.createGame();
      expect(
        game.board.expand((row) => row).where((value) => value != 0).length,
        2,
      );
    });

    test('compresses tiles left and spawns after valid move', () {
      final engine = GameEngine(
        config: config,
        random: SequenceRandomSource([0, 0]),
      );
      final game = state([
        [0, 2, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);
      final result = engine.move(game, Direction.left);
      expect(result.changed, isTrue);
      expect(game.board[0][0], 2);
      expect(
        game.board.expand((row) => row).where((value) => value != 0).length,
        2,
      );
    });

    test('merges each tile only once', () {
      final engine = GameEngine(
        config: config,
        random: SequenceRandomSource([15, 0]),
      );
      final game = state([
        [2, 2, 2, 2],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);
      final result = engine.move(game, Direction.left);
      expect(game.board[0].take(2), [4, 4]);
      expect(result.scoreGain, 8);
      expect(result.merges, 2);
    });

    test('does not chain merge 2 2 4 into 8', () {
      final engine = GameEngine(
        config: config,
        random: SequenceRandomSource([15, 0]),
      );
      final game = state([
        [2, 2, 4, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);
      engine.move(game, Direction.left);
      expect(game.board[0].take(2), [4, 4]);
    });

    test('invalid move does not spawn a tile', () {
      final engine = GameEngine(
        config: config,
        random: SequenceRandomSource([0, 0]),
      );
      final game = state([
        [2, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);
      final before =
          game.board.expand((row) => row).where((value) => value != 0).length;
      final result = engine.move(game, Direction.left);
      final after =
          game.board.expand((row) => row).where((value) => value != 0).length;
      expect(result.changed, isFalse);
      expect(after, before);
    });

    test('detects game over on full board with no merges', () {
      final engine = GameEngine(
        config: config,
        random: SequenceRandomSource([0]),
      );
      final game = state([
        [2, 4, 2, 4],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
        [4, 2, 4, 2],
      ]);
      engine.move(game, Direction.left);
      expect(game.status, GameStatus.lost);
    });

    test('marks target reached as won', () {
      final engine = GameEngine(
        config: config,
        random: SequenceRandomSource([15, 0]),
      );
      final game = state([
        [1024, 1024, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);
      engine.move(game, Direction.left);
      expect(game.highestTile, 2048);
      expect(game.status, GameStatus.won);
    });

    test('supports vertical movement', () {
      final engine = GameEngine(
        config: config,
        random: SequenceRandomSource([15, 0]),
      );
      final game = state([
        [2, 0, 0, 0],
        [2, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);
      engine.move(game, Direction.down);
      expect(game.board[3][0], 4);
    });

    test('move limit ends challenge when target is not reached', () {
      const limited = GameConfig(
        mode: GameMode.moveLimit,
        size: 4,
        moveLimit: 1,
      );
      final engine = GameEngine(
        config: limited,
        random: SequenceRandomSource([15, 0]),
      );
      final game = GameState(
        board: [
          [0, 2, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ],
        config: limited,
      );
      engine.move(game, Direction.left);
      expect(game.status, GameStatus.lost);
    });

    test('time challenge expires deterministically using supplied clock', () {
      const timed = GameConfig(
        mode: GameMode.timeChallenge,
        size: 4,
        timeLimitSeconds: 60,
      );
      final started = DateTime.utc(2026, 8, 14, 10);
      final engine = GameEngine(config: timed, random: SequenceRandomSource([0]));
      final game = GameState(
        board: [
          [2, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ],
        config: timed,
        startedAt: started,
      );
      engine.refreshStatus(
        game,
        now: started.add(const Duration(seconds: 60)),
      );
      expect(game.status, GameStatus.lost);
    });

    test('restored RNG state produces the same next spawn', () {
      final engine = GameEngine(
        config: config,
        random: SequenceRandomSource([3, 0, 7, 0]),
      );
      final game = state([
        [2, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);
      game.rngState = 2;
      final first = game.copy();
      final second = game.copy();
      engine.spawnTile(first);
      engine.spawnTile(second);
      expect(first.board, second.board);
      expect(first.rngState, second.rngState);
    });
  });
}
