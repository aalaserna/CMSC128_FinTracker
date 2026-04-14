import 'package:fins/utils/app_colors.dart';
import 'package:flutter/material.dart';

class ThemeSelectorPopup extends StatelessWidget{
  final dynamic theme;

  const ThemeSelectorPopup({
    super.key,
    required this.theme
  });

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      backgroundColor: theme.pageBackground,
      children: [
        Padding(
          padding: const EdgeInsets.all(15),
          child: SizedBox(
            width: double.maxFinite, // Ensure it takes the dialog width
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3, // Forces exactly 3 per row
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildThemeChoice(themeChoice: AppColors.blue, currentTheme: theme),
                _buildThemeChoice(themeChoice: AppColors.blue, currentTheme: theme),
                _buildThemeChoice(themeChoice: AppColors.blue, currentTheme: theme),
                _buildThemeChoice(themeChoice: AppColors.blue, currentTheme: theme),
                _buildThemeChoice(themeChoice: AppColors.blue, currentTheme: theme),
                _buildThemeChoice(themeChoice: AppColors.blue, currentTheme: theme),
              ],
            ),
          )
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child:
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.fieldBackground,
                      foregroundColor: theme.pageTitleText,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child:
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.pageTitleText,
                      foregroundColor: theme.fieldBackground,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

}

Widget _buildThemeChoice({
  required dynamic themeChoice,
  required dynamic currentTheme,
  bool isSelected = false,
}){

  return Container(
    padding: const EdgeInsets.all(2),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: isSelected ? currentTheme.pageBackground : Colors.black,
        width: 2,
      ),
    ),
    child: CircleAvatar(
      radius: 20,
      backgroundColor: currentTheme.pageBackground,
    ),
  );
}
