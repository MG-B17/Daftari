import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/customer.dart';
import '../entities/customer_query.dart';
import '../entities/customer_with_balance.dart';
import '../entities/new_customer.dart';

/// Contract for customer data operations (agent.md Section 6.2).
///
/// One-shot operations return `Either<Failure, T>` and never throw across
/// layers (rule R5). Watches return plain streams; the Cubit maps stream
/// errors to a failure state (agent.md Section 6.1).
abstract interface class CustomersRepository {
  /// Creates a customer, generating its UUID v4 `id` and timestamps
  /// (rule R3).
  Future<Either<Failure, Customer>> addCustomer(NewCustomer input);

  /// Updates a customer's editable fields and bumps `updated_at`
  /// (rule R3).
  Future<Either<Failure, Customer>> updateCustomer(
    String id,
    NewCustomer input,
  );

  /// Soft-deletes a customer (rule R3): the customer disappears from the
  /// list and its transactions are excluded from list and balance queries.
  Future<Either<Failure, Unit>> deleteCustomer(String id);

  /// Returns a single customer, or a failure if it does not exist.
  Future<Either<Failure, Customer>> getCustomer(String id);

  /// Watches the non-deleted customers with their derived balances
  /// (rule R2), applying the query's search (name contains,
  /// case-insensitive), filter, and sort. Emits again on every relevant
  /// data change.
  Stream<List<CustomerWithBalance>> watchCustomers(CustomerQuery query);

  /// Watches one customer with their derived balance, or `null` when the
  /// customer does not exist or is soft-deleted.
  Stream<CustomerWithBalance?> watchCustomerWithBalance(String id);
}
