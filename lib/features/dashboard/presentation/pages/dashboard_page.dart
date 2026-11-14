import 'package:daftari/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/daftari_app_bar.dart';
import '../../../../core/widgets/empty_state.dart';

/// Dashboard placeholder page (built out in Phase 3).
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: DaftariAppBar(title: l10n.tabDashboard),
      body: EmptyState(
        title: l10n.emptyStateTitle,
        message: l10n.emptyStateMessage,
      ),
    );
  }
}
