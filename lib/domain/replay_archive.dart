import 'dart:convert';

import 'game_engine.dart';
import 'game_state.dart';
import 'game_types.dart';

enum ReplayEventKind {
  move,
  undo,
  continueAfterWin,
  statusRefresh,
}

class ReplayEvent {
  const ReplayEvent({
    required this.kind,
    required this.elapsedMilliseconds,
    this.direction,
  });

  static const maxElapsedMilliseconds = 365 * 24 * 60 * 60 * 1000;

  final ReplayEventKind kind;
  final int elapsedMilliseconds;
  final Direction? direction;

  Map<String, Object?> toJson() => {
        'kind': kind.name,
        'elapsedMilliseconds': elapsedMilliseconds,
        if (direction != null) 'direction': direction!.name,
      };

  factory ReplayEvent.fromJson(Map<String, Object?> json) {
    final rawKind = json['kind'];
    if (rawKind is! String) {
      throw const FormatException('Replay event kind is invalid');
    }
    ReplayEventKind? kind;
    for (final value in ReplayEventKind.values) {
      if (value.name == rawKind) {
        kind = value;
        break;
      }
    }
    if (kind == null) {
      throw const FormatException('Replay event kind is unsupported');
    }

    final elapsed = _strictInt(
      json['elapsedMilliseconds'],
      'replay event time',
    );
    if (elapsed < 0 || elapsed > maxElapsedMilliseconds) {
      throw const FormatException('Replay event time is out of range');
    }

    final rawDirection = json['direction'];
    Direction? direction;
    if (rawDirection != null) {
      if (rawDirection is! String) {
        throw const FormatException('Replay move direction is invalid');
      }
      for (final value in Direction.values) {
        if (value.name == rawDirection) {
          direction = value;
          break;
        }
      }
      if (direction == null) {
        throw const FormatException('Replay move direction is unsupported');
      }
    }

    if (kind == ReplayEventKind.move && direction == null) {
      throw const FormatException('Replay move direction is missing');
    }
    if (kind != ReplayEventKind.move && direction != null) {
      throw const FormatException('Replay direction is only valid for moves');
    }

    return ReplayEvent(
      kind: kind,
      elapsedMilliseconds: elapsed,
      direction: direction,
    );
  }

  static int _strictInt(Object? value, String label) {
    if (value is! num || !value.isFinite || value.toInt() != value) {
      throw FormatException('Invalid $label');
    }
    return value.toInt();
  }
}

class ReplayCapture {
  ReplayCapture({
    required GameState initialState,
    required this.startsAtSessionStart,
    this.overflowed = false,
    Iterable<ReplayEvent> events = const [],
  })  : initialState = initialState.copy(),
        events = List<ReplayEvent>.from(events) {
    _validateHeader();
    if (this.events.length > maxEvents) {
      throw const FormatException('Replay event limit exceeded');
    }
  }

  static const maxEvents = 4096;

  factory ReplayCapture.start(GameState state) => ReplayCapture(
        initialState: state,
        startsAtSessionStart: true,
      );

  factory ReplayCapture.incomplete(GameState state) => ReplayCapture(
        initialState: state,
        startsAtSessionStart: false,
      );

  final GameState initialState;
  final bool startsAtSessionStart;
  bool overflowed;
  final List<ReplayEvent> events;

  bool get isFullSessionExportable => startsAtSessionStart && !overflowed;

  bool belongsTo(GameState state) {
    final a = initialState.config;
    final b = state.config;
    return initialState.startedAt.isAtSameMomentAs(state.startedAt) &&
        a.mode == b.mode &&
        a.size == b.size &&
        a.target == b.target &&
        a.moveLimit == b.moveLimit &&
        a.timeLimitSeconds == b.timeLimitSeconds &&
        a.seed == b.seed;
  }

  bool appendMove(Direction direction, DateTime at) => _append(
        ReplayEvent(
          kind: ReplayEventKind.move,
          elapsedMilliseconds: _elapsedAt(at),
          direction: direction,
        ),
      );

