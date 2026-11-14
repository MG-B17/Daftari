import 'package:flutter_test/flutter_test.dart';

import 'package:daftari/core/money/money.dart';
import 'package:daftari/features/transactions/domain/entities/transaction.dart';
import 'package:daftari/features/transactions/domain/usecases/build_running_balance.dart';

void main() {
  const buildRunningBalance = BuildRunningBalance();

  var nextId = 0;

  Transaction transaction({
    required TransactionType type,
    required int amountPiasters,
    DateTime? occurredAt,
    DateTime? createdAt,
  }) {
    nextId += 1;
    final id = 't-$nextId';
    return Transaction(
      id: id,
      customerId: 'c-1',
      type: type,
      amount: Money.fromPiasters(amountPiasters),
      occurredAt: occurredAt ?? DateTime(2026, 1, 1),
      createdAt: createdAt ?? DateTime(2026, 1, 1, 12),
      updatedAt: DateTime(2026, 1, 1, 12),
    );
  }

  test('orders past-dated entries correctly regardless of the input order', () {
    final jan5 = transaction(
      type: TransactionType.credit,
      amountPiasters: 100,
      occurredAt: DateTime(2026, 1, 5),
    );
    final jan1 = transaction(
      type: TransactionType.credit,
      amountPiasters: 200,
      occurredAt: DateTime(2026, 1, 1),
    );
    final jan3 = transaction(
      type: TransactionType.payment,
      amountPiasters: 50,
      occurredAt: DateTime(2026, 1, 3),
    );

    final entries = buildRunningBalance([jan5, jan1, jan3]);

    expect(entries.map((entry) => entry.transaction.id), [
      jan1.id,
      jan3.id,
      jan5.id,
    ]);
  });

  test('breaks an occurred_at tie by created_at', () {
    final later = transaction(
      type: TransactionType.credit,
      amountPiasters: 100,
      occurredAt: DateTime(2026, 1, 3),
      createdAt: DateTime(2026, 1, 3, 15),
    );
    final earlier = transaction(
      type: TransactionType.credit,
      amountPiasters: 200,
      occurredAt: DateTime(2026, 1, 3),
      createdAt: DateTime(2026, 1, 3, 9),
    );

    final entries = buildRunningBalance([later, earlier]);

    expect(entries.map((entry) => entry.transaction.id), [
      earlier.id,
      later.id,
    ]);
  });

  test('accumulates the running balance after every entry', () {
    final credit = transaction(
      type: TransactionType.credit,
      amountPiasters: 10000,
    );
    final payment = transaction(
      type: TransactionType.payment,
      amountPiasters: 3000,
    );
    final secondCredit = transaction(
      type: TransactionType.credit,
      amountPiasters: 5000,
    );

    final entries = buildRunningBalance([credit, payment, secondCredit]);

    expect(entries, hasLength(3));
    expect(entries[0].transaction.id, credit.id);
    expect(entries[0].runningBalance, const Money.fromPiasters(10000));
    expect(entries[1].transaction.id, payment.id);
    expect(entries[1].runningBalance, const Money.fromPiasters(7000));
    expect(entries[2].transaction.id, secondCredit.id);
    expect(entries[2].runningBalance, const Money.fromPiasters(12000));
  });

  test('starts the running balance from zero', () {
    final payment = transaction(
      type: TransactionType.payment,
      amountPiasters: 4000,
    );

    final entries = buildRunningBalance([payment]);

    expect(entries.single.runningBalance, const Money.fromPiasters(-4000));
  });

  test('does not mutate the input list', () {
    final later = transaction(
      type: TransactionType.credit,
      amountPiasters: 100,
      occurredAt: DateTime(2026, 1, 5),
    );
    final earlier = transaction(
      type: TransactionType.credit,
      amountPiasters: 200,
      occurredAt: DateTime(2026, 1, 1),
    );
    final input = [later, earlier];

    buildRunningBalance(input);

    expect(input.map((t) => t.id), [later.id, earlier.id]);
  });

  test('maps an empty list to an empty ledger', () {
    expect(buildRunningBalance([]), isEmpty);
  });
}
