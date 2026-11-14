import '../../../../core/database/app_database.dart' as db;
import '../../../../core/money/money.dart';
import '../../domain/entities/transaction.dart';

/// Mappers from Drift rows to the transactions domain entities.
///
/// Drift row classes stay in the data layer (rule R4): the domain never sees
/// them, so the database import is prefixed as `db` to keep the Drift row
/// `db.Transaction` distinct from the domain `Transaction`.
extension TransactionRowMapper on db.Transaction {
  /// Maps a database row to the domain entity.
  ///
  /// `type` is always `credit` or `payment` (the database check constraint
  /// enforces it), and `amount_piasters` is always greater than zero
  /// (rule R1).
  Transaction toEntity() {
    return Transaction(
      id: id,
      customerId: customerId,
      type: TransactionType.values.byName(type),
      amount: Money.fromPiasters(amountPiasters),
      occurredAt: occurredAt,
      note: note,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