  bool appendUndo(DateTime at) => _append(
        ReplayEvent(
          kind: ReplayEventKind.undo,
          elapsedMilliseconds: _elapsedAt(at),
        ),
      );

  bool appendContinueAfterWin(DateTime at) => _append(
        ReplayEvent(
          kind: ReplayEventKind.continueAfterWin,
          elapsedMilliseconds: _elapsedAt(at),
        ),
      );

  bool appendStatusRefresh(DateTime at) => _append(
        ReplayEvent(
          kind: ReplayEventKind.statusRefresh,
          elapsedMilliseconds: _elapsedAt(at),
        ),
      );

  Map<String, Object?> toJson() => {
        'initialState': initialState.toJson(),
        'startsAtSessionStart': startsAtSessionStart,
        'overflowed': overflowed,
        'events': events.map((event) => event.toJson()).toList(),
      };

  factory ReplayCapture.fromJson(Map<String, Object?> json) {
    final rawInitial = json['initialState'];
    if (rawInitial is! Map) {
      throw const FormatException('Replay initial state is missing');
    }

    final rawStartsAtStart = json['startsAtSessionStart'];
    final rawOverflowed = json['overflowed'];
    if (rawStartsAtStart is! bool || rawOverflowed is! bool) {
      throw const FormatException('Replay capture flags are invalid');
    }

    final rawEvents = json['events'];
    if (rawEvents is! List) {
      throw const FormatException('Replay events are invalid');
    }
    if (rawEvents.length > maxEvents) {
      throw const FormatException('Replay event limit exceeded');
    }

    final events = <ReplayEvent>[];
    for (final item in rawEvents) {
      if (item is! Map) {
        throw const FormatException('Replay event is invalid');
      }
      events.add(
        ReplayEvent.fromJson(Map<String, Object?>.from(item)),
      );
    }

    return ReplayCapture(
      initialState: GameState.fromJson(
        Map<String, Object?>.from(rawInitial),
      ),
      startsAtSessionStart: rawStartsAtStart,
      overflowed: rawOverflowed,
      events: events,
    );
  }

  bool _append(ReplayEvent event) {
    if (overflowed) return false;
    if (events.length >= maxEvents) {
      overflowed = true;
      return false;
    }
    events.add(event);
    return true;
  }

  int _elapsedAt(DateTime at) {
    var elapsed = at.difference(initialState.startedAt).inMilliseconds;
    if (elapsed < 0) elapsed = 0;
    if (events.isNotEmpty && elapsed < events.last.elapsedMilliseconds) {
      elapsed = events.last.elapsedMilliseconds;
    }
    if (elapsed > ReplayEvent.maxElapsedMilliseconds) {
      elapsed = ReplayEvent.maxElapsedMilliseconds;
    }
    return elapsed;
  }

  void _validateHeader() {
    if (!startsAtSessionStart) return;
    if (initialState.moves != 0 ||
        initialState.score != 0 ||
        initialState.totalMerges != 0 ||
        initialState.status != GameStatus.playing ||
        initialState.hasAcknowledgedWin) {
      throw const FormatException(
        'Full replay must begin at the session start',
      );
    }
  }
}

class ReplayArchive {
  const ReplayArchive._();

  static const format = 'nova2048.fullReplay';
  static const version = 1;
  static const maxEncodedLength = 1000000;

  static String encode(
    ReplayCapture capture, {
    DateTime? exportedAt,
  }) {
    if (!capture.isFullSessionExportable) {
      throw StateError('Full replay capture is incomplete');
    }
    ReplayArchivePlayer.build(capture);
    return jsonEncode({
      'format': format,
      'version': version,
      'exportedAt': (exportedAt ?? DateTime.now().toUtc()).toIso8601String(),
      'capture': capture.toJson(),
    });
  }

