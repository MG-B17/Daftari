import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

import 'package:daftari/core/database/app_database.dart' hide Customer;
import 'package:daftari/core/error/failure.dart';
import 'package:daftari/core/money/money.dart';
import 'package:daftari/core/utils/clock.dart';
import 'package:daftari/features/customers/data/repositories/customers_repository_impl.dart';
import 'package:daftari/features/customers/domain/entities/customer.dart';
import 'package:daftari/features/customers/domain/entities/customer_query.dart';
import 'package:daftari/features/customers/domain/entities/customer_with_balance.dart';
import 'package:daftari/features/customers/domain/entities/new_customer.dart';

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
  late CustomersRepositoryImpl repository;

  const allByName = CustomerQuery(
    searchText: '',
    filter: CustomerFilter.all,
    sort: CustomerSort.byName,
  );

  /// The UUID v4 format: version nibble `4`, variant nibble `[89ab]`.
  final uuidV4 = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  );

  setUp(() {
    db = AppDatabase.inMemory();
    clock = _FakeClock(DateTime(2026, 1, 1, 12));
    repository = CustomersRepositoryImpl(database: db, clock: clock);
  });

  tearDown(() async {
    await db.close();
  });

  var transactionId = 0;

  T rightOf<T>(Either<Failure, T> result) => result.fold(
    (failure) => fail('expected a Right, got $failure'),
    (value) => value,
  );

  Failure failureOf(Either<Failure, Object?> result) =>
      result.fold((failure) => failure, (_) => fail('expected a Left'));

  Future<Customer> addCustomerNamed(String name, {String? phone}) async {
    return rightOf(
      await repository.addCustomer(NewCustomer(name: name, phone: phone)),
    );
  }

  /// Inserts a transaction row directly, because the transactions data layer
  /// is built in the next task.
  Future<void> insertTransaction(
    String customerId, {
    required String type,
    required int amountPiasters,
    DateTime? occurredAt,
    bool deleted = false,
  }) async {
    transactionId += 1;
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            id: 't-$transactionId',
            customerId: customerId,
            type: type,
            amountPiasters: amountPiasters,
            occurredAt: occurredAt ?? clock.now(),
            createdAt: clock.now(),
            updatedAt: clock.now(),
            deletedAt: Value(deleted ? clock.now() : null),
          ),
        );
  }

  test('adds a customer with a UUID v4 id, pending sync state, and clock timestamps', () async {
    final customer = await addCustomerNamed('محمد');

    expect(customer.name, 'محمد');
    expect(customer.phone, isNull);
    expect(uuidV4.hasMatch(customer.id), isTrue);
    expect(customer.createdAt, DateTime(2026, 1, 1, 12));
    expect(customer.updatedAt, DateTime(2026, 1, 1, 12));

    final row = await (db.select(
      db.customers,
    )..where((c) => c.id.equals(customer.id))).getSingle();
    expect(row.syncState, 'pending');
    expect(row.deletedAt, isNull);
  });

  test('addCustomer stores the optional phone', () async {
    final customer = await addCustomerNamed('أحمد', phone: '01001234567');

    final stored = rightOf(await repository.getCustomer(customer.id));
    expect(stored.phone, '01001234567');
    expect(stored.note, isNull);
  });

  test('updateCustomer bumps updated_at and keeps created_at and the pending sync state', () async {
    final customer = await addCustomerNamed('أحمد');
    clock.advance(const Duration(hours: 2));

    final updated = rightOf(
      await repository.updateCustomer(
        customer.id,
        NewCustomer(name: 'أحمد محمد', phone: '0100'),
      ),
    );

    expect(updated.name, 'أحمد محمد');
    expect(updated.phone, '0100');
    expect(updated.createdAt, DateTime(2026, 1, 1, 12));
    expect(updated.updatedAt, DateTime(2026, 1, 1, 14));

    final row = await (db.select(
      db.customers,
    )..where((c) => c.id.equals(customer.id))).getSingle();
    expect(row.syncState, 'pending');
    expect(row.deletedAt, isNull);
  });

  test('updateCustomer fails for a customer that does not exist', () async {
    final failure = failureOf(
      await repository.updateCustomer('missing', NewCustomer(name: 'لا أحد')),
    );

    expect(failure, isA<DatabaseFailure>());
  });

  test('updateCustomer fails for a soft-deleted customer', () async {
    final customer = await addCustomerNamed('محذوف');
    rightOf(await repository.deleteCustomer(customer.id));

    final failure = failureOf(
      await repository.updateCustomer(customer.id, NewCustomer(name: 'آخر')),
    );

    expect(failure, isA<DatabaseFailure>());
  });

  test('deleteCustomer soft-deletes: the row stays, and the customer disappears from every read', () async {
    final customer = await addCustomerNamed('سالم');
    clock.advance(const Duration(hours: 1));

    rightOf(await repository.deleteCustomer(customer.id));

    // The row is still there, marked as deleted (rule R3 — no hard delete).
    final rows = await db.select(db.customers).get();
    expect(rows, hasLength(1));
    expect(rows.single.deletedAt, DateTime(2026, 1, 1, 13));
    expect(rows.single.updatedAt, DateTime(2026, 1, 1, 13));
    expect(rows.single.syncState, 'pending');

    final list = await repository.watchCustomers(allByName).first;
    expect(list, isEmpty);

    expect(
      await repository.watchCustomerWithBalance(customer.id).first,
      isNull,
    );

    expect(
      failureOf(await repository.getCustomer(customer.id)),
      isA<DatabaseFailure>(),
    );
  });

  test('deleteCustomer fails for a customer that does not exist', () async {
    expect(
      failureOf(await repository.deleteCustomer('missing')),
      isA<DatabaseFailure>(),
    );
  });

  test('deleteCustomer fails when the customer is already deleted', () async {
    final customer = await addCustomerNamed('سالم');
    rightOf(await repository.deleteCustomer(customer.id));

    expect(
      failureOf(await repository.deleteCustomer(customer.id)),
      isA<DatabaseFailure>(),
    );
  });

  test('getCustomer returns the customer when it exists', () async {
    final customer = await addCustomerNamed('محمد');

    final stored = rightOf(await repository.getCustomer(customer.id));
    expect(stored, customer);
  });

  test('getCustomer fails for a customer that does not exist', () async {
    expect(
      failureOf(await repository.getCustomer('missing')),
      isA<DatabaseFailure>(),
    );
  });

  test(
    'watchCustomers searches by a name fragment, case-insensitively',
    () async {
      await addCustomerNamed('Mahmoud');
      await addCustomerNamed('علي');

      final list = await repository
          .watchCustomers(
            const CustomerQuery(
              searchText: 'MAHM',
              filter: CustomerFilter.all,
              sort: CustomerSort.byName,
            ),
          )
          .first;

      expect(list.map((entry) => entry.customer.name), ['Mahmoud']);
    },
  );

  test(
    'watchCustomers matches LIKE wildcards in the search literally',
    () async {
      await addCustomerNamed('100% طبيعي');
      await addCustomerNamed('100X طبيعي');

      final list = await repository
          .watchCustomers(
            const CustomerQuery(
              searchText: '100%',
              filter: CustomerFilter.all,
              sort: CustomerSort.byName,
            ),
          )
          .first;

      expect(list.map((entry) => entry.customer.name), ['100% طبيعي']);
    },
  );

  test(
    'watchCustomers with an empty search returns every non-deleted customer',
    () async {
      await addCustomerNamed('أحمد');
      await addCustomerNamed('سالم');

      final list = await repository.watchCustomers(allByName).first;

      expect(list, hasLength(2));
    },
  );

  test(
    'watchCustomers filter owes keeps only customers with a positive balance',
    () async {
      final debtor = await addCustomerNamed('مدين');
      final settled = await addCustomerNamed('خالص');
      final ahead = await addCustomerNamed('سبق');
      await insertTransaction(debtor.id, type: 'credit', amountPiasters: 50000);
      await insertTransaction(
        settled.id,
        type: 'credit',
        amountPiasters: 30000,
      );
      await insertTransaction(
        settled.id,
        type: 'payment',
        amountPiasters: 30000,
      );
      await insertTransaction(ahead.id, type: 'payment', amountPiasters: 20000);

      final owes = await repository
          .watchCustomers(
            const CustomerQuery(
              searchText: '',
              filter: CustomerFilter.owes,
              sort: CustomerSort.byName,
            ),
          )
          .first;
      expect(owes.map((entry) => entry.customer.id), [debtor.id]);

      final settledList = await repository
          .watchCustomers(
            const CustomerQuery(
              searchText: '',
              filter: CustomerFilter.settled,
              sort: CustomerSort.byName,
            ),
          )
          .first;
      expect(
        settledList.map((entry) => entry.customer.id),
        unorderedEquals([settled.id, ahead.id]),
      );

      final all = await repository.watchCustomers(allByName).first;
      expect(all, hasLength(3));
    },
  );

  test(
    'watchCustomers sorts by name alphabetically, case-insensitively',
    () async {
      await addCustomerNamed('Baher');
      await addCustomerNamed('ahmed');
      await addCustomerNamed('Ali');

      final list = await repository.watchCustomers(allByName).first;

      expect(list.map((entry) => entry.customer.name), [
        'ahmed',
        'Ali',
        'Baher',
      ]);
    },
  );

  test('watchCustomers sorts by balance with the highest first', () async {
    final big = await addCustomerNamed('كبير');
    final small = await addCustomerNamed('صغير');
    final zero = await addCustomerNamed('خالص');
    await insertTransaction(big.id, type: 'credit', amountPiasters: 50000);
    await insertTransaction(small.id, type: 'credit', amountPiasters: 10000);

    final list = await repository
        .watchCustomers(
          const CustomerQuery(
            searchText: '',
            filter: CustomerFilter.all,
            sort: CustomerSort.byBalanceDesc,
          ),
        )
        .first;

    expect(list.map((entry) => entry.customer.id), [big.id, small.id, zero.id]);
  });

  test('watchCustomers sorts by latest activity with customers without activity last', () async {
    final active = await addCustomerNamed('نشط');
    final older = await addCustomerNamed('قديم');
    final inactive = await addCustomerNamed('جديد');
    await insertTransaction(
      older.id,
      type: 'credit',
      amountPiasters: 100,
      occurredAt: DateTime(2026, 1, 1),
    );
    await insertTransaction(
      active.id,
      type: 'credit',
      amountPiasters: 200,
      occurredAt: DateTime(2026, 1, 5),
    );

    final list = await repository
        .watchCustomers(
          const CustomerQuery(
            searchText: '',
            filter: CustomerFilter.all,
            sort: CustomerSort.byRecentActivity,
          ),
        )
        .first;

    expect(list.map((entry) => entry.customer.id), [
      active.id,
      older.id,
      inactive.id,
    ]);
  });

  test(
    'watchCustomers reports a zero balance for a customer without transactions',
    () async {
      await addCustomerNamed('جديد');

      final list = await repository.watchCustomers(allByName).first;

      expect(list.single.balance, const Money.fromPiasters(0));
    },
  );

  test(
    'watchCustomers derives the balance as credits minus payments',
    () async {
      final customer = await addCustomerNamed('عميل');
      await insertTransaction(
        customer.id,
        type: 'credit',
        amountPiasters: 125000,
      );
      await insertTransaction(
        customer.id,
        type: 'payment',
        amountPiasters: 25000,
      );

      final list = await repository.watchCustomers(allByName).first;

      expect(list.single.balance, const Money.fromPiasters(100000));
    },
  );

  test(
    'a soft-deleted transaction does not count towards the balance',
    () async {
      final customer = await addCustomerNamed('عميل');
      await insertTransaction(
        customer.id,
        type: 'credit',
        amountPiasters: 50000,
      );
      await insertTransaction(
        customer.id,
        type: 'payment',
        amountPiasters: 20000,
        deleted: true,
      );

      final list = await repository.watchCustomers(allByName).first;

      expect(list.single.balance, const Money.fromPiasters(50000));
    },
  );

  test('a soft-deleted customer is excluded and its transactions are excluded from the list', () async {
    final deleted = await addCustomerNamed('محذوف');
    final remaining = await addCustomerNamed('باقي');
    await insertTransaction(deleted.id, type: 'credit', amountPiasters: 10000);
    await insertTransaction(
      remaining.id,
      type: 'payment',
      amountPiasters: 4000,
    );
    rightOf(await repository.deleteCustomer(deleted.id));

    final list = await repository.watchCustomers(allByName).first;

    expect(list.map((entry) => entry.customer.id), [remaining.id]);
    expect(list.single.balance, const Money.fromPiasters(-4000));
  });

  test('watchCustomerWithBalance emits the customer with a zero balance when it has no transactions', () async {
    final customer = await addCustomerNamed('جديد');

    final result = await repository.watchCustomerWithBalance(customer.id).first;

    expect(result, isNotNull);
    expect(result!.customer, customer);
    expect(result.balance, const Money.fromPiasters(0));
  });

  test(
    'watchCustomerWithBalance emits null for a customer that does not exist',
    () async {
      expect(
        await repository.watchCustomerWithBalance('missing').first,
        isNull,
      );
    },
  );

  test(
    'watchCustomers does not re-emit when only a non-domain field changes',
    () async {
      final customer = await addCustomerNamed('عميل');
      final emissions = <List<CustomerWithBalance>>[];
      final subscription = repository
          .watchCustomers(allByName)
          .listen(emissions.add);
      await pumpEventQueue();
      expect(emissions, hasLength(1));

      // sync_state is not part of the domain entity, so this change must not
      // reach the presentation layer.
      await (db.update(db.customers)..where((c) => c.id.equals(customer.id)))
          .write(const CustomersCompanion(syncState: Value('synced')));
      await pumpEventQueue();

      expect(emissions, hasLength(1));
      await subscription.cancel();
    },
  );

  test(
    'watchCustomers re-emits when a transaction changes a balance',
    () async {
      final customer = await addCustomerNamed('عميل');
      final emissions = <List<CustomerWithBalance>>[];
      final subscription = repository
          .watchCustomers(allByName)
          .listen(emissions.add);
      await pumpEventQueue();
      expect(emissions.single.single.balance, const Money.fromPiasters(0));

      await insertTransaction(
        customer.id,
        type: 'credit',
        amountPiasters: 10000,
      );
      await pumpEventQueue();

      expect(emissions, hasLength(2));
      expect(emissions.last.single.balance, const Money.fromPiasters(10000));
      await subscription.cancel();
    },
  );
}
