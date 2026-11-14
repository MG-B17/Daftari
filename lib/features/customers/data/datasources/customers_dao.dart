import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables/customers_table.dart';
import '../../../../core/database/tables/transactions_table.dart';
import '../../domain/entities/customer_query.dart';

part 'customers_dao.g.dart';

/// A customer row together with its derived balance in piasters (rule R2 —
/// balances are computed from transactions, never stored).
typedef CustomerWithBalanceRow = ({Customer row, int balancePiasters});

/// Data source for customer rows and their derived balances.
///
/// Exposes queries only; mapping rows to domain entities and the write rules
/// (UUID v4 ids, timestamps, `sync_state`, rule R3) live in the repository
/// implementation.
@DriftAccessor(tables: [Customers, Transactions])
class CustomersDao extends DatabaseAccessor<AppDatabase>
    with _$CustomersDaoMixin {
  CustomersDao(super.db);

  /// The per-customer balance over non-deleted transactions (rule R2) and
  /// the customer's latest activity, computed once and joined onto the
  /// customer rows.
  static const String _balanceSubquery = '''
    SELECT customer_id,
           SUM(CASE type WHEN 'credit' THEN amount_piasters
                         ELSE -amount_piasters END) AS balance,
           MAX(occurred_at) AS last_activity
    FROM transactions
    WHERE deleted_at IS NULL
    GROUP BY customer_id
  ''';

  /// Watches the non-deleted customers with their derived balances,
  /// filtered and sorted by [query]. Emits again on every change to the
  /// customers or transactions tables.
  ///
  /// Search matches a fragment of the name, case-insensitively: `LOWER()`
  /// folds ASCII case on both sides, and Arabic has no case, so this is
  /// sufficient (plan.md Section 4). LIKE wildcards in the search text are
  /// escaped so they match literally.
  Stream<List<CustomerWithBalanceRow>> watchCustomersWithBalance(
    CustomerQuery query,
  ) {
    final conditions = <String>['c.deleted_at IS NULL'];
    final variables = <Variable<String>>[];

    final search = query.searchText.trim();
    if (search.isNotEmpty) {
      conditions.add("LOWER(c.name) LIKE ? ESCAPE '\\'");
      variables.add(Variable('%${_escapeLike(search.toLowerCase())}%'));
    }
    switch (query.filter) {
      case CustomerFilter.owes:
        conditions.add('COALESCE(t.balance, 0) > 0');
      case CustomerFilter.settled:
        conditions.add('COALESCE(t.balance, 0) <= 0');
      case CustomerFilter.all:
        break;
    }

    // Secondary keys keep the ordering deterministic so identical results
    // can be dropped before they reach the presentation layer.
    final orderBy = switch (query.sort) {
      CustomerSort.byName => 'c.name COLLATE NOCASE, c.created_at, c.id',
      CustomerSort.byBalanceDesc => 'balance DESC, c.name COLLATE NOCASE, c.id',
      CustomerSort.byRecentActivity =>
        't.last_activity DESC, c.name COLLATE NOCASE, c.id',
    };

    final sql =
        'SELECT c.*, COALESCE(t.balance, 0) AS balance '
        'FROM customers c '
        'LEFT JOIN ($_balanceSubquery) AS t ON t.customer_id = c.id '
        'WHERE ${conditions.join(' AND ')} '
        'ORDER BY $orderBy';

    return customSelect(
      sql,
      variables: variables,
      readsFrom: {customers, transactions},
    ).watch().map((rows) => rows.map(_toRowWithBalance).toList());
  }

  /// Watches one non-deleted customer with their derived balance, or `null`
  /// when the customer does not exist or is soft-deleted. Emits again on
  /// every change to the customers or transactions tables.
  Stream<CustomerWithBalanceRow?> watchCustomerWithBalanceRow(String id) {
    final sql =
        'SELECT c.*, COALESCE(t.balance, 0) AS balance '
        'FROM customers c '
        'LEFT JOIN ($_balanceSubquery) AS t ON t.customer_id = c.id '
        'WHERE c.id = ? AND c.deleted_at IS NULL';

    return customSelect(
      sql,
      variables: [Variable(id)],
      readsFrom: {customers, transactions},
    ).watch().map(
      (rows) => rows.isEmpty ? null : _toRowWithBalance(rows.first),
    );
  }

  /// Inserts a customer row and returns it.
  Future<Customer> addCustomer(CustomersCompanion entry) =>
      into(customers).insertReturning(entry);

  /// Updates the non-deleted customer with [id]. Returns the updated rows:
  /// an empty list means the customer does not exist or is soft-deleted.
  Future<List<Customer>> updateCustomer(String id, CustomersCompanion entry) =>
      (update(customers)..where((c) => c.id.equals(id) & c.deletedAt.isNull()))
          .writeReturning(entry);

  /// Soft-deletes the customer with [id] (rule R3). Returns the updated
  /// rows: an empty list means the customer does not exist or is already
  /// soft-deleted.
  Future<List<Customer>> softDeleteCustomer(
    String id,
    CustomersCompanion entry,
  ) => (update(customers)..where((c) => c.id.equals(id) & c.deletedAt.isNull()))
      .writeReturning(entry);

  /// Returns the non-deleted customer with [id], or `null`.
  Future<Customer?> findNotDeletedById(String id) => (select(
    customers,
  )..where((c) => c.id.equals(id) & c.deletedAt.isNull())).getSingleOrNull();

  CustomerWithBalanceRow _toRowWithBalance(QueryRow row) => (
    row: Customer(
      id: row.read<String>('id'),
      name: row.read<String>('name'),
      phone: row.read<String?>('phone'),
      note: row.read<String?>('note'),
      createdAt: row.read<DateTime>('created_at'),
      updatedAt: row.read<DateTime>('updated_at'),
      deletedAt: row.read<DateTime?>('deleted_at'),
      syncState: row.read<String>('sync_state'),
    ),
    balancePiasters: row.read<int>('balance'),
  );

  /// Escapes the LIKE wildcards so the search matches literal characters
  /// only. The escape character is declared as `\` next to the LIKE.
  static String _escapeLike(String input) => input
      .replaceAll('\\', '\\\\')
      .replaceAll('%', '\\%')
      .replaceAll('_', '\\_');
}
