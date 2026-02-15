import 'package:flutter/material.dart';

/// Color palette extracted from Google Stitch designs.
///
/// Home screen uses Tranquil Blue (#195de6) as primary.
/// Memorial Profile uses Deep Indigo-Violet (#3b19e6) as primary.
/// Both share the Newsreader serif typography and ethereal aesthetic.
class AppColors {
  AppColors._();

  // ─── Primary Brand Colors ───────────────────────────────
  static const Color primary = Color(0xFF195DE6);         // Tranquil Blue (Home)
  static const Color primaryProfile = Color(0xFF3B19E6);  // Deep Indigo-Violet (Profile)
  static const Color primaryLight = Color(0xFF4F7FF0);
  static const Color primaryDark = Color(0xFF0D3DA8);

  // ─── Light Theme ────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF6F8FB); // Sky-blue tinted off-white
  static const Color surfaceLight = Color(0xFFFFFFFF);     // Pure white cards

  // ─── Dark Theme ─────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF141121);   // Obsidian with violet undertone
  static const Color surfaceDark = Color(0xFF1A2130);      // Slightly elevated dark

  // ─── Text Colors ────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1E293B);      // Slate 800
  static const Color textSecondary = Color(0xFF64748B);    // Slate 500
  static const Color textMuted = Color(0xFF94A3B8);        // Slate 400
  static const Color textLight = Color(0xFFE2E8F0);        // Slate 200
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ─── Border Colors ──────────────────────────────────────
  static const Color borderLight = Color(0xFFE2E8F0);     // Slate 200
  static const Color borderDark = Color(0xFF1E293B);       // Slate 800

  // ─── Status / Interaction ───────────────────────────────
  static const Color candleAmber = Color(0xFFF59E0B);      // Candle lit glow
  static const Color accentGold = Color(0xFFD4AF37);       // Metallic Gold
  static const Color accentCandle = candleAmber;            // Alias for profile page
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);

  // ─── Shadows (as Color for BoxShadow) ───────────────────
  static const Color shadowSoft = Color(0x14195DE6);       // rgba(25,93,230,0.08)
  static const Color shadowCard = Color(0x0D195DE6);       // rgba(25,93,230,0.05)

  // ─── Ethereal Gradient (Profile) ────────────────────────
  static const Color etherealGradientStart = Color(0x263B19E6); // primary at 15%
  static const Color etherealGradientEnd = Color(0x00141121);   // background transparent
}
