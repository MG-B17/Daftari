import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

import 'package:daftari/core/error/failure.dart';
import 'package:daftari/core/money/money.dart';
import 'package:daftari/features/transactions/domain/entities/new_transaction.dart';
import 'package:daftari/features/transactions/domain/entities/transaction.dart';
import 'package:daftari/features/transactions/domain/repositories/transactions_repository.dart';
import 'package:daftari/features/transactions/domain/usecases/watch_customer_history.dart';

/// A hand-rolled fake (no mocking package until Phase 2) that only serves
/// `watchCustomerHistory`; every other method is out of scope for this use
/// case.
class _FakeTransactionsRepository implements TransactionsRepository {
  _FakeTransactionsRepository(this.watchCustomerHistoryStream);

  final Stream<List<Transaction>> watchCustomerHistoryStream;

  String? lastCustomerId;
  int watchCalls = 0;

  @override
  Stream<List<Transaction>> watchCustomerHistory(String customerId) {
    watchCalls += 1;
    lastCustomerId = customerId;
    return watchCustomerHistoryStream;
  }

  @override
  Future<Either<Failure, Transaction>> addTransaction(NewTransaction input) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> deleteTransaction(String id) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Transaction>> getTransaction(String id) =>
      throw UnimplementedError();

  @override
  Stream<Money> watchCustomerBalance(String customerId) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Transaction>> updateTransaction(
    String id,
    NewTransaction input,
  ) => throw UnimplementedError();
}

void main() {
  var nextId = 0;

  Transaction transaction({
    required TransactionType type,
    required int amountPiasters,
  }) {
    nextId += 1;
    return Transaction(
      id: 't-$nextId',
      customerId: 'c-1',
      type: type,
      amount: Money.fromPiasters(amountPiasters),
      occurredAt: DateTime(2026, 1, 1),
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
  }

  test('forwards the customer id to the repository and returns its stream', () {
    final controller = StreamController<List<Transaction>>();
    final source = controller.stream;
    final repository = _FakeTransactionsRepository(source);
    final useCase = WatchCustomerHistory(repository);

    final stream = useCase.call('c-42');

    expect(repository.watchCalls, 1);
    expect(repository.lastCustomerId, 'c-42');
    expect(stream, same(source));
    controller.close();
  });

  test('emissions pass through unchanged', () async {
    final controller = StreamController<List<Transaction>>();
    final repository = _FakeTransactionsRepository(controller.stream);
    final useCase = WatchCustomerHistory(repository);

    final first = <Transaction>[];
    final second = [
      transaction(type: TransactionType.credit, amountPiasters: 10000),
      transaction(type: TransactionType.payment, amountPiasters: 4000),
    ];

    final emissions = <List<Transaction>>[];
    final subscription = useCase.call('c-1').listen(emissions.add);
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
    expect(emissions[1][0].amount, const Money.fromPiasters(10000));
    expect(emissions[1][1].amount, const Money.fromPiasters(4000));
  });
}
