import 'package:flutter/material.dart';

import 'daftari_theme_extension.dart';
import 'design_tokens.dart';

/// App themes built from the Daftari design tokens (agent.md Section 8).
///
/// Material 3, Cairo as the app font. The exact same token-driven structure is
/// used for light and dark so the two modes stay visually consistent.
abstract final class DaftariTheme {
  static const String fontFamily = 'Cairo';

  static ThemeData light() => _build(
    background: DaftariTokens.backgroundLight,
    surface: DaftariTokens.surfaceLight,
    primary: DaftariTokens.primaryLight,
    text: DaftariTokens.textLight,
    secondaryText: DaftariTokens.secondaryTextLight,
    border: DaftariTokens.borderLight,
    owed: DaftariTokens.owedLight,
    paid: DaftariTokens.paidLight,
    warning: DaftariTokens.warningLight,
    brightness: Brightness.light,
  );

  static ThemeData dark() => _build(
    background: DaftariTokens.backgroundDark,
    surface: DaftariTokens.surfaceDark,
    primary: DaftariTokens.primaryDark,
    text: DaftariTokens.textDark,
    secondaryText: DaftariTokens.secondaryTextDark,
    border: DaftariTokens.borderDark,
    owed: DaftariTokens.owedDark,
    paid: DaftariTokens.paidDark,
    warning: DaftariTokens.warningDark,
    brightness: Brightness.dark,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color primary,
    required Color text,
    required Color secondaryText,
    required Color border,
    required Color owed,
    required Color paid,
    required Color warning,
  }) {
    final onPrimary = brightness == Brightness.light
        ? DaftariTokens.surfaceLight
        : DaftariTokens.backgroundDark;
    final onError = brightness == Brightness.light
        ? DaftariTokens.surfaceLight
        : DaftariTokens.backgroundDark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      secondary: primary,
      onSecondary: onPrimary,
      error: owed,
      onError: onError,
      surface: surface,
      onSurface: text,
      onSurfaceVariant: secondaryText,
      outline: border,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      fontFamily: fontFamily,
      textTheme: ThemeData(brightness: brightness).textTheme
          .apply(fontFamily: fontFamily, bodyColor: text, displayColor: text),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: primary.withValues(alpha: 0.14),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontFamily: fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: text,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? primary : secondaryText);
        }),
      ),
      dividerTheme: DividerThemeData(color: border),
      extensions: <ThemeExtension<dynamic>>[
        DaftariThemeExtension(owed: owed, paid: paid, warning: warning),
      ],
    );
  }
}
