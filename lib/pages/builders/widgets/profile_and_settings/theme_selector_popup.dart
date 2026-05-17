import 'package:fins/themes/logic/app_themes.dart';
import 'package:flutter/material.dart';

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



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasThemeChoiceChanged = _tempSelectedTheme != widget.initialTheme;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, minWidth: 320),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                  child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: AppThemeType.values.length,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1,
                  children: AppThemeType.values.map((type) {
                    return Align(
                      alignment: Alignment.center,
                      child: _buildThemeChoice(
                        type: type,
                        isSelected: _tempSelectedTheme == type,
                        onTap: () => setState(() => _tempSelectedTheme = type),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
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
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: hasThemeChoiceChanged
                              ? () {
                                  widget.onConfirm(_tempSelectedTheme);
                                  Navigator.pop(context, _tempSelectedTheme);
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: hasThemeChoiceChanged
                                ? context.primary
                                : context.primary.withOpacity(0.8),
                            foregroundColor: hasThemeChoiceChanged
                                ? context.hintText
                                : context.hintText.withOpacity(0.8),
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
          ),
        ),
      ),
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
