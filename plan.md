# Daftari (دفتري) — Project Plan

Shop credit ledger for small shop owners in Egypt. Arabic first (RTL), offline first, Android first.

> Status: planning.

---

## 1. Overview

**Problem.** Small shops (groceries, pharmacies, kiosks) track customers' unpaid credit in paper notebooks. Entries get lost, balances are disputed, and a lost notebook means lost money.

**Users.** Shop owners and cashiers, 25–60, Arabic speakers, mid/low-end Android phones, using the app one-handed at a counter with customers waiting.

**Core promise.** Add an entry in under 10 seconds. Never lose the data.

### Version 1 goals
- Customers: add, edit, delete, search, filter, sort
- Transactions: "credit" (عليه) and "payment" (سدّد), with past-dated entries and full history per customer
- Balance calculated from transactions, never typed in
- Dashboard: total owed, customers with a balance, top debtors, recent activity
- Share a customer statement by WhatsApp
- Optional account (Google or email) for backup and restore
- PIN lock with optional biometrics
- Arabic and English (full RTL), Light and Dark mode
- Crash reporting
- Dashboard extras: today's collections, a "your book is safe" reassurance card, and short tips
- Add-transaction speed-ups: quick amount chips (+50, +100, +200, +500) and a change-customer chooser
- Import a customer's name and phone from the Android contact picker

### Non-goals for version 1
Payments processing, invoicing, multiple shops, multi-device live sync, reminders and push notifications, PDF statements, reports and charts, iOS release.

### Principles
1. **Speed over decoration.** Main actions are one tap away; amount entry uses a big keypad.
2. **Money is integers.** Store amounts in piasters (`int`), never `double`.
3. **Balance is derived.** `balance = sum(credit) − sum(payment)` over non-deleted transactions.
4. **Offline first.** The app is fully usable without an account or internet. Backup is optional.
5. **No sensitive data in logs.** Never log names, phone numbers, or amounts.
6. **Arabic first.** Design and test in RTL first, then English.

---

## 2. Tech stack

| Area | Choice | Notes |
|---|---|---|
| Language / framework | Dart, Flutter | Android only for v1 |
| State management | `flutter_bloc` (Cubit) | One Cubit per screen or flow |
| Architecture | Clean Architecture, feature-first | `core/` + `features/<name>/{data,domain,presentation}` |
| Error handling | `fpdart` (`Either<Failure, T>`) | Domain layer never throws |
| Dependency injection | `get_it` | Registered in `core/di` |
| Navigation | `go_router` | Redirect guard for onboarding and PIN lock |
| Local database | `drift` + `drift_flutter` (SQLite) | Migrations, streams, in-memory tests |
| Models / immutability | `freezed`, `json_serializable` | For entities, states, and DTOs |
| Backend | `supabase_flutter` | Auth (Google + email), Postgres, RLS |
| Google sign-in | `google_sign_in` → Supabase `signInWithIdToken` | Needs OAuth client IDs and SHA-1 per build |
| Secure storage | `flutter_secure_storage` | PIN hash, auth session |
| Biometrics | `local_auth` | Optional, after PIN is set |
| Preferences | `shared_preferences` | Language, theme, onboarding flag, sync cursor |
| Localization | `flutter_localizations`, `intl`, gen-l10n (ARB) | `ar` default, `en` |
| Sharing | `url_launcher` (`wa.me`), `share_plus` | share_plus is the fallback |
| Contact import | A package that opens the system contact picker, for example `flutter_contacts` (`openExternalPick`) | Verify the final choice needs no `READ_CONTACTS` permission before adopting it |
| IDs | `uuid` | Client-generated UUID v4 for all rows |
| Connectivity | `connectivity_plus` | Trigger sync when back online |
| Crash reporting | `firebase_core`, `firebase_crashlytics` | Firebase used only for this |
| Splash / icons | `flutter_native_splash`, `flutter_launcher_icons` | |
| Testing | `flutter_test`, `bloc_test`, `mocktail`, `integration_test`, Drift in-memory DB | |
| Code generation | `build_runner`, `drift_dev`, `freezed`, `json_serializable` | |
| Lints | `very_good_analysis` (or `flutter_lints`) | Pick one and enforce in CI |

Package versions are not pinned in this plan. Use the latest compatible versions when adding them and commit `pubspec.lock`.

---

## 3. Architecture

### Layers and dependency rule
```
presentation  →  domain  ←  data
(Cubit, UI)      (entities,    (repositories impl,
                  use cases,    Drift DAOs,
                  repo interfaces) Supabase datasources)
```
- `domain` depends on nothing in Flutter, Drift, or Supabase.
- `presentation` talks to `domain` only (use cases and entities).
- `data` implements the domain repository interfaces and maps DTOs/rows to entities.

