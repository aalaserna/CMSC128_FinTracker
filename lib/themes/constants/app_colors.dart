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
  static const green = _GreenColorCollection();
  static const orange = _OrangeColorCollection();
  static const cyan = _CyanColorCollection();
  static const purple = _PurpleColorCollection();
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
  final dateContainer = const Color(0xFF);

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
  final container = const Color(0xFFC7D7F0); //container for profile and settings page
  final bubble = const Color (0xFFF6BCDF);
  final activeElement = const Color (0xFF3A1E2E);
  final themeItemIcon = const Color(0xFFF0C3DE);
  final dateContainer = const Color(0xFFF0C3DE);


  // text colors
  final pageTitleText = const Color(0xFF3A1E2E);
  final bodyText = const Color(0xFF84355E);
  final hintText = const Color(0xFFC282A3);
}

class _GreenColorCollection{
  const _GreenColorCollection();

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
  final confirmButton = const Color (0xFF1E2A3A);
  final cancelButton = const Color(0xFFFFFFFF);
  final themeItemIcon = const Color(0xFF5CBB5C);

  // text colors
  final pageTitleText = const Color(0xFF1C2340);
  final bodyText = const Color(0xFF2E3A59);
  final hintText = const Color(0xFF8A9BB5);
}

class _OrangeColorCollection{
  const _OrangeColorCollection();

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
  final confirmButton = const Color (0xFF1E2A3A);
  final cancelButton = const Color(0xFFFFFFFF);
  final themeItemIcon = const Color(0xFFE5965D);

  // text colors
  final pageTitleText = const Color(0xFF1C2340);
  final bodyText = const Color(0xFF2E3A59);
  final hintText = const Color(0xFF8A9BB5);
}

class _CyanColorCollection{
  const _CyanColorCollection();

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
  final confirmButton = const Color (0xFF1E2A3A);
  final cancelButton = const Color(0xFFFFFFFF);
  final themeItemIcon = const Color(0xFF5CBBB3);

  // text colors
  final pageTitleText = const Color(0xFF1C2340);
  final bodyText = const Color(0xFF2E3A59);
  final hintText = const Color(0xFF8A9BB5);
}

class _PurpleColorCollection{
  const _PurpleColorCollection();

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
  final confirmButton = const Color (0xFF1E2A3A);
  final cancelButton = const Color(0xFFFFFFFF);
  final themeItemIcon = const Color(0xFF985CBB);

  // text colors
  final pageTitleText = const Color(0xFF1C2340);
  final bodyText = const Color(0xFF2E3A59);
  final hintText = const Color(0xFF8A9BB5);
}

