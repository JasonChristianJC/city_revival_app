import 'package:flutter/material.dart';

class AppColors {
  // Sacred Modernism Core Palette
  static const Color primaryWine = Color(0xFF6F1728); // Royal Burgundy / Wine
  static const Color primaryBurgundyDark = Color(0xFF4A0E1A);
  static const Color primaryBurgundyLight = Color(0xFF8B2639);

  static const Color divineGold = Color(0xFFD4AF37); // Metallic Gold
  static const Color divineGoldLight = Color(0xFFF1D779);
  static const Color divineGoldDark = Color(0xFFA68519);

  // Surfaces
  static const Color parchmentCream = Color(0xFFFBF7F0); // Warm Cream / Parchment Light
  static const Color parchmentCreamAlt = Color(0xFFF4ECE1);
  static const Color parchmentCard = Color(0xFFFFFFFF);

  static const Color velvetCharcoal = Color(0xFF0F1117); // Dark Surface / Night Mode
  static const Color darkCard = Color(0xFF181B23);
  static const Color darkCardAlt = Color(0xFF222632);

  // Alerts & Highlights
  static const Color liveRed = Color(0xFFE11D48); // Vibrant Ruby Red
  static const Color successGreen = Color(0xFF16A34A);
  static const Color amberWarning = Color(0xFFD97706);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF1C1917);
  static const Color textSecondaryLight = Color(0xFF78716C);
  static const Color textTertiaryLight = Color(0xFFA8A29E);

  static const Color textPrimaryDark = Color(0xFFF5F5F4);
  static const Color textSecondaryDark = Color(0xFFA8A29E);
  static const Color textTertiaryDark = Color(0xFF78716C);

  // Accent Gradients
  static const LinearGradient burgundyGradient = LinearGradient(
    colors: [Color(0xFF6F1728), Color(0xFF4A0E1A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF1D779), Color(0xFFD4AF37), Color(0xFFA68519)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF1A1D27), Color(0xFF12141C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient liveRedGradient = LinearGradient(
    colors: [Color(0xFFF43F5E), Color(0xFFE11D48)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
