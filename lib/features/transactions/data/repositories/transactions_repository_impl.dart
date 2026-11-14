import 'package:drift/drift.dart' show Value;
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart' hide Transaction;
import '../../../../core/error/failure.dart';
import '../../../../core/money/money.dart';
import '../../../../core/utils/clock.dart';
import '../../domain/entities/new_transaction.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transactions_repository.dart';
import '../datasources/transactions_dao.dart';
import '../models/transaction_mappers.dart';

/// Drift-backed implementation of [TransactionsRepository]
/// (agent.md Section 6.3).
///
/// The write rules live here (rule R3): UUID v4 ids, timestamps from the
/// injectable [Clock], and `sync_state = 'pending'` on every local change.
/// Failures never carry the input or any customer data (rule R6).
class TransactionsRepositoryImpl implements TransactionsRepository {
  TransactionsRepositoryImpl({
    required AppDatabase database,
    required this._clock,
  }) : _dao = database.transactionsDao;

  static const Uuid _uuid = Uuid();

  static const String _pendingSyncState = 'pending';

  final TransactionsDao _dao;
  final Clock _clock;

  @override
  Future<Either<Failure, Transaction>> addTransaction(
    NewTransaction input,
  ) async {
    try {
      final now = _clock.now();
      final row = await _dao.addTransaction(
        TransactionsCompanion.insert(
          id: _uuid.v4(),
          customerId: input.customerId,
          type: input.type.name,
          amountPiasters: input.amount.asPiasters,
          occurredAt: input.occurredAt,
          note: Value(input.note),
          createdAt: now,
          updatedAt: now,
          syncState: const Value(_pendingSyncState),
        ),
      );
      return Right(row.toEntity());
    } on Object {
      // Includes foreign key violations for a missing customer.
      return const Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, Transaction>> updateTransaction(
    String id,
    NewTransaction input,
  ) async {
    try {
      final rows = await _dao.updateTransaction(
        id,
        TransactionsCompanion(
          customerId: Value(input.customerId),
          type: Value(input.type.name),
          amountPiasters: Value(input.amount.asPiasters),
          occurredAt: Value(input.occurredAt),
          note: Value(input.note),
          updatedAt: Value(_clock.now()),
          syncState: const Value(_pendingSyncState),
        ),
      );
      if (rows.isEmpty) {
        return const Left(DatabaseFailure());
      }
      return Right(rows.single.toEntity());
    } on Object {
      return const Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTransaction(String id) async {
    try {
      final now = _clock.now();
      final rows = await _dao.softDeleteTransaction(
        id,
        TransactionsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          syncState: const Value(_pendingSyncState),
        ),
      );
      if (rows.isEmpty) {
        return const Left(DatabaseFailure());
      }
      return const Right(unit);
    } on Object {
      return const Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, Transaction>> getTransaction(String id) async {
    try {
      final row = await _dao.findNotDeletedById(id);
      if (row == null) {
        return const Left(DatabaseFailure());
      }
      return Right(row.toEntity());
    } on Object {
      return const Left(DatabaseFailure());
    }
  }

  @override
  Stream<List<Transaction>> watchCustomerHistory(String customerId) {
    return _dao
        .watchCustomerHistory(customerId)
        .map((rows) => rows.map((row) => row.toEntity()).toList())
        .distinct(_listsEqual);
  }

  @override
  Stream<Money> watchCustomerBalance(String customerId) {
    return _dao
        .watchCustomerBalancePiasters(customerId)
        .map(Money.fromPiasters)
        .distinct();
  }

  /// Element-wise equality for the watched lists (freezed `==` on the
  /// elements), so identical emissions are dropped before they reach the
  /// presentation layer (agent.md Section 6.4).
  static bool _listsEqual(List<Transaction> previous, List<Transaction> next) {
    if (previous.length != next.length) {
      return false;
    }
    for (var i = 0; i < previous.length; i++) {
      if (previous[i] != next[i]) {
        return false;
      }
    }
    return true;
  }
}
