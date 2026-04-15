import 'package:fins/pages/builders/designs/colors.dart';
import 'package:flutter/material.dart';
import 'package:fins/themes/constants/app_colors.dart';
import 'package:fins/themes/constants/app_theme_type.dart';
export 'package:fins/themes/constants/app_theme_type.dart'; // bc main will use this

/*
===========================================================================
   This file contains the logic for themes and reuses the app colors class.
   It also uses the enum types on app theme types for the getters.
===========================================================================
*/

// this is for the customized widgets
class ExtraColors extends ThemeExtension<ExtraColors> {
  final Color bubble;
  final Color themeItemIcon;
  final Color hintText;

  const ExtraColors({
    required this.bubble,
    required this.themeItemIcon,
    required this.hintText,
  });

  @override
  ExtraColors copyWith() => this;

  // lerp means linear interpolation. it finds the middle ground value for a smooth animation
  @override
  ExtraColors lerp(ThemeExtension<ExtraColors>? newTheme, double t) {
    if (newTheme is! ExtraColors) return this;
    return ExtraColors(
      bubble: Color.lerp(bubble, newTheme.bubble, t)!,
      themeItemIcon: Color.lerp(themeItemIcon, newTheme.themeItemIcon, t)!,
      hintText: Color.lerp(hintText, newTheme.hintText, t)!,
    );
  }
}

class AppThemes {
  AppThemes._();

  // --- THEME BUILDER ---
  static ThemeData _build({
    required Color background,
    required Color primary,
    required Color onPrimary,
    required Color surface,
    required Color onSurface,
    required Color bubble,
    required Color themeItemIcon,
    required Color hintText,
  }) {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary, // main app theme, just the same with primary
        primary: primary,   // auto-styles buttons (main buttons, selected states, active UI elements)
        onPrimary: onPrimary,
        surface: surface,   // auto-styles cards (what sits on top of the page, widgets)
        onSurface: onSurface,    // auto-styles text above widgets
      ),
      // Add your custom "rebel" colors to the extension
      extensions: [
        ExtraColors(
          bubble: bubble,
          themeItemIcon: themeItemIcon,
          hintText: hintText,
        ),
      ],
    );
  }

  // --- ACCESS THEMES HERE ---
  static ThemeData get blue => _build(
    background: AppColors.blue.pageBackground,
    primary: AppColors.blue.activeElement,
    surface: AppColors.blue.cardBackground,
    onPrimary: AppColors.blue.pageTitleText,
    onSurface: AppColors.blue.bodyText,
    bubble: AppColors.blue.bubble,
    themeItemIcon: AppColors.blue.themeItemIcon,
    hintText: AppColors.blue.hintText
  );

  static ThemeData get pink => _build(
    background: AppColors.pink.pageBackground,
    primary: AppColors.pink.activeElement,
    surface: AppColors.pink.cardBackground,
    onPrimary: AppColors.pink.pageTitleText,
    onSurface: AppColors.pink.bodyText,
    bubble: AppColors.pink.bubble,
    themeItemIcon: AppColors.pink.themeItemIcon,
    hintText: AppColors.blue.hintText
  );

  static ThemeData get green => _build(
    background: AppColors.pink.pageBackground,
    primary: AppColors.pink.activeElement,
    surface: AppColors.pink.cardBackground,
    onPrimary: AppColors.pink.pageTitleText,
    onSurface: AppColors.pink.bodyText,
    bubble: AppColors.pink.bubble,
    themeItemIcon: AppColors.green.themeItemIcon,
    hintText: AppColors.blue.hintText
  );

  static ThemeData get orange => _build(
    background: AppColors.pink.pageBackground,
    primary: AppColors.pink.activeElement,
    surface: AppColors.pink.cardBackground,
    onPrimary: AppColors.pink.pageTitleText,
    onSurface: AppColors.pink.bodyText,
    bubble: AppColors.pink.bubble,
    themeItemIcon: AppColors.orange.themeItemIcon,
    hintText: AppColors.blue.hintText
  );

  static ThemeData get cyan => _build(
    background: AppColors.pink.pageBackground,
    primary: AppColors.pink.activeElement,
    surface: AppColors.pink.cardBackground,
    onPrimary: AppColors.pink.pageTitleText,
    onSurface: AppColors.pink.bodyText,
    bubble: AppColors.pink.bubble,
    themeItemIcon: AppColors.cyan.themeItemIcon,
    hintText: AppColors.blue.hintText
  );

  static ThemeData get purple => _build(
    background: AppColors.pink.pageBackground,
    primary: AppColors.pink.activeElement,
    surface: AppColors.pink.cardBackground,
    onPrimary: AppColors.pink.pageTitleText,
    onSurface: AppColors.pink.bodyText,
    bubble: AppColors.pink.bubble,
    themeItemIcon: AppColors.purple.themeItemIcon,
    hintText: AppColors.blue.hintText
  );


}

// Use in UI
extension ThemeShortcut on BuildContext {
  // Use: context.primary, etc.
  Color get primary => Theme.of(this).colorScheme.primary;
  Color get surface => Theme.of(this).colorScheme.surface;
  Color get onPrimary => Theme.of(this).colorScheme.onPrimary;
  Color get onSurface => Theme.of(this).colorScheme.onSurface;

  // Use: context.bubble / context.highlight / context.container
  ExtraColors get _extra => Theme.of(this).extension<ExtraColors>()!;
  Color get bubble => _extra.bubble;
  Color get themeIconContainer => _extra.themeItemIcon;
  Color get hintText => _extra.hintText;
}

ThemeData getTheme(AppThemeType type) {
  switch (type) {
    case AppThemeType.blue:
      return AppThemes.blue;
    case AppThemeType.pink:
      return AppThemes.pink;
    case AppThemeType.green:
      return AppThemes.green;
    case AppThemeType.orange:
      return AppThemes.orange;
    case AppThemeType.cyan:
      return AppThemes.cyan;
    case AppThemeType.purple:
      return AppThemes.purple;
    default:
      return AppThemes.blue;
  }
}
