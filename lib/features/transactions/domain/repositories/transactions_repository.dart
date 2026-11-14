import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/money/money.dart';
import '../entities/new_transaction.dart';
import '../entities/transaction.dart';

/// Contract for transaction data operations (agent.md Section 6.2).
///
/// One-shot operations return `Either<Failure, T>` and never throw across
/// layers (rule R5). Watches return plain streams; the Cubit maps stream
/// errors to a failure state (agent.md Section 6.1).
abstract interface class TransactionsRepository {
  /// Creates a transaction for an existing customer, generating its UUID v4
  /// `id` and timestamps (rule R3). Fails when the customer does not exist.
  Future<Either<Failure, Transaction>> addTransaction(NewTransaction input);

  /// Updates a transaction's editable fields and bumps `updated_at`
  /// (rule R3).
  Future<Either<Failure, Transaction>> updateTransaction(
    String id,
    NewTransaction input,
  );

  /// Soft-deletes a transaction (rule R3): it disappears from the history
  /// and stops counting towards the balance (rule R2).
  Future<Either<Failure, Unit>> deleteTransaction(String id);

  /// Returns a single transaction, or a failure if it does not exist.
  Future<Either<Failure, Transaction>> getTransaction(String id);

  /// Watches a customer's non-deleted history, sorted by `occurred_at` then
  /// `created_at` (agent.md Section 7 — entries may be past-dated). Emits
  /// again on every relevant data change.
  Stream<List<Transaction>> watchCustomerHistory(String customerId);

  /// Watches the customer's balance derived from their non-deleted
  /// transactions (rule R2): sum of credits minus payments. A positive
  /// balance means the customer owes the shop (عليه).
  Stream<Money> watchCustomerBalance(String customerId);
}
