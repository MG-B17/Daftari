# Daftari (دفتري) — Engineering Guide for AI Coding Agents

| | |
|---|---|
| **Audience** | AI coding agents (Claude, Cursor, Antigravity, OpenCode) and human contributors |
| **Version** | 1.0 (November 2026) |
| **Source of truth for product scope** | `plan.md` |
| **Precedence** | Section 2 (Non-negotiable rules) overrides everything else in this file |

## 1. Product context

Daftari is a shop credit ledger for small shop owners in Egypt. Customers owe the shop money (**عليه**) and pay it back (**سدّد**). The app is **Arabic-first (RTL), offline-first, and Android-first**.

**Product promise:** an entry can be added in under 10 seconds, and recorded data is never lost.

**Users:** shop owners and cashiers (aged 25 to 60) on mid-range and budget Android phones, working one-handed at a counter, often interrupted.

## 2. Non-negotiable rules

Violating any of these is a defect, regardless of the task.

| ID | Rule | Reason |
|---|---|---|
| R1 | Money is `int` piasters, wrapped in `Money`. Never use `double` for money. | Rounding errors corrupt balances. |
| R2 | A balance is derived from transactions. Never store or directly edit a balance. | A single source of truth keeps history auditable. |
| R3 | Soft delete only (`deleted_at`). Every row has `id` (UUID v4), `created_at`, `updated_at`, `deleted_at`, `sync_state`. Every local change updates `updated_at` and sets `sync_state = 'pending'`. | Keeps the app sync-ready without a later migration. |
| R4 | Dependency rule: `presentation → domain ← data`. `domain` is pure Dart. | Testability and replaceable infrastructure. |
| R5 | One-shot domain operations return `Either<Failure, T>`. Never throw across layers. | Predictable error handling. |
| R6 | Never log, report, or attach customer names, phone numbers, or amounts anywhere (console, Crashlytics, error messages). | Privacy of shop owners and their customers. |
| R7 | No hard-coded user-facing strings. Add keys to both ARB files. Use directional widgets. | Arabic-first and RTL correctness. |
| R8 | Stay within the current scope (Section 3). Do not add features that are not in `plan.md`. | Prevents scope creep. |
| R9 | Do not add or change packages without approval. State what the package is for and what it replaces. | Controls dependency risk. |
| R10 | Every change ships with tests. Domain logic is tested before UI is built. | Money logic must be verified. |
| R11 | Never edit generated files (`*.g.dart`, `*.freezed.dart`). Regenerate them. | Hand edits are lost and break builds. |
| R12 | Every schema change bumps `schemaVersion`, adds a migration step, and adds a migration test. | Existing users' data must survive updates. |

## 3. Scope and roadmap

**Strategy:** build **offline first**. Backup is the last stage of this version.

| Phase | Content | Status | Design screens |
|---|---|---|---|
| 0 | Foundation: structure, lints, theme, l10n, DI, router shell, Drift database | Done | — |
| 1 | Domain and data for customers and transactions, with tests | Current | — |
| 2 | Customers and transactions screens, keypad, quick amount chips, change-customer chooser | Planned | cutomers, empty_customers, add_new_customer, customer_details_and_history, add_transaction |
| 3 | Dashboard, settings, theme mode, language, shop name | Planned | dashboard, settings, dark_mode, choose_language |
| 4 | Security: PIN, biometrics, auto-lock | Planned | lock_screen |
| 5 | Statement and WhatsApp sharing | Planned | wattsapp_report |
| 6 | Offline polish: onboarding, splash, empty states, accessibility | Planned | splash, onboarding (+ choose_language, empty_customers) |
| 7 | Account and backup: Supabase, sign-in, sync, restore, account deletion | Last stage | login, create_account, backup |
| 8 | Release: flavors, release workflow, closed testing, Google Play | Planned | — |

Design screens live in `desgin/` (filenames as-is, including typos) and are the visual source of truth for each phase; each phase is Marionette-verified against them before its Status changes to Done.

**Until Phase 7:** do not add Supabase, Google sign-in, connectivity or sync code, or any backup UI (home banner, reassurance card, Settings backup rows, sign-in screens).

**Out of scope for v1:** voice search, reminders and push notifications, PDF statements, multiple shops, charts and reports, payments, iOS.

Update the Status column when a phase starts or finishes.

## 4. Technology stack

