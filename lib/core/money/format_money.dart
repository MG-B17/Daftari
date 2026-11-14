import 'dart:ui' show Locale;

import 'package:intl/intl.dart';

import 'money.dart';

/// Formats the numeric part of an amount, without a currency suffix:
/// `1,250`, `1,250.50`, or `-1,250.50`.
///
/// Integer piasters are converted to pounds using pure integer math (rule R1
/// — never convert money to `double`) and grouped with Western digits in both
/// locales (plan.md Section 7). Used by widgets that render their own text
/// label next to the amount, such as `BalanceText`.
String formatMoneyAmount(Money amount) {
  const numberLocale = 'en';
  final piasters = amount.asPiasters;
  final abs = piasters.abs();
  final pounds = abs ~/ 100;
  final fraction = abs % 100;
  final grouped = NumberFormat('#,##0', numberLocale).format(pounds);
  final sign = piasters < 0 ? '-' : '';
  return fraction == 0
      ? '$sign$grouped'
      : '$sign$grouped.${fraction.toString().padLeft(2, '0')}';
}

/// Formats an amount for display with its currency suffix (plan.md Section 7):
/// `1,250 ج.م` in Arabic and `1,250 EGP` in English, Western digits in both.
String formatMoney(Money amount, Locale locale) {
  final suffix = switch (locale.languageCode) {
    'ar' => 'ج.م',
    _ => 'EGP',
  };
  return '${formatMoneyAmount(amount)} $suffix';
}
