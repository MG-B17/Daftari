import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/money/money.dart';

part 'transaction.freezed.dart';

/// The type of a ledger entry (agent.md Section 7).
enum TransactionType {
  /// The customer took goods on credit and owes the shop (عليه).
  credit,

  /// The customer paid back part or all of what they owe (سدّد).
  payment,
}

/// A single ledger entry for a customer.
///
/// [amount] is always greater than zero (the database enforces this); the
/// [type] decides whether it increases or decreases the customer's balance.
/// `occurredAt` may be a past date — the entry date, not the recording time.
///
/// Pure domain entity: carries no `syncState` or `deletedAt` — those are
/// data-layer concerns handled by the repositories and Phase 7 sync
/// (rule R4).
///
/// `toString` is disabled because the generated one would print the amount
/// (rule R6).
@Freezed(toStringOverride: false)
abstract class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    required String customerId,
    required TransactionType type,
    required Money amount,
    required DateTime occurredAt,
    String? note,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Transaction;
}
