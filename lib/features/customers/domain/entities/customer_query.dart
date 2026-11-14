import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer_query.freezed.dart';

/// Which customers the list shows, by their balance state.
enum CustomerFilter {
  /// Every non-deleted customer.
  all,

  /// Customers whose balance is greater than zero — they owe the shop (عليه).
  owes,

  /// Customers whose balance is zero or negative — settled (خالص) or paid
  /// ahead.
  settled,
}

/// How the customers list is ordered.
enum CustomerSort {
  /// Alphabetically by name.
  byName,

  /// By balance, highest (owes the most, عليه) first.
  byBalanceDesc,

  /// By the customer's latest transaction activity, newest first.
  byRecentActivity,
}

/// The search, filter, and sort applied to the customers list.
///
/// Value equality lets callers compare queries and skip redundant work.
///
/// `toString` is disabled because [searchText] is user-typed text that may
/// contain a customer's name or phone (rule R6).
@Freezed(toStringOverride: false)
abstract class CustomerQuery with _$CustomerQuery {
  const factory CustomerQuery({
    required String searchText,
    required CustomerFilter filter,
    required CustomerSort sort,
  }) = _CustomerQuery;
}
