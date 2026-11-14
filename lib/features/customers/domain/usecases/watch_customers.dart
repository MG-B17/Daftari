import '../entities/customer_query.dart';
import '../entities/customer_with_balance.dart';
import '../repositories/customers_repository.dart';

/// Watches the non-deleted customers with their derived balances (rule R2),
/// applying the query's search, filter, and sort.
///
/// A thin forwarder: the query semantics live in the repository contract
/// (agent.md Section 6.2). The stream emits again on every relevant data
/// change, with identical consecutive emissions already dropped.
class WatchCustomers {
  const WatchCustomers(this._repository);

  final CustomersRepository _repository;

  Stream<List<CustomerWithBalance>> call(CustomerQuery query) =>
      _repository.watchCustomers(query);
}