### Folder structure
```
lib/
  main.dart                  # entry, calls bootstrap()
  bootstrap.dart             # init Firebase, Supabase, DI, error hooks
  app/
    app.dart                 # MaterialApp.router, theme, locale
    router/                  # go_router config, route names, guards
    theme/                   # color tokens, ThemeExtension (owed/paid), text styles
  core/
    di/                      # get_it registration
    database/                # AppDatabase (Drift), tables, migrations
    error/                   # Failure types, error mapping
    money/                   # Money value type, formatters
    utils/                   # date helpers, debouncer
    widgets/                 # DaftariAppBar, Keypad, BalanceText, EmptyState
  features/
    onboarding/              # splash, language, intro
    customers/
    transactions/
    dashboard/
    statement/
    backup/                  # auth + sync
    security/                # PIN, biometrics, auto-lock
    settings/
  l10n/                      # app_ar.arb, app_en.arb
test/                        # mirrors lib/
integration_test/
```

Each feature:
```
features/<name>/
  data/
    datasources/     # local (Drift DAO) and remote (Supabase)
    models/          # DTOs / mappers
    repositories/    # implementations
  domain/
    entities/
    repositories/    # abstract interfaces
    usecases/
  presentation/
    cubit/
    pages/
    widgets/
```

### Error handling
- `sealed class Failure`: `DatabaseFailure`, `NetworkFailure`, `AuthFailure`, `ValidationFailure`, `UnexpectedFailure`.
- One-shot operations return `Future<Either<Failure, T>>`.
- Reactive reads (Drift `watch`) return `Stream<T>`; the Cubit maps stream errors to a failure state.
- Repositories catch exceptions and convert them to failures. Cubits never see raw exceptions.

### State management rules
- Cubit states are `freezed` unions or a single state class with a `status` enum. Pick one style and keep it.
- **No unnecessary rebuilds.** Rebuild a widget only when the part of the state it shows changes: use `BlocBuilder` with `buildWhen`, or `BlocSelector` (or `context.select`) to read one field. Split each screen into small widgets that read only what they need. Use `BlocListener` with `listenWhen` for one-off effects (navigation, snackbars) instead of rebuilding. States use value equality (`freezed` or `Equatable`) so identical states are not emitted. Use `const` widgets and `ValueKey(id)` in lists. Never `context.watch` a whole Cubit at the top of a page.
- **No unnecessary rebuilds.** Rebuild only the widget that depends on the data that changed:
  - Use `BlocSelector` (or `context.select`) to read a single field, for example the amount on the keypad screen or the total on the dashboard. Avoid one big `BlocBuilder` at the top of a screen.
  - Add `buildWhen` to every `BlocBuilder` whose widget depends on only part of the state, comparing just the relevant fields. Add `listenWhen` to every `BlocListener` (navigation, snackbars) so side effects fire once per change.
  - Use `context.read` to call Cubit methods; never use a builder just to dispatch an event.
  - States have value equality (freezed or Equatable) so identical states do not cause rebuilds. Keep states small and flat.
  - Split large screens into small widgets, each with its own selector. Use `const` constructors, `ValueKey(id)` on list items, and `ListView.builder` for long lists.
  - Drift streams re-emit whenever a watched table changes. Watch the smallest query needed and drop repeated identical results (for example `.distinct()` with list equality) before they reach the Cubit.
  - Check hot screens (dashboard, customers list, add-transaction keypad) with Flutter DevTools rebuild tracking.
- Cubits subscribe to repository streams and cancel in `close()`.
- No business logic in widgets. No Drift or Supabase imports in `presentation`.
- Lists are driven by streams so the UI updates when data changes.

---

## 4. Data model

### Local database (Drift)

**customers**
| Column | Type | Notes |
|---|---|---|
| id | text (uuid) | primary key |
| name | text | required |
| phone | text? | used for the WhatsApp link |
| note | text? | |
| created_at | datetime | |
| updated_at | datetime | set on every local change |
| deleted_at | datetime? | soft delete |
| sync_state | text | `synced` or `pending` |

**transactions**
| Column | Type | Notes |
|---|---|---|
| id | text (uuid) | primary key |
| customer_id | text | references customers.id |
| type | text | `credit` or `payment` |
| amount_piasters | int | always > 0 |
| occurred_at | datetime | can be a past date; history sorts by this |
| note | text? | |
| created_at, updated_at, deleted_at, sync_state | | same as customers |

Opening balance for a customer is just a regular transaction (note "رصيد سابق") dated at creation or earlier.

Indexes: `transactions(customer_id, occurred_at)`, `transactions(sync_state)`, `customers(sync_state)`, `customers(name)`.

**Derived queries**
- Customer balance: `SUM(CASE type WHEN 'credit' THEN amount ELSE -amount END)` where `deleted_at IS NULL`.
- Dashboard total owed: the same sum across all customers (only positive per-customer balances count as "owed to the shop").
- Top debtors: group by customer, order by balance descending, limit 3.
- Running balance in history: computed in the domain layer from the sorted list.

**Migrations.** Every schema change bumps `schemaVersion` and adds a migration step with a test. Never change a released schema without one.

