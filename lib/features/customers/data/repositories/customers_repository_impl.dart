import 'package:drift/drift.dart' show Value;
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart' hide Customer;
import '../../../../core/error/failure.dart';
import '../../../../core/utils/clock.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/customer_query.dart';
import '../../domain/entities/customer_with_balance.dart';
import '../../domain/entities/new_customer.dart';
import '../../domain/repositories/customers_repository.dart';
import '../datasources/customers_dao.dart';
import '../models/customer_mappers.dart';

/// Drift-backed implementation of [CustomersRepository]
/// (agent.md Section 6.3).
///
/// The write rules live here (rule R3): UUID v4 ids, timestamps from the
/// injectable [Clock], and `sync_state = 'pending'` on every local change.
/// Failures never carry the input or any customer data (rule R6).
class CustomersRepositoryImpl implements CustomersRepository {
  CustomersRepositoryImpl({required AppDatabase database, required this._clock})
    : _dao = database.customersDao;

  static const Uuid _uuid = Uuid();

  static const String _pendingSyncState = 'pending';

  final CustomersDao _dao;
  final Clock _clock;

  @override
  Future<Either<Failure, Customer>> addCustomer(NewCustomer input) async {
    try {
      final now = _clock.now();
      final row = await _dao.addCustomer(
        CustomersCompanion.insert(
          id: _uuid.v4(),
          name: input.name,
          createdAt: now,
          updatedAt: now,
          phone: Value(input.phone),
          note: Value(input.note),
          syncState: const Value(_pendingSyncState),
        ),
      );
      return Right(row.toEntity());
    } on Object {
      return const Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, Customer>> updateCustomer(
    String id,
    NewCustomer input,
  ) async {
    try {
      final rows = await _dao.updateCustomer(
        id,
        CustomersCompanion(
          name: Value(input.name),
          phone: Value(input.phone),
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
  Future<Either<Failure, Unit>> deleteCustomer(String id) async {
    try {
      final now = _clock.now();
      final rows = await _dao.softDeleteCustomer(
        id,
        CustomersCompanion(
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
  Future<Either<Failure, Customer>> getCustomer(String id) async {
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
  Stream<List<CustomerWithBalance>> watchCustomers(CustomerQuery query) {
    return _dao
        .watchCustomersWithBalance(query)
        .map((rows) => rows.map(toCustomerWithBalance).toList())
        .distinct(_listsEqual);
  }

  @override
  Stream<CustomerWithBalance?> watchCustomerWithBalance(String id) {
    return _dao
        .watchCustomerWithBalanceRow(id)
        .map((data) => data == null ? null : toCustomerWithBalance(data))
        .distinct();
  }

  /// Element-wise equality for the watched lists (freezed `==` on the
  /// elements), so identical emissions are dropped before they reach the
  /// presentation layer (agent.md Section 6.4).
  static bool _listsEqual(
    List<CustomerWithBalance> previous,
    List<CustomerWithBalance> next,
  ) {
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
