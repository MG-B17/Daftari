import 'package:flutter/material.dart';

import '../../app/theme/daftari_theme_extension.dart';
import '../money/format_money.dart';
import '../money/money.dart';

/// Displays a money amount with a text label next to it (agent.md Section 8).
///
/// The amount is a [Money] value in integer piasters (rule R1) rendered
/// through [formatMoneyAmount]. The color carries meaning only together with
/// [label]: a positive balance (customer owes) uses the `owed` color, a
/// negative balance (customer paid back) uses the `paid` color, and zero
/// stays neutral.
class BalanceText extends StatelessWidget {
  const BalanceText({
    required this.amount,
    required this.label,
    this.style,
    super.key,
  });

  /// Amount: positive means the customer owes the shop (عليه).
  final Money amount;

  /// Text label describing the amount, always shown (never color alone).
  final String label;

  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final themeExtension = Theme.of(context)
        .extension<DaftariThemeExtension>()!;
    final amountColor = switch (amount.asPiasters) {
      > 0 => themeExtension.owed,
      < 0 => themeExtension.paid,
      _ => Theme.of(context).colorScheme.onSurface,
    };

    final amountStyle = (style ?? Theme.of(context).textTheme.titleMedium)
        ?.copyWith(color: amountColor);
    final labelStyle = (style ?? Theme.of(context).textTheme.bodySmall)
        ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: formatMoneyAmount(amount), style: amountStyle),
          TextSpan(text: ' $label', style: labelStyle),
        ],
      ),
    );
  }
}
