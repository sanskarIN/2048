abstract interface class RandomSource {
  int get state;
  set state(int value);
  int nextInt(int max);
  double nextDouble();
}

class SeededRandomSource implements RandomSource {
  SeededRandomSource(int seed) : _state = seed & 0x7fffffff;

  int _state;

  @override
  int get state => _state;

  @override
  set state(int value) => _state = value & 0x7fffffff;

  int _nextRaw() {
    _state = (1103515245 * _state + 12345) & 0x7fffffff;
    return _state;
  }

  @override
  int nextInt(int max) {
    if (max <= 0) throw ArgumentError.value(max, 'max', 'Must be positive.');
    return _nextRaw() % max;
  }

  @override
  double nextDouble() => _nextRaw() / 0x80000000;
}

class SequenceRandomSource implements RandomSource {
  SequenceRandomSource(this.values);

  final List<int> values;
  int _index = 0;

  @override
  int get state => _index;

  @override
  set state(int value) => _index = value < 0 ? 0 : value;

  int _next() {
    if (values.isEmpty) return 0;
    final value = values[_index % values.length];
    _index += 1;
    return value;
  }

  @override
  int nextInt(int max) {
    if (max <= 0) throw ArgumentError.value(max, 'max', 'Must be positive.');
    return _next().abs() % max;
  }

  @override
  double nextDouble() => (_next().abs() % 1000) / 1000;
}