### Remote database (Supabase / Postgres)
```sql
create table public.customers (
  id uuid primary key,
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  name text not null,
  phone text,
  note text,
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz,
  server_updated_at timestamptz not null default now()
);

create table public.transactions (
  id uuid primary key,
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  customer_id uuid not null references public.customers(id) on delete cascade,
  type text not null check (type in ('credit', 'payment')),
  amount_piasters bigint not null check (amount_piasters > 0),
  occurred_at timestamptz not null,
  note text,
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz,
  server_updated_at timestamptz not null default now()
);

create index on public.customers (user_id, server_updated_at);
create index on public.transactions (user_id, server_updated_at);
create index on public.transactions (customer_id);

-- keep server_updated_at authoritative
create function public.touch_server_updated_at() returns trigger
language plpgsql as $$
begin
  new.server_updated_at = now();
  return new;
end $$;

create trigger customers_touch before insert or update on public.customers
  for each row execute function public.touch_server_updated_at();
create trigger transactions_touch before insert or update on public.transactions
  for each row execute function public.touch_server_updated_at();

-- Row Level Security: each user sees only their own rows
alter table public.customers enable row level security;
alter table public.transactions enable row level security;

create policy "own customers" on public.customers
  for all to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "own transactions" on public.transactions
  for all to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);
```

### Sync design (local first, last write wins)
- Every row has a client-generated UUID, so rows can be created offline without conflicts.
- Local writes set `updated_at = now()` and `sync_state = 'pending'`.
- **Push:** upload pending customers first, then pending transactions (upsert by `id`). On success mark `synced`.
- **Pull:** fetch rows with `server_updated_at > last_pull_cursor` in pages, ordered by `server_updated_at`. For each remote row: if it does not exist locally or `remote.updated_at > local.updated_at`, overwrite local; otherwise keep local (it will push). Save the new cursor.
- Deletes are soft (`deleted_at`) and sync like any other change. Purging old soft-deleted rows is out of scope for v1.
- **Triggers:** manual "Back up now", right after login, when connectivity returns, and on app resume (debounced).
- **Restore on a new phone:** log in, then pull with an empty cursor.
- **First login on a phone that already has data:** push local rows and pull remote rows; rows merge by UUID.
- Use the server's `server_updated_at` for the pull cursor so a wrong phone clock cannot hide rows.
- Known limit: last-write-wins by client `updated_at` can lose a change if two devices edit the same row. Acceptable for v1 (single-device use).

### Account deletion
- In-app "Delete account" (confirmation, then a Supabase Edge Function using the service role to delete the auth user; table rows are removed by `on delete cascade`).
- A public web page explaining how to request deletion (required by Google Play for apps with account creation; confirm current policy before submission).

---

## 5. Features

Each feature lists scope, screens (from the Figma design), Cubits, use cases, and key tests.

### 5.1 core (shared)
- Theme: Material 3 `ThemeData` built from the design tokens (cream background, teal primary, owed red, paid green, amber accent); a `ThemeExtension` for `owed`, `paid`, and `warning` colors; Light and Dark.
- Font: Cairo.
- Shared widgets: `DaftariAppBar` (the only app bar used on inner screens), `DaftariBottomNav`, `Keypad`, `BalanceText` (color + label, never color alone), `CustomerTile`, `TransactionTile`, `EmptyState`, `QuickAmountChips`, `TipCard`.
- `Money` value type: wraps `int piasters`, parses and formats via `intl`, supports Arabic and English digits per locale setting.
- DI, router, database, error types.

### 5.2 onboarding
- Screens: Splash, Language choice, Intro (3 pages).
- State: `OnboardingCubit` (current page, completed flag in `shared_preferences`).
- Native splash via `flutter_native_splash`; keep it short.
- Test: router redirect shows onboarding only on first launch.

### 5.3 customers
- Screens: Customers list (search, filter chips, sort, FAB, empty state), Add/Edit customer.
- Entities: `Customer`, `CustomerWithBalance`.
- Use cases: `WatchCustomers(query, filter, sort)`, `GetCustomer`, `AddCustomer`, `UpdateCustomer`, `DeleteCustomer` (soft).
- Cubits: `CustomersCubit` (list, search, filter, sort), `CustomerFormCubit`.
- Validation: name required; phone optional but normalized (Egyptian format) when present.
- **Import from contacts:** a "سحب اسم من جهات الاتصال" button on Add customer opens the system contact picker; the chosen name and phone fill the form (phone normalized), and the user can edit them before saving. No contacts permission is requested and nothing else from the contact is read or stored.
- **Tip card:** a dismissible static tip on the customers list (empty state and list). Tips come from the ARB files, with no network; the dismissed state is kept in `shared_preferences`.
- Tests: search and filter logic, soft delete hides the customer and its transactions, imported contact phone normalization.

