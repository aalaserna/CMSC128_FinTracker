import 'package:fins/themes/constants/app_colors.dart';
import 'package:fins/themes/logic/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class ThemeSelectorPopup extends StatefulWidget{
  final AppThemeType initialTheme;
  final Function(AppThemeType) onConfirm; // save chosen theme


  const ThemeSelectorPopup({
    super.key,
    required this.initialTheme,
    required this.onConfirm,
  });

  @override
  State<ThemeSelectorPopup> createState() => _ThemeSelectorPopupState();
}

class _ThemeSelectorPopupState extends State<ThemeSelectorPopup> {

  late AppThemeType _tempSelectedTheme;

  @override
  void initState() {
    super.initState();
    _tempSelectedTheme = widget.initialTheme;
  }

  void _handleThemeSelection(AppThemeType choice) {
    setState(() {
      _tempSelectedTheme = choice;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasThemeChoiceChanged = _tempSelectedTheme != widget.initialTheme;

    return SimpleDialog(
      backgroundColor: theme.scaffoldBackgroundColor,
      children: [
        Padding(
          padding: const EdgeInsets.all(15),
          child: SizedBox(
            width: double.maxFinite,
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              physics: const NeverScrollableScrollPhysics(),
              children: AppThemeType.values.map((type) {
                return _buildThemeChoice(
                  type: type,
                  isSelected: _tempSelectedTheme == type,
                  onTap: () => setState(() => _tempSelectedTheme = type),
                );
              }).toList(),
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
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.surface,
                      foregroundColor: context.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
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
                    onPressed: hasThemeChoiceChanged
                      ? () {
                      widget.onConfirm(_tempSelectedTheme);
                      Navigator.pop(context, _tempSelectedTheme);
                      }
                      : null,
                    style: ElevatedButton.styleFrom( // confirm button is disabled unless selected theme is not initial theme
                      backgroundColor: hasThemeChoiceChanged ? context.primary :  context.primary.withOpacity(0.8),
                      foregroundColor: hasThemeChoiceChanged ? context.hintText :  context.hintText.withOpacity(0.8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
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
  required AppThemeType type,
  required bool isSelected,
  required VoidCallback onTap,
}){
  final previewTheme = getTheme(type);

  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? previewTheme.colorScheme.onPrimary : previewTheme.colorScheme.onPrimary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: CircleAvatar(
        radius: 20,
        backgroundColor: previewTheme.extension<ExtraColors>()!.themeItemIcon,
      ),
    ),
  );
}
