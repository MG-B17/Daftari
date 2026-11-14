import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/money/money.dart';
import 'customer.dart';

part 'customer_with_balance.freezed.dart';

/// A customer together with their balance, as shown in the customers list.
///
/// The balance is always derived from transactions (rule R2 — never stored).
/// A positive [balance] means the customer owes the shop (عليه); zero or
/// negative means settled (خالص) or paid ahead.
///
/// `toString` is disabled because the generated one would print the
/// customer's name and phone (rule R6).
@Freezed(toStringOverride: false)
abstract class CustomerWithBalance with _$CustomerWithBalance {
  const factory CustomerWithBalance({
    required Customer customer,
    required Money balance,
  }) = _CustomerWithBalance;
}
