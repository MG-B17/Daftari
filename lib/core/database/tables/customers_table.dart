import 'package:drift/drift.dart';

/// Customers tracked by the shop (agent.md Section 7).
///
/// Every row has `id` (UUID v4), `created_at`, `updated_at`, `deleted_at`, and
/// `sync_state` so the schema stays sync-ready (rule R3). Deletes are soft
/// (`deleted_at`); this schema version never hard-deletes rows.
@TableIndex(name: 'idx_customers_sync_state', columns: {#syncState})
@TableIndex(name: 'idx_customers_name', columns: {#name})
class Customers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get syncState => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}
