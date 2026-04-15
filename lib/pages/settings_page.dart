import 'package:fins/pages/builders/widgets/profile_and_settings/theme_selector_popup.dart';
import 'package:fins/themes/constants/app_theme_type.dart';
import 'package:fins/themes/logic/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'package:fins/themes/logic/app_themes.dart';
import 'builders/designs/bubble_background.dart';
import 'package:flutter/foundation.dart';
import 'package:fins/pages/builders/widgets/profile_and_settings/settings_card.dart';

// please integrate your shared preferences data here
// this is just a temporary template to access the theme colors

class SettingsPage extends StatefulWidget {


  const SettingsPage({
    super.key,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late AppThemeType _currentTheme;

  @override
  void initState() {
    super.initState();
    _currentTheme = ThemeController.notifier.value;
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Stack(
        children: [
          const Bubble(top: -30, right: -20, size: 160, opacity: 0.45),
          const Bubble(top: 40, right: 30, size: 80, opacity: 0.30),
          const Bubble(bottom: -40, left: -30, size: 180, opacity: 0.35),
          const Bubble(bottom: 60, left: 20, size: 90, opacity: 0.25),
          const Bubble(bottom: 180, right: -10, size: 110, opacity: 0.20),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SafeArea(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.arrow_back_ios_new_rounded,
                                  color: context.onSurface, size: 16),
                              SizedBox(width: 4),
                              // NOTE: Pls dont press the back button unless tapos na inyo profile page
                              Text(
                                'Back',
                                style: TextStyle(
                                  color: context.onSurface,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    'Settings',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: context.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  buildItemRow(isFirstRow: true, label: "Change theme", icon: Icons.palette,
                    onTap: (){
                      showDialog(
                        context: context,
                        builder: (_) => ThemeSelectorPopup(
                          initialTheme: _currentTheme,
                          onConfirm: (newTheme) {
                            setState(() {
                              _currentTheme = newTheme;
                            });
                            ThemeController.setTheme(newTheme);
                        }),
                      );
                    },
                    trailing: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 2,
                          color: context.onSurface.withOpacity(0.3)
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 8,
                        backgroundColor: context.themeIconContainer,
                      ),
                    ),
                  ),
                  // the following items below are just temporary, kindly change it to the proper settings items
                  buildItemRow(label: "Change theme", icon: Icons.palette),
                  buildItemRow(isLastRow: true, label: "Change theme", icon: Icons.palette),
                ],
              ),
            ),
          ),
        ],
      )
    );
  }
}
