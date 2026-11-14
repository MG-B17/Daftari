import '../../../../core/money/money.dart';
import '../entities/transaction.dart';

/// Computes a customer's balance from their transactions (rule R2 —
/// balances are derived, never stored): the sum of credits minus payments.
///
/// Pure integer math through [Money]'s operators (rule R1). A positive
/// result means the customer owes the shop (عليه); a negative result means
/// they paid back more than they owed. An empty list sums to zero.
class CalculateBalance {
  const CalculateBalance();

  Money call(List<Transaction> transactions) {
    var balance = const Money.fromPiasters(0);
    for (final transaction in transactions) {
      balance = switch (transaction.type) {
        TransactionType.credit => balance + transaction.amount,
        TransactionType.payment => balance - transaction.amount,
      };
    }
    return balance;
  }
}
