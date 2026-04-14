import 'package:flutter/material.dart';

Widget buildItemRow({
  required dynamic theme,
  required String label,
  required IconData icon,
  Widget? trailing,
  VoidCallback? onTap,
  bool isFirstRow = false,
  bool isLastRow = false,
}){

  final borderRadius = BorderRadius.vertical(
    top: isFirstRow ? const Radius.circular(20) : Radius.zero,
    bottom: isLastRow ? const Radius.circular(20) : Radius.zero,
  );

  return ClipRRect(  // rounded rectangle
    borderRadius: borderRadius,
    child: Column(
      children: [
        Material(
          color: theme.container,
          child: ListTile(
            leading: Icon(icon, color: theme.icon),
            title: Text(label, style: TextStyle(color: theme.bodyText)),
            onTap: onTap,
            trailing: trailing,
            ),
          ),
        if (!isLastRow) Divider(height: 1, color: theme.divider, indent: 16, endIndent: 16),
      ],
    ),
  );
}