### 5.4 transactions
- Screens: Customer details with history, Add transaction (keypad), Edit transaction.
- Entities: `Transaction`, `TransactionType`, `LedgerEntry` (transaction + running balance).
- Use cases: `WatchCustomerHistory`, `AddTransaction`, `UpdateTransaction`, `DeleteTransaction` (soft, with undo), `CalculateBalance`, `BuildRunningBalance`.
- Cubits: `CustomerDetailsCubit`, `AddTransactionCubit` (type, amount from keypad, date, note).
- **Change customer:** the add-transaction screen shows the selected customer with a "تغيير" action that opens a searchable bottom sheet of customers. When the screen is opened from Home's "تسجيل حركة" there is no customer yet, so the sheet opens first; opened from a customer's details it is preselected. `AddTransactionCubit` holds a nullable `selectedCustomer`, and saving is disabled until one is chosen.
- **Quick amount chips:** +50, +100, +200, +500 add to the current amount (they do not replace it) so tapping +100 twice gives 200. The chips work in piasters through `Money`, use localized digits, and give light haptic feedback. Chip values may become configurable later.
- Rules: amount > 0; date may be in the past; history sorted by `occurred_at` then `created_at`.
- Tests (priority): balance math, running balance, past-dated ordering, edit/delete effects, keypad-to-`Money` conversion.