| Area | Choice |
|---|---|
| Platform | Flutter and Dart, Android only |
| State management | `flutter_bloc` (**Cubit**) |
| Architecture | Clean Architecture, feature-first |
| Dependency injection | `get_it` |
| Navigation | `go_router` |
| Local database | `drift` (SQLite) |
| Models and states | `freezed`, `json_serializable` |
| Error handling | `fpdart` (`Either<Failure, T>`) |
| Localization | gen-l10n (ARB) and `intl` |
| Security | `local_auth`, `flutter_secure_storage` |
| Settings | `shared_preferences` |
| Sharing | `url_launcher` (`wa.me`), `share_plus` |
| Contact import | System contact picker (no contacts permission) |
| Crash reporting | `firebase_crashlytics` |
| Testing | `flutter_test`, `bloc_test`, `mocktail`, `integration_test`, in-memory Drift |

Do not introduce Provider, Riverpod, GetX, Sqflite, Hive, or Isar.

## 5. Architecture

```
presentation  →  domain  ←  data
(Cubit, UI)      (entities, repository interfaces, use cases)   (repository impls, Drift DAOs, Supabase)
```

### Layer responsibilities
| Layer | Contains | Must not |
|---|---|---|
| `domain` | Entities, repository interfaces, use cases, `Failure`, `Money` rules | Import Flutter, Drift, Supabase, or other layers' code |
| `data` | Repository implementations, Drift DAOs, DTO and row mappers, remote datasources (Phase 7) | Contain UI or Cubit code |
| `presentation` | Cubits, states, pages, widgets | Import Drift or Supabase; contain business logic |

### Folder structure
```
lib/
  main.dart
  bootstrap.dart
  app/            # app.dart, router/, theme/
  core/           # di/, database/, error/, money/, utils/, widgets/
  features/<name>/
    data/         # datasources/, models/, repositories/
    domain/       # entities/, repositories/, usecases/
    presentation/ # cubit/, pages/, widgets/
  l10n/           # app_ar.arb, app_en.arb
test/             # mirrors lib/
integration_test/
```
Features: `onboarding`, `customers`, `transactions`, `dashboard`, `statement`, `backup`, `security`, `settings`.

### Naming conventions
| Item | Convention | Example |
|---|---|---|
| Files | `snake_case.dart` | `add_transaction_cubit.dart` |
| Classes | `UpperCamelCase` | `CustomerWithBalance` |
| Use cases | `VerbNoun`, one `call()` method | `AddCustomer`, `WatchTodayCollections` |
| Repository interfaces | `<Feature>Repository` | `CustomersRepository` |
| Repository implementations | `<Feature>RepositoryImpl` | `CustomersRepositoryImpl` |
| Cubits and states | `<Screen>Cubit`, `<Screen>State` | `DashboardCubit`, `DashboardState` |
| Tests | Mirror the source path with `_test.dart` | `test/features/customers/domain/usecases/add_customer_test.dart` |

## 6. Code patterns

### 6.1 Errors
```dart
sealed class Failure {
  const Failure();
}
final class DatabaseFailure extends Failure { const DatabaseFailure(); }
final class NetworkFailure extends Failure { const NetworkFailure(); }
final class AuthFailure extends Failure { const AuthFailure(); }
final class ValidationFailure extends Failure {
  const ValidationFailure(this.code);
  final String code; // a stable key, never user data
}
final class UnexpectedFailure extends Failure { const UnexpectedFailure(); }
```
- One-shot operations return `Future<Either<Failure, T>>`.
- Reactive reads (Drift `watch`) return a plain `Stream<T>`; the Cubit maps stream errors to a failure state.

### 6.2 Repository interface and use case
```dart
abstract interface class CustomersRepository {
  Future<Either<Failure, Customer>> addCustomer(NewCustomer input);
  Stream<List<CustomerWithBalance>> watchCustomers(CustomerQuery query);
}

class AddCustomer {
  const AddCustomer(this._repository);
  final CustomersRepository _repository;

  Future<Either<Failure, Customer>> call(NewCustomer input) {
    if (input.name.trim().isEmpty) {
      return Future.value(const Left(ValidationFailure('name_required')));
    }
    return _repository.addCustomer(input);
  }
}
```

### 6.3 Repository implementation
```dart
@override
Future<Either<Failure, Customer>> addCustomer(NewCustomer input) async {
  try {
    final row = await _local.insert(input); // sets id, timestamps, sync_state = pending
    return Right(row.toEntity());
  } on Object {
    return const Left(DatabaseFailure()); // do not attach the input or the exception message
  }
}
```

