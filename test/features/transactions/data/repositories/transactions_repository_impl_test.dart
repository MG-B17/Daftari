import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

import 'package:daftari/core/database/app_database.dart' hide Transaction;
import 'package:daftari/core/error/failure.dart';
import 'package:daftari/core/money/money.dart';
import 'package:daftari/core/utils/clock.dart';
import 'package:daftari/features/transactions/data/repositories/transactions_repository_impl.dart';
import 'package:daftari/features/transactions/domain/entities/new_transaction.dart';
import 'package:daftari/features/transactions/domain/entities/transaction.dart';

/// A clock that only moves when the test advances it, so timestamps are
/// deterministic (agent.md Section 10).
class _FakeClock implements Clock {
  _FakeClock(this._now);

  DateTime _now;

  void advance(Duration duration) {
    _now = _now.add(duration);
  }

  @override
  DateTime now() => _now;
}

void main() {
  late AppDatabase db;
  late _FakeClock clock;
  late TransactionsRepositoryImpl repository;

  /// The UUID v4 format: version nibble `4`, variant nibble `[89ab]`.
  final uuidV4 = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  );

  setUp(() {
    db = AppDatabase.inMemory();
    clock = _FakeClock(DateTime(2026, 1, 1, 12));
    repository = TransactionsRepositoryImpl(database: db, clock: clock);
  });

  tearDown(() async {
    await db.close();
  });

  T rightOf<T>(Either<Failure, T> result) => result.fold(
    (failure) => fail('expected a Right, got $failure'),
    (value) => value,
  );

  Failure failureOf(Either<Failure, Object?> result) =>
      result.fold((failure) => failure, (_) => fail('expected a Left'));

  /// Seeds a customer row directly, because the customers repository
  /// generates its own ids (established pattern from the database tests).
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

  Future<Transaction> addTransactionFor(
    String customerId, {
    required TransactionType type,
    required int amountPiasters,
    DateTime? occurredAt,
    String? note,
  }) async {
    return rightOf(
      await repository.addTransaction(
        NewTransaction(
          customerId: customerId,
          type: type,
          amount: Money.fromPiasters(amountPiasters),
          occurredAt: occurredAt ?? clock.now(),
          note: note,
        ),
      ),
    );
  }

  test('adds a transaction with a UUID v4 id, pending sync state, and clock timestamps', () async {
    await insertCustomer();

    final transaction = await addTransactionFor(
      'c-1',
      type: TransactionType.credit,
      amountPiasters: 125000,
    );

    expect(transaction.customerId, 'c-1');
    expect(transaction.type, TransactionType.credit);
    expect(transaction.amount, const Money.fromPiasters(125000));
    expect(uuidV4.hasMatch(transaction.id), isTrue, reason: transaction.id);
    expect(transaction.createdAt, DateTime(2026, 1, 1, 12));
    expect(transaction.updatedAt, DateTime(2026, 1, 1, 12));

    final row = await (db.select(
      db.transactions,
    )..where((t) => t.id.equals(transaction.id))).getSingle();
    expect(row.amountPiasters, 125000);
    expect(row.syncState, 'pending');
    expect(row.deletedAt, isNull);
  });

  test('addTransaction stores the note and the payment type', () async {
    await insertCustomer();

    final transaction = await addTransactionFor(
      'c-1',
      type: TransactionType.payment,
      amountPiasters: 5000,
      note: 'سدّد جزء',
    );

    final stored = rightOf(await repository.getTransaction(transaction.id));
    expect(stored.type, TransactionType.payment);
    expect(stored.note, 'سدّد جزء');
  });

  test('addTransaction fails for a customer that does not exist', () async {
    final failure = failureOf(
      await repository.addTransaction(
        NewTransaction(
          customerId: 'missing',
          type: TransactionType.credit,
          amount: Money.fromPiasters(10000),
          occurredAt: clock.now(),
        ),
      ),
    );

    expect(failure, isA<DatabaseFailure>());
  });

  test('updateTransaction bumps updated_at and keeps created_at and the pending sync state', () async {
    await insertCustomer();
    final transaction = await addTransactionFor(
      'c-1',
      type: TransactionType.credit,
      amountPiasters: 10000,
    );
    clock.advance(const Duration(hours: 2));

    final updated = rightOf(
      await repository.updateTransaction(
        transaction.id,
        NewTransaction(
          customerId: 'c-1',
          type: TransactionType.credit,
          amount: Money.fromPiasters(20000),
          occurredAt: transaction.occurredAt,
          note: 'معدّلة',
        ),
      ),
    );

    expect(updated.amount, const Money.fromPiasters(20000));
    expect(updated.note, 'معدّلة');
    expect(updated.createdAt, DateTime(2026, 1, 1, 12));
    expect(updated.updatedAt, DateTime(2026, 1, 1, 14));

    final row = await (db.select(
      db.transactions,
    )..where((t) => t.id.equals(transaction.id))).getSingle();
    expect(row.syncState, 'pending');
    expect(row.deletedAt, isNull);
  });

  test(
    'updateTransaction fails for a transaction that does not exist',
    () async {
      final failure = failureOf(
        await repository.updateTransaction(
          'missing',
          NewTransaction(
            customerId: 'c-1',
            type: TransactionType.credit,
            amount: Money.fromPiasters(10000),
            occurredAt: clock.now(),
          ),
        ),
      );

      expect(failure, isA<DatabaseFailure>());
    },
  );

  test('updateTransaction fails for a soft-deleted transaction', () async {
    await insertCustomer();
    final transaction = await addTransactionFor(
      'c-1',
      type: TransactionType.credit,
      amountPiasters: 10000,
    );
    rightOf(await repository.deleteTransaction(transaction.id));

    final failure = failureOf(
      await repository.updateTransaction(
        transaction.id,
        NewTransaction(
          customerId: 'c-1',
          type: TransactionType.credit,
          amount: Money.fromPiasters(20000),
          occurredAt: transaction.occurredAt,
        ),
      ),
    );

    expect(failure, isA<DatabaseFailure>());
  });

  test('deleteTransaction soft-deletes: the row stays, and the transaction disappears from every read', () async {
    await insertCustomer();
    final transaction = await addTransactionFor(
      'c-1',
      type: TransactionType.credit,
      amountPiasters: 10000,
    );
    clock.advance(const Duration(hours: 1));

    rightOf(await repository.deleteTransaction(transaction.id));

    // The row is still there, marked as deleted (rule R3 — no hard delete).
    final row = await (db.select(
      db.transactions,
    )..where((t) => t.id.equals(transaction.id))).getSingle();
    expect(row.deletedAt, DateTime(2026, 1, 1, 13));
    expect(row.updatedAt, DateTime(2026, 1, 1, 13));
    expect(row.syncState, 'pending');

    expect(await repository.watchCustomerHistory('c-1').first, isEmpty);
    expect(
      await repository.watchCustomerBalance('c-1').first,
      const Money.fromPiasters(0),
    );
    expect(
      failureOf(await repository.getTransaction(transaction.id)),
      isA<DatabaseFailure>(),
    );
  });

  test(
    'deleteTransaction fails for a transaction that does not exist',
    () async {
      expect(
        failureOf(await repository.deleteTransaction('missing')),
        isA<DatabaseFailure>(),
      );
    },
  );

  test(
    'deleteTransaction fails when the transaction is already deleted',
    () async {
      await insertCustomer();
      final transaction = await addTransactionFor(
        'c-1',
        type: TransactionType.credit,
        amountPiasters: 10000,
      );
      rightOf(await repository.deleteTransaction(transaction.id));

      expect(
        failureOf(await repository.deleteTransaction(transaction.id)),
        isA<DatabaseFailure>(),
      );
    },
  );

  test('getTransaction returns the transaction when it exists', () async {
    await insertCustomer();
    final transaction = await addTransactionFor(
      'c-1',
      type: TransactionType.credit,
      amountPiasters: 10000,
    );

    final stored = rightOf(await repository.getTransaction(transaction.id));
    expect(stored, transaction);
  });

  test('getTransaction fails for a transaction that does not exist', () async {
    expect(
      failureOf(await repository.getTransaction('missing')),
      isA<DatabaseFailure>(),
    );
  });

  test('watchCustomerHistory orders by occurred_at, oldest first, regardless of insertion order', () async {
    await insertCustomer();
    final later = await addTransactionFor(
      'c-1',
      type: TransactionType.credit,
      amountPiasters: 100,
      occurredAt: DateTime(2026, 1, 5),
    );
    final earlier = await addTransactionFor(
      'c-1',
      type: TransactionType.credit,
      amountPiasters: 200,
      occurredAt: DateTime(2026, 1, 1),
    );

    final history = await repository.watchCustomerHistory('c-1').first;

    expect(history.map((t) => t.id), [earlier.id, later.id]);
  });

  test(
    'watchCustomerHistory breaks an occurred_at tie by created_at',
    () async {
      await insertCustomer();
      final first = await addTransactionFor(
        'c-1',
        type: TransactionType.credit,
        amountPiasters: 100,
        occurredAt: DateTime(2026, 1, 3),
      );
      clock.advance(const Duration(hours: 1));
      final second = await addTransactionFor(
        'c-1',
        type: TransactionType.credit,
        amountPiasters: 200,
        occurredAt: DateTime(2026, 1, 3),
      );

      final history = await repository.watchCustomerHistory('c-1').first;

      expect(history.map((t) => t.id), [first.id, second.id]);
    },
  );

  test('watchCustomerHistory emits an empty list for a customer without transactions', () async {
    await insertCustomer();

    expect(await repository.watchCustomerHistory('c-1').first, isEmpty);
  });

  test('watchCustomerHistory excludes soft-deleted transactions', () async {
    await insertCustomer();
    final kept = await addTransactionFor(
      'c-1',
      type: TransactionType.credit,
      amountPiasters: 100,
    );
    final removed = await addTransactionFor(
      'c-1',
      type: TransactionType.payment,
      amountPiasters: 50,
    );
    rightOf(await repository.deleteTransaction(removed.id));

    final history = await repository.watchCustomerHistory('c-1').first;

    expect(history.map((t) => t.id), [kept.id]);
  });

  test('watchCustomerBalance derives credits minus payments', () async {
    await insertCustomer();
    await addTransactionFor(
      'c-1',
      type: TransactionType.credit,
      amountPiasters: 125000,
    );
    await addTransactionFor(
      'c-1',
      type: TransactionType.payment,
      amountPiasters: 25000,
    );

    expect(
      await repository.watchCustomerBalance('c-1').first,
      const Money.fromPiasters(100000),
    );
  });

  test(
    'watchCustomerBalance emits zero for a customer without transactions',
    () async {
      await insertCustomer();

      expect(
        await repository.watchCustomerBalance('c-1').first,
        const Money.fromPiasters(0),
      );
    },
  );

  test('watchCustomerBalance excludes soft-deleted transactions', () async {
    await insertCustomer();
    await addTransactionFor(
      'c-1',
      type: TransactionType.credit,
      amountPiasters: 50000,
    );
    final removed = await addTransactionFor(
      'c-1',
      type: TransactionType.payment,
      amountPiasters: 20000,
    );
    rightOf(await repository.deleteTransaction(removed.id));

    expect(
      await repository.watchCustomerBalance('c-1').first,
      const Money.fromPiasters(50000),
    );
  });

  test('watchCustomerHistory re-emits when a transaction is added', () async {
    await insertCustomer();
    final emissions = <List<Transaction>>[];
    final subscription = repository
        .watchCustomerHistory('c-1')
        .listen(emissions.add);
    await pumpEventQueue();
    expect(emissions.single, isEmpty);

    await addTransactionFor(
      'c-1',
      type: TransactionType.credit,
      amountPiasters: 10000,
    );
    await pumpEventQueue();

    expect(emissions, hasLength(2));
    expect(emissions.last.single.amount, const Money.fromPiasters(10000));
    await subscription.cancel();
  });

  test('watchCustomerHistory does not re-emit when only a non-domain field changes', () async {
    await insertCustomer();
    final transaction = await addTransactionFor(
      'c-1',
      type: TransactionType.credit,
      amountPiasters: 10000,
    );
    final emissions = <List<Transaction>>[];
    final subscription = repository
        .watchCustomerHistory('c-1')
        .listen(emissions.add);
    await pumpEventQueue();
    expect(emissions, hasLength(1));

    // sync_state is not part of the domain entity, so this change must not
    // reach the presentation layer.
    await (db.update(db.transactions)
          ..where((t) => t.id.equals(transaction.id)))
        .write(const TransactionsCompanion(syncState: Value('synced')));
    await pumpEventQueue();

    expect(emissions, hasLength(1));
    await subscription.cancel();
  });

  test('watchCustomerBalance re-emits when a transaction is added', () async {
    await insertCustomer();
    final emissions = <Money>[];
    final subscription = repository
        .watchCustomerBalance('c-1')
        .listen(emissions.add);
    await pumpEventQueue();
    expect(emissions.single, const Money.fromPiasters(0));

    await addTransactionFor(
      'c-1',
      type: TransactionType.credit,
      amountPiasters: 10000,
    );
    await pumpEventQueue();

    expect(emissions, hasLength(2));
    expect(emissions.last, const Money.fromPiasters(10000));
    await subscription.cancel();
  });

  test('watchCustomerBalance does not re-emit when only a non-balance field changes', () async {
    await insertCustomer();
    final transaction = await addTransactionFor(
      'c-1',
      type: TransactionType.credit,
      amountPiasters: 10000,
    );
    final emissions = <Money>[];
    final subscription = repository
        .watchCustomerBalance('c-1')
        .listen(emissions.add);
    await pumpEventQueue();
    expect(emissions, hasLength(1));

    // The note is not part of the balance, so this change must not reach
    // the presentation layer.
    await (db.update(db.transactions)
          ..where((t) => t.id.equals(transaction.id)))
        .write(const TransactionsCompanion(note: Value('ملاحظة')));
    await pumpEventQueue();

    expect(emissions, hasLength(1));
    await subscription.cancel();
  });
}
