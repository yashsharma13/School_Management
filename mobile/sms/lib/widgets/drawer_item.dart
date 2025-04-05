// lib/widgets/drawer_item.dart
import 'package:flutter/material.dart';

Widget buildDrawerItem(IconData icon, String title, BuildContext context) {
  return ListTile(
    leading: Icon(icon, color: Colors.black87),
    title: Text(title, style: const TextStyle(fontSize: 16)),
    onTap: () {
      Navigator.pop(context);
    },
  );
}
