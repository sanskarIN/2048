import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/app/state/app_controller.dart';
import 'package:nova_2048/data/local_store.dart';
import 'package:nova_2048/domain/game_engine.dart';
import 'package:nova_2048/domain/game_types.dart';
import 'package:nova_2048/domain/replay_archive.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const config = GameConfig(mode: GameMode.classic, size: 4, seed: 4242);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('new game starts a complete exportable replay capture', () async {
    final controller = AppController(store: LocalStore());
    await controller.initialize();
    await controller.newGame(config);

    final capture = controller.replayCapture;
    expect(capture, isNotNull);
    expect(capture!.startsAtSessionStart, isTrue);
    expect(capture.overflowed, isFalse);
    expect(capture.events, isEmpty);
    expect(capture.isFullSessionExportable, isTrue);
    expect(capture.belongsTo(controller.game!), isTrue);
  });

  test('successful move is recorded and survives controller restart', () async {
    final store = LocalStore();
    final controller = AppController(store: store);
    await controller.initialize();
    await controller.newGame(config);

    final direction = controller.hint();
    expect(direction, isNotNull);
    final outcome = await controller.move(direction!);
    expect(outcome?.changed, isTrue);
    expect(controller.replayCapture!.events.length, 1);
    expect(controller.replayCapture!.events.single.kind, ReplayEventKind.move);

    final restored = AppController(store: store);
    await restored.initialize();
    expect(restored.replayCapture, isNotNull);
    expect(restored.replayCapture!.startsAtSessionStart, isTrue);
    expect(restored.replayCapture!.events.length, 1);
    final frames = ReplayArchivePlayer.build(restored.replayCapture!);
    expect(ReplayArchivePlayer.equivalent(frames.last, restored.game!), isTrue);
  });

  test(
    'undo is captured and reconstructed spectator state matches live game',
    () async {
      final controller = AppController(store: LocalStore());
      await controller.initialize();
      await controller.newGame(config);

      final direction = controller.hint()!;
      expect((await controller.move(direction))!.changed, isTrue);
      await controller.undo();

      final capture = controller.replayCapture!;
      expect(capture.events.length, 2);
      expect(capture.events[0].kind, ReplayEventKind.move);
      expect(capture.events[1].kind, ReplayEventKind.undo);
      final frames = ReplayArchivePlayer.build(capture);
      expect(
        ReplayArchivePlayer.equivalent(frames.last, controller.game!),
        isTrue,
      );
    },
  );

  test(
    'portable game backup progress receives incomplete replay capture',
    () async {
      final controller = AppController(store: LocalStore());
      await controller.initialize();
      final imported = GameEngine(config: config).createGame();
      final direction = GameEngine(config: config).hint(imported)!;
      GameEngine(config: config).move(imported, direction);

      await controller.importGameBackup(imported);

      expect(controller.currentGameIsUnranked, isTrue);
      expect(controller.replayCapture, isNotNull);
      expect(controller.replayCapture!.startsAtSessionStart, isFalse);
      expect(controller.replayCapture!.isFullSessionExportable, isFalse);
      expect(
        () => ReplayArchive.encode(controller.replayCapture!),
        throwsStateError,
      );
    },
  );
}
