// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Daftari';

  @override
  String get tabDashboard => 'Home';

  @override
  String get tabCustomers => 'Customers';

  @override
  String get tabSettings => 'Settings';

  @override
  String get splashTagline =>
      'Your customer credit ledger — easy and always available';

  @override
  String get emptyStateTitle => 'Nothing here yet';

  @override
  String get emptyStateMessage =>
      'Data will appear here once you start adding customers and transactions';
}
