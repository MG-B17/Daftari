/// Base type for every failure returned by one-shot domain operations
/// (rule R5 — never throw across layers).
///
/// Failures carry no exception details and never contain customer names,
/// phone numbers, or amounts (rule R6).
sealed class Failure {
  const Failure();
}

/// A local database (Drift/SQLite) operation failed.
final class DatabaseFailure extends Failure {
  const DatabaseFailure();
}

/// A network operation failed (used from Phase 7 — account and backup).
final class NetworkFailure extends Failure {
  const NetworkFailure();
}

/// Authentication failed (used from Phase 7 — account and backup).
final class AuthFailure extends Failure {
  const AuthFailure();
}

/// Input validation failed.
final class ValidationFailure extends Failure {
  const ValidationFailure(this.code);

  /// A stable key describing the problem (for example `name_required`),
  /// never user data (rule R6). The presentation layer maps it to a
  /// localized message.
  final String code;
}

/// An error that does not match any known failure category.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure();
}
