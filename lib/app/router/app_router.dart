import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/daftari_bottom_nav.dart';
import '../../features/customers/presentation/pages/customers_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/onboarding/presentation/pages/daftari_splash_screen.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

/// App router (plan.md Section 6): `/splash` first, then the home shell with
/// the three bottom navigation branches.
///
/// Tests call [createAppRouter] directly to get a fresh router instance.
GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const DaftariSplashScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => Scaffold(
          body: navigationShell,
          bottomNavigationBar: DaftariBottomNav(
            navigationShell: navigationShell,
          ),
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/dashboard',
                name: 'dashboard',
                builder: (context, state) => const DashboardPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/customers',
                name: 'customers',
                builder: (context, state) => const CustomersPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/settings',
                name: 'settings',
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// The shared router instance used by the app.
final GoRouter appRouter = createAppRouter();
