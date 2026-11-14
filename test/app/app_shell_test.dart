import 'package:daftari/app/app.dart';
import 'package:daftari/app/router/app_router.dart';
import 'package:daftari/core/widgets/daftari_app_bar.dart';
import 'package:daftari/features/customers/presentation/pages/customers_page.dart';
import 'package:daftari/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:daftari/features/onboarding/presentation/pages/daftari_splash_screen.dart';
import 'package:daftari/features/settings/presentation/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  Future<GoRouter> pumpApp(
    WidgetTester tester, {
    Locale locale = const Locale('ar'),
  }) async {
    final router = createAppRouter();
    await tester.pumpWidget(DaftariApp(locale: locale, routerConfig: router));
    await tester.pumpAndSettle();
    return router;
  }

  Future<void> pumpAppOnHome(
    WidgetTester tester, {
    Locale locale = const Locale('ar'),
  }) async {
    final router = await pumpApp(tester, locale: locale);
    router.go('/home/dashboard');
    await tester.pumpAndSettle();
  }

  testWidgets('starts on the splash screen', (tester) async {
    await pumpApp(tester);

    expect(find.byType(DaftariSplashScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('shows the home shell with the three localized tabs in Arabic', (
    tester,
  ) async {
    await pumpAppOnHome(tester);

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('الرئيسية'), findsWidgets);
    expect(find.text('العملاء'), findsOneWidget);
    expect(find.text('الإعدادات'), findsOneWidget);
    expect(find.byType(DashboardPage), findsOneWidget);
  });

  testWidgets('switches to the customers tab and shows its page', (
    tester,
  ) async {
    await pumpAppOnHome(tester);

    await tester.tap(find.text('العملاء'));
    await tester.pumpAndSettle();

    expect(find.byType(CustomersPage), findsOneWidget);
    expect(find.byType(DaftariAppBar), findsOneWidget);
    expect(find.text('العملاء'), findsWidgets);
  });

  testWidgets('switches to the settings tab and shows its page', (
    tester,
  ) async {
    await pumpAppOnHome(tester);

    await tester.tap(find.text('الإعدادات'));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsPage), findsOneWidget);
  });

  testWidgets('renders right-to-left with the default Arabic locale', (
    tester,
  ) async {
    await pumpAppOnHome(tester);

    final directionality = Directionality.of(
      tester.element(find.byType(NavigationBar)),
    );
    expect(directionality, TextDirection.rtl);
  });

  testWidgets('renders left-to-right with the English locale', (tester) async {
    await pumpAppOnHome(tester, locale: const Locale('en'));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Customers'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    final directionality = Directionality.of(
      tester.element(find.byType(NavigationBar)),
    );
    expect(directionality, TextDirection.ltr);
    expect(find.byType(DashboardPage), findsOneWidget);
  });
}
