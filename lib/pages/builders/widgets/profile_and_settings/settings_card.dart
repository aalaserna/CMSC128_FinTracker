import 'package:flutter/material.dart';

Widget buildItemRow({
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
          child: ListTile(
            leading: Icon(icon),
            title: Text(label),
            onTap: onTap,
            trailing: trailing,
            ),
          ),
        if (!isLastRow) Divider(height: 1, indent: 16, endIndent: 16),
      ],
    ),
  );
}
