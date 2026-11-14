import 'package:get_it/get_it.dart';

import '../database/app_database.dart';

/// Global service locator for the app.
final GetIt sl = GetIt.instance;

/// Registers app-wide dependencies.
///
/// Kept minimal in Phase 0: only the database singleton. Repositories and use
/// cases are registered in later phases.
void registerDependencies() {
  sl.registerLazySingleton<AppDatabase>(AppDatabase.new);
}
