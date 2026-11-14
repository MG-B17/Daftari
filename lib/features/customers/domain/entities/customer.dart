import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer.freezed.dart';

/// A customer tracked by the shop (عميل).
///
/// Pure domain entity: carries no `syncState` or `deletedAt` — those are
/// data-layer concerns handled by the repositories and Phase 7 sync
/// (rule R4).
///
/// `toString` is disabled because the generated one would print the
/// customer's name and phone (rule R6).
@Freezed(toStringOverride: false)
abstract class Customer with _$Customer {
  const factory Customer({
    required String id,
    required String name,
    String? phone,
    String? note,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Customer;
}
