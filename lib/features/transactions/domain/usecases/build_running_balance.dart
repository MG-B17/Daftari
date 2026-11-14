import '../../../../core/money/money.dart';
import '../entities/ledger_entry.dart';
import '../entities/transaction.dart';

/// Builds a customer's ledger: one [LedgerEntry] per transaction, each
/// carrying the balance right after that entry (rule R2 — the running
/// balance is derived here, never stored).
///
/// The entries are ordered by `occurred_at` ascending, then `created_at`
/// ascending — the same ledger order as the history contract (agent.md
/// Section 7; entries may be past-dated). The input list is copied before
/// sorting, so the caller's list is never mutated. The running balance
/// starts from zero and accumulates credits minus payments entry by entry.
class BuildRunningBalance {
  const BuildRunningBalance();

  List<LedgerEntry> call(List<Transaction> transactions) {
    final sorted = [...transactions]
      ..sort((a, b) {
        final byOccurred = a.occurredAt.compareTo(b.occurredAt);
        if (byOccurred != 0) {
          return byOccurred;
        }
        return a.createdAt.compareTo(b.createdAt);
      });

    var running = const Money.fromPiasters(0);
    final entries = <LedgerEntry>[];
    for (final transaction in sorted) {
      running = switch (transaction.type) {
        TransactionType.credit => running + transaction.amount,
        TransactionType.payment => running - transaction.amount,
      };
      entries.add(
        LedgerEntry(transaction: transaction, runningBalance: running),
      );
    }
    return entries;
  }
}
