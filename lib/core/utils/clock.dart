/// Injectable source of the current time (agent.md Section 10).
///
/// Anything time-dependent (timestamps on writes, today's collections,
/// auto-lock) reads time through a [Clock] so tests can fix the clock and
/// stay deterministic.
abstract interface class Clock {
  /// The current time.
  DateTime now();
}

/// The default [Clock] backed by the device system clock.
class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}
