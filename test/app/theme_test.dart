import 'package:flutter_test/flutter_test.dart';

import 'package:daftari/app/theme/app_theme.dart';
import 'package:daftari/app/theme/daftari_theme_extension.dart';
import 'package:daftari/app/theme/design_tokens.dart';

void main() {
  group('light theme', () {
    final theme = DaftariTheme.light();

    test('uses the Cairo font', () {
      expect(theme.textTheme.bodyMedium!.fontFamily, 'Cairo');
    });

    test('is built from the exact design tokens', () {
      expect(theme.colorScheme.primary, DaftariTokens.primaryLight);
      expect(theme.scaffoldBackgroundColor, DaftariTokens.backgroundLight);
      expect(theme.colorScheme.surface, DaftariTokens.surfaceLight);
      expect(theme.colorScheme.onSurface, DaftariTokens.textLight);
      expect(theme.appBarTheme.backgroundColor, DaftariTokens.surfaceLight);
    });

    test('exposes owed, paid, and warning through the theme extension', () {
      final extension = theme.extension<DaftariThemeExtension>();
      expect(extension, isNotNull);
      expect(extension!.owed, DaftariTokens.owedLight);
      expect(extension.paid, DaftariTokens.paidLight);
      expect(extension.warning, DaftariTokens.warningLight);
    });
  });

  group('dark theme', () {
    final theme = DaftariTheme.dark();

    test('uses the Cairo font', () {
      expect(theme.textTheme.bodyMedium!.fontFamily, 'Cairo');
    });

    test('is built from the exact design tokens', () {
      expect(theme.colorScheme.primary, DaftariTokens.primaryDark);
      expect(theme.scaffoldBackgroundColor, DaftariTokens.backgroundDark);
      expect(theme.colorScheme.surface, DaftariTokens.surfaceDark);
      expect(theme.colorScheme.onSurface, DaftariTokens.textDark);
      expect(theme.appBarTheme.backgroundColor, DaftariTokens.surfaceDark);
    });

    test('exposes owed, paid, and warning through the theme extension', () {
      final extension = theme.extension<DaftariThemeExtension>();
      expect(extension, isNotNull);
      expect(extension!.owed, DaftariTokens.owedDark);
      expect(extension.paid, DaftariTokens.paidDark);
      expect(extension.warning, DaftariTokens.warningDark);
    });
  });
}