### 6.4 Cubit and targeted rebuilds
```dart
// Read one field: rebuilds only when that field changes
BlocSelector<DashboardCubit, DashboardState, Money>(
  selector: (state) => state.todayCollections,
  builder: (context, collections) => MoneyText(collections),
);

// Depend on part of the state: always add buildWhen
BlocBuilder<CustomersCubit, CustomersState>(
  buildWhen: (previous, current) => previous.customers != current.customers,
  builder: (context, state) => CustomersList(customers: state.customers),
);

// Side effects fire once per change: always add listenWhen
BlocListener<AddTransactionCubit, AddTransactionState>(
  listenWhen: (previous, current) => previous.status != current.status,
  listener: (context, state) { /* navigate or show a message */ },
  child: const AddTransactionView(),
);

// Dispatch events with read, never with a builder
context.read<AddTransactionCubit>().amountDigitPressed(5);
```

Rules:
- One Cubit per screen or flow. States have value equality (freezed or Equatable) and stay small and flat.
- Cubits subscribe to repository streams and cancel in `close()`.
- Split large screens into small widgets, each with its own selector. Use `const`, `ValueKey(id)` on list items, and `ListView.builder`.
- Drift streams re-emit on any write to a watched table: watch the smallest query needed and drop identical results before they reach the Cubit.

### 6.5 Money
```dart
final amount = Money.fromPiasters(125000);   // 1,250.00 EGP
final label = formatMoney(amount, locale);   // "1,250 ج.م"
```
All arithmetic is on integers. Parsing and formatting live in `core/money`. Never convert to `double`.

## 7. Data model rules

| Entity | Required columns |
|---|---|
| `customers` | `id`, `name`, `phone?`, `note?`, `created_at`, `updated_at`, `deleted_at?`, `sync_state` |
| `transactions` | `id`, `customer_id`, `type` (`credit` or `payment`), `amount_piasters` (> 0), `occurred_at`, `note?`, `created_at`, `updated_at`, `deleted_at?`, `sync_state` |

- `balance = sum(credit) − sum(payment)` over non-deleted transactions. A positive balance means the customer owes the shop.
- `occurred_at` may be a past date. History sorts by `occurred_at`, then `created_at`.
- An opening balance is an ordinary transaction (note "رصيد سابق").
- Deleting a customer hides its transactions.
- **Today's collections** = sum of non-deleted payments with `occurred_at` between local midnight and the next local midnight.

## 8. UI, design, and localization

- Follow the Figma design. Use the shared widgets in `core/widgets`: `DaftariAppBar`, `DaftariBottomNav`, `Keypad`, `BalanceText`, `CustomerTile`, `TransactionTile`, `EmptyState`, `QuickAmountChips`, `TipCard`. Do not create new app bar styles, colors, or fonts.
- The `desgin/` PNGs are the visual source of truth per phase (see Section 3); after each UI phase the implementation is verified against them with Marionette screenshots (see Sections 12 and 14).
- Default locale `ar` (RTL), also `en`. Use `EdgeInsetsDirectional` and `AlignmentDirectional`; never `left` or `right` for layout. Test every screen in both directions.
- Always pair color with a text label. Never use color alone.
- Minimum touch target 48 px. Support larger system font sizes.
- User-facing terms: **عليه** (credit), **سدّد** (payment), **خالص** (settled). Do not invent other terms.
- Money format: `1,250 ج.م` (Western digits, EGP suffix).

### Design tokens
| Token | Light | Dark |
|---|---|---|
| Background | `#FBF7F0` | `#14110F` |
| Surface | `#FFFFFF` | `#1E1A17` |
| Primary (teal) | `#0F766E` | `#2DD4BF` |
| Text | `#1F2937` | `#F5F1EA` |
| Secondary text | `#6B7280` | `#A8A29A` |
| Border | `#E7E0D3` | `#3A332D` |
| Owed (red) | `#B91C1C` | `#F87171` |
| Paid (green) | `#15803D` | `#4ADE80` |
| Accent (amber) | `#F59E0B` | `#F59E0B` |

Font: Cairo. Material 3. Custom colors (`owed`, `paid`, `warning`) are exposed through a `ThemeExtension`.

## 9. Security and privacy

