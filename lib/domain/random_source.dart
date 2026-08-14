import 'dart:math';

abstract interface class RandomSource {
  int nextInt(int max);
  double nextDouble();
}

class DartRandomSource implements RandomSource {
  DartRandomSource([int? seed]) : _random = Random(seed);

  final Random _random;

  @override
  int nextInt(int max) => _random.nextInt(max);

  @override
  double nextDouble() => _random.nextDouble();
}

class SequenceRandomSource implements RandomSource {
  SequenceRandomSource(this.values);

  final List<int> values;
  int _index = 0;

  int _next() {
    if (values.isEmpty) return 0;
    final value = values[_index % values.length];
    _index += 1;
    return value;
  }

  @override
  int nextInt(int max) => _next().abs() % max;

  @override
  double nextDouble() => (_next().abs() % 1000) / 1000;
}
