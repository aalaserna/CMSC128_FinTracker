import 'package:flutter/material.dart';

Widget buildItemRow({
  required dynamic theme,
  required String label,
  required IconData icon,
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
            onTap: () {},
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
        ),
        if (!isLastRow) Divider(height: 1, color: theme.divider, indent: 16, endIndent: 16),
      ],
    ),
  );
}
