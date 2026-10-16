/// Injectable time source so all engine logic is deterministic in tests.
typedef Clock = DateTime Function();

/// Default production clock.
DateTime systemClock() => DateTime.now();