### 5.5 dashboard
- Screen: Home (summary card with today's collections, quick actions, top debtors, recent activity, backup banner or reassurance card, tip card).
- Use cases: `WatchDashboardSummary`, `WatchTopDebtors`, `WatchRecentTransactions`, `WatchTodayCollections`.
- Cubit: `DashboardCubit`.
- **Today's collections ("تحصيلات اليوم"):** the sum of non-deleted `payment` transactions whose `occurred_at` falls between local midnight and the next local midnight. It is based on the entry's date, so a payment entered today with a past date is not counted. Computed in a query stream so it updates live.
- **Backup banner vs reassurance card:** one slot with two states, built in the backup stage (Phase 7); until then show neither. If the user is not backed up, show the "بياناتك غير محفوظة" banner with the create-account action. If backup is on and recent, show the "دفترك مظبوط ومحمي" card as a static reassurance (and mention the PIN lock only when it is enabled). The card is informational, with no actions.
- **Tip card:** a dismissible static tip from the ARB files (no network), rotating by day; dismissed state kept in `shared_preferences`.
- Tests: totals match the sum of customer balances; today's collections around midnight and with past-dated payments; banner/card shown for each backup state.

### 5.6 statement
- Screen: Statement preview and share.
- Use cases: `BuildStatementText(customer, lastN)`, `ShareStatement`.
- Statement text (Arabic or English by app language): shop name, customer name, current balance with label, last 5 entries (date, type, amount).
- Share: open `https://wa.me/<phone>?text=<encoded>`; fall back to `share_plus` when there is no phone or WhatsApp is not installed.
- Requires a **shop name** setting (added to Settings; optional, prompted when first sharing).
- Tests: statement text formatting (Arabic and English), phone normalization for `wa.me`.

### 5.7 backup (auth + sync): built last (Phase 7)
- Everything before this stage works with no account and no internet. The account and backup UI (home banner, reassurance card, Settings account and backup rows, sign-in screens) is not built or shown until this stage.
- Screens: Sign in / Sign up, Backup and restore, plus the home banner and Settings rows.
- Domain: `AuthRepository` (Google, email/password, sign out, delete account), `SyncRepository`.
- Use cases: `SignInWithGoogle`, `SignInWithEmail`, `SignUpWithEmail`, `SignOut`, `DeleteAccount`, `SyncNow`, `RestoreFromCloud`, `WatchSyncStatus`.
- Cubits: `AuthCubit`, `BackupCubit` (last backup time, pending count, syncing, error).
- Session stored with a custom secure `LocalStorage` for `supabase_flutter` (backed by `flutter_secure_storage`).
- Tests: sync push/pull logic with fake remote and in-memory Drift (conflict, delete, resume after failure); never crash on network errors.

### 5.8 security
- Screens: PIN setup, PIN lock, change/disable PIN (inside Settings).
- PIN: 4 digits (configurable later). Store only a salted hash (random salt + HMAC-SHA256 via the `crypto` package) in secure storage; add attempt limiting with a growing delay.
- Biometrics: `local_auth`, offered after the PIN exists; the PIN is always the fallback.
- Auto-lock: `WidgetsBindingObserver`; lock after the app has been in the background longer than the chosen time (default 1 minute).
- Router guard: if lock is enabled and the app is locked, redirect to the lock screen.
- Tests: hash verification, attempt limiting, auto-lock timing logic (injectable clock).

### 5.9 settings
- Screen: Settings (account and backup, security, appearance, language, currency, shop name, privacy policy, about, delete account).
- Cubits: `SettingsCubit` (theme mode, locale, currency display, shop name).
- Persisted in `shared_preferences`.
- Tests: theme and locale changes propagate to `MaterialApp`.

---

## 6. Navigation

```
/splash
/onboarding/language
/onboarding/intro
/lock                       (PIN / biometrics)
/home                       (shell: bottom nav)
  /home/dashboard
  /home/customers
  /home/settings
/customers/new
/customers/:id
/customers/:id/edit
/customers/:id/transaction/new?type=credit|payment
/transactions/new?type=credit|payment      (from Home; choose a customer first)
/transactions/:id/edit
/customers/:id/statement
/backup
/backup/auth
/settings/pin
```
- Shell route with 3 tabs (Dashboard, Customers, Settings) using `StatefulShellRoute`.
- Redirect order: onboarding not done → onboarding; lock enabled and locked → `/lock`; otherwise continue.

---

## 7. Localization and RTL
- Default locale `ar`; also `en`. All strings in ARB files, no hard-coded text.
- Use `EdgeInsetsDirectional`, `AlignmentDirectional`, and `Directionality`-aware icons; never `left` / `right`.
- Numbers and dates formatted with `intl` for the active locale; money shown as `1,250 ج.م` (Western digits, EGP suffix) in both languages unless the digit setting changes.
- Support larger system font sizes; test the main flows at 1.3× text scale.
- Test every screen in both Arabic (RTL) and English (LTR).

---

## 8. Monitoring
- Crashlytics: `FlutterError.onError` and `PlatformDispatcher.instance.onError` forward to Crashlytics; collection disabled in debug.
- Non-fatal errors (`recordError`) for: failed backup, failed restore, migration errors, unexpected sync conflicts.
- Never include customer names, phone numbers, or amounts in logs, keys, or custom data.
- Separate Firebase apps for `dev` and `prod`.
- Watch Play Console vitals (crash rate, ANR) after release.
- Declare Crashlytics data collection in the Play Data safety form.

---

## 9. Testing strategy

| Level | What | Tools |
|---|---|---|
| Unit (domain) | Balance, running balance, Money, statement text, PIN hashing, use cases | `flutter_test`, `mocktail` |
| Data | Repositories against Drift in-memory DB, migrations, sync with fake remote | `drift` in-memory, `mocktail` |
| Cubit | State transitions for every Cubit | `bloc_test` |
| Widget | Keypad, add-transaction flow, customer list (search/filter), lock screen, RTL layout, rebuild counts on the dashboard, customer list, and keypad | `flutter_test` |
| Integration | Happy path: add customer → add credit → add payment → balance and history → share statement | `integration_test` |

Rules: domain logic must be covered before the UI is built. New bug → add a failing test first. CI runs `flutter analyze` and all tests on every push.

---

## 10. Environments and configuration
- Flavors (planned for the release stage; until then a single default build): `dev` and `prod` Android product flavors, with `applicationIdSuffix ".dev"` for dev.
- Application ID: decide once (for example `com.<yourname>.daftari`); it cannot change after publishing.
- Config (introduced together with flavors) via `--dart-define-from-file=config/dev.json` and `config/prod.json` (Supabase URL and anon key, flags). Never commit secrets; the Supabase anon key is public by design, but the service role key must never be in the app or the repo.
- Separate Supabase projects (or at least separate schemas) for dev and prod.
- Google sign-in: register OAuth clients with the SHA-1 of each signing key (debug, upload key, and Play app-signing key).

---

## 11. Release and CI/CD

Branch: `master`. Three stages: every change is checked, every merge to `master` is sent to testers, and every version tag goes to Google Play.

### Current pipeline (in use)

Branch: `master`. One workflow (`.github/workflows/daftari_workflow.yml`) and one Fastlane lane (`firebase`).

| Trigger | What it does |
|---|---|
| Pull request to `master` | pub get, format check, analyze, tests |
| Push to `master` | The same checks, then builds a release APK and distributes it to Firebase App Distribution through Fastlane |

Secrets: `FIREBASE_APP_ID`, `FIREBASE_CLI_TOKEN`.

Recommended: branch protection on `master` that requires the `quality` job to pass.

#### `.github/workflows/daftari_workflow.yml`
```yaml
name: Flutter CI/CD

on:
  push:
    branches:
      - master

  pull_request:
    branches:
      - master

permissions:
  contents: read

concurrency:
  group: flutter-ci-${{ github.ref }}
  cancel-in-progress: true

jobs:
  quality:
    name: Flutter Quality Checks
    runs-on: ubuntu-latest

    steps:
      # 1. Get repository source code
      - name: Checkout repository
        uses: actions/checkout@v4

      # 2. Setup Java for Android builds
      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '21'

      # 3. Install Flutter SDK
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: stable
          flutter-version: '3.47.8'
          cache: true

      # 4. Setup Ruby and Fastlane dependencies
      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.3'
          bundler-cache: true

      # 5. Install Flutter dependencies
      - name: Install dependencies
        run: flutter pub get

      # 6. Check Dart formatting
      - name: Check formatting
        run: dart format --output=none --set-exit-if-changed .

      # 7. Run static analysis
      - name: Flutter analyze
        run: flutter analyze --fatal-infos

      # 8. Run automated tests
      - name: Flutter tests
        run: flutter test --coverage

      # 9. Build APK and distribute to Firebase
      - name: Deploy to Firebase App Distribution
        if: github.event_name == 'push' && github.ref == 'refs/heads/master'
        env:
          FIREBASE_APP_ID: ${{ secrets.FIREBASE_APP_ID }}
          FIREBASE_CLI_TOKEN: ${{ secrets.FIREBASE_CLI_TOKEN }}
        run: bundle exec fastlane android firebase --fastfile android/fastlane/Fastfile
```

#### `android/fastlane/Fastfile`
```ruby
default_platform(:android)

PROJECT_ROOT = File.expand_path("../..", __dir__)

platform :android do

  desc "Build APK and distribute to Firebase App Distribution"
  lane :firebase do
    Dir.chdir(PROJECT_ROOT) do

      sh("flutter clean")
      sh("flutter build apk --release")

      firebase_app_distribution(
        app: ENV.fetch("FIREBASE_APP_ID"),
        firebase_cli_token: ENV.fetch("FIREBASE_CLI_TOKEN"),
        android_artifact_path: File.join(
          PROJECT_ROOT,
          "build/app/outputs/flutter-apk/app-release.apk"
        ),
        testers: "mostafagalal1712004@gmail.com",
        release_notes: "Automated CI build"
      )

    end
  end

end
```

#### Requirements for this pipeline to run
- The deploy condition uses `refs/heads/master`, matching the branch name (an earlier version checked `main`, so it never deployed).
- `flutter-version` must be an exact Flutter version that exists; confirm it with `flutter --version` on your machine.
- Drift and freezed need generated code. If generated files are not committed, add this step before the format and analyze steps:
  ```yaml
  - name: Generate code
    run: dart run build_runner build --delete-conflicting-outputs
  ```
- The `firebase_app_distribution` plugin must be in the `Gemfile` and `fastlane/Pluginfile`, with `Gemfile.lock` in the repo root, so `bundle exec fastlane` works.
- `FIREBASE_CLI_TOKEN` still works but is deprecated by Firebase; moving to a service account is on the list below.
- Until flavors exist, the build is the single default app.

### Planned for the release stage (Phase 8, not in use yet)

| Trigger | Workflow | What it does |
|---|---|---|
| Tag `v*` (for example `v1.0.0`) | `release.yml` | Checks, then builds the signed **prod** AAB and uploads it to Play **internal testing** |

Improvements to adopt at that stage:
- Android flavors `dev` and `prod`, with `--flavor` and `--dart-define-from-file` in the Fastlane build commands.
- Firebase service account (`FIREBASE_SERVICE_ACCOUNT`) instead of the CLI token, and a Firebase tester group instead of a personal email in the repo.
- Remove `flutter clean` (unneeded on a fresh runner), cache Gradle, and add job timeouts.
- Versioning, signing, and Play upload as described below.

### `.github/workflows/release.yml`
```yaml
name: Release

on:
  push:
    tags: ['v*']

permissions:
  contents: read

jobs:
  release:
    name: Build and upload to Play internal testing
    runs-on: ubuntu-latest
    environment: production        # optional: require manual approval
    timeout-minutes: 45
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '21'
          cache: gradle

      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          flutter-version: '<exact version from flutter --version>'
          cache: true

      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.3'
          bundler-cache: true

      - run: flutter pub get
      - run: dart run build_runner build --delete-conflicting-outputs
      - run: flutter analyze --fatal-infos
      - run: flutter test

      - name: Prepare signing
        env:
          UPLOAD_KEYSTORE_BASE64: ${{ secrets.UPLOAD_KEYSTORE_BASE64 }}
          KEYSTORE_PASSWORD: ${{ secrets.KEYSTORE_PASSWORD }}
          KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
          KEY_ALIAS: ${{ secrets.KEY_ALIAS }}
        run: |
          echo "$UPLOAD_KEYSTORE_BASE64" | base64 -d > android/app/upload-keystore.jks
          {
            echo "storePassword=$KEYSTORE_PASSWORD"
            echo "keyPassword=$KEY_PASSWORD"
            echo "keyAlias=$KEY_ALIAS"
            echo "storeFile=upload-keystore.jks"
          } > android/key.properties

      - name: Upload to Play internal testing
        env:
          PLAY_SERVICE_ACCOUNT: ${{ secrets.PLAY_SERVICE_ACCOUNT }}
          BUILD_NUMBER: ${{ github.run_number }}
        run: |
          printf '%s' "$PLAY_SERVICE_ACCOUNT" > "$RUNNER_TEMP/play-sa.json"
          export PLAY_JSON_KEY_FILE="$RUNNER_TEMP/play-sa.json"
          export VERSION_NAME="${GITHUB_REF_NAME#v}"
          bundle exec fastlane android play_internal --fastfile android/fastlane/Fastfile
```

### Target `android/fastlane/Fastfile` (after flavors are added)
```ruby
default_platform(:android)

PROJECT_ROOT = File.expand_path("../..", __dir__)

platform :android do
  desc "Build the dev APK and distribute it to Firebase App Distribution"
  lane :firebase do
    Dir.chdir(PROJECT_ROOT) do
      sh("flutter build apk --release --flavor dev " \
         "--dart-define-from-file=config/dev.json " \
         "--build-number=#{ENV.fetch('BUILD_NUMBER')}")

      firebase_app_distribution(
        app: ENV.fetch("FIREBASE_APP_ID"),
        service_credentials_file: ENV.fetch("FIREBASE_SA_FILE"),
        android_artifact_type: "APK",
        android_artifact_path: File.join(
          PROJECT_ROOT, "build/app/outputs/flutter-apk/app-dev-release.apk"
        ),
        groups: "daftari-testers",
        release_notes: ENV.fetch("RELEASE_NOTES", "Automated CI build")
      )
    end
  end

  desc "Build the prod AAB and upload it to Play internal testing"
  lane :play_internal do
    Dir.chdir(PROJECT_ROOT) do
      sh("flutter build appbundle --release --flavor prod " \
         "--dart-define-from-file=config/prod.json " \
         "--build-name=#{ENV.fetch('VERSION_NAME')} " \
         "--build-number=#{ENV.fetch('BUILD_NUMBER')}")

      upload_to_play_store(
        package_name: "<your.application.id>",
        track: "internal",
        aab: File.join(
          PROJECT_ROOT, "build/app/outputs/bundle/prodRelease/app-prod-release.aab"
        ),
        json_key: ENV.fetch("PLAY_JSON_KEY_FILE"),
        release_status: "draft",
        skip_upload_metadata: true,
        skip_upload_images: true,
        skip_upload_screenshots: true
      )
    end
  end

  desc "Promote the internal build to another track (closed testing, production)"
  lane :play_promote do |options|
    upload_to_play_store(
      package_name: "<your.application.id>",
      track: "internal",
      track_promote_to: options[:to] || "alpha",
      json_key: ENV.fetch("PLAY_JSON_KEY_FILE"),
      skip_upload_aab: true,
      skip_upload_metadata: true,
      skip_upload_images: true,
      skip_upload_screenshots: true
    )
  end
end
```

### Fastlane setup
- `Gemfile` and `Gemfile.lock` live in the repo root (or set `BUNDLE_GEMFILE`), listing `fastlane` and loading the plugin file.
- Install the Firebase plugin: `fastlane add_plugin firebase_app_distribution` (creates `fastlane/Pluginfile`, which the Gemfile loads).
- Run the lanes locally once before trusting CI.

### Versioning
- `versionName` comes from the tag (`v1.0.0` becomes `1.0.0`).
- `versionCode` comes from the workflow run number (`--build-number`). Play rejects a repeated or lower code, so never re-use or reset it.
- Dev builds use the `.dev` application ID, so their build numbers are independent from prod.

### Signing
- Keep the upload keystore out of the repo. Store it base64-encoded as a secret; CI decodes it and writes `android/key.properties` only during the release job.
- `android/app/build.gradle` reads `key.properties` for the release signing config and falls back to the debug config when the file is missing (local and dev builds).
- Back up the keystore and its passwords somewhere safe. Enroll in Play App Signing.

### Secrets for the planned release stage (GitHub repository secrets)
| Secret | Used for |
|---|---|
| `FIREBASE_APP_ID_DEV` | Firebase App Distribution app ID (dev) |
| `FIREBASE_SERVICE_ACCOUNT` | Service account JSON with App Distribution permission |
| `PLAY_SERVICE_ACCOUNT` | Play Console API service account JSON |
| `UPLOAD_KEYSTORE_BASE64` | Base64 of the upload keystore |
| `KEYSTORE_PASSWORD`, `KEY_PASSWORD`, `KEY_ALIAS` | Signing credentials |

Other files CI needs: the per-flavor `google-services.json` for Crashlytics (`android/app/src/dev/` and `android/app/src/prod/`) and `config/dev.json` and `config/prod.json`. Commit config files only if they hold public values; otherwise generate them from secrets in the workflow. Never put a service role key in either.

### Notes and limits
- The first release of a new app must be uploaded manually in Play Console; automated uploads work after the app exists. Check Google's current rules for new apps (including closed-testing requirements) before relying on automation.
- Uploads go as `draft` at first; switch to a completed release status once the store listing and policy forms are finished.
- Add the Play service account in Play Console with release permissions for the app.
- Until the backup stage, the app has no Supabase settings, so the config files only hold flags.

### Google Play checklist
- Developer account registered (check current requirements, including any closed-testing period for new accounts)
- App signing enrolled; upload key stored safely
- Store listing in Arabic and English (title, short and full descriptions, screenshots, icon, feature graphic)
- Privacy policy URL; Data safety form; content rating; target audience
- Account deletion in-app plus a web page URL
- Closed testing with real shop owners before production

---

## 12. Build order

The app is built **offline first**. Phases 0 to 6 produce a complete app that works with no account and no internet. Backup is the last stage of this version (Phase 7). The schema is sync-ready from day one (UUID ids, `updated_at`, `deleted_at`, `sync_state`), so adding backup later needs no data migration. Add `supabase_flutter`, `google_sign_in`, and `connectivity_plus` only in Phase 7. Each phase below lists the design screens it implements; the PNGs live in `desgin/` and are the visual source of truth (filenames quoted as-is, including typos).

**Phase 0 — Foundation**
Design screens: none (no dedicated screens; theme tokens, l10n, and the router shell underpin every screen).
- [ ] Repo setup, lints, folder structure
- [ ] Theme tokens and `ThemeExtension`, shared widgets skeleton
- [ ] gen-l10n with Arabic and English, RTL check
- [ ] GetIt, router shell with bottom nav, bootstrap, Crashlytics hooks
- [ ] Drift `AppDatabase` with both tables, migration test, CI running through the existing `daftari_workflow.yml`

**Phase 1 — Domain and data (with tests)**
Design screens: none (logic only, no UI).
- [ ] `Money`, `Failure`, entities, repository interfaces
- [ ] Customers and transactions repositories, DAOs, balance queries
- [ ] Use cases and unit tests for balance, history, and ordering

**Phase 2 — Core screens**
Design screens: desgin/cutomers.png, desgin/empty_customers.png, desgin/add_new_customer.png, desgin/customer_details_and_history.png, desgin/add_transaction.png.
- [ ] Customers list, add/edit customer, import from contacts
- [ ] Customer details with history
- [ ] Add/edit transaction with the keypad, quick amount chips, and the change-customer chooser
- [ ] Add marionette_flutter (debug-only) and MarionetteBinding behind kDebugMode for design-match verification

**Phase 3 — Dashboard and settings**
Design screens: desgin/dashboard.png, desgin/settings.png, desgin/dark_mode.png, desgin/choose_language.png (language chooser is built here as the settings language-switch destination and reused by the Phase 6 first-run flow).
- [ ] Dashboard (today's collections, reassurance card, tip cards), settings, theme mode, language switch, shop name

**Phase 4 — Security**
Design screens: desgin/lock_screen.png (PIN setup reuses the same keypad UI).
- [ ] PIN setup and lock, biometrics, auto-lock, router guard

**Phase 5 — Statement**
Design screens: desgin/wattsapp_report.png (statement preview + WhatsApp share).
- [ ] Statement text, WhatsApp share, fallback

**Phase 6 — Offline polish**
Design screens: desgin/splash.png, desgin/onboarding.png; reuses desgin/choose_language.png (first-run flow: splash → language → onboarding) and polishes desgin/empty_customers.png.
- [ ] Onboarding and splash, empty states, accessibility pass, low-end device check
- [ ] Rebuild check with Flutter DevTools on the dashboard, customers list, and history (no widget rebuilds for unrelated state changes)
- [ ] Full offline check: every feature works with no account and no internet

**Phase 7 — Account and backup (last stage of this version)**
Design screens: desgin/login.png, desgin/create_account.png, desgin/backup.png (these screens must not be built before this phase).
- [ ] Supabase project, schema, RLS, triggers
- [ ] Auth (Google, email), secure session storage
- [ ] Sync push/pull, status UI, restore, account deletion (Edge Function)
- [ ] Home backup banner and reassurance card, Settings account and backup rows

**Phase 8 — Release**
Design screens: none (no new UI; store assets derive from existing screens).
- [ ] Flavors and `--dart-define` config, service-account auth, release workflow, closed testing, fixes, production release

**UI verification (Marionette)**

Applies to every phase with screens (Phases 2 to 7), before the phase is marked Done in agent.md Section 3.

- Run the app in debug mode (`flutter run`) and connect Marionette MCP to the VM service.
- Walk through each of the phase's design screens in Arabic (RTL) and English, Light and Dark, capture screenshots, and compare them against the corresponding `desgin/` PNGs.
- The bar is structure, hierarchy, spacing, colors, typography, and RTL behavior — the PNGs are mockups, not pixel specs. Fix mismatches, re-verify, then mark the phase Done.
- Screenshots are working artifacts: never commit them.

**Definition of done for a feature**
- Domain and Cubit tests pass; widget tests for key flows
- Works in Arabic (RTL) and English, Light and Dark
- No analyzer warnings; no business logic in widgets
- No sensitive data in logs
- Manually checked on a low-end Android device
- UI matches the phase's design screens (verified with Marionette screenshots)

---

## 13. Rules for AI coding tools (agent.md content)
- Follow the dependency rule: `presentation → domain ← data`. Never import Drift, Supabase, or Flutter UI into `domain`.
- Use `Either<Failure, T>` for one-shot domain operations; do not throw across layer boundaries.
- Amounts are `int` piasters. Never use `double` for money.
- Balance is always derived from transactions; never store or edit a balance directly.
- Soft delete only (`deleted_at`); every local change updates `updated_at` and sets `sync_state = 'pending'`.
- Never use hard-coded user-facing strings; add keys to both ARB files.
- Use directional widgets (`EdgeInsetsDirectional`, `AlignmentDirectional`); test RTL.
- Use the shared `DaftariAppBar` and design tokens; do not create new colors or app bar variants.
- Keep rebuilds minimal: `buildWhen` / `BlocSelector`, small widgets, `const` constructors, and states with value equality.
- Avoid unnecessary rebuilds: use `BlocSelector`, `buildWhen`, and `listenWhen`; no screen-level `BlocBuilder` that rebuilds everything.
- Never log or report customer names, phone numbers, or amounts.
- Add or update tests with every change; run `flutter analyze` and `flutter test` before finishing.
- Generated files (`*.g.dart`, `*.freezed.dart`) are never edited by hand.
- Review AI-generated code for architecture fit, edge cases (empty states, errors, offline), and security before merging.

---

## 14. Open items
- Final application ID and Firebase / Supabase project names
- Privacy policy and account-deletion web pages (hosting location)
- PIN length (4 vs 6 digits)
- Whether reminders move into v1.1
- Final contact-picker package (confirm it needs no contacts permission)
