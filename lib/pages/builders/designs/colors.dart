import 'package:flutter/material.dart';
import 'package:fins/themes/constants/app_colors.dart';
import 'package:fins/themes/logic/theme_controller.dart';
import 'package:fins/themes/constants/app_theme_type.dart';

// Theme-aware color accessors. These read the current theme from
// ThemeController.notifier and map to the appropriate AppColors collection.
AppThemeType get _activeTheme => ThemeController.notifier.value;

_ColorCollection _collectionFor(AppThemeType t) {
	switch (t) {
		case AppThemeType.blue:
			return _ColorCollection(
				pageTitleText: AppColors.blue.pageTitleText,
				cardBg: AppColors.blue.cardBackground,
				pageBg: AppColors.blue.pageBackground,
				bodyText: AppColors.blue.bodyText,
				hintText: AppColors.blue.hintText,
				lightDivider: AppColors.blue.lightDivider,
			);
		case AppThemeType.pink:
			return _ColorCollection(
				pageTitleText: AppColors.pink.pageTitleText,
				cardBg: AppColors.pink.cardBackground,
				pageBg: AppColors.pink.pageBackground,
				bodyText: AppColors.pink.bodyText,
				hintText: AppColors.pink.hintText,
				lightDivider: AppColors.pink.lightDivider,
			);
		case AppThemeType.yellow:
			return _ColorCollection(
				pageTitleText: AppColors.yellow.pageTitleText,
				cardBg: AppColors.yellow.cardBackground,
				pageBg: AppColors.yellow.pageBackground,
				bodyText: AppColors.yellow.bodyText,
				hintText: AppColors.yellow.hintText,
				lightDivider: AppColors.yellow.lightDivider,
			);
	}
}

class _ColorCollection {
	final Color pageTitleText;
	final Color cardBg;
	final Color pageBg;
	final Color bodyText;
	final Color hintText;
	final Color lightDivider;

	const _ColorCollection({
		required this.pageTitleText,
		required this.cardBg,
		required this.pageBg,
		required this.bodyText,
		required this.hintText,
		required this.lightDivider,
	});
}

Color get colorNavy => _collectionFor(_activeTheme).pageTitleText;
Color get colorCardBg => _collectionFor(_activeTheme).cardBg;
Color get colorFieldBg => Colors.white;
Color get colorBodyText => _collectionFor(_activeTheme).bodyText;
Color get colorHintText => _collectionFor(_activeTheme).hintText;
Color get colorPageBg => _collectionFor(_activeTheme).pageBg;
Color get colorDivider => _collectionFor(_activeTheme).lightDivider;