- Rule R6 applies to logs, analytics, Crashlytics keys, and exception messages.
- **PIN:** store only a salted hash in `flutter_secure_storage`, never the PIN. Limit attempts with a growing delay. Biometrics are optional; the PIN is always the fallback.
- **Auto-lock** after the app has been in the background longer than the chosen time.
- **Contact import** uses the system contact picker only. Do not request the contacts permission.
- Never commit secrets, keystores, or service account files. The Supabase service role key must never be in the app or the repository.
- Crashlytics: collection disabled in debug; report non-fatal errors by type only.

## 10. Testing standards

| Level | Scope | Tools |
|---|---|---|
| Unit | Balance, running balance, `Money`, statement text, PIN hashing, use cases | `flutter_test`, `mocktail` |
| Data | Repositories on in-memory Drift, migrations | Drift in-memory |
| Cubit | Every state transition | `bloc_test` |
| Widget | Keypad, add-transaction flow, customer list, lock screen, RTL, rebuild counts on the dashboard, customer list, and keypad | `flutter_test` |
| Integration | Add customer, add credit, add payment, check balance and history, share statement | `integration_test` |

- Use arrange, act, assert. One behavior per test; name tests by behavior.
- Fix a bug by writing a failing test first.
- Use an injectable clock for anything time-dependent (today's collections, auto-lock).

## 11. Git and CI

- Main branch: `master`. Work on short-lived branches: `feat/<topic>`, `fix/<topic>`, `chore/<topic>`.
- Commit messages follow Conventional Commits, for example `feat(transactions): add quick amount chips`.
- Open a pull request into `master`. CI (`daftari_workflow.yml`) must pass: format check, analyzer with `--fatal-infos`, and tests.
- Commands:
  ```
  flutter pub get
  dart run build_runner build --delete-conflicting-outputs
  dart format .
  flutter analyze --fatal-infos
  flutter test
  ```

## 12. Agent workflow

**Before coding**
1. Read this file and the relevant part of `plan.md`. Read nearby code and match its style.
2. State a short plan: layer, files to change, tests to add.
3. If product or design intent is unclear, ask a question instead of guessing.

**While coding**
- Make small, focused changes. Do not refactor unrelated code.
- Handle empty, error, loading, and offline states on every screen.

**Before finishing**
1. Run format, analyze, and tests.
2. Self-review against the checklist in Section 14.
3. Report: what changed, files touched, tests added and their results, assumptions made, and open questions.
4. For phases with UI, run the design-match pass: connect Marionette to the debug app, capture each of the phase's design screens, and compare against the `desgin/` PNGs; fix mismatches before reporting done.

## 13. Anti-patterns

| Do not | Do instead |
|---|---|
| Store money as `double` | Use `Money` (`int` piasters) |
| Store or edit a balance field | Derive it from transactions |
| Hard delete rows | Set `deleted_at` and mark `sync_state = 'pending'` |
| Import Drift or Supabase in a Cubit or widget | Go through use cases and repositories |
| Throw exceptions from the domain layer | Return `Left(Failure)` |
| Wrap a whole screen in one `BlocBuilder` | Use `BlocSelector` and small widgets with `buildWhen` |
| Hard-code Arabic or English text | Add keys to both ARB files |
| Use `left` / `right` / `EdgeInsets.only(left:)` | Use directional equivalents |
| Log a customer name, phone, or amount | Log a failure type or an operation name |
| Add a feature that is not in `plan.md` | Ask first |
| Edit a generated file | Change the source and regenerate |
| Add Supabase or backup UI before Phase 7 | Keep the app fully offline until that phase |

## 14. Definition of done

- [ ] Rules R1 to R12 are respected.
- [ ] Domain, data, and Cubit tests pass; widget tests cover the key flows.
- [ ] Works in Arabic (RTL) and English, Light and Dark, and at larger font sizes.
- [ ] No analyzer warnings; no business logic in widgets; no unnecessary rebuilds.
- [ ] Empty, error, loading, and offline states are handled.
- [ ] No sensitive data in logs or reports.
- [ ] Checked on a low-end Android device.
- [ ] UI matches the phase's design screens (verified with Marionette screenshots).

## 15. Glossary

| Term | Meaning |
|---|---|
| عليه (credit) | The customer took goods on credit and owes the shop |
| سدّد (payment) | The customer paid back part or all of what they owe |
| خالص (settled) | The customer's balance is zero |
| Piaster | One hundredth of an Egyptian pound; the unit used to store money |
| `sync_state` | `pending` when a local change is not yet backed up, otherwise `synced` |
| Soft delete | Marking a row with `deleted_at` instead of removing it |
