import 'package:flutter/material.dart';

/// Palette for the whole app.
///
/// The colors whose names end with the suffix `Light` (e.g. `bgLight`,
/// `surfaceLight`, `textPrimaryLight`, `textSecondaryLight`) and the generic
/// `border` are intentionally **adaptive**: their getters return the dark
/// variant when [AppColors.brightness] is `Brightness.dark`. This lets
/// existing widget code that already references `AppColors.surfaceLight`
/// auto-switch between light/dark without rewriting every call site.
///
/// `AppColors.brightness` is updated by `main.dart`'s top-level rebuild
/// whenever the resolved theme mode changes. The `*Lit` constants below
/// expose the raw light values for places (only the theme definitions in
/// `app_theme.dart`) that must keep using the literal light color.
class AppColors {
  // Brand blue
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color accent = Color(0xFF3B82F6);

  // Tint — light blue accent surface (used for highlight cards, chips, etc.)
  // Adaptive: in dark mode we return a deep blue tinted with the primary
  // brand color so highlight cards remain visually distinct from the base
  // surface but no longer look glaringly white.
  static const Color tintLit = Color(0xFFEFF6FF);
  static const Color tintDark = Color(0xFF1B2E55);

  // Light surface — raw literal values (use only inside AppTheme.light()
  // or where you intentionally want the light shade even in dark mode).
  static const Color bgLightLit = Color(0xFFFFFFFF);
  static const Color surfaceLightLit = Color(0xFFF5F8FF);
  static const Color textPrimaryLightLit = Color(0xFF0F172A);
  static const Color textSecondaryLightLit = Color(0xFF64748B);
  static const Color borderLit = Color(0xFFE2E8F0);

  // Dark surface
  static const Color bgDark = Color(0xFF0B1220);
  static const Color surfaceDark = Color(0xFF111827);
  static const Color textPrimaryDark = Color(0xFFE2E8F0);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color borderDark = Color(0xFF1F2937);

  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color danger = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF06B6D4);
  static const Color spam = Color(0xFFE11D48);

  // Resolved brightness, updated by the root rebuild whenever ThemeMode or
  // platform brightness changes. Defaults to light. Exposed as a
  // [ValueNotifier] so a top-level listener in main.dart can force a full
  // widget-tree rebuild when the value flips — widgets that read the static
  // [surfaceLight]/[tint]/etc. getters do not subscribe to Flutter's Theme
  // InheritedWidget, so they would otherwise keep painting with the previous
  // brightness's color until their parent happens to rebuild.
  static final ValueNotifier<Brightness> brightnessNotifier =
      ValueNotifier<Brightness>(Brightness.light);
  static Brightness get brightness => brightnessNotifier.value;
  static set brightness(Brightness v) {
    if (brightnessNotifier.value != v) brightnessNotifier.value = v;
  }

  // ---- Adaptive surface getters (used across all feature screens) ----
  // These automatically switch to the dark variant in dark mode so that
  // pre-existing call sites like `AppColors.surfaceLight` keep working.
  static Color get bgLight =>
      brightness == Brightness.dark ? bgDark : bgLightLit;
  static Color get surfaceLight =>
      brightness == Brightness.dark ? surfaceDark : surfaceLightLit;
  static Color get textPrimaryLight =>
      brightness == Brightness.dark ? textPrimaryDark : textPrimaryLightLit;
  static Color get textSecondaryLight =>
      brightness == Brightness.dark ? textSecondaryDark : textSecondaryLightLit;
  static Color get border =>
      brightness == Brightness.dark ? borderDark : borderLit;
  static Color get tint =>
      brightness == Brightness.dark ? tintDark : tintLit;
}
