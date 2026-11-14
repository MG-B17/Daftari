/// A signed amount of money in piasters (قرش) — 100 piasters = 1 EGP.
///
/// Rule R1: money is always an `int` of piasters wrapped in this type, never
/// a `double`, and never a stored balance (rule R2 — balances are derived
/// from transactions). A positive amount means the customer owes the shop
/// (عليه); a negative amount means the customer paid back more than owed.
///
/// This file stays pure Dart (no Flutter imports) so domain entities and use
/// cases can depend on it (rule R4). Display formatting lives in
/// `format_money.dart`.
class Money {
  const Money.fromPiasters(int piasters) : _piasters = piasters;

  final int _piasters;

  /// The signed value in piasters, for queries and persistence only.
  int get asPiasters => _piasters;

  /// Adds two amounts with integer math (rule R1).
  Money operator +(Money other) =>
      Money.fromPiasters(_piasters + other._piasters);

  /// Subtracts [other] from this amount with integer math (rule R1).
  Money operator -(Money other) =>
      Money.fromPiasters(_piasters - other._piasters);

  /// Returns the amount with the opposite sign.
  Money negate() => Money.fromPiasters(-_piasters);

  /// Compares two amounts by their signed piasters value.
  int compareTo(Money other) => _piasters.compareTo(other._piasters);

  bool operator <(Money other) => compareTo(other) < 0;

  bool operator >(Money other) => compareTo(other) > 0;

  bool operator <=(Money other) => compareTo(other) <= 0;

  bool operator >=(Money other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) =>
      other is Money && other._piasters == _piasters;

  @override
  int get hashCode => _piasters.hashCode;
}
