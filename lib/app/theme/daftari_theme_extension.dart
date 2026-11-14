import 'package:flutter/material.dart';

import 'design_tokens.dart';

/// Semantic status colors for balances: money owed ([owed]), money paid back
/// ([paid]), and neutral emphasis ([warning]).
///
/// Always pair these colors with a text label; never use color alone.
class DaftariThemeExtension extends ThemeExtension<DaftariThemeExtension> {
  const DaftariThemeExtension({
    required this.owed,
    required this.paid,
    required this.warning,
  });

  factory DaftariThemeExtension.light() => const DaftariThemeExtension(
    owed: DaftariTokens.owedLight,
    paid: DaftariTokens.paidLight,
    warning: DaftariTokens.warningLight,
  );

  factory DaftariThemeExtension.dark() => const DaftariThemeExtension(
    owed: DaftariTokens.owedDark,
    paid: DaftariTokens.paidDark,
    warning: DaftariTokens.warningDark,
  );

  final Color owed;
  final Color paid;
  final Color warning;

  @override
  DaftariThemeExtension copyWith({Color? owed, Color? paid, Color? warning}) {
    return DaftariThemeExtension(
      owed: owed ?? this.owed,
      paid: paid ?? this.paid,
      warning: warning ?? this.warning,
    );
  }

  @override
  DaftariThemeExtension lerp(DaftariThemeExtension? other, double t) {
    if (other == null) return this;
    return DaftariThemeExtension(
      owed: Color.lerp(owed, other.owed, t)!,
      paid: Color.lerp(paid, other.paid, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}
