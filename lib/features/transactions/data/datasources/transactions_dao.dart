import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables/transactions_table.dart';

part 'transactions_dao.g.dart';

/// Data source for transaction rows.
///
/// Exposes queries only; mapping rows to domain entities and the write rules
/// (UUID v4 ids, timestamps, `sync_state`, rule R3) live in the repository
/// implementation. The foreign key to `customers` is enforced by the
/// database (PRAGMA in `beforeOpen`): an insert for a missing customer
/// throws, and the repository maps that to a failure.
@DriftAccessor(tables: [Transactions])
class TransactionsDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionsDaoMixin {
  TransactionsDao(super.db);

  /// Watches the customer's non-deleted transactions in ledger order:
  /// `occurred_at` ascending, then `created_at` ascending — oldest entry
  /// first, the order a statement reads and running balances accumulate in
  /// (agent.md Section 7). Emits again on every change to the transactions
  /// table.
  Stream<List<Transaction>> watchCustomerHistory(String customerId) {
    return (select(transactions)
          ..where((t) => t.customerId.equals(customerId) & t.deletedAt.isNull())
          ..orderBy([
            (t) => OrderingTerm.asc(t.occurredAt),
            (t) => OrderingTerm.asc(t.createdAt),
          ]))
        .watch();
  }

  /// Watches the customer's derived balance in piasters (rule R2 — balances
  /// are computed from transactions, never stored): the sum of credits
  /// minus payments over non-deleted rows, `0` when there are none. Emits
  /// again on every change to the transactions table.
  Stream<int> watchCustomerBalancePiasters(String customerId) {
    const sql =
        'SELECT COALESCE(SUM(CASE type WHEN \'credit\' THEN amount_piasters '
        'ELSE -amount_piasters END), 0) AS balance '
        'FROM transactions '
        'WHERE customer_id = ? AND deleted_at IS NULL';

    return customSelect(
      sql,
      variables: [Variable(customerId)],
      readsFrom: {transactions},
    ).watch().map((rows) => rows.first.read<int>('balance'));
  }

  /// Inserts a transaction row and returns it.
  Future<Transaction> addTransaction(TransactionsCompanion entry) =>
      into(transactions).insertReturning(entry);

  /// Updates the non-deleted transaction with [id]. Returns the updated
  /// rows: an empty list means the transaction does not exist or is
  /// soft-deleted.
  Future<List<Transaction>> updateTransaction(
    String id,
    TransactionsCompanion entry,
  ) =>
      (update(transactions)
            ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
          .writeReturning(entry);

  /// Soft-deletes the transaction with [id] (rule R3). Returns the updated
  /// rows: an empty list means the transaction does not exist or is already
  /// soft-deleted.
  Future<List<Transaction>> softDeleteTransaction(
    String id,
    TransactionsCompanion entry,
  ) =>
      (update(transactions)
            ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
          .writeReturning(entry);

  /// Returns the non-deleted transaction with [id], or `null`.
  Future<Transaction?> findNotDeletedById(String id) => (select(
    transactions,
  )..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();
}
