import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/domain/daily_record.dart';

void main() {
  test('daily record serializes update time as an absolute UTC instant', () {
    final localUpdatedAt = DateTime(2026, 8, 17, 14, 15, 30);
    final record = DailyRecord(
      seed: 20260817,
      score: 2048,
      moves: 128,
      highestTile: 2048,
      completed: true,
      won: true,
      updatedAt: localUpdatedAt,
    );

    final serialized = record.toJson()['updatedAt'] as String;
    final restored = DailyRecord.fromJson(record.toJson());

    expect(localUpdatedAt.isUtc, isFalse);
    expect(serialized, endsWith('Z'));
    expect(restored.updatedAt.isUtc, isTrue);
    expect(restored.updatedAt.isAtSameMomentAs(localUpdatedAt), isTrue);
  });
}
