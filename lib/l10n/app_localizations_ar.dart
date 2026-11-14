// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'دفتري';

  @override
  String get tabDashboard => 'الرئيسية';

  @override
  String get tabCustomers => 'العملاء';

  @override
  String get tabSettings => 'الإعدادات';

  @override
  String get splashTagline => 'سجّل حسابات عملائك بسهولة وبدون إنترنت';

  @override
  String get emptyStateTitle => 'لا يوجد شيء بعد';

  @override
  String get emptyStateMessage =>
      'ستظهر البيانات هنا عندما تبدأ بإضافة العملاء والحركات';
}
