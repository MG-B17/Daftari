import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/money/money.dart';
import 'transaction.dart';

part 'ledger_entry.freezed.dart';

/// A history row: a transaction together with the customer's balance right
/// after it (plan.md Section 4 — the running balance is computed in the
/// domain layer, never stored).
///
/// `toString` is disabled because the generated one would print the amounts
/// (rule R6).
@Freezed(toStringOverride: false)
abstract class LedgerEntry with _$LedgerEntry {
  const factory LedgerEntry({
    required Transaction transaction,
    required Money runningBalance,
  }) = _LedgerEntry;
}
