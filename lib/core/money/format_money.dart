import 'package:intl/intl.dart';

/// Formats an amount in piasters for display.
///
/// Phase 0 skeleton: integer piasters are converted to pounds using pure
/// integer math (rule R1 — never convert money to `double`) and grouped with
/// Western digits in both locales (plan.md Section 7). The full `Money` value
/// type with locale-aware parsing and formatting arrives in Phase 1.
String formatMoney(int amountPiasters) {
  const numberLocale = 'en';
  final abs = amountPiasters.abs();
  final pounds = abs ~/ 100;
  final piasters = abs % 100;
  final grouped = NumberFormat('#,##0', numberLocale).format(pounds);
  final sign = amountPiasters < 0 ? '-' : '';
  return piasters == 0
      ? '$sign$grouped'
      : '$sign$grouped.${piasters.toString().padLeft(2, '0')}';
}
