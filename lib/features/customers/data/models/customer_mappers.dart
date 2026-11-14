import '../../../../core/database/app_database.dart' as db;
import '../../../../core/money/money.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/customer_with_balance.dart';
import '../datasources/customers_dao.dart';

/// Mappers from Drift rows to the customers domain entities.
///
/// Drift row classes stay in the data layer (rule R4): the domain never sees
/// them, so the database import is prefixed as `db` to keep the Drift row
/// `db.Customer` distinct from the domain `Customer`.
extension CustomerRowMapper on db.Customer {
  /// Maps a database row to the domain entity.
  Customer toEntity() => Customer(
    id: id,
    name: name,
    phone: phone,
    note: note,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

/// Maps a customer row and its derived balance (rule R2) to the list entity.
CustomerWithBalance toCustomerWithBalance(CustomerWithBalanceRow data) {
  return CustomerWithBalance(
    customer: data.row.toEntity(),
    balance: Money.fromPiasters(data.balancePiasters),
  );
}
