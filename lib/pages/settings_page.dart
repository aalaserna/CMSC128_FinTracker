import 'package:fins/pages/builders/widgets/profile_and_settings/theme_selector_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'builders/designs/bubble_background.dart';
import 'package:flutter/foundation.dart';
import 'package:fins/utils/app_colors.dart';
import 'builders/widgets/profile_and_settings/settings_card.dart';

// please integrate your shared preferences data here
// this is just a temporary template to access the theme colors

class SettingsPage extends StatefulWidget {

  final dynamic theme;

  const SettingsPage({
    super.key,
    required this.theme
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context){

    final theme = widget.theme;

    return Scaffold(
      backgroundColor: theme.pageBackground,
      body: Stack(
        children: [
          const _Bubble(top: -30, right: -20, size: 160, opacity: 0.45),
          const _Bubble(top: 40, right: 30, size: 80, opacity: 0.30),
          const _Bubble(bottom: -40, left: -30, size: 180, opacity: 0.35),
          const _Bubble(bottom: 60, left: 20, size: 90, opacity: 0.25),
          const _Bubble(bottom: 180, right: -10, size: 110, opacity: 0.20),
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
                                  color: AppColors.blue.pageTitleText, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Back',
                                style: TextStyle(
                                  color: AppColors.blue.pageTitleText,
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
                      color: AppColors.blue.pageTitleText,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  buildItemRow(isFirstRow: true, theme: theme, label: "Change theme", icon: Icons.palette,
                    onTap: (){
                      showDialog(
                        context: context,
                        builder: (BuildContext context){
                          return ThemeSelectorPopup(theme: theme);
                        }
                      );
                    },
                    trailing: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.containerDivider,
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 8,
                        backgroundColor: theme.pageBackground,
                      ),
                    ),
                  ),
                  // the following items below are just temporary, kindly change it to the proper settings items
                  buildItemRow(theme: AppColors.blue, label: "Change theme", icon: Icons.palette),
                  buildItemRow(isLastRow: true, theme: AppColors.blue, label: "Change theme", icon: Icons.palette),
                ],
              ),
            ),
          ),
        ],
      )
    );
  }
}

class _Bubble extends StatelessWidget {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double size;
  final double opacity;

  const _Bubble({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity),
        ),
      ),
    );
  }
}
