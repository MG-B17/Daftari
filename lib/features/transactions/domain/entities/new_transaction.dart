import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/money/money.dart';
import 'transaction.dart';

part 'new_transaction.freezed.dart';

/// Write input for creating or updating a transaction.
///
/// Carries no `id` or timestamps: the repository generates the UUID v4 `id`
/// and the `createdAt`/`updatedAt` timestamps (rule R3).
///
/// `toString` is disabled because the generated one would print the amount
/// (rule R6).
@Freezed(toStringOverride: false)
abstract class NewTransaction with _$NewTransaction {
  const factory NewTransaction({
    required String customerId,
    required TransactionType type,
    required Money amount,
    required DateTime occurredAt,
    String? note,
  }) = _NewTransaction;
}
