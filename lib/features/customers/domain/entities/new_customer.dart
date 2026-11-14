import 'package:freezed_annotation/freezed_annotation.dart';

part 'new_customer.freezed.dart';

/// Write input for creating or updating a customer.
///
/// Carries no `id` or timestamps: the repository generates the UUID v4 `id`
/// and the `createdAt`/`updatedAt` timestamps (rule R3).
///
/// `toString` is disabled because the generated one would print the
/// customer's name and phone (rule R6).
@Freezed(toStringOverride: false)
abstract class NewCustomer with _$NewCustomer {
  const factory NewCustomer({
    required String name,
    String? phone,
    String? note,
  }) = _NewCustomer;
}
