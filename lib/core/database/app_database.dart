import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../features/customers/data/datasources/customers_dao.dart';
import '../../features/transactions/data/datasources/transactions_dao.dart';
import 'tables/customers_table.dart';
import 'tables/transactions_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Customers, Transactions],
  daos: [CustomersDao, TransactionsDao],
)
class AppDatabase extends _$AppDatabase {
  /// Opens the app's on-disk database (offline-first local storage).
  AppDatabase() : super(driftDatabase(name: 'daftari'));

  /// In-memory database for tests.
  AppDatabase.inMemory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    beforeOpen: (details) async {
      // Enforce the foreign key constraints declared in the schema.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
