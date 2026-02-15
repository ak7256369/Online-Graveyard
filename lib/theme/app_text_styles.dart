import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography system extracted from Google Stitch designs.
///
/// The app uses Newsreader (serif) as the display font,
/// giving it a newspaper-obituary quality: dignified, timeless, literary.
class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Newsreader';

  // ─── App Title (Home header) ────────────────────────────
  static TextStyle get appTitle => GoogleFonts.newsreader(
    fontSize: 30,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.5,
    height: 1.2,
  );

  // ─── Person Name (on cards) ─────────────────────────────
  static TextStyle get cardName => GoogleFonts.newsreader(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  // ─── Person Name (on profile) ──────────────────────────
  static TextStyle get profileName => GoogleFonts.newsreader(
    fontSize: 30,
    fontWeight: FontWeight.w500,
  );

  // ─── Birth–Death Dates ──────────────────────────────────
  static TextStyle get dates => GoogleFonts.newsreader(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.italic,
  );

  // ─── Section Headings ──────────────────────────────────
  static TextStyle get sectionHeading => GoogleFonts.newsreader(
    fontSize: 20,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get headlineMedium => GoogleFonts.newsreader(
    fontSize: 28,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get titleMedium => GoogleFonts.newsreader(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  );

  // ─── Body Text (bio, tributes) ─────────────────────────
  static TextStyle get bodyText => GoogleFonts.newsreader(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  // ─── Section Divider Label (IN LOVING MEMORY) ──────────
  static TextStyle get dividerLabel => GoogleFonts.inter( // Sans-serif for small labels
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 3.0,
  );

  // ─── Filter Chip Text ──────────────────────────────────
  static TextStyle get chipText => GoogleFonts.newsreader(
    fontSize: 18,
    fontWeight: FontWeight.w400,
  );

  // ─── Quote / Epitaph ──────────────────────────────────
  static TextStyle get quote => GoogleFonts.newsreader(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // ─── Small Labels ─────────────────────────────────────
  static TextStyle get smallLabel => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  // ─── Stat Count (candle/flower numbers) ────────────────
  static TextStyle get statCount => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  // ─── Missing Getters (for compatibility) ───────────────
  static TextStyle get headlineSmall => GoogleFonts.newsreader(
    fontSize: 24,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get bodyLarge => GoogleFonts.newsreader(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
    letterSpacing: 0.5,
  );

  static TextStyle get bodyMedium => GoogleFonts.newsreader(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );

  static TextStyle get headlineLarge => GoogleFonts.newsreader(
    fontSize: 32,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get labelLarge => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  static TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static TextStyle get labelSmall => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  /// Full TextTheme for Material theme integration.
  static TextTheme get textTheme {
    return GoogleFonts.newsreaderTextTheme().copyWith(
      displayLarge: GoogleFonts.newsreader(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
      ),
      displayMedium: GoogleFonts.newsreader(
        fontSize: 45,
        fontWeight: FontWeight.w400,
      ),
      displaySmall: GoogleFonts.newsreader(
        fontSize: 36,
        fontWeight: FontWeight.w400,
      ),
      headlineLarge: GoogleFonts.newsreader(
        fontSize: 32,
        fontWeight: FontWeight.w500,
      ),
      headlineMedium: GoogleFonts.newsreader(
        fontSize: 28,
        fontWeight: FontWeight.w500,
      ),
      headlineSmall: GoogleFonts.newsreader(
        fontSize: 24,
        fontWeight: FontWeight.w500,
      ),
      titleLarge: GoogleFonts.newsreader(
        fontSize: 22,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: GoogleFonts.newsreader(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
      ),
      titleSmall: GoogleFonts.newsreader(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      bodyLarge: GoogleFonts.newsreader(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.6,
        letterSpacing: 0.5,
      ),
      bodyMedium: GoogleFonts.newsreader(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      ),
      bodySmall: GoogleFonts.newsreader(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );
  }
}
