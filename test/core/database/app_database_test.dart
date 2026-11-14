import 'package:flutter_test/flutter_test.dart';

import 'package:daftari/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.inMemory();
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> insertCustomer({String id = 'c-1'}) async {
    await db
        .into(db.customers)
        .insert(
          CustomersCompanion.insert(
            id: id,
            name: 'عميل تجريبي',
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 1),
          ),
        );
  }

  test('creates schema version 1 from scratch', () async {
    expect(db.schemaVersion, 1);

    // Creating the database from scratch works: the first write succeeds and
    // rows are readable. This is the v1 migration baseline (rule R12).
    await insertCustomer();
    final customers = await db.select(db.customers).get();
    expect(customers, hasLength(1));
  });

  test('inserts a customer with the pending sync state by default', () async {
    await insertCustomer();

    final customers = await db.select(db.customers).get();
    expect(customers, hasLength(1));
    expect(customers.single.name, 'عميل تجريبي');
    expect(customers.single.syncState, 'pending');
    expect(customers.single.deletedAt, isNull);
  });

  test('inserts a credit transaction linked to a customer', () async {
    await insertCustomer();

    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            id: 't-1',
            customerId: 'c-1',
            type: 'credit',
            amountPiasters: 125000,
            occurredAt: DateTime(2026, 1, 2),
            createdAt: DateTime(2026, 1, 2),
            updatedAt: DateTime(2026, 1, 2),
          ),
        );

    final transactions = await db.select(db.transactions).get();
    expect(transactions, hasLength(1));
    expect(transactions.single.type, 'credit');
    expect(transactions.single.amountPiasters, 125000);
    expect(transactions.single.syncState, 'pending');
    expect(transactions.single.deletedAt, isNull);
  });

  test('rejects a transaction with a non-positive amount', () async {
    await insertCustomer();

    await expectLater(
      db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: 't-zero',
              customerId: 'c-1',
              type: 'credit',
              amountPiasters: 0,
              occurredAt: DateTime(2026, 1, 2),
              createdAt: DateTime(2026, 1, 2),
              updatedAt: DateTime(2026, 1, 2),
            ),
          ),
      throwsA(anything),
    );

    await expectLater(
      db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: 't-negative',
              customerId: 'c-1',
              type: 'payment',
              amountPiasters: -50,
              occurredAt: DateTime(2026, 1, 2),
              createdAt: DateTime(2026, 1, 2),
              updatedAt: DateTime(2026, 1, 2),
            ),
          ),
      throwsA(anything),
    );

    final transactions = await db.select(db.transactions).get();
    expect(transactions, isEmpty);
  });

  test(
    'rejects a transaction with a type other than credit or payment',
    () async {
      await insertCustomer();

      await expectLater(
        db
            .into(db.transactions)
            .insert(
              TransactionsCompanion.insert(
                id: 't-bad-type',
                customerId: 'c-1',
                type: 'loan',
                amountPiasters: 100,
                occurredAt: DateTime(2026, 1, 2),
                createdAt: DateTime(2026, 1, 2),
                updatedAt: DateTime(2026, 1, 2),
              ),
            ),
        throwsA(anything),
      );
    },
  );

  test('rejects a transaction for a customer that does not exist', () async {
    await expectLater(
      db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: 't-orphan',
              customerId: 'missing',
              type: 'credit',
              amountPiasters: 100,
              occurredAt: DateTime(2026, 1, 2),
              createdAt: DateTime(2026, 1, 2),
              updatedAt: DateTime(2026, 1, 2),
            ),
          ),
      throwsA(anything),
    );
  });

  test('filters customers by deleted_at presence', () async {
    await insertCustomer();

    final notDeleted = await (db.select(
      db.customers,
    )..where((c) => c.deletedAt.isNull())).get();
    expect(notDeleted, hasLength(1));

    final deleted = await (db.select(
      db.customers,
    )..where((c) => c.deletedAt.isNotNull())).get();
    expect(deleted, isEmpty);
  });
}
