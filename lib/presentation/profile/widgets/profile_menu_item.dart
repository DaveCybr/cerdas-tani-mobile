// Model untuk menu item
import 'package:flutter/material.dart';

class ProfileMenuItem {
  final String title;
  final IconData icon;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool showArrow;
  final Color? iconColor;

  ProfileMenuItem({
    required this.title,
    required this.icon,
    this.subtitle,
    this.onTap,
    this.showArrow = true,
    this.iconColor,
  });
}
