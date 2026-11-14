import 'package:daftari/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';

/// Root widget: Material 3 app with the Daftari themes and the go_router
/// configuration.
class DaftariApp extends StatelessWidget {
  const DaftariApp({
    this.locale = const Locale('ar'),
    this.routerConfig,
    super.key,
  });

  /// App locale. Arabic (RTL) is the default (plan.md Section 7); the
  /// language switch in Settings arrives in Phase 3.
  final Locale locale;

  /// Router override (used by tests to get a fresh navigation state).
  final GoRouter? routerConfig;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      theme: DaftariTheme.light(),
      darkTheme: DaftariTheme.dark(),
      routerConfig: routerConfig ?? appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
