import 'package:flutter/material.dart';

/*
==================================================================================
   This is a dumb file containing the app colors for all 6 selected themes.
   It will be used by the app themes, which will be the one containing the logic.
   If you ever need to change a color or whatever, go to this file.
==================================================================================
*/

class AppColors {

  AppColors._();

  static const blue = _BlueColorCollection(); // DEFAULT BLUE THEME
  static const pink = _PinkColorCollection();
  static const yellow = _YellowColorCollection();
}

class _BlueColorCollection{
  const _BlueColorCollection();

  // background colors for page, card, and field
  final pageBackground = const Color(0xFFDDE4EE);
  final cardBackground = const Color(0xFFBFC8D6);
  final fieldBackground =  const Color(0xFFFFFFFF); // white

  // widget colors
  final lightDivider = const Color(0xFFD0D7E2);
  final darkDivider = const Color(0xFF6C80A4);
  final icon =  const Color(0xFF8694AD);
  final container = const Color(0xFFC7D7F0); //container for profile and settings page
  final bubble = const Color (0xFFC3D4F0);
  final activeElement = const Color (0xFF1E2A3A);
  final themeItemIcon = const Color(0xFF8694AD);
  final dateContainer = const Color(0xFFC7D7F0);

  // text colors
  final pageTitleText = const Color(0xFF1C2340);
  final bodyText = const Color(0xFF2E3A59);
  final hintText = const Color(0xFF8A9BB5);
}

class _PinkColorCollection{
  const _PinkColorCollection();

  // background colors for page, card, and field
  final pageBackground = const Color(0xFFF7E7FF);
  final cardBackground = const Color(0xFFDDBCCD);
  final fieldBackground =  const Color(0xFFFFFFFF); // white

  // widget colors
  final lightDivider = const Color(0xFFF9D5EB);
  final darkDivider = const Color(0xFFC282A3);
  final icon =  const Color(0xFF3A1E2E);
  final container = const Color(0xFFF3D2E6); // pink container (was accidentally blue)
  final bubble = const Color (0xFFF6BCDF);
  final activeElement = const Color (0xFF3A1E2E);
  final themeItemIcon = const Color(0xFFF0C3DE);
  final dateContainer = const Color(0xFFF0C3DE);


  // text colors
  final pageTitleText = const Color(0xFF3A1E2E);
  final bodyText = const Color(0xFF84355E);
  final hintText = const Color(0xFFC282A3);
}

class _YellowColorCollection{
  const _YellowColorCollection();

  // background colors for page, card, and field
  final pageBackground = const Color(0xFFFEF7DF);
  final cardBackground = const Color(0xFFF9E5AB);
  final fieldBackground =  const Color(0xFFFFFFFF); // white

  // widget colors
  final lightDivider = const Color(0xFFF7E6C2);
  final darkDivider = const Color(0xFFB78E45);
  final icon =  const Color(0xFF8A6B3A);
  final container = const Color(0xFFFFF3D6); //container for profile and settings page
  final bubble = const Color (0xFFFCE8B8);
  final confirmButton = const Color (0xFF5A3F10);
  final cancelButton = const Color(0xFFFFFFFF);
  final themeItemIcon = const Color(0xFFE0C07A);

  // text colors
  final pageTitleText = const Color(0xFF4A3618);
  final bodyText = const Color(0xFF6B4E2A);
  final hintText = const Color(0xFFAD936E);
}





