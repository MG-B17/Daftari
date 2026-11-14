import 'package:daftari/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Branded splash screen matching the Figma splash frame: cream background,
/// teal rounded logo mark, app name and tagline in Cairo. All strings come
/// from l10n (rule R7); no timers yet.
class DaftariSplashScreen extends StatelessWidget {
  const DaftariSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _logoMark(theme),
            const SizedBox(height: 24),
            Text(
              l10n.appName,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.splashTagline,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _logoMark(ThemeData theme) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Icon(
        Icons.menu_book_rounded,
        size: 48,
        color: theme.colorScheme.onPrimary,
      ),
    );
  }
}
