import '../entities/transaction.dart';
import '../repositories/transactions_repository.dart';

/// Watches a customer's non-deleted history in ledger order: `occurred_at`
/// ascending, then `created_at` ascending — oldest entry first, the order a
/// statement reads and running balances accumulate in (agent.md Section 7).
///
/// A thin forwarder: the ordering and soft-delete semantics live in the
/// repository contract (agent.md Section 6.2). The stream emits again on
/// every relevant data change, with identical consecutive emissions already
/// dropped.
class WatchCustomerHistory {
  const WatchCustomerHistory(this._repository);

  final TransactionsRepository _repository;

  Stream<List<Transaction>> call(String customerId) =>
      _repository.watchCustomerHistory(customerId);
}
