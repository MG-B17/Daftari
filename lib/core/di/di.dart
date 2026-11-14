import 'package:get_it/get_it.dart';

import '../../features/customers/data/repositories/customers_repository_impl.dart';
import '../../features/customers/domain/repositories/customers_repository.dart';
import '../../features/customers/domain/usecases/watch_customers.dart';
import '../../features/transactions/data/repositories/transactions_repository_impl.dart';
import '../../features/transactions/domain/repositories/transactions_repository.dart';
import '../../features/transactions/domain/usecases/build_running_balance.dart';
import '../../features/transactions/domain/usecases/calculate_balance.dart';
import '../../features/transactions/domain/usecases/watch_customer_history.dart';
import '../database/app_database.dart';
import '../utils/clock.dart';

/// Global service locator for the app.
final GetIt sl = GetIt.instance;

/// Registers app-wide dependencies.
///
/// Phase 1 (complete): the database, the injectable clock, the customers and
/// transactions repositories, and the four use cases built on them. The
/// presentation layer (Cubits, UI) consumes the use cases from Phase 2.
void registerDependencies() {
  sl.registerLazySingleton<AppDatabase>(AppDatabase.new);
  sl.registerLazySingleton<Clock>(() => const SystemClock());
  sl.registerLazySingleton<CustomersRepository>(
    () => CustomersRepositoryImpl(
      database: sl<AppDatabase>(),
      clock: sl<Clock>(),
    ),
  );
  sl.registerLazySingleton<TransactionsRepository>(
    () => TransactionsRepositoryImpl(
      database: sl<AppDatabase>(),
      clock: sl<Clock>(),
    ),
  );
  sl.registerFactory<WatchCustomers>(
    () => WatchCustomers(sl<CustomersRepository>()),
  );
  sl.registerFactory<WatchCustomerHistory>(
    () => WatchCustomerHistory(sl<TransactionsRepository>()),
  );
  sl.registerFactory<CalculateBalance>(() => const CalculateBalance());
  sl.registerFactory<BuildRunningBalance>(() => const BuildRunningBalance());
}
