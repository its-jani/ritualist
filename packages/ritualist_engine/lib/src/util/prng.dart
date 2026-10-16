/// Deterministic pseudo-randomness.
///
/// Shuffles (token order for step-ordering, right-column order for matching)
/// must be stable across app restarts so that a lesson always looks the same
/// to the user and tests are reproducible. We therefore never use `Random()`
/// but a tiny xorshift32 PRNG seeded from a FNV-1a hash of the exercise id
/// (optionally mixed with an attempt counter).
library;

/// FNV-1a 32-bit hash. Stable across runs and platforms (unlike String.hashCode
/// which is only stable within a single VM run).
int fnv1a(String s) {
  var hash = 0x811c9dc5;
  for (var i = 0; i < s.length; i++) {
    hash ^= s.codeUnitAt(i);
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return hash;
}

/// xorshift32: tiny, fast, good enough for content shuffling.
class Xorshift32 {
  Xorshift32(int seed) : _state = (seed == 0 ? 0x9E3779B9 : seed) & 0xFFFFFFFF;

  int _state;

  int next() {
    var x = _state;
    x ^= (x << 13) & 0xFFFFFFFF;
    x ^= x >> 17;
    x ^= (x << 5) & 0xFFFFFFFF;
    _state = x & 0xFFFFFFFF;
    return _state;
  }

  int nextBelow(int bound) {
    if (bound <= 0) {
      throw ArgumentError.value(bound, 'bound', 'must be > 0');
    }
    return next() % bound;
  }
}

List<int> shuffledIndices(int count, int seed) {
  final order = List<int>.generate(count, (i) => i);
  final rng = Xorshift32(seed);
  for (var i = count - 1; i > 0; i--) {
    final j = rng.nextBelow(i + 1);
    final tmp = order[i];
    order[i] = order[j];
    order[j] = tmp;
  }
  return order;
}

/// Display order for [count] items that is shuffled but never the identity
/// order (when count > 1), so ordering exercises always look shuffled.
List<int> displayOrder(int count, int seed, {bool avoidIdentity = true}) {
  final order = shuffledIndices(count, seed);
  if (!avoidIdentity || count < 2) {
    return order;
  }
  var isIdentity = true;
  for (var i = 0; i < count; i++) {
    if (order[i] != i) {
      isIdentity = false;
      break;
    }
  }
  if (isIdentity) {
    // Deterministic rotation keeps the result stable.
    return List<int>.generate(count, (i) => (i + 1) % count);
  }
  return order;
}
