import 'package:drift/drift.dart';

/// Ledger entries: `credit` (عليه — customer took goods on credit) and
/// `payment` (سدّد — customer paid back), per agent.md Section 7.
///
/// Amounts are always integer piasters greater than zero (rule R1); the check
/// constraint lives in the database so bad values can never be stored.
@TableIndex(
  name: 'idx_transactions_customer_occurred',
  columns: {#customerId, #occurredAt},
)
@TableIndex(name: 'idx_transactions_sync_state', columns: {#syncState})
class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get customerId =>
      text().customConstraint('NOT NULL REFERENCES customers (id)')();

  /// Either `credit` or `payment`; enforced by a check constraint.
  TextColumn get type => text().check(
    const CustomExpression<bool>("type IN ('credit', 'payment')"),
  )();

  /// Amount in piasters; enforced `> 0` by a check constraint (rule R1).
  IntColumn get amountPiasters =>
      integer().check(const CustomExpression<bool>('amount_piasters > 0'))();

  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get syncState => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}
