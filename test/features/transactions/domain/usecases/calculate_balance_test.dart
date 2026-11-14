import 'package:flutter_test/flutter_test.dart';

import 'package:daftari/core/money/money.dart';
import 'package:daftari/features/transactions/domain/entities/transaction.dart';
import 'package:daftari/features/transactions/domain/usecases/calculate_balance.dart';

void main() {
  const calculateBalance = CalculateBalance();

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

  test('sums an empty list to zero', () {
    final balance = calculateBalance([]);

    expect(balance, const Money.fromPiasters(0));
  });

  test('sums credits only', () {
    final balance = calculateBalance([
      transaction(type: TransactionType.credit, amountPiasters: 10000),
      transaction(type: TransactionType.credit, amountPiasters: 25050),
    ]);

    expect(balance, const Money.fromPiasters(35050));
  });

  test('sums payments only to a negative balance', () {
    final balance = calculateBalance([
      transaction(type: TransactionType.payment, amountPiasters: 30000),
      transaction(type: TransactionType.payment, amountPiasters: 20000),
    ]);

    expect(balance, const Money.fromPiasters(-50000));
  });

  test('subtracts payments from credits for a mixed list', () {
    final balance = calculateBalance([
      transaction(type: TransactionType.credit, amountPiasters: 125000),
      transaction(type: TransactionType.payment, amountPiasters: 25000),
      transaction(type: TransactionType.credit, amountPiasters: 10000),
      transaction(type: TransactionType.payment, amountPiasters: 60000),
    ]);

    expect(balance, const Money.fromPiasters(50000));
  });

  test(
    'a customer who paid back more than they owe gets a negative balance',
    () {
      final balance = calculateBalance([
        transaction(type: TransactionType.credit, amountPiasters: 50000),
        transaction(type: TransactionType.payment, amountPiasters: 80000),
      ]);

      expect(balance, const Money.fromPiasters(-30000));
    },
  );

  test('a positive result means the customer owes the shop', () {
    final balance = calculateBalance([
      transaction(type: TransactionType.credit, amountPiasters: 80000),
      transaction(type: TransactionType.payment, amountPiasters: 30000),
    ]);

    expect(balance, const Money.fromPiasters(50000));
    expect(balance > const Money.fromPiasters(0), isTrue);
  });
}
