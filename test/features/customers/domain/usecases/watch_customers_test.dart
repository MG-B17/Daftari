import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

import 'package:daftari/core/error/failure.dart';
import 'package:daftari/core/money/money.dart';
import 'package:daftari/features/customers/domain/entities/customer.dart';
import 'package:daftari/features/customers/domain/entities/customer_query.dart';
import 'package:daftari/features/customers/domain/entities/customer_with_balance.dart';
import 'package:daftari/features/customers/domain/entities/new_customer.dart';
import 'package:daftari/features/customers/domain/repositories/customers_repository.dart';
import 'package:daftari/features/customers/domain/usecases/watch_customers.dart';

/// A hand-rolled fake (no mocking package until Phase 2) that only serves
/// `watchCustomers`; every other method is out of scope for this use case.
class _FakeCustomersRepository implements CustomersRepository {
  _FakeCustomersRepository(this.watchCustomersStream);

  final Stream<List<CustomerWithBalance>> watchCustomersStream;

  CustomerQuery? lastQuery;
  int watchCalls = 0;

  @override
  Stream<List<CustomerWithBalance>> watchCustomers(CustomerQuery query) {
    watchCalls += 1;
    lastQuery = query;
    return watchCustomersStream;
  }

  @override
  Future<Either<Failure, Customer>> addCustomer(NewCustomer input) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> deleteCustomer(String id) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Customer>> getCustomer(String id) =>
      throw UnimplementedError();

  @override
  Stream<CustomerWithBalance?> watchCustomerWithBalance(String id) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Customer>> updateCustomer(
    String id,
    NewCustomer input,
  ) => throw UnimplementedError();
}

void main() {
  Customer customer(String id) => Customer(
    id: id,
    name: 'عميل $id',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  CustomerWithBalance entry(String id, int balancePiasters) =>
      CustomerWithBalance(
        customer: customer(id),
        balance: Money.fromPiasters(balancePiasters),
      );

  test('forwards the query to the repository and returns its stream', () {
    final controller = StreamController<List<CustomerWithBalance>>();
    final source = controller.stream;
    final repository = _FakeCustomersRepository(source);
    final useCase = WatchCustomers(repository);
    const query = CustomerQuery(
      searchText: 'محمد',
      filter: CustomerFilter.owes,
      sort: CustomerSort.byBalanceDesc,
    );

    final stream = useCase.call(query);

    expect(repository.watchCalls, 1);
    expect(repository.lastQuery, query);
    expect(stream, same(source));
    controller.close();
  });

  test('emissions pass through unchanged', () async {
    final controller = StreamController<List<CustomerWithBalance>>();
    final repository = _FakeCustomersRepository(controller.stream);
    final useCase = WatchCustomers(repository);
    const query = CustomerQuery(
      searchText: '',
      filter: CustomerFilter.all,
      sort: CustomerSort.byName,
    );

    final first = [entry('c-1', 0)];
    final second = [entry('c-1', 10000), entry('c-2', -5000)];

    final emissions = <List<CustomerWithBalance>>[];
    final subscription = useCase.call(query).listen(emissions.add);
    controller.add(first);
    await pumpEventQueue();
    controller.add(second);
    await pumpEventQueue();
    await subscription.cancel();
    await controller.close();

    // The same list instances arrive untouched: the use case adds nothing.
    expect(emissions, hasLength(2));
    expect(emissions[0], same(first));
    expect(emissions[1], same(second));
    expect(emissions[1][0], entry('c-1', 10000));
    expect(emissions[1][1], entry('c-2', -5000));
  });
}
