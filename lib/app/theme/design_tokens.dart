import 'package:flutter/material.dart';

/// Design tokens from the Daftari design system (agent.md Section 8).
///
/// These are the only colors the app may use; never invent new ones (rule R8).
abstract final class DaftariTokens {
  // Light mode.
  static const Color backgroundLight = Color(0xFFFBF7F0);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color primaryLight = Color(0xFF0F766E);
  static const Color textLight = Color(0xFF1F2937);
  static const Color secondaryTextLight = Color(0xFF6B7280);
  static const Color borderLight = Color(0xFFE7E0D3);
  static const Color owedLight = Color(0xFFB91C1C);
  static const Color paidLight = Color(0xFF15803D);
  static const Color warningLight = Color(0xFFF59E0B);

  // Dark mode.
  static const Color backgroundDark = Color(0xFF14110F);
  static const Color surfaceDark = Color(0xFF1E1A17);
  static const Color primaryDark = Color(0xFF2DD4BF);
  static const Color textDark = Color(0xFFF5F1EA);
  static const Color secondaryTextDark = Color(0xFFA8A29A);
  static const Color borderDark = Color(0xFF3A332D);
  static const Color owedDark = Color(0xFFF87171);
  static const Color paidDark = Color(0xFF4ADE80);
  static const Color warningDark = Color(0xFFF59E0B);
}