  static ReplayCapture decode(String raw) {
    final text = raw.trim();
    if (text.isEmpty) {
      throw const FormatException('Replay archive is empty');
    }
    if (text.length > maxEncodedLength) {
      throw const FormatException('Replay archive is too large');
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(text);
    } on FormatException {
      rethrow;
    } on Object {
      throw const FormatException('Replay archive is malformed');
    }
    if (decoded is! Map) {
      throw const FormatException('Replay archive is malformed');
    }
    final json = Map<String, Object?>.from(decoded);

    if (json['format'] != format) {
      throw const FormatException('Unsupported replay archive format');
    }
    final rawVersion = json['version'];
    if (rawVersion is! num ||
        !rawVersion.isFinite ||
        rawVersion.toInt() != rawVersion) {
      throw const FormatException('Invalid replay archive version');
    }
    if (rawVersion.toInt() != version) {
      throw const FormatException('Unsupported replay archive version');
    }

    final rawExportedAt = json['exportedAt'];
    if (rawExportedAt is! String || DateTime.tryParse(rawExportedAt) == null) {
      throw const FormatException('Invalid replay export time');
    }

    final rawCapture = json['capture'];
    if (rawCapture is! Map) {
      throw const FormatException('Replay capture is missing');
    }
    final capture = ReplayCapture.fromJson(
      Map<String, Object?>.from(rawCapture),
    );
    if (!capture.isFullSessionExportable) {
      throw const FormatException('Replay archive is incomplete');
    }

    ReplayArchivePlayer.build(capture);
    return capture;
  }
}

class ReplayArchivePlayer {
  const ReplayArchivePlayer._();

  static List<GameState> build(ReplayCapture capture) {
    var current = capture.initialState.copy();
    var engine = GameEngine(config: current.config);
    final undo = <GameState>[];
    final frames = <GameState>[current.copy()];
    var lastElapsed = 0;

    for (final event in capture.events) {
      if (event.elapsedMilliseconds < lastElapsed) {
        throw const FormatException('Replay event times are out of order');
      }
      lastElapsed = event.elapsedMilliseconds;
      final now = current.startedAt.add(
        Duration(milliseconds: event.elapsedMilliseconds),
      );

      switch (event.kind) {
        case ReplayEventKind.move:
          final snapshot = current.copy();
          final outcome = engine.move(
            current,
            event.direction!,
            now: now,
          );
          if (!outcome.changed) {
            throw const FormatException(
              'Replay contains an invalid recorded move',
            );
          }
          undo.add(snapshot);
          break;
        case ReplayEventKind.undo:
          if (undo.isEmpty) {
            throw const FormatException(
              'Replay contains an invalid undo',
            );
          }
          current = undo.removeLast();
          engine = GameEngine(config: current.config);
          break;
        case ReplayEventKind.continueAfterWin:
          if (current.status != GameStatus.won ||
              current.hasAcknowledgedWin) {
            throw const FormatException(
              'Replay contains an invalid win continuation',
            );
          }
          current.hasAcknowledgedWin = true;
          current.status = GameStatus.playing;
          break;
        case ReplayEventKind.statusRefresh:
          final before = current.status;
          engine.refreshStatus(current, now: now);
          if (before == current.status) {
            throw const FormatException(
              'Replay contains a redundant status refresh',
            );
          }
          break;
      }
      frames.add(current.copy());
    }

    return List<GameState>.unmodifiable(frames);
  }

  static bool equivalent(GameState a, GameState b) {
    final ac = a.config;
    final bc = b.config;
    if (!a.startedAt.isAtSameMomentAs(b.startedAt) ||
        ac.mode != bc.mode ||
        ac.size != bc.size ||
        ac.target != bc.target ||
        ac.moveLimit != bc.moveLimit ||
        ac.timeLimitSeconds != bc.timeLimitSeconds ||
        ac.seed != bc.seed ||
        a.score != b.score ||
        a.moves != b.moves ||
        a.totalMerges != b.totalMerges ||
        a.status != b.status ||
        a.hasAcknowledgedWin != b.hasAcknowledgedWin ||
        a.rngState != b.rngState ||
        a.board.length != b.board.length) {
      return false;
    }
    for (var row = 0; row < a.board.length; row++) {
      if (a.board[row].length != b.board[row].length) return false;
      for (var col = 0; col < a.board[row].length; col++) {
        if (a.board[row][col] != b.board[row][col]) return false;
      }
    }
    return true;
  }
}
